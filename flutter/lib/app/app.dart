import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:cellar/app/pages/splash.dart';
import 'package:cellar/app/pages/home.dart';
import 'package:cellar/app/pages/drink.dart';
import 'package:cellar/app/pages/post.dart';
import 'package:cellar/app/pages/sign_in.dart';

import 'package:cellar/domain/entities/user.dart';
import 'package:cellar/domain/entities/drink.dart';

import 'package:cellar/app/widget/transitions/fade_in_route.dart';
import 'package:cellar/app/widget/transitions/slide_up_route.dart';


class Cellar extends StatefulWidget {
  Cellar({Key key}) : super(key: key);

  @override
  _CellarState createState() => _CellarState();
}

class _CellarState extends State<Cellar> {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  User user;

  void _setUser(User user) {
    setState(() {
      this.user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cellar',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return fadeInRoute(HomePage(user: user));
        }
        if (settings.name == '/signIn') {
          return fadeInRoute(SignInPage(setUser: _setUser));
        }
        if (settings.name == '/drink') {
          final Drink drink = settings.arguments;
          return slideUpRoute(DrinkPage(drink: drink));
        }
        if (settings.name == '/post') {
          return slideUpRoute(PostPage(user: user));
        }

        return MaterialPageRoute(builder: (context) => SplashPage(setUser: _setUser));
      },
    );
  }
}
