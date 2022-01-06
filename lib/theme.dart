import 'package:flutter/material.dart';

import 'constants.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: kBaseColor0,
    fontFamily: "Iransans",
    appBarTheme: appBarTheme(),


   visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
AppBarTheme appBarTheme() {
  return AppBarTheme(
    color: kBaseColor0,
    elevation: 0,
    brightness: Brightness.light,
    iconTheme: IconThemeData(color: Colors.black),
    textTheme: TextTheme(
      headline6: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
    ),
  );
}