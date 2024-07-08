import 'package:customercare/pages/calling_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class CallHandler extends StatefulWidget {
  @override
  _CallHandlerState createState() => _CallHandlerState();
}

class _CallHandlerState extends State<CallHandler> {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.31.129:3000'),
  );
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _isCalling = false; // Track if call is active
  bool _isIncomingCall = false; // Track if there is an incoming call
  String _caller = ''; // Track the caller

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _connectToSignalingServer();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  Map<String, dynamic>? _incomingOffer;
  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _connectToSignalingServer() {
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      print('Received message: $data');

      switch (data['type']) {
        case 'register':
          print('Registered as ${data['userType']}');
          break;
        case 'incoming_call':
          print('Incoming call from ${data['from']}');
          _handleIncomingCall(data['from'], data['offer']);
          break;
        case 'call_answered':
          print('Call answered by ${data['from']}');
          _handleCallAnswered(data['answer']);
          break;
        case 'candidate':
          print('Received ICE candidate');
          _handleCandidate(data['candidate']);
          break;
      }
    });

    channel.sink
        .add(jsonEncode({'type': 'register', 'userType': 'customer-care'}));
  }

  void _handleIncomingCall(String caller, Map<String, dynamic> offer) {
    print('Handling incoming call: $offer');

    setState(() {
      _isIncomingCall = true;
      _caller = caller;
    });

    // Store the offer for later use
    _incomingOffer = offer;
  }

  void _handleCallAnswered(Map<String, dynamic> answer) async {
    print('Handling call answered: $answer');

    await _peerConnection?.setRemoteDescription(
      RTCSessionDescription(answer['sdp'], answer['type']),
    );

    // Add other necessary logic
  }

  void _handleCandidate(Map<String, dynamic> candidate) async {
    print('Handling ICE candidate: $candidate');

    await _peerConnection?.addCandidate(
      RTCIceCandidate(candidate['candidate'], candidate['sdpMid'],
          candidate['sdpMLineIndex']),
    );

    // Add other necessary logic
  }

  void _acceptCall() async {
    setState(() {
      _isIncomingCall = false;
      _isCalling = true;
    });

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
        'to': _caller,
      }));
    };

    await _peerConnection?.setRemoteDescription(
      RTCSessionDescription(_incomingOffer!['sdp'], _incomingOffer!['type']),
    );

    _localStream = await navigator.mediaDevices.getUserMedia({
      'video': false,
      'audio': true,
    });

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    final answer = await _peerConnection?.createAnswer();
    await _peerConnection?.setLocalDescription(answer!);

    channel.sink.add(jsonEncode({
      'type': 'answer',
      'from': 'customer-care',
      'to': _caller,
      'answer': answer?.toMap(),
    }));

    setState(() {});
  }

  void _endCall() {
    _peerConnection?.close();
    _peerConnection = null;
    _localStream?.dispose();
    _localStream = null;

    setState(() {
      _isCalling = false;
      _isIncomingCall = false;
      _caller = '';
    });

    channel.sink.add(jsonEncode({
      'type': 'end_call',
      'from': 'customer-care',
      'to': _caller,
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (_isIncomingCall) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Incoming call from $_caller'),
          ElevatedButton(
            onPressed: _acceptCall,
            child: Text('Accept Call'),
          ),
        ],
      );
    } else if (_isCalling) {
      return CallingScreen(onEndCall: _endCall);
    } else {
      return Column(
        children: [
          Expanded(
            child: RTCVideoView(_localRenderer),
          ),
          Expanded(
            child: RTCVideoView(_remoteRenderer),
          ),
        ],
      );
    }
  }
}
