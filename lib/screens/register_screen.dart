import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final Function toggleView;
  RegisterScreen({this.toggleView});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _email, _password, _confirm_password;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  @override
  Widget build(BuildContext context) {

    // push defaults to user account
    void getDefaults(String userID) async {
      FirebaseFirestore.instance.collection('defaluts')
      .get()
      .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          FirebaseFirestore.instance.collection('users')
          .doc(userID)
          .collection('presets')
          .add({
            'name': doc['name'],
            'target': doc['target']
          });
         })
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Register Screen",
          style: TextStyle(color: Colors.white, fontSize: 28),
        ),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            label: Text(
              "Login",
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
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                      hintText: "Email",
                      border: UnderlineInputBorder(),
                      errorStyle:
                          TextStyle(color: Theme.of(context).primaryColor)),
                  onChanged: (value) {
                    this.setState(() {
                      _email = value;
                    });
                  },
                  validator: (input) =>
                      input.isEmpty ? 'Please enter an email.' : null,
                ),
                TextFormField(
                    controller: _pass,
                    decoration: InputDecoration(
                        hintText: "Password",
                        border: UnderlineInputBorder(),
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
                    }),
                TextFormField(
                    controller: _confirmPass,
                    decoration: InputDecoration(
                        hintText: "Confirm Password",
                        border: UnderlineInputBorder(),
                        errorStyle:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    obscureText: true,
                    onChanged: (value) {
                      this.setState(() {
                        _confirm_password = value;
                      });
                    },
                    validator: (input) {
                      if (input.isEmpty) {
                        return 'Enter a confirm password';
                      }
                      if (input != _pass.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    }),
                RaisedButton(
                  color: Colors.grey[900],
                  child: Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: _email, password: _password)
                          .then((onValue) {
                            getDefaults(onValue.user.uid.toString());
                          })
                          .catchError((error) {
                        print(error.toString());
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
