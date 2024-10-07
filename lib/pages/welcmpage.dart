// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../components/button.dart';

class WelcomeScrn extends StatelessWidget {
  const WelcomeScrn({super.key});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: w,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: Image.asset(
              'assets/bg01.png',
            ).image,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 30,
            ),
            CircleAvatar(
              backgroundImage:
                  AssetImage('assets/photo_2024-07-16_13-43-01.jpg'),
              radius: 80,
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                Navigator.pushNamed(context, '/second');
              },
              child: ButnTyp1(
                  text: 'Next',
                  size: 30,
                  btnColor: Colors.white,
                  borderRadius: 30),
            ),
            Column(
              children: [Text('V1.1')],
            ),
          ],
        ),
      ),
    );
  }
}
