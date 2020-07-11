import 'package:flutter/material.dart';

class LabelText extends StatelessWidget {
  final String text;
  final String size;
  final single;
  LabelText(this.text, {
    this.size,
    this.single = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: size == 'small' ? 6 : 8,
        horizontal: size == 'small' ? 8 : 12
      ),
      margin: EdgeInsets.only(
        right: single ? 0 : 6,
        bottom: single ? 0 : 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(14.0)),
        color: Theme.of(context).primaryColor,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size == 'small' ? 10 : 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}
