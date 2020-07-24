import 'package:flutter/material.dart';

Route fadeInRoute(String pageName, Widget page) {
  return PageRouteBuilder(
    settings: RouteSettings(name: pageName),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
