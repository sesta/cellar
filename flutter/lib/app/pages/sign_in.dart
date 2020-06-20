import 'package:flutter/material.dart';

import 'package:bacchus/repository/provider/auth.dart';
import 'package:bacchus/domain/entities/user.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.setUser}) : super(key: key);

  final setUser;

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignInPage> {
  void _checkSignIn() async {
    final firebaseUser = await signIn();
    final user = User(firebaseUser.uid, firebaseUser.displayName);

    widget.setUser(user);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ログイン'),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    onPressed: _checkSignIn,
                    child: Text('Googleでログイン'),
                  ),
                ]
            )
        )
    );
  }
}
