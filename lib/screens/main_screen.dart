import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(  
        // leading: IconButton( 
        //     icon: Icon(Icons.menu),
        //     onPressed: () => {},
        //   ),
        backgroundColor: Colors.grey[900],
        title: Text(  
          "Home",
          style: TextStyle(color: Colors.white, fontSize: 28),
        ),
      ),
      drawer: Drawer(  
        child: ListView(  
          children: <Widget>[
            DrawerHeader(child: Text("This is the drawer header"),),
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
          ],
        ),
      ),
      backgroundColor: Colors.red[400],
      body: Center(  
        child: RaisedButton(  
          onPressed: () async {
            await FirebaseAuth.instance.signOut().then((value) {
            });
          },
          color: Colors.grey[900],
          child: Text(  
            "Sign Out",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}