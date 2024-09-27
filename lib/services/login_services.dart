import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import secure storage
import 'package:http/http.dart' as http;
import '../constants.dart';

class LoginServices {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, String> body = {
      'email_id': email,
      'password': password,
    };

    try {
      final http.Response response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/auth/login'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String token = responseData['token'];

        // Check if the user is an interviewer, recruiter, or admin based on object names
        final bool isInterviewer = responseData.containsKey('interviewer');
        final bool isRecruiter = responseData.containsKey('recruiter');
        final bool isAdmin = responseData.containsKey('admin');

        // Store token and roles
        await _storeToken(token);
        await _storeUserRole('is_interviewer', isInterviewer);
        await _storeUserRole('is_recruiter', isRecruiter);
        await _storeUserRole('is_admin', isAdmin);

        return {
          'success': true,
          'token': token,
          'is_interviewer': isInterviewer,
          'is_recruiter': isRecruiter,
          'is_admin': isAdmin
        };
      } else {
        print('Error: ${response.body}');
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {'success': false, 'error': errorData['error']};
      }
    } catch (e) {
      return {'success': false, 'error': e};
    }
  }

  // Method to store token securely
  static Future<void> _storeToken(String token) async {
    try {
      await _secureStorage.write(key: 'token', value: token);
      print("Stored token securely: $token");
    } catch (error) {
      print('Error storing token securely: $error');
    }
  }

  // General method to store user roles securely
  static Future<void> _storeUserRole(String key, bool value) async {
    try {
      await _secureStorage.write(key: key, value: value.toString());
      print("Stored $key securely: $value");
    } catch (error) {
      print('Error storing $key securely: $error');
    }
  }

  // Method to retrieve token securely
  static Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'token');
    } catch (error) {
      print('Error retrieving token securely: $error');
      return null;
    }
  }

  // Method to retrieve user roles securely
  static Future<bool?> getUserRole(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value == 'true';
    } catch (error) {
      print('Error retrieving $key securely: $error');
      return null;
    }
  }

  static Future<bool?> getIsInterviewer() async => getUserRole('is_interviewer');
  static Future<bool?> getIsRecruiter() async => getUserRole('is_recruiter');
  static Future<bool?> getIsAdmin() async => getUserRole('is_admin');
}
