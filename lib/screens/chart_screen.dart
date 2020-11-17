import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';

class ChartScreen extends StatefulWidget {
  final Widget child;

  ChartScreen({Key key, this.child}) : super(key: key);

  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<charts.Series<Sales, int>> _seriesLineData;
  List<String> dropwDownList = new List<String>();
  String _currentName;

  _generateData() {
    var linesalesdata = [
      new Sales(0, 45),
      new Sales(1, 56),
      new Sales(2, 55),
      new Sales(3, 60),
      new Sales(4, 61),
      new Sales(5, 70),
    ];

    _seriesLineData.add(
      charts.Series(
        colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xff990099)),
        id: 'Air Pollution',
        data: linesalesdata,
        domainFn: (Sales sales, _) => sales.yearval,
        measureFn: (Sales sales, _) => sales.salesval,
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _seriesLineData = List<charts.Series<Sales, int>>();
    // _generateData();
  }

  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser;
    final String uid = user.uid;

    var userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    var dateRef = userRef.collection('date');

    var presetsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('presets');

    _getMax(List arr) {
      var compare = 0;

      for (var val in arr) {
        if (val > compare) compare = val;
      }

      return compare;
    }

    _generateMaxWeight(String workout) async {
      var dates = [];

      await dateRef.get().then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          dates.add(doc.id);
        });
      });

      List<Sales> lineMaxWeightData = [];

      int i = 0;
      dates.forEach((date) async {
        await dateRef
            .doc(date)
            .collection('target')
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((doc) async {
            if (doc['name'] == workout) {
              if (doc['weight'].length > 1) {
                var max = _getMax(doc['weight']);
                lineMaxWeightData.add(new Sales(i, max));
              } else {
                lineMaxWeightData.add(new Sales(i, doc['weight'][0]));
              }
              i++;
            }
          });
        });
      });
      i = 0;

      _seriesLineData.add(
        charts.Series(
          colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xff990099)),
          id: 'Max Weight',
          data: lineMaxWeightData,
          domainFn: (Sales sales, _) => sales.yearval,
          measureFn: (Sales sales, _) => sales.salesval,
        ),
      );
    }

    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: presetsRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    );
                  else {
                    List<DropdownMenuItem> workouts = [];
                    for (int i = 0; i < snapshot.data.docs.length; i++) {
                      DocumentSnapshot snap = snapshot.data.docs[i];
                      workouts.add(
                        DropdownMenuItem(
                          child: Text(
                            snap['name'],
                          ),
                          value: snap['name'],
                        ),
                      );
                    }
                    return DropdownButton(
                      items: workouts,
                      onChanged: (val) async {
                        setState(() {
                          _currentName = val;
                        });
                        await _generateMaxWeight(val);
                      },
                      value: _currentName,
                      isExpanded: false,
                      hint: Text(
                        "Choose workout",
                      ),
                    );
                  }
                }),
            Container(
              height: 300,
              child: _seriesLineData.isNotEmpty
                  ? Column(
                      children: [
                        Text(
                          'Max Weight',
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: charts.LineChart(_seriesLineData,
                              defaultRenderer: new charts.LineRendererConfig(
                                  includePoints: true),
                              animate: false,
                              behaviors: [
                                new charts.ChartTitle('Dates',
                                    behaviorPosition:
                                        charts.BehaviorPosition.bottom,
                                    titleOutsideJustification: charts
                                        .OutsideJustification.middleDrawArea),
                                new charts.ChartTitle('Max Weight',
                                    behaviorPosition:
                                        charts.BehaviorPosition.start,
                                    titleOutsideJustification: charts
                                        .OutsideJustification.middleDrawArea),
                                new charts.ChartTitle(
                                  '',
                                  behaviorPosition: charts.BehaviorPosition.end,
                                  titleOutsideJustification: charts
                                      .OutsideJustification.middleDrawArea,
                                )
                              ]),
                        ),
                      ],
                    )
                  : Divider(),
            )
          ],
        ),
      ),
    );
  }
}

class Sales {
  int yearval;
  int salesval;

  Sales(this.yearval, this.salesval);
}
