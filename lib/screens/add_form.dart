import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class AddForm extends StatefulWidget {
  final String date;

  const AddForm({this.date});

  @override
  _AddFormState createState() => _AddFormState();
}

class _AddFormState extends State<AddForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final List<String> categories = [
    "Abs",
    "Back",
    "Biceps",
    "Chest",
    "Legs",
    "Traps",
    "Triceps",
  ];
  final List<int> setSets = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  List<dynamic> names = new List<dynamic>();

  List<TextFormField> reps = new List<TextFormField>(0);
  List<TextFormField> weights = new List<TextFormField>(0);

  // form values
  String _currentName, _currentCategory;
  List<int> sets;
  List<int> weight;
  int _setValue = 1;

  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser;
    final String uid = user.uid;

    var userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    var dateRef = userRef.collection('date');
    var targetRef = dateRef.doc(widget.date).collection('target');

    void _getWorkouts() async {
      int j = 0;
      await userRef
          .collection('presets')
          .where('target', isEqualTo: _currentCategory)
          .get()
          .then((QuerySnapshot querySnapshot) => {
                names = new List(querySnapshot.docs.length),
                querySnapshot.docs.forEach((doc) {
                  // print(doc["name"]);
                  setState(() {
                    names[j] = doc["name"];
                  });
                  j++;
                })
              });
      print(names);
      j = 0;
    }

    _setSetsList(int i) {
      setState(() {
        reps = new List<TextFormField>(i);
        weights = new List<TextFormField>(i);
        sets = new List<int>(i);
        weight = new List<int>(i);
      });
    }

    List<Widget> makeListWidget() {
      return reps.asMap().entries.map<Widget>((document) {
        int i = document.key;
        int displayIndex = i + 1;
        return Row(
          children: [
            Expanded(
              child: Text(displayIndex.toString()),
            ),
            Expanded(
                child: SizedBox(
                    width: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: "Reps"),
                        onChanged: (val) =>
                            setState(() => sets[i] = int.parse(val)),
                        validator: (value) =>
                            value == null ? 'Missing Entry' : null,
                      ),
                    ))),
            Expanded(
                child: SizedBox(
                    width: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: "Weight"),
                        onChanged: (val) =>
                            setState(() => weight[i] = int.parse(val)),
                        validator: (value) =>
                            value == null ? 'Missing Entry' : null,
                      ),
                    ))),
          ],
        );
      }).toList();
    }

    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          Center(
            child: Text(
              'Add a Workout',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          SizedBox(
            height: 20.0,
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
              onChanged: (val) async {
                setState(() {
                  _currentCategory = val;
                  names = [];
                  _currentName = null;
                });
                _getWorkouts();
              }),
          IgnorePointer(
            ignoring: _currentCategory == null ? true : false,
            child: DropdownButtonFormField(
                value: _currentName,
                validator: (value) =>
                    value == null ? 'Please select workout' : null,
                hint: _currentCategory == null
                    ? Text("Select a category first")
                    : Text("Select a workout"),
                items: names.map((name) {
                  return DropdownMenuItem(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _currentName = val)),
          ),
          // TextFormField(
          //   decoration: const InputDecoration(hintText: "Workout Name"),
          //   validator: (val) => val.isEmpty ? 'Please enter a name' : null,
          //   onChanged: (val) => setState(() => _currentName = val),
          // ),
          SizedBox(
            height: 20.0,
          ),
          DropdownButtonFormField(
            validator: (val) =>
                val == null ? 'Please select number of sets' : null,
            hint: Text("Select # of sets"),
            //value: _setValue,
            items: setSets.map((sets) {
              return DropdownMenuItem(
                  value: sets,
                  child: Text(sets == 1 ? '$sets set' : '$sets sets'));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _setValue = val;
              });
              _setSetsList(val);
            },
          ),
          Column(
            children: makeListWidget(),
          ),
          RaisedButton(
            color: Theme.of(context).accentColor,
            child: Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                await dateRef.doc(widget.date).set({'date': widget.date});

                await targetRef.add({
                  'name': _currentName,
                  'reps': sets,
                  'target': _currentCategory,
                  'weight': weight
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
