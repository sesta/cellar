import 'package:flutter/material.dart';

import 'package:bacchus/repository/provider/auth.dart';

import 'package:bacchus/app/pages/home.dart';
import 'package:bacchus/app/pages/sign_in.dart';
import 'package:bacchus/app/widget/fade_in_route.dart';

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
      Navigator.pushReplacement(
        context,
        FadeInRoute(
          widget: SignInPage(setUser: widget.setUser),
          opaque: true,
        ),
      );

      return ;
    }

    widget.setUser(user);
    Navigator.pushReplacement(
      context,
      FadeInRoute(
        widget: HomePage(),
        opaque: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Text('いい感じのロゴ'),
      )
    );
  }
}

// TODO: 別の場所におく
