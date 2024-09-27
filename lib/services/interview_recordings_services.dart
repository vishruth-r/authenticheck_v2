import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import secure storage
import '../../constants.dart';

class InterviewRecordingServices {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Fetch recordings from the API with token from local storage
  static Future<List<Map<String, dynamic>>?> fetchRecordings(BuildContext context) async {
    try {
      // Get the token from secure storage
      String? token = await _secureStorage.read(key: 'token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token not found. Please log in again.')),
        );
        return null;
      }

      // Make the API request with the token in the Authorization header
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/interviewer/meetings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': '1',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> recordings = jsonDecode(response.body);
        return recordings.map((e) => e as Map<String, dynamic>).toList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load recordings: ${response.body}')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server. $e')),
      );
      return null;
    }
  }
}
