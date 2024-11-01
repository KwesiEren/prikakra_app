// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  InputField(
      {required this.displaytxt,
      required this.hidetxt,
      required this.borderRadius,
      this.borderColor,
      super.key});

  String displaytxt;
  double borderRadius;
  Color? borderColor;
  bool hidetxt;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  final _contrlr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: widget.hidetxt,
      controller: _contrlr,
      decoration: InputDecoration(
        hintText: widget.displaytxt,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.borderColor ?? Colors.white),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
