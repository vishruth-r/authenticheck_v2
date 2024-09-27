import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants.dart';

class CreateMeetingService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> createMeeting({
    required BuildContext context,
    required String intervieweeEmail,
    required String recruitersEmail,
    required TimeOfDay? time,
    required DateTime? date,
    required String role,
    required String meetingLink,
  }) async {
    String? token = await _secureStorage.read(key: 'token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found. Please log in again.')),
      );
      return;
    }

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final Map<String, String> body = {
      'interviewee_mail': intervieweeEmail,
      'recruiter_mail': recruitersEmail,
      'time': time != null ? time.format(context) : '',
      'date': date != null ? DateFormat('yyyy-MM-dd').format(date) : '',
      'role': role,
      'meet_link': meetingLink,
    };

    try {
      final http.Response response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/interviewer/create_meetings/'),
        headers: headers,
        body: jsonEncode(body),
      );
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meeting created successfully!')),
        );
        Navigator.pop(context);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${errorData['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server.')),
      );
    }
  }
}