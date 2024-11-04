import 'package:flutter/material.dart';

import '../components/button.dart';

//Welcome Screen, just that lol.

class WelcomeScrn extends StatelessWidget {
  const WelcomeScrn({super.key});

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
                Navigator.pushNamed(context, '/login');
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
                  'Version 2.1',
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
