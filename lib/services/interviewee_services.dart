import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class IntervieweeServices {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Load user data from Flutter Secure Storage
  static Future<Map<String, String?>> loadUserData() async {
    String? name = await _secureStorage.read(key: 'name');
    String? email = await _secureStorage.read(key: 'email');
    return {'name': name, 'email': email};
  }

  // Fetch interviews from API using token stored in Flutter Secure Storage
  static Future<Map<String, dynamic>> fetchInterviews(BuildContext context) async {
    String? token = await _secureStorage.read(key: 'token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found. Please log in again.')),
      );
      return {'interviews': [], 'isLoading': false};
    }

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': '1'

    };

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/interviewee/meetings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        print(response.body);
        final List<dynamic> interviews = jsonDecode(response.body);
        return {
          'interviews': interviews.map((e) => e as Map<String, dynamic>).toList(),
          'isLoading': false
        };
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load interviews: ${response.body}')),
        );
        return {'interviews': [], 'isLoading': false};
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server.')),
      );
      return {'interviews': [], 'isLoading': false};
    }
  }

  // Fetch interviewee details from API
  static Future<Map<String, dynamic>?> fetchIntervieweeDetails(BuildContext context) async {
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
        Uri.parse('${Constants.apiBaseUrl}/interviewee/details'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> intervieweeDetails = jsonDecode(response.body);
        print(intervieweeDetails);
        return intervieweeDetails;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load interviewee details: ${response.body}')),
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

  // Log out user and clear data from Flutter Secure Storage
  static Future<void> logout(BuildContext context) async {
    await _secureStorage.delete(key: 'token');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}