import 'package:flutter/material.dart';

class MainText extends StatelessWidget {
  final String text;
  final bool bold;
  final bool multiLine;
  final TextAlign textAlign;
  MainText(this.text, {
    this.bold = false,
    this.multiLine = false,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 24,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        height: multiLine ? 1.5 : 1,
      ),
      textAlign: textAlign,
    );
  }
}
