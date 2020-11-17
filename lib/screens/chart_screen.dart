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
    _generateData();
  }

  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser;
    final String uid = user.uid;

    var userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    var dateRef = userRef.collection('date');

    _generateMaxWeight() async {
      var dates = [];
      var maxWeights = [];

      await dateRef.get().then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          dates.add(doc.id);
        });
      });

      var lineMaxWeightData = [
        new Sales(0, 45),
        new Sales(1, 56),
        new Sales(2, 55),
        new Sales(3, 60),
        new Sales(4, 61),
        new Sales(5, 70),
      ];

      // for (int i = 0; i < dates.length; i++) {
      //   // lineMaxWeightData.add(new Sales(i, 3));
      //   await dateRef
      //       .doc(dates[i])
      //       .collection('target')
      //       .get()
      //       .then((querySnapshot) {
      //     querySnapshot.docs.forEach((doc) {
      //       if (doc['name'] == 'Crunches') {
      //         maxWeights[i] = doc['weight'].reduce(max);
      //       }
      //     });
      //   });
      // }

      _seriesLineData.add(
        charts.Series(
          colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xff990099)),
          id: 'Air Pollution',
          data: lineMaxWeightData,
          domainFn: (Sales sales, _) => sales.yearval,
          measureFn: (Sales sales, _) => sales.salesval,
        ),
      );
    }

    _generateMaxWeight();

    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              'Max Weight',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: charts.LineChart(_seriesLineData,
                  defaultRenderer:
                      new charts.LineRendererConfig(includePoints: true),
                  animate: false,
                  behaviors: [
                    new charts.ChartTitle('Years',
                        behaviorPosition: charts.BehaviorPosition.bottom,
                        titleOutsideJustification:
                            charts.OutsideJustification.middleDrawArea),
                    new charts.ChartTitle('Sales',
                        behaviorPosition: charts.BehaviorPosition.start,
                        titleOutsideJustification:
                            charts.OutsideJustification.middleDrawArea),
                    new charts.ChartTitle(
                      'Departments',
                      behaviorPosition: charts.BehaviorPosition.end,
                      titleOutsideJustification:
                          charts.OutsideJustification.middleDrawArea,
                    )
                  ]),
            ),
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
