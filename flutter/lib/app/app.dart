import 'package:flutter/material.dart';

import 'package:cellar/domain/entities/status.dart';
import 'package:cellar/domain/entities/user.dart';
import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/repository/analytics_repository.dart';

import 'package:cellar/app/pages/splash.dart';
import 'package:cellar/app/pages/home.dart';
import 'package:cellar/app/pages/drink.dart';
import 'package:cellar/app/pages/post.dart';
import 'package:cellar/app/pages/edit.dart';
import 'package:cellar/app/pages/sign_up.dart';
import 'package:cellar/app/pages/setting.dart';

import 'package:cellar/app/widget/transitions/fade_in_route.dart';
import 'package:cellar/app/widget/transitions/slide_up_route.dart';

class Cellar extends StatefulWidget {
  Cellar({Key key}) : super(key: key);

  @override
  _CellarState createState() => _CellarState();
}

class _CellarState extends State<Cellar> {
  Status _status;
  User _user;

  _setStatus(Status status) {
    setState(() {
      _status = status;
    });
  }

  _setUser(User user) {
    setState(() {
      _user = user;
    });

    AnalyticsRepository().setUser(user.userId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cellar',
      theme: ThemeData.dark().copyWith(
        accentColor: Colors.blueGrey,
      ),
      color: Theme.of(context).accentColor,
      navigatorObservers: [
        AnalyticsRepository().observer,
      ],
      onGenerateRoute: (settings) {
        switch(settings.name) {
          case '/home':
            return fadeInRoute(
              'home',
              HomePage(status: _status, user: _user, setUser: _setUser),
            );

          case '/signUp':
            final String userId = settings.arguments;
            return fadeInRoute(
              'signUp',
              SignUpPage(userId: userId, setUser: _setUser),
            );

          case '/drink':
            final Drink drink = settings.arguments;
            return slideUpRoute(
              'drink',
              DrinkPage(user: _user, drink: drink),
            );

          case '/post':
            return slideUpRoute(
              'post',
              PostPage(status: _status, user: _user),
            );

          case '/edit':
            final Drink drink = settings.arguments;
            return slideUpRoute(
              'edit',
              EditPage(status: _status, user: _user, drink: drink),
            );

          case '/setting':
            return slideUpRoute(
              'setting',
              SettingPage(user: _user),
            );
        }

        return MaterialPageRoute(builder: (context) => SplashPage(setStatus: _setStatus, setUser: _setUser));
      },
    );
  }
}
