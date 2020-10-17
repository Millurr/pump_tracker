import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditForm extends StatefulWidget {
  final String date, id;
  final doc;

  const EditForm({this.date, this.id, this.doc});

  @override
  _EditFormState createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  String name = '';

  var weights = new List<dynamic>();
  var sets = new List<dynamic>();

  int reps, weight;

  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser;
    final String uid = user.uid;

    var workoutData = widget.doc.data();

    // String name = workoutData['name'];

    //initState();

    updateSets() {}

    var targetRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('date')
        .doc(widget.date)
        .collection('target')
        .doc(widget.id);

    targetRef.get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data ${documentSnapshot.data()}');
        setState(() {
          weights = documentSnapshot.data()['weight'];
          sets = documentSnapshot.data()['reps'];
        });
      } else {
        print("No data.");
      }
    });

    Container _makeFormWidget() {
      return Container(
        height: 200,
        child: ListView.builder(
            itemCount: sets.length,
            itemBuilder: (context, index) {
              int displayIndex = index + 1;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text("Set " + (displayIndex).toString()),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                            initialValue: sets[index].toString(),
                            onChanged: (input) {
                              setState(() {
                                reps = int.parse(input);
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                            initialValue: weights[index].toString(),
                            onChanged: (input) {
                              setState(() {
                                weight = int.parse(input);
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: FlatButton(
                          child: Icon(Icons.delete),
                          onPressed: () async {
                            sets.removeAt(index);
                            weights.removeAt(index);
                            await targetRef
                                .update({'reps': sets, 'weight': weights});
                          },
                        ),
                      ),
                    ],
                  ),
                  index == sets.length - 1
                      ? Container(
                          child: RaisedButton(
                            color: Theme.of(context).accentColor,
                            child: Icon(Icons.add),
                            onPressed: () async {
                              sets.add(0);
                              weights.add(0);
                              await targetRef
                                  .update({'reps': sets, 'weight': weights});
                            },
                          ),
                        )
                      : Container(
                          height: 10,
                          width: 20,
                          child: Divider(),
                        )
                ],
              );
            }),
      );
    }

    return StreamBuilder<Object>(
        stream: targetRef.snapshots(),
        builder: (context, snapshot) {
          return Container(
              child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Center(
                    child: Text(
                  "Update " + workoutData['name'],
                  style: TextStyle(fontSize: 18.0),
                )),
                _makeFormWidget(),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Text('Update'),
                          onPressed: () async {
                            await targetRef
                                .update({'sets': sets, 'weight': weights});
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ));
        });
  }
}
