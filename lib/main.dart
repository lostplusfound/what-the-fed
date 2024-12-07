import 'package:civic_project/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: HomePage());
  }
}
