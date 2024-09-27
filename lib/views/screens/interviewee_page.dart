import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/interviewee_services.dart'; // Import the service file

class IntervieweePage extends StatefulWidget {
  @override
  _IntervieweePageState createState() => _IntervieweePageState();
}

class _IntervieweePageState extends State<IntervieweePage> {
  List<Map<String, dynamic>> _interviews = [];
  bool _isLoading = true;
  String? _userName;
  String? _userEmail;
  String? _faceId;
  String? _voiceId;
  int? _intervieweeId;

  @override
  void initState() {
    super.initState();
    _loadIntervieweeDetails();
    _fetchInterviews();
  }

  // Load interviewee details using IntervieweeServices
  Future<void> _loadIntervieweeDetails() async {
    final intervieweeDetails = await IntervieweeServices.fetchIntervieweeDetails(context);
    setState(() {
      _userName = intervieweeDetails?['name'] ?? 'Guest';
      _userEmail = intervieweeDetails?['email_id'] ?? 'No email';
      _faceId = intervieweeDetails?['face_id'];
      _voiceId = intervieweeDetails?['voice_id'];
      _intervieweeId = intervieweeDetails?['interviewee_id'];
    });
  }

  // Fetch interviews using IntervieweeServices
  Future<void> _fetchInterviews() async {
    final result = await IntervieweeServices.fetchInterviews(context);
    setState(() {
      _interviews = result['interviews'];
      _isLoading = result['isLoading'];
    });
  }

  // Display an error message if face_id or voice_id is null
  void _showIncompleteBiometricError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please complete the video biometric first.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Handle meeting tap
  Future<void> _onMeetingTap(String meetingUrl) async {
    if (_faceId == null || _voiceId == null) {
      _showIncompleteBiometricError();
    } else {
      if (await canLaunch(meetingUrl)) {
        await launch(meetingUrl);
      } else {
        throw 'Could not launch $meetingUrl';
      }
    }
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('MMMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  String _formatTime(String time) {
    try {
      final DateTime parsedTime = DateFormat.Hms().parse(time);
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  Future<void> _launchVideoBiometricUrl() async {
    final url = 'https://authenticheck-video-upload.onrender.com/?name=${Uri.encodeComponent(_intervieweeId.toString() ?? 'User')}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduled Interviews'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                _userName ?? 'Guest',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userEmail ?? '',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.video_call),
              title: Text('Video Biometric'),
              onTap: () {
                Navigator.pop(context);
                _launchVideoBiometricUrl();
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                IntervieweeServices.logout(context);
              },
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
          final meetingUrl = 'https://interview-verification.onrender.com/?id=${interview['meeting_id']}&url=${Uri.encodeComponent(interview['meet_link'])}';
          return InkWell(
            onTap: () => _onMeetingTap(meetingUrl),
            child: Card(
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
              ),
            ),
          );
        },
      ),
    );
  }
}