import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage
import 'package:authenticheck_v2/routes.dart';
import 'package:authenticheck_v2/views/screens/interviewee_page.dart';
import 'package:authenticheck_v2/views/screens/interviewer_page.dart';
import 'package:authenticheck_v2/views/screens/login_page.dart'; // Assuming you have a login page
import 'package:authenticheck_v2/views/screens/interview_recordings_page.dart'; // The page for video recordings

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: routes,
      home: FutureBuilder<Map<String, dynamic>>(
        future: _checkUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(), // Show a loading widget
            );
          } else if (snapshot.hasData && snapshot.data!['token'] != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final bool isInterviewer = snapshot.data!['isInterviewer'];
              final bool isRecruiter = snapshot.data!['isRecruiter'];
              final bool isAdmin = snapshot.data!['isAdmin'];

              // Navigate based on user roles
              if (isRecruiter || isAdmin) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => InterviewRecordingsPage()), // Navigate to video recordings page
                );
              } else if (isInterviewer) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => InterviewerPage()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => IntervieweePage()),
                );
              }
            });
            return Container(); // Return an empty container during navigation
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // No token found, navigate to login page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()), // Assuming you have a login page widget
              );
            });
            return Container(); // Return an empty container during navigation
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  // Helper method to check if the user is logged in and retrieve their role
  Future<Map<String, dynamic>> _checkUserRole() async {
    // Retrieve data securely from Flutter Secure Storage
    String? token = await _secureStorage.read(key: 'token');
    String? isInterviewerStr = await _secureStorage.read(key: 'is_interviewer');
    String? isRecruiterStr = await _secureStorage.read(key: 'isRecruiter');
    String? isAdminStr = await _secureStorage.read(key: 'isAdmin');

    // Convert the stored string values to booleans
    bool isInterviewer = isInterviewerStr == 'true';
    bool isRecruiter = isRecruiterStr == 'true';
    bool isAdmin = isAdminStr == 'true';

    return {
      'token': token,
      'isInterviewer': isInterviewer,
      'isRecruiter': isRecruiter,
      'isAdmin': isAdmin,
    };
  }
}
