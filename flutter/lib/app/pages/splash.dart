import 'package:flutter/material.dart';

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
    final user = await signIn();
    if (user == null) {
      Navigator.of(context).pushReplacementNamed('/signIn');

      return ;
    }

    widget.setUser(user);
    Navigator.of(context).pushReplacementNamed('/home');
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
