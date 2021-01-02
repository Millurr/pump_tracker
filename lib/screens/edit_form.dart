import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditForm extends StatefulWidget {
  final String date, id;
  final doc;
  final targetRef;

  const EditForm({this.date, this.id, this.doc, this.targetRef});

  @override
  _EditFormState createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final _formKey = GlobalKey<FormState>();

  String name = '';

  var weights = new List<dynamic>();
  var sets = new List<dynamic>();

  int reps, weight;
  int i = 0;

  var submitSetsArr, submitWeightsArr;

  bool deletePressed = false;

  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser;
    final String uid = user.uid;

    var targetRef = widget.targetRef.doc(widget.id);

    Container _makeFormWidget(var arrSets, var arrWeights) {
      return Container(
        height: 300,
        child: ListView.builder(
            itemCount: arrSets.length,
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
                            key: deletePressed
                                ? Key(arrSets[index].toString())
                                : null,
                            initialValue: arrSets[index].toString(),
                            validator: (value) =>
                                value == null ? 'Missing Entry' : null,
                            onChanged: (input) async {
                              setState(() {
                                reps = int.parse(input);
                              });
                              arrSets[index] = int.parse(input);
                              await targetRef.update({'reps': arrSets});
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
                            key: deletePressed
                                ? Key(arrWeights[index].toString())
                                : null,
                            initialValue: arrWeights[index].toString(),
                            validator: (value) =>
                                value == null ? 'Missing Entry' : null,
                            onChanged: (input) async {
                              setState(() {
                                weight = int.parse(input);
                              });
                              arrWeights[index] = int.parse(input);
                              await targetRef.update({'weight': arrWeights});
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: FlatButton(
                          child: Icon(Icons.delete),
                          onPressed: () async {
                            setState(() {
                              deletePressed = true;
                            });
                            arrSets.removeAt(index);
                            arrWeights.removeAt(index);
                            await targetRef.update(
                                {'reps': arrSets, 'weight': arrWeights});
                            setState(() {
                              deletePressed = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  index == arrSets.length - 1
                      ? Container(
                          child: RaisedButton(
                            color: Theme.of(context).accentColor,
                            child: Icon(Icons.add),
                            onPressed: () async {
                              arrSets.add(0);
                              arrWeights.add(0);
                              await targetRef.update(
                                  {'reps': arrSets, 'weight': arrWeights});
                            },
                          ),
                        )
                      : Container(
                          height: 10,
                          width: 20,
                          child: Divider(),
                        ),
                ],
              );
            }),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
        stream: targetRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data;
            return Container(
                child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Center(
                    child: Text(
                      "Update " + data['name'],
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  _makeFormWidget(data['reps'], data['weight']),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                  )
                ],
              ),
            ));
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
