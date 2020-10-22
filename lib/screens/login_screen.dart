import 'package:firebase_auth/firebase_auth.dart';
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
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
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
        child: Form(
          key: _formKey,
            child: Center(
            child: Container(
            width: 300,
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextFormField(
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                      hintText: "Email", border: UnderlineInputBorder(),
                      errorStyle:
                          TextStyle(color: Theme.of(context).primaryColor)),
                  onChanged: (value) {
                    this.setState(() {
                      _email = value;
                    });
                  },
                  validator: (input) {
                      if (input.isEmpty) {
                        return 'Enter an email.';
                      }
                      return null;
                    }
                ),
                TextFormField(
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                      hintText: "Password", border: UnderlineInputBorder(),
                      errorStyle:
                          TextStyle(color: Theme.of(context).primaryColor)),
                  obscureText: true,
                  onChanged: (value) {
                    this.setState(() {
                      _password = value;
                    });
                  },
                  validator: (input) {
                      if (input.isEmpty) {
                        return 'Enter a password';
                      }
                      return null;
                    }
                ),
                RaisedButton(
                  color: Colors.grey[900],
                  child: Text(
                    "Sign In",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: _email, password: _password)
                        .catchError((onError) {
                          print(onError.toString());
                    });
                    }
                  },
                )
              ],
            ),
          )),
        ),
      ),
    );
  }
}
