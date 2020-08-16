import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputType {
  String,
  Number,
}

class TextInput extends StatelessWidget {
  final TextEditingController controller;
  final TextStyle textStyle;
  final int maxLines;
  final InputType inputType;
  final onChanged;
  final String placeholder;

  TextInput(this.controller, {
    this.textStyle,
    this.maxLines = 1,
    this.inputType = InputType.String,
    this.onChanged,
    this.placeholder = '',
  });

  @override
  Widget build(BuildContext context) {
    TextInputType keyboardType = TextInputType.text;
    if (inputType == InputType.Number) {
      keyboardType = TextInputType.number;
    }
    if (maxLines > 1) {
      keyboardType = TextInputType.multiline;
    }

    return TextField(
      controller: controller,
      onChanged: onChanged,
      cursorColor: Theme.of(context).primaryColorLight,
      style: textStyle,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputType == InputType.Number
        ? <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly
          ]
        : <TextInputFormatter>[],
      decoration: InputDecoration(
        hintText: placeholder,
      ),
    );
  }
}
