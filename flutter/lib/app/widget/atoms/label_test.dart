import 'package:flutter/material.dart';

class LabelText extends StatelessWidget {
  final String text;
  LabelText(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: EdgeInsets.only(
        right: 6,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(14.0)),
        color: Colors.black38,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}
