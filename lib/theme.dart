import 'package:flutter/material.dart';

ThemeData basicTheme() {
  TextTheme _basicTextTheme(TextTheme base) {
    return base.copyWith(
      headline1: base.headline1.copyWith(color: Colors.white),
    );
  }

  final ThemeData base = ThemeData.dark();
  return base.copyWith(
      textTheme: _basicTextTheme(base.textTheme),
      primaryColor: Color(0xff4829b2),
      iconTheme: IconThemeData(color: Colors.white));
}
