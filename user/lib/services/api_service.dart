import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://192.168.31.129:3000'; // Replace with your backend URL

  static Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    Uri url = Uri.parse('$baseUrl/api/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'userType': 'user', // Replace with logic to determine userType
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successful registration
        return true;
      } else {
        // Handle errors or display error message
        print('Error registering user: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

// login user

  static Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    Uri url = Uri.parse('$baseUrl/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'userType': 'user',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // Handle errors or display error message
        print('Error login user: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserDetails(String email) async {
    final url = Uri.parse('$baseUrl/api/auth/userdetails?email=$email');
    final response = await http.get(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // print(json.decode(response.body));
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user details');
    }
  }
}
