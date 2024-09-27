import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/create_meeting_services.dart';

class CreateMeetingsPage extends StatefulWidget {
  const CreateMeetingsPage({Key? key}) : super(key: key);

  @override
  _CreateMeetingsPageState createState() => _CreateMeetingsPageState();
}

class _CreateMeetingsPageState extends State<CreateMeetingsPage> {
  final _formKey = GlobalKey<FormState>();
  String intervieweeEmail = '';
  String recruitersEmail = '';
  TimeOfDay? time;
  DateTime? date;
  String role = '';
  String meetingLink = '';

  final CreateMeetingService _createMeetingService = CreateMeetingService();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: time ?? TimeOfDay.now(),
    );
    if (picked != null && picked != time) {
      setState(() {
        time = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Meeting'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Interviewee Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the interviewee\'s email';
                  }
                  return null;
                },
                onChanged: (value) {
                  intervieweeEmail = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Recruiter\'s Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the recruiter\'s email';
                  }
                  return null;
                },
                onChanged: (value) {
                  recruitersEmail = value;
                },
              ),
              ListTile(
                title: Text('Date'),
                subtitle: Text(date != null ? DateFormat('yyyy-MM-dd').format(date!) : 'Select Date'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text('Time'),
                subtitle: Text(time != null ? time!.format(context) : 'Select Time'),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Role'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a role';
                  }
                  return null;
                },
                onChanged: (value) {
                  role = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Meeting Link'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the meeting link';
                  }
                  return null;
                },
                onChanged: (value) {
                  meetingLink = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _createMeetingService.createMeeting(
                      context: context,
                      intervieweeEmail: intervieweeEmail,
                      recruitersEmail: recruitersEmail,
                      time: time,
                      date: date,
                      role: role,
                      meetingLink: meetingLink,
                    );
                  }
                },
                child: Text('Create Meeting'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}