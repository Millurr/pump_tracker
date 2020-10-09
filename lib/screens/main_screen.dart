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
      return ListTile(
        title: Text(document['name']),
        subtitle: Container(
            child: Text("Weight: " +
                document['weight'][0].toString() +
                ' lbs x ' +
                document['reps'][0].toString())),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser;
    final String uid = user.uid;

    String category = "Chest";
    String date = "20201005";

    FirebaseFirestore.instance
        .collection('users/')
        .doc(uid)
        .collection('date')
        .doc(date)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        for (int i = 0; i < documentSnapshot.data()['parts'].length; i++) {
          print(documentSnapshot.data()['parts'][i].toString());
        }
      } else {
        print('Document does not exist on the database');
      }
    });

    var userRef = FirebaseFirestore.instance.collection('users/').doc(uid);
    var dateRef = userRef.collection('date').doc(date);
    var workoutRef = dateRef.collection(category);

    var test = dateRef.collection(category).snapshots();

    print(dateRef);

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
          stream: workoutRef.snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              default:
                {
                  //var workoutDocument = snapshot.data;
                  return StreamBuilder(
                      stream: workoutRef.snapshots(),
                      builder: (context, snapshot2) {
                        switch (snapshot2.connectionState) {
                          case ConnectionState.waiting:
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          default:
                            return ListView(
                              children: makeListWidget(snapshot2),
                            );
                        }
                      });
                }
            }
          },
        )));
  }
}
