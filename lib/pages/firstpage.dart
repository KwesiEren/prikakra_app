import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/glscontainer.dart';
import '../components/textarea.dart';
import '../components/tile.dart';
import '../models/sb_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailInput = TextEditingController();
  final TextEditingController _passwordInput = TextEditingController();
  final _auth = SBAuth();

  @override
  void dispose() {
    _emailInput.dispose();
    _passwordInput.dispose();
    super.dispose();
  }

  Future<void> loginAct() async {
    final email = _emailInput.text;
    final password = _passwordInput.text;

    final response = await _auth.login(email, password);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response)), // Show response message
    );

    if (response.startsWith("Login successful")) {
      Navigator.pushNamed(context, '/todo_scrn');
    }
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screen.width,
          height: screen.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg1.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(255, 16, 99, 19),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GlassBox(
                  child: Container(
                    padding: const EdgeInsets.only(left: 45, right: 45),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InputField(
                              displaytxt: 'Email',
                              hidetxt: false,
                              borderRadius: 20,
                              contrlr: _emailInput,
                            ),
                            const SizedBox(height: 20),
                            InputField(
                              displaytxt: 'Password',
                              hidetxt: true,
                              borderRadius: 20,
                              contrlr: _passwordInput,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: loginAct,
                          child: ButnTyp1(
                            text: 'LOGIN',
                            size: 15,
                            btnColor: Colors.green,
                            borderRadius: 5,
                          ),
                        ),
                        const Text(
                          'or',
                          style: TextStyle(
                            fontWeight: FontWeight.w100,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 50, right: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: screen.width * 0.18,
                                  height: screen.height * 0.08,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        228, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.contain,
                                        image: AssetImage('assets/google.png'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: ButnTile(
                                  icnName: 'assets/twitter.png',
                                  margin: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account? ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
