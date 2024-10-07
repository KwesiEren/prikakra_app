// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

class toDolist extends StatelessWidget {
  const toDolist({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    //required this.deleteFunction,
  });

  final String taskName;
  final bool taskCompleted;
  final Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 0,
        right: 0,
        bottom: 20,
      ),
      child: GestureDetector(
        child: Row(
          children: [
            Checkbox(
              value: taskCompleted,
              onChanged: onChanged,
              side: const BorderSide(color: Colors.black),
            ),
            Text(
              taskName,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  decoration: taskCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationThickness: 3,
                  decorationColor: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
