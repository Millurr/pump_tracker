import 'package:flutter/material.dart';
import 'package:pump_tracker/screens/login_screen.dart';
import 'package:pump_tracker/screens/register_screen.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  bool showSignIn = true;

  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return LoginScreen(toggleView: toggleView);
    }
    else {
      return RegisterScreen(toggleView: toggleView);
    }
  }
}