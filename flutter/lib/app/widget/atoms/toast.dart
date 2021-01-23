import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(
  BuildContext context,
  String message,
  {
    isError: false,
  }
) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: isError ? ToastGravity.CENTER : ToastGravity.TOP,
    backgroundColor: isError ? Colors.redAccent : Theme.of(context).primaryColor,
  );
}
