import 'package:flutter/material.dart';

Color textColor = const Color.fromRGBO(20, 20, 20, 1);
Color lightBlack = const Color.fromRGBO(50, 50, 50, 1);
String table = 'current_books';

List<BoxShadow> lightShadows = [
  BoxShadow(
      color: Colors.white.withOpacity(0.5), spreadRadius: -5, offset: const Offset(-5, -5), blurRadius: 4),
  BoxShadow(
      color: Colors.black.withOpacity(.2),
      spreadRadius: 2,

      offset: const Offset(3, 3),
      blurRadius: 4)
];

List<BoxShadow> primaryShadows = [
  BoxShadow(
      color: Colors.white.withOpacity(0.5), spreadRadius: -5, offset: Offset(-5, -5), blurRadius: 20),
  BoxShadow(
      color: Colors.black.withOpacity(.2),
      spreadRadius: 2,

      offset: const Offset(7, 7),
      blurRadius: 20)
];

List<BoxShadow> lowOpaShadow = [
  BoxShadow(
      color: Colors.white.withOpacity(0.2), spreadRadius: -5, offset: Offset(-5, -5), blurRadius: 10),
  BoxShadow(
      color: Colors.black.withOpacity(.1),
      spreadRadius: 2,

      offset: const Offset(4, 4),
      blurRadius: 10)
];