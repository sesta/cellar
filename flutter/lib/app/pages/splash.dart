import 'package:flutter/material.dart';

import 'package:cellar/repository/provider/auth.dart';

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
      Navigator.pushReplacementNamed(context, '/signIn');

      return ;
    }

    widget.setUser(user);
    Navigator.pushReplacementNamed(context, '/home');
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
