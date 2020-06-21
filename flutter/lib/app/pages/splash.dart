import 'package:flutter/material.dart';

import 'package:bacchus/app/pages/home.dart';
import 'package:bacchus/repository/provider/auth.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key, this.setUser}) : super(key: key);

  final setUser;

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    _checkSignIn();
  }

  void _checkSignIn() async {
    final user = await getSignInUser();
    if (user == null) {
      Navigator.of(context).pushReplacementNamed('/signIn');

      return ;
    }

    widget.setUser(user);
    Navigator.pushReplacement(
      context,
      SlidePageRoute(
        page: HomePage(title: 'Home'),
        settings: RouteSettings(
          name: '/second',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('スプラッシュ'),
                ]
            )
        )
    );
  }
}

// TODO: いい感じのトランジションを研究する
class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final RouteSettings settings;

  SlidePageRoute({this.page, this.settings}) : super(
    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      return page;
    },
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget page,
    ) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0),
          end: Offset.zero,
        ).animate(animation),
        child: page,
      );
    },
  );
}
