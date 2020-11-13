import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddToForm extends StatefulWidget {
  final String name, target;

  const AddToForm({this.name, this.target});

  @override
  _AddToFormState createState() => _AddToFormState();
}

class _AddToFormState extends State<AddToForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final _formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();
  String date = '';

  var weights = new List<dynamic>();
  var sets = new List<dynamic>();

  int reps, weight;
  int i = 0;

  var arrSets = [0];
  var arrWeights = [0];

  bool deletePressed = false;

  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser;
    final String uid = user.uid;

    setState(() {
      date = selectedDate.toString().split(" ")[0];
    });

    _selectedDate(BuildContext context) async {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2019),
          lastDate: DateTime(2021),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                primaryColor: const Color(0xFF8CE7F1),
                accentColor: const Color(0xFF8CE7F1),
                colorScheme:
                    ColorScheme.dark(primary: Theme.of(context).accentColor),
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.primary),
              ),
              child: child,
            );
          });
      if (picked != null && picked != selectedDate)
        setState(() {
          selectedDate = picked;
          date = selectedDate.toString().split(" ")[0];
        });
    }

    return Container(
      height: 300,
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Muscle group: " + widget.target,
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Workout: " + widget.name,
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedDate.month.toString() +
                        '-' +
                        selectedDate.day.toString() +
                        '-' +
                        selectedDate.year.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: Colors.white),
                    onPressed: () {
                      _selectedDate(context);
                    },
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('date')
                      .doc(date)
                      .collection('target')
                      .add({
                    'name': widget.name,
                    'target': widget.target,
                    'reps': arrSets,
                    'weight': arrWeights
                  }).then((i) {
                    Navigator.pop(context);
                  });
                },
              ),
            )
            // Expanded(
            //   child: Container(
            //     height: 300,
            //     child: ListView.builder(
            //       itemCount: sets.length == 0 ? 1 : sets.length,
            //       itemBuilder: (context, index) {
            //         sets.length == 0 ? sets.add(0) : null;
            //         weights.length == 0 ? weights.add(0) : null;
            //         int displayIndex = index + 1;
            //         return Column(
            //           children: [
            //             Row(
            //               children: [
            //                 Expanded(
            //                   child: Padding(
            //                     padding: const EdgeInsets.only(left: 8.0),
            //                     child: Text("Set " + (displayIndex).toString()),
            //                   ),
            //                 ),
            //                 Expanded(
            //                   child: Padding(
            //                     padding: const EdgeInsets.only(left: 8.0),
            //                     child: TextFormField(
            //                       inputFormatters: [
            //                         FilteringTextInputFormatter.digitsOnly
            //                       ],
            //                       keyboardType: TextInputType.number,
            //                       key: deletePressed
            //                           ? Key(sets[index].toString())
            //                           : null,
            //                       initialValue: sets[index].toString(),
            //                       validator: (value) =>
            //                           value == null ? 'Missing Entry' : null,
            //                       onChanged: (input) {
            //                         setState(() {
            //                           sets[index] = int.parse(input);
            //                         });
            //                         sets[index] = int.parse(input);
            //                       },
            //                     ),
            //                   ),
            //                 ),
            //                 Expanded(
            //                   child: Padding(
            //                     padding: const EdgeInsets.only(left: 8.0),
            //                     child: TextFormField(
            //                       inputFormatters: [
            //                         FilteringTextInputFormatter.digitsOnly
            //                       ],
            //                       keyboardType: TextInputType.number,
            //                       key: deletePressed
            //                           ? Key(weights[index].toString())
            //                           : null,
            //                       initialValue: weights[index].toString(),
            //                       validator: (value) =>
            //                           value == null ? 'Missing Entry' : null,
            //                       onChanged: (input) {
            //                         setState(() {
            //                           weights[index] = int.parse(input);
            //                         });
            //                         weights[index] = int.parse(input);
            //                       },
            //                     ),
            //                   ),
            //                 ),
            //                 Expanded(
            //                   child: FlatButton(
            //                     child: Icon(Icons.delete),
            //                     onPressed: () async {
            //                       setState(() {
            //                         deletePressed = true;
            //                       });

            //                       sets.removeAt(index);
            //                       weights.removeAt(index);
            //                     },
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             index == sets.length - 1
            //                 ? Container(
            //                     child: RaisedButton(
            //                       color: Theme.of(context).accentColor,
            //                       child: Icon(Icons.add),
            //                       onPressed: () async {
            //                         setState(() {
            //                           sets.add(0);
            //                           weights.add(0);
            //                         });
            //                       },
            //                     ),
            //                   )
            //                 : Container(
            //                     height: 10,
            //                     width: 20,
            //                     child: Divider(),
            //                   ),
            //           ],
            //         );
            //       },
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
