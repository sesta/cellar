import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/repositories.dart';

import 'package:cellar/app/pages/splash.dart';
import 'package:cellar/app/pages/home.dart';
import 'package:cellar/app/pages/drink.dart';
import 'package:cellar/app/pages/post.dart';
import 'package:cellar/app/pages/edit.dart';
import 'package:cellar/app/pages/sign_up.dart';
import 'package:cellar/app/pages/setting.dart';
import 'package:cellar/app/pages/maintenance.dart';

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

    if (user != null) {
      AnalyticsRepository().setUser(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cellar',
      theme: _cellarThemeData,
      navigatorObservers: [
        AnalyticsRepository().observer,
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("ja"),
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
              SettingPage(user: _user, setUser: _setUser),
            );

          case '/maintenance':
            return fadeInRoute(
              'maintenance',
              MaintenancePage(status: _status),
            );
        }

        return MaterialPageRoute(builder: (context) => SplashPage(setStatus: _setStatus, setUser: _setUser));
      },
    );
  }
}

ThemeData get _cellarThemeData => ThemeData.dark().copyWith(
  primaryColor: Colors.blueGrey,
  primaryColorLight: Colors.blueGrey[200],
  primaryColorDark: Colors.blueGrey[700],
  scaffoldBackgroundColor: Colors.black,
  backgroundColor: Colors.grey[900],
  disabledColor: Colors.grey[500],
  textTheme: TextTheme(
    headline2: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.5,
    ),
    subtitle1: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      height: 1,
    ),
    subtitle2: TextStyle(
      fontSize: 14,
      height: 1,
    ),
    bodyText1: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      height: 1.5,
    ),
    bodyText2: TextStyle(
      fontSize: 14,
      height: 1.5,
    ),
    caption: TextStyle(
      fontSize: 12,
      height: 1.5,
    ),
  ),
  applyElevationOverlayColor: true, // ダークモードだとfalseになるようなので指定
);
