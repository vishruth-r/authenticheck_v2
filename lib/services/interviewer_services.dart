import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants.dart';

class InterviewerServices {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<List<Map<String, dynamic>>?> fetchInterviews(BuildContext context) async {
    String? token = await _secureStorage.read(key: 'token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found. Please log in again.')),
      );
      return null;
    }

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': '1'

    };

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/interviewer/meetings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        print(response.body);
        final List<dynamic> interviews = jsonDecode(response.body);
        return interviews.map((e) => e as Map<String, dynamic>).toList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load interviews: ${response.body}')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server.')),
      );
      return null;
    }
  }

  // Fetch interviewer details using token from secure storage
  // Fetch interviewer details using token from secure storage
  static Future<Map<String, dynamic>?> fetchInterviewerDetails(BuildContext context) async {
    String? token = await _secureStorage.read(key: 'token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found. Please log in again.')),
      );
      return null;
    }

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': '1'

    };

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/interviewer/details'),
        headers: headers,

      );

      if (response.statusCode == 200) {
        print("Response: ${response.body}");
        final Map<String, dynamic> interviewerDetails = jsonDecode(response.body);

        // Print the details recovered from the /interviewer/details route
        print('Interviewer Details: $interviewerDetails');

        return interviewerDetails;
      } else {
        print("Response: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load interviewer details: ${response.body}')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server.')),
      );
      return null;
    }
  }


  // Load user info securely
  static Future<Map<String, String>> loadUserInfo() async {
    String? name = await _secureStorage.read(key: 'name');
    String? email = await _secureStorage.read(key: 'email');
    return {
      'name': name ?? 'No name',
      'email': email ?? 'No email',
    };
  }

  static Future<bool> uploadVideoWeb(String uploadURL, Uint8List fileBytes, String fileName) async {
    try {
      // Send the raw bytes using a PUT request directly
      var response = await http.put(
        Uri.parse(uploadURL),
        headers: {
          'Content-Type': 'video/mp4', // Assuming the video is in mp4 format. Adjust as necessary.
        },
        body: fileBytes, // Send the raw bytes
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("File uploaded successfully");
        return true;
      } else {
        print('Failed to upload video: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error uploading video: $e');
      return false;
    }
  }

  static Future<void> logout(BuildContext context) async {
    await _secureStorage.deleteAll(); // Clear all stored keys
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
