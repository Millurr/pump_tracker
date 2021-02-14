import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final List<int> setSets = [1, 2, 3, 4, 5];

  List<int> sets, weight;

  List<TextFormField> reps = new List<TextFormField>(0);
  List<TextFormField> weights = new List<TextFormField>(0);

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
          lastDate: DateTime(2022),
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
      child: Container(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 30.0, left: 8.0),
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
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () {
                    _selectedDate(context);
                  },
                ),
                Text(
                  selectedDate.month.toString() +
                      '-' +
                      selectedDate.day.toString() +
                      '-' +
                      selectedDate.year.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      decoration: TextDecoration.underline),
                ),
              ],
            ),
            // Drop down menu for the number of sets
            DropdownButtonFormField(
              validator: (val) =>
                  val == null ? 'Please select a number of sets' : null,
              hint: Text("Select # of sets"),
              items: setSets.map((sets) {
                return DropdownMenuItem(
                  value: sets,
                  child: Text(sets == 1 ? '$sets set' : '$sets sets'),
                );
              }).toList(),
              onChanged: (val) {
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
                  // Checks if there's any null values in the arrays
                  // If so, sets it equal to 1
                  for (int k = 0; k < sets.length; k++) {
                    if (sets[k] == null) sets[k] = 1;
                    if (weight[k] == null) weight[k] = 1;
                  }
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('date')
                      .doc(date)
                      .collection('target')
                      .add({
                    'name': widget.name,
                    'target': widget.target,
                    'reps': sets,
                    'weight': weight,
                  }).then((i) {
                    Navigator.pop(context);
                  });
                } else {
                  print("Validation failed.");
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
