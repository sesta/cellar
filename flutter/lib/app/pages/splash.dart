import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/repositories.dart';

class SplashPage extends StatefulWidget {
  SplashPage({
    Key key,
    @required this.setStatus,
    @required this.setUser,
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
    await Firebase.initializeApp();
    Status status = await StatusRepository().getStatus();
    AlertRepository().slackUrl = status.slackUrl;
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
      await AuthRepository().signInNoLoginUser();
      return null;
    }

    var user;
    try {
      user = await UserRepository().getUser(userId);
    } catch (e) {
      // SharedPreferencesに保存されているユーザーIDで認証していない時を考慮
      await AuthRepository().signOut();
    }
    if (user == null) {
      return null;
    }

    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Image.asset(
          'assets/images/icon.png',
          width: 124,
        ),
      )
    );
  }
}
