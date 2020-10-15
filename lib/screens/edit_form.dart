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

  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser;
    final String uid = user.uid;

    var workoutData = widget.doc.data();

    // String name = workoutData['name'];
    List<int> weights = List<int>(workoutData['weight'].length);
    List<int> sets = List<int>(workoutData['reps'].length);

    print(workoutData);

    // FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(uid)
    //     .collection('date')
    //     .doc(widget.date)
    //     .collection('target')
    //     .doc(widget.id)
    //     .get()
    //     .then((DocumentSnapshot documnetSnapshot) {
    //   if (documnetSnapshot.exists) {
    //     print('Document data ${documnetSnapshot.data()}');
    //   } else {
    //     print("No data.");
    //   }
    // });

    List<Widget> _makeFormWidget() {
      return sets.asMap().entries.map<Widget>((document) {
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
                        initialValue: workoutData['reps'][i].toString(),
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
                        initialValue: workoutData['weight'][i].toString(),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: "Weight"),
                        onChanged: (val) =>
                            setState(() => weights[i] = int.parse(val)),
                        validator: (value) =>
                            value == null ? 'Missing Entry' : null,
                      ),
                    ))),
            Expanded(
                child: SizedBox(
                    width: 20,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            setState(() {
                              weights.removeAt(i);
                              sets.removeAt(i);
                            });
                          },
                        )))),
          ],
        );
      }).toList();
    }

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
          TextFormField(
            initialValue: workoutData['name'],
            onChanged: (input) {
              setState(() {
                name = input;
              });
            },
          ),
          Column(
            children: _makeFormWidget(),
          )
        ],
      ),
    ));
  }
}
