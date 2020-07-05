import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputType {
  String,
  Number,
}

class NormalTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool bold;
  final int maxLines;
  final InputType inputType;

  NormalTextField(this.controller, {
    this.bold = false,
    this.maxLines = 1,
    this.inputType = InputType.String,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 14,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        height: maxLines == 1 ? 1 : 1.5,
      ),
      maxLines: maxLines,
      keyboardType: inputType == InputType.Number
        ? TextInputType.number
        : TextInputType.text,
      inputFormatters: inputType == InputType.Number
          ? <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ]
          : <TextInputFormatter>[],
    );
  }
}
