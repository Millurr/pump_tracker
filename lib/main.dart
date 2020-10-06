import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pump_tracker/screens/authenticate.dart';
import 'package:pump_tracker/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MaterialApp(
    title: "FlutterFire App",
    home: _handleWindowDisplay()
  ));
}

Widget _handleWindowDisplay() {
  return StreamBuilder(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (BuildContext context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: Text("Loading"),);
      } else {
        if (snapshot.hasData) {
          return MainScreen();
        } else {
          return Authenticate();
        }
      }
    }
  );
}