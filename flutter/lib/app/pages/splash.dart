import 'package:bacchus/app/pages/sign_in.dart';
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
      Navigator.pushReplacement(
        context,
        FadeInRoute(
          widget: SignInPage(),
          opaque: true,
        ),
      );

      return ;
    }

    widget.setUser(user);
    Navigator.pushReplacement(
      context,
      FadeInRoute(
        widget: HomePage(title: 'Home'),
        opaque: true,
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

// TODO: 別の場所におく
// 参考: https://github.com/kitoko552/flutter_image_viewer_sample/blob/master/lib/fade_in_route.dart
class FadeInRoute extends PageRouteBuilder {
  FadeInRoute({
    @required this.widget,
    this.opaque = true,
    this.onTransitionCompleted,
    this.onTransitionDismissed,
  }) : super(
    opaque: opaque,
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) {
      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed &&
            onTransitionCompleted != null) {
          onTransitionCompleted();
        } else if (status == AnimationStatus.dismissed &&
            onTransitionDismissed != null) {
          onTransitionDismissed();
        }
      });

      return widget;
    },
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );

  final Widget widget;
  final bool opaque;
  final Function onTransitionCompleted;
  final Function onTransitionDismissed;
}
