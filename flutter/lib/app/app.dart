import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:bacchus/app/pages/splash.dart';
import 'package:bacchus/app/pages/home.dart';
import 'package:bacchus/app/pages/drink.dart';
import 'package:bacchus/app/pages/post.dart';
import 'package:bacchus/app/pages/sign_in.dart';

import 'package:bacchus/domain/entities/user.dart';
import 'package:bacchus/domain/entities/drink.dart';

import 'package:bacchus/app/widget/fade_in_route.dart';
import 'package:bacchus/app/widget/slide_up_route.dart';


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
        primarySwatch: Colors.blueGrey,
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return FadeInRoute(
            widget: HomePage(),
            opaque: true,
          );
        }
        if (settings.name == '/signIn') {
          return FadeInRoute(
            widget: SignInPage(setUser: _setUser),
            opaque: true,
          );
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
