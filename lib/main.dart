import 'package:firebase_test2/pages/welcmpage.dart';
import 'package:firebase_test2/pages/worksheet.dart';
import 'package:flutter/material.dart';

import 'models/db_provider.dart';
import 'pages/firstpage.dart';
import 'pages/home.dart';
import 'pages/scndpage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDB.instnc.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, routes: {
      '/': (context) => const WelcomeScrn(),
      '/login': (context) => const LoginPage(),
      '/signup': (context) => const SignUp(),
      '/home': (context) => const HomePage(),
      '/todo_scrn': (context) => const WorkArea(),
    });
  }
}
