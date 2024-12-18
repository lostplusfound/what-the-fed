import 'package:civic_project/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0x00b22234))),
        title: 'What the Fed?',
        home: const HomePage());
  }
}
