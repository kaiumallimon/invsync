import 'dart:convert'; // Import this for JSON encoding/decoding
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Check the credentials before making the request (for debugging)
    print('Sending login request with email: $email and password: $password');

    final response = await http.post(
      Uri.parse('https://invsync.bcrypt.website/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }), // Ensure the body is encoded as JSON
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      // Decode the JSON response body into a Map<String, dynamic>
      return json.decode(response.body);
    } else {
      // Return an error map if the status code is not 200
      return jsonDecode(response.body);
    }
  }

  Future<void> logout(BuildContext context) async {
    // Open the Hive box named 'user'
    var userBox = await Hive.openBox('user');

    // Clear all data from the box
    await userBox.clear();

    // Navigate to the login screen
    Navigator.pushReplacementNamed(context, '/login');
  }
}
