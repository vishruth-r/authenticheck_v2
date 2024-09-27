import 'package:authenticheck_v2/views/screens/interviewee_page.dart';
import 'package:authenticheck_v2/views/screens/interviewer_page.dart';
import 'package:authenticheck_v2/views/screens/login_page.dart';
import 'package:flutter/material.dart';


final Map<String, WidgetBuilder> routes = {
  '/login': (BuildContext context) => LoginPage(),
  '/interviewee': (BuildContext context) => IntervieweePage(),
  '/interviewer': (BuildContext context) => InterviewerPage(),
};