import 'package:civic_project/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'What the Fed?', home: HomePage());
  }
}
