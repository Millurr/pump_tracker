import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ChartScreen extends StatefulWidget {
  final Widget child;

  ChartScreen({Key key, this.child}) : super(key: key);

  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<charts.Series<Workouts, DateTime>> _maxWeightLineData =
      new List<charts.Series<Workouts, DateTime>>();
  List<charts.Series<Workouts, DateTime>> _volumeLineData =
      new List<charts.Series<Workouts, DateTime>>();
  List<String> dropwDownList = new List<String>();
  String _currentName;

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

    _getVol(List sets, List weights) {
      var volume = 0;

      for (int i = 0; i < sets.length; i++) {
        volume += sets[i] * weights[i];
      }

      return volume;
    }

    _generateMaxWeight(String workout) async {
      setState(() {
        _maxWeightLineData = new List<charts.Series<Workouts, DateTime>>();
        _volumeLineData = new List<charts.Series<Workouts, DateTime>>();
      });

      var dates = [];

      await dateRef.get().then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          dates.add(doc.id);
        });
      });

      List<Workouts> lineMaxWeightData = [];
      List<Workouts> lineVolumeData = [];

      for (int i = 0; i < dates.length; i++) {
        await dateRef.doc(dates[i]).collection('target').get().then((snap) {
          snap.docs.forEach((doc) async {
            if (doc['name'] == workout) {
              if (doc['weight'].length > 1) {
                var max = _getMax(doc['weight']);
                var volume = _getVol(doc['reps'], doc['weight']);
                lineMaxWeightData
                    .add(new Workouts(DateTime.parse(dates[i]), max));
                lineVolumeData
                    .add(new Workouts(DateTime.parse(dates[i]), volume));
              } else {
                lineMaxWeightData.add(
                    new Workouts(DateTime.parse(dates[i]), doc['weight'][0]));
                lineVolumeData.add(new Workouts(DateTime.parse(dates[i]),
                    doc['weight'][0] * doc['reps'][0]));
              }
            }
          });
        });
      }

      if (lineMaxWeightData.length > 1) {
        setState(() {
          _maxWeightLineData.add(
            charts.Series<Workouts, DateTime>(
              colorFn: (__, _) => charts.ColorUtil.fromDartColor(
                  Theme.of(context).primaryColor),
              id: 'Max Weight',
              data: lineMaxWeightData,
              domainFn: (Workouts workouts, _) => workouts.dayVal,
              measureFn: (Workouts workouts, _) => workouts.weightVal,
            ),
          );
        });
      }

      if (lineVolumeData.length > 1) {
        setState(() {
          _volumeLineData.add(
            charts.Series<Workouts, DateTime>(
              colorFn: (__, _) => charts.ColorUtil.fromDartColor(
                  Theme.of(context).primaryColor),
              id: 'Max Weight',
              data: lineVolumeData,
              domainFn: (Workouts workouts, _) => workouts.dayVal,
              measureFn: (Workouts workouts, _) => workouts.weightVal,
            ),
          );
        });
      }
    }

    Future<List<charts.Series<Workouts, DateTime>>> data =
        Future<List<charts.Series<Workouts, DateTime>>>.delayed(
            Duration(milliseconds: 500), () => _maxWeightLineData);

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: presetsRef.orderBy('name').snapshots(),
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
                child: _maxWeightLineData.isNotEmpty
                    ? FutureBuilder<List<charts.Series<Workouts, DateTime>>>(
                        future: data,
                        builder: (context, snapshot) {
                          if (snapshot.hasData)
                            return Chart(
                                _maxWeightLineData, "Max Weight", "Weight");
                          else
                            return Container(
                              height: 100,
                              width: 100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                              ),
                            );
                        })
                    : Divider()),
            Container(
                height: 300,
                child: _volumeLineData.isNotEmpty
                    ? FutureBuilder<List<charts.Series<Workouts, DateTime>>>(
                        future: data,
                        builder: (context, snapshot) {
                          if (snapshot.hasData)
                            return Chart(
                                _volumeLineData, "Volume", "Weight x Reps");
                          else
                            return Container(
                              height: 100,
                              width: 100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                              ),
                            );
                        })
                    : Divider()),
          ],
        ),
      ),
    );
  }
}

class Chart extends StatelessWidget {
  final String title, sideTitle;
  final List<charts.Series<Workouts, DateTime>> seriesLineData;

  Chart(this.seriesLineData, this.title, this.sideTitle);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: charts.TimeSeriesChart(seriesLineData,
              defaultRenderer:
                  new charts.LineRendererConfig(includePoints: true),
              animate: false,
              domainAxis: new charts.EndPointsTimeAxisSpec(),
              behaviors: [
                new charts.ChartTitle(sideTitle,
                    behaviorPosition: charts.BehaviorPosition.start,
                    titleOutsideJustification:
                        charts.OutsideJustification.middleDrawArea),
              ]),
        ),
        Divider(color: Theme.of(context).primaryColor, height: 20, thickness: 2)
      ],
    );
  }
}

class Workouts {
  DateTime dayVal;
  int weightVal;

  Workouts(this.dayVal, this.weightVal);
}
