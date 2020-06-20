import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:bacchus/app/pages/home.dart';
import 'package:bacchus/domain/entities/user.dart';
import 'package:bacchus/repository/provider/auth.dart';

class Bacchus extends StatefulWidget {
  Bacchus({Key key}) : super(key: key);

  @override
  _BacchusState createState() => _BacchusState();
}

class _BacchusState extends State<Bacchus> {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  User user;

  @override
  void initState() {
    super.initState();

    signIn().then((user) {
      print(user.toString());
      setState(() {
        this.user = user;
      });
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
      initialRoute: '/',
      routes: <String, WidgetBuilder> {
        '/': (BuildContext context) => HomePage(title: 'Home'),
      },
    );
  }
}

