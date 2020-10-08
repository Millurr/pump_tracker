import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Widget> makeListWidget(AsyncSnapshot snapshot) {
    return snapshot.data.documents.map<Widget>((document) {
      return ListTile(title: Text(document['name']));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser;
    final String uid = user.uid;

    var userRef = FirebaseFirestore.instance.collection('users/').doc(uid);
    var dateRef = userRef.collection('date').doc('20201005');

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          title: Text(
            "Home",
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Text("This is the drawer header"),
              ),
              ListTile(
                title: Text("1"),
              ),
              ListTile(
                title: Text("2"),
              ),
              ListTile(
                title: Text("3"),
              ),
              ListTile(
                title: Text("4"),
              ),
              RaisedButton(
                onPressed: () async {
                  await _auth.signOut().then((value) {});
                },
                color: Colors.grey[900],
                child: Text(
                  "Sign Out",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.red[400],
        body: Container(
            child: StreamBuilder(
          stream: dateRef.snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              default:
                {
                  var dateDocument = snapshot.data;
                  return new Text(dateDocument['date']);
                }
              // return ListView(
              //   children: makeListWidget(snapshot),
              // );
            }
          },
        )));
  }
}
