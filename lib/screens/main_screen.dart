import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:pump_tracker/screens/add_form.dart';
import 'package:pump_tracker/screens/preset_screen.dart';
import 'package:pump_tracker/screens/chart_screen.dart';
import 'package:pump_tracker/screens/edit_form.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime selectedDate = DateTime.now();
  String date = '';

  int _selectedIndex = 0;
  bool deletePressed = false;

  int reps, weight;

  static List<Widget> _widgetOptions = <Widget>[
    null,
    PresetScreen(),
    ChartScreen(),
    null
  ];

  static List<Text> _textOptions = <Text>[
    null,
    Text("Preset Workouts"),
    Text("Chart"),
    null
  ];

  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser;
    final String uid = user.uid;
    String docID = '';

    setState(() {
      date = selectedDate.toString().split(" ")[0];
    });

    var userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    var dateRef = userRef.collection('date');
    var targetRef = dateRef.doc(date).collection('target');

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

    void _showAddPanel(String date) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
              child: AddForm(date: date),
            );
          });
    }

    void _showEditPanel(String date, String id, var doc, var ref) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
              child: EditForm(
                date: date,
                id: docID,
                doc: doc,
                targetRef: ref,
              ),
            );
          });
    }

    Padding _showDetails(var arrSets, var arrWeights) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 40 * arrSets.length.toDouble(),
          color: Colors.grey[800],
          child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: arrSets.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.grey[800],
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  arrSets[index].toString() +
                                      " x " +
                                      arrWeights[index].toString() +
                                      " lbs",
                                  style:
                                      TextStyle(fontSize: 14, wordSpacing: 10),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
        ),
      );
    }

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        setState(() {
          _selectedIndex = 0;
          Navigator.pop(context);
        });
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () async {
        await _auth.signOut();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Sign Out"),
      content: Text("Are you sure you want to sign out?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    void showConfirmation() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    void _onTapped(int index) async {
      setState(() {
        _selectedIndex = index;
      });
      if (_selectedIndex == 3) {
        showConfirmation();
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: _selectedIndex == 0
            ? IconButton(
                onPressed: () {
                  _selectedDate(context);
                },
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                ),
              )
            : null,
        title: _selectedIndex == 0
            ? Text(
                selectedDate.month.toString() +
                    '-' +
                    selectedDate.day.toString() +
                    '-' +
                    selectedDate.year.toString(),
                style: TextStyle(color: Colors.white, fontSize: 20),
              )
            : _textOptions.elementAt(_selectedIndex),
        actions: [
          _selectedIndex == 0
              ? IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _showAddPanel(date),
                )
              : Text('')
        ],
      ),
      backgroundColor: Theme.of(context).accentColor,
      body: _selectedIndex == 0
          ? Container(
              child: StreamBuilder(
              stream: targetRef.snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    );
                  default:
                    if (snapshot.data.documents.length > 0) {
                      return GroupedListView<dynamic, String>(
                        elements: snapshot.data.documents,
                        groupBy: (element) => element['target'],
                        groupComparator: (value1, value2) =>
                            value2.compareTo(value1),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        "Delete",
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ),
                                  ),
                                  key: Key(element.documentID),
                                  onDismissed: (direction) async {
                                    print(direction.index);
                                    await targetRef
                                        .doc(element.documentID)
                                        .delete();
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
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              docID = element.documentID;
                                            });
                                            _showEditPanel(date, docID, element,
                                                targetRef);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: Column(children: [
                                    _showDetails(
                                        element['reps'], element['weight'])
                                  ]),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                          child: Text(
                        "No data for this day",
                        style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(context).primaryColor),
                      ));
                    }
                }
              },
            ))
          : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Presets'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(
            label: 'Sign Out',
            icon: Icon(Icons.person),
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).accentColor,
        onTap: _onTapped,
      ),
    );
  }
}
