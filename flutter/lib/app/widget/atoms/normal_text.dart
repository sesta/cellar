import 'package:flutter/material.dart';

class NormalText extends StatelessWidget {
  final String text;
  final bool bold;
  final bool multiLine;
  NormalText(this.text, {
    this.bold = false,
    this.multiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        height: multiLine ? 1.5 : 1,
      ),
    );
  }
}
