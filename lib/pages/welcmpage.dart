import 'package:flutter/material.dart';

import '../components/button.dart';
import '../models/sb_auth.dart';
import '../pages/worksheet.dart';

//Welcome Screen, just that lol.

class WelcomeScrn extends StatefulWidget {
  const WelcomeScrn({super.key});

  @override
  State<WelcomeScrn> createState() => _WelcomeScrnState();
}

class _WelcomeScrnState extends State<WelcomeScrn> {
  final _auth = SBAuth();

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _auth.isLoggedIn();
    if (isLoggedIn) {
      // Retrieve the logged-in user's email
      final email = await _auth.getLoggedInUserEmail();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkArea(userEmail: email ?? ''), // Pass email
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: screen.width,
        decoration:
            //Background Image here:
            BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: Image.asset(
              'assets/bg1.png',
            ).image,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              height: 30,
            ),
            const CircleAvatar(
              backgroundImage: AssetImage('assets/bg2.png'),
              radius: 80,
            ),
            Container(
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Welcome!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                    ),
                  ),
                  Text(
                    "Get started",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                //_checkLoginStatus();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WorkArea(userEmail: 'Please Sign In'), // Pass email
                  ),
                );
              },
              child: ButnTyp1(
                  text: 'Next',
                  size: 25,
                  btnColor: Colors.green,
                  borderRadius: 30),
            ),
            const Column(
              children: [
                Text(
                  'Version 2.3',
                  style: TextStyle(color: Color.fromARGB(99, 255, 255, 255)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
