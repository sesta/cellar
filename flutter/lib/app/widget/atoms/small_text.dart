import 'package:flutter/material.dart';

class SmallText extends StatelessWidget {
  final String text;
  final bool bold;
  final bool multiLine;
  SmallText(this.text, {
    this.bold = false,
    this.multiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        height: multiLine ? 1.5 : 1,
      ),
    );
  }
}
