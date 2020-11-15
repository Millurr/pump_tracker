import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddGeneric extends StatefulWidget {
  @override
  _AddGenericState createState() => _AddGenericState();
}

class _AddGenericState extends State<AddGeneric> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final _formKey = GlobalKey<FormState>();

  final List<String> categories = [
    "Abs",
    "Back",
    "Biceps",
    "Chest",
    "Legs",
    "Traps",
    "Triceps",
  ];

  String _currentCategory, _name;

  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser;
    final String uid = user.uid;

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Center(
            child: Text(
              "Add a workout preset.",
              style: TextStyle(fontSize: 20),
            ),
          ),
          DropdownButtonFormField(
              validator: (value) =>
                  value == null ? 'Please select a category' : null,
              hint: Text("Select a category"),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text('$category'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _currentCategory = val)),
          TextFormField(
            decoration: InputDecoration(hintText: "Workout Name"),
            onChanged: (input) {
              setState(() {
                _name = input;
              });
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          RaisedButton(
            color: Theme.of(context).accentColor,
            child: Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('presets')
                    .add({
                  'name': _name,
                  'target': _currentCategory,
                });
                Navigator.pop(context);
              } else {
                print("Validation failed.");
              }
            },
          ),
        ],
      ),
    );
  }
}
