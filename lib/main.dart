import 'package:firebase_test2/pages/welcmpage.dart';
import 'package:firebase_test2/pages/worksheet.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/db_provider.dart';
import 'pages/firstpage.dart';
import 'pages/home.dart';
import 'pages/scndpage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://mfnwzlelhbcwriwgrjkc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1mbnd6bGVsaGJjd3Jpd2dyamtjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgzODM3MzgsImV4cCI6MjA0Mzk1OTczOH0.AIF5MooVoQiqRoHsEjPksC5UtgHVx5_DblvqOLtjR1Y',
  );
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
