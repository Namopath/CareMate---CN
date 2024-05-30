import 'package:caremate/pages/login_page.dart';
import 'package:caremate/pages/signup_page.dart';
import 'package:flutter/material.dart';

class LogInOrSignUp extends StatefulWidget {
  const LogInOrSignUp({super.key});

  @override
  State<LogInOrSignUp> createState() => _LogInOrSignUpState();
}

class _LogInOrSignUpState extends State<LogInOrSignUp> {
  // initially set to login page
  bool isLoginPage = true;

  void switchPage() {
    setState(() {
      isLoginPage = !isLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoginPage == true) {
      return LogInPage(switchPage: switchPage);
    } else {
      return SignUpPage(switchPage: switchPage);
    }
  }
}
