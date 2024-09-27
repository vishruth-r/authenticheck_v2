import 'package:authenticheck_v2/views/screens/interview_recordings_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart'; // For file selection
import 'dart:typed_data'; // For web file uploads
import '../../services/interviewer_services.dart';
import 'create_meeting_page.dart';

class InterviewerPage extends StatefulWidget {
  @override
  _InterviewerPageState createState() => _InterviewerPageState();
}

class _InterviewerPageState extends State<InterviewerPage> {
  List<Map<String, dynamic>> _interviews = [];
  bool _isLoading = true;
  String _userName = '';
  String _userEmail = '';
  String _organisation = '';

  @override
  void initState() {
    super.initState();
    _fetchInterviews();
    _loadInterviewerDetails();
  }

  Future<void> _fetchInterviews() async {
    final response = await InterviewerServices.fetchInterviews(context);
    if (response != null) {
      setState(() {
        _interviews = response;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadInterviewerDetails() async {
    final interviewerDetails = await InterviewerServices.fetchInterviewerDetails(context);
    if (interviewerDetails != null) {
      setState(() {
        _userName = interviewerDetails['name'] ?? 'No name';
        _userEmail = interviewerDetails['email_id'] ?? 'No email';
        _organisation = interviewerDetails['organisation'] ?? 'No Organization';
      });
    }
  }

  Future<void> _logout() async {
    await InterviewerServices.logout(context);
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('MMMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return date; // Return the original string if parsing fails
    }
  }

  String _formatTime(String time) {
    try {
      final DateTime parsedTime = DateFormat.Hms().parse(time);
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (e) {
      return time; // Return the original string if parsing fails
    }
  }

  Future<void> _launchMeeting(String meetingLink) async {
    if (await canLaunch(meetingLink)) {
      await launch(meetingLink);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $meetingLink')),
      );
    }
  }

  Future<void> _uploadVideo(String uploadURL) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.single.bytes != null) {
      Uint8List fileBytes = result.files.single.bytes!; // For web compatibility
      String fileName = result.files.single.name;

      bool success = await InterviewerServices.uploadVideoWeb(uploadURL, fileBytes, fileName);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video uploaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video upload failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduled Interviews'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateMeetingsPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_userName),
              accountEmail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_userEmail),
                  SizedBox(height: 4),
                  Text(
                    _organisation,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blue, // Background color of the drawer header
              ),
              margin: EdgeInsets.zero,
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.storage),
                    title: Text('Video Recordings'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InterviewRecordingsPage()),
                      );

                      // _launchVideoBiometricUrl();
                    },
                  ),
                  // Add other drawer items here if needed
                ],
              ),
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _interviews.isEmpty
          ? Center(child: Text('No interviews scheduled.'))
          : ListView.builder(
        itemCount: _interviews.length,
        itemBuilder: (context, index) {
          final interview = _interviews[index];
          final String meetingLink = interview['meet_link'] ?? ''; // Get the meeting link
          final String uploadURL = interview['uploadURL'] ?? ''; // Get the upload URL

          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Meeting ID: ${interview['meeting_id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${_formatDate(interview['date'])}'),
                  Text('Time: ${_formatTime(interview['time'])}'),
                  Text('Role: ${interview['role']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.upload),
                    onPressed: () {
                      if (uploadURL.isNotEmpty) {
                        _uploadVideo(uploadURL); // Trigger video upload
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No upload URL available')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.video_call),
                    onPressed: () {
                      if (meetingLink.isNotEmpty) {
                        _launchMeeting(meetingLink); // Launch the meeting link
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No meeting link available')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
