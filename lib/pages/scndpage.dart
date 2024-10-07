import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/glscontainer.dart';
import '../components/textarea.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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
                  image: AssetImage('assets/bg1.png'), fit: BoxFit.cover)),
          child: SafeArea(
            child: Container(
              width: screen.width,
              height: screen.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign Up',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 43, 155, 47)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  GlassBox(
                    height: 0.5,
                    child: Container(
                      padding: const EdgeInsets.only(left: 45, right: 45),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          RichText(
                            text: const TextSpan(
                              text:
                                  'Looks like you don\'t have an Account.\nLet\'s create one for now and ',
                              style: TextStyle(
                                  color: Colors.white), // General text style
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'join our Community.', // Word 'there'
                                  style: TextStyle(
                                      color: Colors
                                          .greenAccent), // 'there' in blue color
                                ),
                                TextSpan(
                                  text: '.', // Text after 'there'
                                  style: TextStyle(
                                      color:
                                          Colors.black), // General text style
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InputField(
                                  displaytxt: 'Email',
                                  hidetxt: false,
                                  borderRadius: 20),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                  displaytxt: 'Password',
                                  hidetxt: true,
                                  borderRadius: 20),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/todo_scrn');
                            },
                            child: ButnTyp1(
                              text: 'SignUp',
                              size: 20,
                              btnColor: Colors.green,
                              borderRadius: 5,
                            ),
                          ),
                          const Text(
                            'or',
                            style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 15,
                                color: Colors.white),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Do you have an account? ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
