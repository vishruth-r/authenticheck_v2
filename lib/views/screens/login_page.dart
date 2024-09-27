import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../services/login_services.dart';
import 'interviewee_page.dart';
import 'interviewer_page.dart';
import 'interview_recordings_page.dart';  // Assuming you have this page created

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = '';
  String password = '';
  bool _isPasswordVisible = false; // To toggle password visibility

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Container(
            color: Colors.black,
            child: SvgPicture.asset(
              'assets/bg.svg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset(
                      'assets/cross.png',
                      width: 55,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        decoration: const ShapeDecoration(
                          color: Color(0xFF161616),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 20, left: 50, right: 20, bottom: 20),
                          child: Column(
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Welcome \n',
                                      style: TextStyle(
                                        color: Color(0xFF29B6F6),
                                        fontSize: 60,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Back....',
                                      style: TextStyle(
                                        color: Color(0xFFE3DAC9),
                                        fontSize: 60,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 25, right: 25),
                    child: Center(
                      child: TextField(
                        onChanged: (value) => username = value,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xE5161616),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20))),
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            color: Color(0xDBE3DAC9),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 25, right: 25),
                    child: Center(
                      child: TextField(
                        onChanged: (value) => password = value,
                        style: const TextStyle(color: Colors.white),
                        obscureText: !_isPasswordVisible, // Toggle visibility
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xE5161616),
                          border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20))),
                          hintText: 'Password',
                          hintStyle: const TextStyle(
                            color: Color(0xDBE3DAC9),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 25, right: 25),
                    child: Center(
                      child: GestureDetector(
                        onTap: () async {
                          final Map<String, dynamic> responseData = await LoginServices.loginUser(username, password);
                          print(responseData);
                          if (responseData['success'] == true) {
                            // Retrieve the user roles
                            bool? isInterviewer = await LoginServices.getIsInterviewer();
                            bool? isRecruiter = await LoginServices.getIsRecruiter();
                            bool? isAdmin = await LoginServices.getIsAdmin();

                            // Navigate based on user role
                            if (isInterviewer == true) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => InterviewerPage()),
                              );
                            } else if (isRecruiter == true || isAdmin == true) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => InterviewRecordingsPage()),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => IntervieweePage()),
                              );
                            }
                          } else {
                            // Show error message if login fails
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(responseData['error']),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.all(Radius.circular(20))),
                          child: const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Center(
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500),
                                )),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
