import 'package:flutter/material.dart';

import 'package:cellar/domain/entities/status.dart';
import 'package:cellar/domain/entities/user.dart';
import 'package:cellar/repository/status_repository.dart';
import 'package:cellar/repository/user_repository.dart';
import 'package:cellar/repository/auth_repository.dart';

class SplashPage extends StatefulWidget {
  SplashPage({
    Key key,
    this.setStatus,
    this.setUser,
  }) : super(key: key);

  final setStatus;
  final setUser;

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // TODO: 処理をapp.dartに寄せてstatelessにできないか考える
  @override
  initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    Status status = await StatusRepository().getStatus();
    widget.setStatus(status);
    if (status.isMaintenance) {
      Navigator.pushReplacementNamed(context, '/maintenance');
      return;
    }

    User user = await _checkSignIn();
    if (user != null) {
      widget.setUser(user);
    }

    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<User> _checkSignIn() async {
    final userId = await AuthRepository().getSignInUserId();
    if (userId == null) {
      return null;
    }

    final user = await UserRepository().getUser(userId);
    if (user == null) {
      return null;
    }

    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: Center(
        child: Image.asset(
          'assets/images/icon.png',
          width: 124,
        ),
      )
    );
  }
}
