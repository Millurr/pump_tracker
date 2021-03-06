import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pump_tracker/screens/authenticate.dart';
import 'package:pump_tracker/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FlutterFire App",
      theme: ThemeData(
          brightness: Brightness.dark,
          accentColorBrightness: Brightness.dark,
          primaryColor: Colors.grey[900],
          accentColor: Colors.red[400],
          textSelectionHandleColor: Colors.grey[900],
          textTheme: TextTheme(
              headline1: TextStyle(color: Colors.white, fontSize: 20),
              headline2: TextStyle(color: Colors.red[400], fontSize: 28),
              bodyText1: TextStyle(color: Colors.white))),
      home: _handleWindowDisplay()));
}

Widget _handleWindowDisplay() {
  return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasData) {
            return MainScreen();
          } else {
            return Authenticate();
          }
        }
      });
}
