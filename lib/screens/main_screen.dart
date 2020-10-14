import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:pump_tracker/screens/add_form.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Widget> makeListWidget(AsyncSnapshot snapshot) {
    return snapshot.data.documents.map<Widget>((document) {
      print('Here ' + document.data().toString());
      return ListTile(
          title: Text(document['date']),
          subtitle: Column(
            children: [
              Text(document['2020-10-08'][0]['name'].toString()),
              Text(document['2020-10-08'][0]['weight'][0].toString() +
                  ' lbs x ' +
                  document['2020-10-08'][0]['reps'].length.toString())
            ],
          ));
    }).toList();
  }

  DateTime selectedDate = DateTime.now();
  String date = "2020-10-08";

  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser;
    final String uid = user.uid;

    var userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    var dateRef = userRef.collection('date');
    var targetRef = dateRef.doc(date).collection('target');

    setState(() {
      date = selectedDate.toString().split(" ")[0];
    });

    _selectedDate(BuildContext context) async {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: selectedDate, // Refer step 1
          firstDate: DateTime(2000),
          lastDate: DateTime(2025),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark(),
              child: child,
            );
          });
      if (picked != null && picked != selectedDate)
        setState(() {
          selectedDate = picked;
          print(selectedDate.toString().split(" ")[0]);
          date = selectedDate.toString().split(" ")[0];
        });
    }

    void _showAddPanel(String date) {
      showModalBottomSheet(
          // isScrollControlled: true,
          // enableDrag: false,
          context: context,
          builder: (context) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
              child: AddForm(date: date),
            );
          });
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          title: FlatButton.icon(
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
            ),
            label: Text(
              selectedDate.month.toString() +
                  '/' +
                  selectedDate.day.toString() +
                  '/' +
                  selectedDate.year.toString(),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => _selectedDate(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showAddPanel(date),
            )
          ],
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.grey[900],
            child: ListView(
              children: <Widget>[
                Container(
                  color: Colors.grey[900],
                  child: DrawerHeader(
                    child: Center(
                        child: Text(
                      "Pump Tracker",
                      style: TextStyle(color: Colors.red[400], fontSize: 28),
                    )),
                  ),
                ),
                Container(
                  color: Colors.grey[900],
                  child: ListTile(
                    onTap: () {},
                    //leading: Icon(Icons.home),
                    title: Center(
                      child: Text(
                        "Home",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey[900],
                  child: ListTile(
                    onTap: () {},
                    //leading: Icon(Icons.calendar_today),
                    title: Center(
                        child: Text(
                      "Calendar",
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                ),
                Container(
                  color: Colors.grey[900],
                  child: ListTile(
                    onTap: () {},
                    //leading: Icon(Icons.bar_chart),
                    title: Center(
                        child: Text(
                      "Progress Chart",
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
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
                Container(
                  color: Colors.red[400],
                )
              ],
            ),
          ),
        ),
        backgroundColor: Colors.red[400],
        body: Container(
            child: StreamBuilder(
          stream: targetRef.snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.grey[900],
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
                  groupSeparatorBuilder: (String value) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 10.0,
                      margin: new EdgeInsets.symmetric(horizontal: 50.0),
                      color: Colors.red[400],
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900]),
                      ),
                    ),
                  ),
                  itemBuilder: (c, element) {
                    //print("Id: " + element.documentID);
                    return Card(
                      elevation: 8.0,
                      color: Colors.grey[900],
                      margin: new EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 6.0),
                      child: Container(
                        child: ListTile(
                          leading: IconButton(
                            icon: Icon(Icons.grid_view),
                            color: Colors.white,
                            onPressed: () {},
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 2.0),
                          title: Text(
                            element['name'],
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    );
                  },
                );
            }
          },
        )));
  }
}
