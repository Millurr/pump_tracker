import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {

  final Function toggleView;
  LoginScreen({this.toggleView});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  String _email, _password;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[400],
      appBar: AppBar(  
        backgroundColor: Colors.grey[900],
        title: Text(  
          "Login Screen",
          style: TextStyle(color: Colors.white, fontSize: 28),
        ),
        actions: <Widget>[
          FlatButton.icon(  
            icon: Icon(
              Icons.person,
              color: Colors.white,
              ),
            label: Text(
              "Register",
              style: TextStyle(color: Colors.white),
              ),
            onPressed: () {
              widget.toggleView();
            },
          )
        ],
      ),
      body: Container(  
        child: Center(  
          child: Container(  
            width: 300,
            height: 200,
            child: Column(  
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextField(  
                  decoration: InputDecoration.collapsed(hintText: "Email", border: UnderlineInputBorder()),
                  onChanged: (value) {
                    this.setState(() {_email = value;});
                  },
                ),
                TextField(  
                  decoration: InputDecoration.collapsed(hintText: "Password", border: UnderlineInputBorder()),
                  obscureText: true,
                  onChanged: (value) {
                    this.setState(() {_password = value;});
                  },
                ),
                RaisedButton(
                  color: Colors.grey[900],
                  child: Text(
                    "Sign In", 
                    style: TextStyle(color: Colors.white),
                  ), 
                  onPressed: () {
                    FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password)
                      .then((onValue) {
                        
                      })
                      .catchError((error) {
                        print(error.toString());
                      });
                  },)
              ],
            ),
          )
        ),
      ),
    );
  }
}