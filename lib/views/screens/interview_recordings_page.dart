import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/interview_recordings_services.dart';

class InterviewRecordingsPage extends StatefulWidget {
  @override
  _InterviewRecordingsPageState createState() => _InterviewRecordingsPageState();
}

class _InterviewRecordingsPageState extends State<InterviewRecordingsPage> {
  List<Map<String, dynamic>> _recordings = [];
  List<Map<String, dynamic>> _filteredRecordings = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchRecordings();
  }

  Future<void> _fetchRecordings() async {
    final response = await InterviewRecordingServices.fetchRecordings(context);
    if (response != null) {
      setState(() {
        _recordings = response;
        _filteredRecordings = response;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterRecordings(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredRecordings = _recordings.where((recording) {
        return recording['meeting_id'].toString().contains(_searchQuery) ||
            recording['interviewee_mail'].toLowerCase().contains(_searchQuery) ||
            recording['recruiter_mail'].toLowerCase().contains(_searchQuery);
      }).toList();
    });
  }

  Future<void> _openRecordingFolder(String folderUrl) async {
    if (await canLaunch(folderUrl+'interview_video.mp4')) {
      await launch(folderUrl+'interview_video.mp4');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open recording')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interview Recordings'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => _filterRecordings(value),
              decoration: InputDecoration(
                labelText: 'Search by Meeting ID, Interviewee, Recruiter',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredRecordings.isEmpty
                ? Center(child: Text('No recordings found.'))
                : ListView.builder(
              itemCount: _filteredRecordings.length,
              itemBuilder: (context, index) {
                final recording = _filteredRecordings[index];
                final String folderUrl = recording['folderURl'] ?? '';
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Meeting ID: ${recording['meeting_id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Interviewee: ${recording['interviewee_mail']}'),
                        Text('Recruiter: ${recording['recruiter_mail']}'),
                      ],
                    ),
                    onTap: () {
                      if (folderUrl.isNotEmpty) {
                        _openRecordingFolder(folderUrl);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No folder URL available')),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
