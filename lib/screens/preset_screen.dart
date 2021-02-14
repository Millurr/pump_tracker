import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:pump_tracker/screens/add_to_form.dart';

class PresetScreen extends StatefulWidget {
  @override
  _PresetScreenState createState() => _PresetScreenState();
}

class _PresetScreenState extends State<PresetScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser;
    final String uid = user.uid;

    var presetsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('presets');

    void _showAddToFrom(String name, String target) {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
              child: AddToForm(name: name, target: target),
            );
          });
    }

    return Container(
        child: StreamBuilder(
      stream: presetsRef.snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            );
          default:
            return GroupedListView<dynamic, String>(
              elements: snapshot.data.documents,
              groupBy: (element) => element['target'],
              groupComparator: (value1, value2) => value2.compareTo(value1),
              itemComparator: (item1, item2) =>
                  item1['name'].compareTo(item2['name']),
              order: GroupedListOrder.DESC,
              useStickyGroupSeparators: false,
              groupSeparatorBuilder: (String value) => Container(
                color: Theme.of(context).accentColor,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900]),
                ),
              ),
              itemBuilder: (c, element) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Dismissible(
                        background: Container(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Delete",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        key: Key(element.documentID),
                        onDismissed: (direction) async {
                          print(direction.index);
                          await presetsRef.doc(element.documentID).delete();
                        },
                        child: Card(
                          elevation: 8.0,
                          color: Theme.of(context).primaryColor,
                          child: Container(
                            child: ListTile(
                              title: Text(
                                element['name'],
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _showAddToFrom(
                                      element['name'], element['target']);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
        }
      },
    ));
  }
}
