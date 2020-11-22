import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _uName, _fName, _lName;
  int _weight;
  String uid, fname, lname;
  dynamic uname;
  int weight;
  bool didUpdate;

  @override
  void initState() {
    super.initState();
    didUpdate = false;
    uid = _auth.currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var userData = snapshot.data;
            return Center(
              child: Container(
                width: 200,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      TextFormField(
                        textAlign: TextAlign.center,
                        decoration:
                            InputDecoration(contentPadding: EdgeInsets.zero),
                        initialValue: userData['username'],
                        validator: (val) =>
                            val.isEmpty ? 'Please enter a username' : null,
                        onChanged: (val) => setState(() => _uName = val),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        textAlign: TextAlign.center,
                        initialValue: userData['fname'],
                        validator: (val) =>
                            val.isEmpty ? 'Please enter a first name' : null,
                        onChanged: (val) => setState(() => _fName = val),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        textAlign: TextAlign.center,
                        initialValue: userData['lname'],
                        validator: (val) =>
                            val.isEmpty ? 'Please enter a last name' : null,
                        onChanged: (val) => setState(() => _lName = val),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        initialValue: userData['weight'].toString(),
                        validator: (val) =>
                            val.isEmpty ? 'Please enter a weight' : null,
                        onChanged: (val) =>
                            setState(() => _weight = int.parse(val)),
                      ),
                      SizedBox(height: 10.0),
                      RaisedButton(
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            'Update',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .update({
                                'username': ((_uName == '') || (_uName == null))
                                    ? userData['username']
                                    : _uName,
                                'fname': ((_fName == '') || (_fName == null))
                                    ? userData['fname']
                                    : _fName,
                                'lname': ((_lName == '') || (_lName == null))
                                    ? userData['lname']
                                    : _lName,
                                'weight': ((_weight == 0) || (_weight == null))
                                    ? userData['weight']
                                    : _weight
                              }).then((value) {
                                setState(() {
                                  didUpdate = true;
                                });
                              });
                            }
                          }),
                      SizedBox(
                        height: 10.0,
                      ),
                      RaisedButton(
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            await _auth.signOut();
                          }),
                      didUpdate == true
                          ? Text("User updated successfully.")
                          : Divider()
                    ],
                  ),
                ),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

// class UserProfile {
//   final uname, fname, lname;
//   int weight;

//   UserProfile.getProfile(this.uname, this.fname, this.lname);
// }
