import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:user/pages/calling_screen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class CallButton extends StatefulWidget {
  @override
  _CallButtonState createState() => _CallButtonState();
}

class _CallButtonState extends State<CallButton> {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.31.129:3000'),  // Update to your WebSocket server URL
  );
  
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final String currentUser = 'pushpendra';
  final String targetUser = 'xyz';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      _connectToSignalingServer();
    });
  }

  @override
  void dispose() {
    _peerConnection?.close();
    _localStream?.dispose();
    super.dispose();
  }

  void _connectToSignalingServer() {
    channel.stream.listen((message) {
      final data = jsonDecode(message);

      switch (data['type']) {
        case 'incoming_call':
          _answerCall(data['offer']);
          break;
        case 'call_answered':
          _peerConnection?.setRemoteDescription(
            RTCSessionDescription(data['answer']['sdp'], data['answer']['type']),
          );
          break;
        case 'candidate':
          _peerConnection?.addCandidate(
            RTCIceCandidate(data['candidate']['candidate'], data['candidate']['sdpMid'], data['candidate']['sdpMLineIndex']),
          );
          break;
        case 'end_call':
          _endCall(context);
          break;
      }
    });

    channel.sink.add(jsonEncode({'type': 'register', 'username': currentUser}));
  }

  Future<void> _makeCall(BuildContext context) async {
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    _localStream = await navigator.mediaDevices.getUserMedia({
      'video': false,
      'audio': true,
    });

    _peerConnection = await createPeerConnection(configuration);

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    _peerConnection?.onIceCandidate = (candidate) {
      channel.sink.add(jsonEncode({
        'type': 'candidate',
        'candidate': candidate.toMap(),
        'to': targetUser,
      }));
    };

    final offer = await _peerConnection?.createOffer();
    await _peerConnection?.setLocalDescription(offer!);

    channel.sink.add(jsonEncode({
      'type': 'call',
      'from': currentUser,
      'to': targetUser,
      'offer': offer?.toMap(),
    }));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallingScreen(
          onEndCall: () => _endCall(context),
        ),
      ),
    );
  }

  Future<void> _answerCall(Map<String, dynamic> offer) async {
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection?.onIceCandidate = (candidate) {
      channel.sink.add(jsonEncode({
        'type': 'candidate',
        'candidate': candidate.toMap(),
        'to': currentUser,
      }));
    };

    await _peerConnection?.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );
    final answer = await _peerConnection?.createAnswer();
    await _peerConnection?.setLocalDescription(answer!);

    channel.sink.add(jsonEncode({
      'type': 'answer',
      'from': targetUser,
      'to': currentUser,
      'answer': answer?.toMap(),
    }));

    setState(() {});
  }

  Future<void> _endCall(BuildContext context) async {
    _localStream?.getTracks().forEach((track) {
      track.stop();
    });

    await _peerConnection?.close();

    // Optionally, notify the other peer that the call has ended
    channel.sink.add(jsonEncode({
      'type': 'end_call',
      'from': currentUser,
      'to': targetUser,
    }));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _makeCall(context),
      child: Text('Call'),
    );
  }
}
