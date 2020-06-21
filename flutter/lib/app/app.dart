import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:bacchus/app/pages/splash.dart';
import 'package:bacchus/app/pages/home.dart';
import 'package:bacchus/app/pages/sake.dart';
import 'package:bacchus/app/pages/post.dart';
import 'package:bacchus/app/pages/sign_in.dart';
import 'package:bacchus/domain/entities/user.dart';

class Bacchus extends StatefulWidget {
  Bacchus({Key key}) : super(key: key);

  @override
  _BacchusState createState() => _BacchusState();
}

class _BacchusState extends State<Bacchus> {
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
      title: 'Bacchus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      initialRoute: '/splash',
      routes: <String, WidgetBuilder> {
        '/splash': (BuildContext context) => SplashPage(setUser: _setUser),
        '/home': (BuildContext context) => HomePage(title: 'Home'),
        '/sake': (BuildContext context) => SakePage(),
        '/post': (BuildContext context) => PostPage(user: user),
        '/signIn': (BuildContext context) => SignInPage(setUser: _setUser),
      },
    );
  }
}
