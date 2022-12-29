import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/repositories.dart';

import 'package:cellar/app/widget/atoms/toast.dart';

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
    Status status;
    try {
      status = await StatusRepository().getStatus();
    } catch (e) {
      // statusにSlackのURLを格納しているので、ここで落ちると辛い
      showToast(context, 'メンテナンス中です。', isError: true);
    }

    AlertRepository().slackUrl = Uri.parse(status.slackUrl);
    widget.setStatus(status);
    if (status.isMaintenanceMode) {
      Navigator.pushReplacementNamed(context, '/maintenance');
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = Version.parse(packageInfo.version);
    final requiredVersion = Version.parse(status.requiredVersion);
    if (appVersion.compareTo(requiredVersion).isNegative) {
      Navigator.pushReplacementNamed(context, '/update');
      return;
    }

    User user;
    try {
      user = await _checkSignIn();
    } catch (e, stackTrace) {
      AlertRepository().send(
        'サインイン中のユーザーの取得に失敗しました',
        stackTrace.toString().substring(0, 1000),
      );
    }

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
