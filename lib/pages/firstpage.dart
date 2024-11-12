import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/button.dart';
import '../components/glscontainer.dart';
import '../components/textarea.dart';
import '../components/tile.dart';
import '../models/sb_auth.dart';
import 'worksheet.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// This is the Codes for the Login page. I have integrated  user
// authentication using email and password. NB: You can only login when online.

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailInput = TextEditingController();
  final TextEditingController _passwordInput = TextEditingController();
  final _auth = SBAuth();

  @override
  void initState() {
    // TODO: implement initState
    _checkLoginStatus();
    super.initState();
  }

  @override
  void dispose() {
    _emailInput.dispose();
    _passwordInput.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _auth.isLoggedIn();
    if (isLoggedIn) {
      // Retrieve the logged-in user's email
      final user = await _auth.getLoggedInUserName();
      final email = await _auth.getLoggedInUserEmail();
      final password = await _auth.getLoggedInUserPassword();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkArea(
            userEmail: email ?? '',
            userPassword: password ?? '',
            userName: user ?? '',
          ), // Pass email
        ),
      );
    } else {
      print('No User Session Found, Log in again.');
    }
  }

  // Login Function that takes the email and password as parameters
  // and runs an authentication call to the online database.
  Future<void> loginAct() async {
    final email = _emailInput.text;
    final password = _passwordInput.text;
    final username = await Supabase.instance.client
        .from('user_credentials')
        .select('user')
        .eq('email', email)
        .single();

    final response = await _auth.login(email, password);
    final catchUser = username['user'];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(response),
        elevation: 30,
        backgroundColor: Colors.green,
      ), // Show response message
    );

    if (response.startsWith("Login successful")) {
      _onLoginSuccess(email, password, catchUser);
    }
  }

  void _onLoginSuccess(String email, String password, catchUser) {
    _emailInput.clear(); // Clear email input
    _passwordInput.clear(); // Clear password input
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkArea(
          userEmail: email,
          userPassword: password,
          userName: catchUser,
        ), // Pass email
      ),
    );
  }

  // UI code block:
  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screen.width,
          height: screen.height,
          decoration:
              //Background Image here:
              const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg1.jpg'),
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
                  height: 0.55,
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
