import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserVent extends StatefulWidget {
  const UserVent({super.key});

  @override
  State<UserVent> createState() => _UserVentState();
}

class _UserVentState extends State<UserVent> {
  List users = [];
  Future<void> readJson() async {
    final String resp = await rootBundle.loadString('assets/credentials.json');
    final data = await json.decode(resp);

    setState(() {
      users = data["User_info"];
      print(users);
    });
  }

  var email = "stupid@gmail.com";
  var Password;

  void updateUser(String email, String newPassword) {
    setState(() {
      // Find the index of the user with the given email
      int index = users.indexWhere((user) => user["email"] == email);

      // If the user is found, update the password
      if (index != -1) {
        users[index]["password"] = newPassword;
        print("User password updated: ${users[index]}");
      } else {
        print("User with email $email not found");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
          onPressed: () {
            readJson();
          },
          child: Center(
            child: Text("Load Data"),
          )),
    );
  }
}
