import 'dart:async';

import 'package:flutter/material.dart';

//Welcome Screen, just that lol.

class WelcomeScrn extends StatefulWidget {
  const WelcomeScrn({super.key});

  @override
  State<WelcomeScrn> createState() => _WelcomeScrnState();
}

class _WelcomeScrnState extends State<WelcomeScrn> {
  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      _runPeriodicFunction();
      timer.cancel();
    });
    super.initState();
  }

  void _runPeriodicFunction() async {
    // Place your logic here
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => WorkArea(
    //       userEmail: '',
    //       userPassword: '',
    //       userName: '',
    //     ), // Pass email
    //   ),
    // );
    Navigator.pushReplacementNamed(context, '/guest');
    debugPrint('Splash Screen');
  }
  /*Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _auth.isLoggedIn();
    if (isLoggedIn) {
      // Retrieve the logged-in user's email
      final email = await _auth.getLoggedInUserEmail();
      final password = await _auth.getLoggedInUserPassword();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkArea(userEmail: email ?? '', userPassword: password??'',), // Pass email
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: screen.width,
        decoration:
            //Background Image here:
            const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/bg1.jpg'),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              height: 30,
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
