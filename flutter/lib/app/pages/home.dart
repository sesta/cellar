import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/repositories.dart';

import 'package:cellar/app/widget/mine_timeline.dart';
import 'package:cellar/app/widget/all_timeline.dart';
import 'package:cellar/app/widget/summary.dart';
import 'package:cellar/app/widget/setting.dart';
import 'package:cellar/app/widget/atoms/toast.dart';

enum BottomSelectType {
  TimelineMine,
  TimelineAll,
  Summary,
  Setting
}

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
    @required this.user,
    @required this.status,
    @required this.setUser,
  }) : super(key: key);

  final User user;
  final Status status;
  final setUser;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BottomSelectType _bottomSelectType = BottomSelectType.TimelineMine;

  bool _loadingSignIn = false;
  bool _enableAppleSignIn = false;

  @override
  initState() {
    super.initState();

    AuthRepository().enableAppleSignIn.then((enable) => setState(() {
      _enableAppleSignIn = enable;
    }));
  }

  _updateBottomSelectType(BottomSelectType bottomSelectType) {
    if (_bottomSelectType == bottomSelectType) {
      return;
    }

    setState(() {
      _bottomSelectType = bottomSelectType;
    });

    AnalyticsRepository().sendEvent(
      EventType.ChangeTimelineType,
      {
        'timelineType': bottomSelectType.toString(),
      },
    );
  }

  Future<void> _signIn(AuthType authType) async {
    setState(() {
      this._loadingSignIn = true;
    });
    var userId;
    try {
      userId = await AuthRepository().signIn(authType);
    } catch (e, stackTrace) {
      showToast(context, 'サインインに失敗しました。', isError: true);
      AlertRepository().send(
        'SignInに失敗しました',
        stackTrace.toString().substring(0, 1000),
      );
    }

    if (userId == null) {
      setState(() {
        this._loadingSignIn = false;
      });
      return;
    }

    User user;
    try {
      user = await UserRepository().getUser(userId);
    } catch (e, stackTrace) {
      AlertRepository().send(
        'ユーザーの情報の取得に失敗しました',
        stackTrace.toString().substring(0, 1000),
      );
    }
    setState(() {
      this._loadingSignIn = false;
    });

    if (user != null) {
      widget.setUser(user);
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }

    Navigator.of(context).pushNamed('/signUp', arguments: userId);
  }

  Future<void> _movePostPage() async {
    final isPosted = await Navigator.of(context).pushNamed('/post');
    if (isPosted == null) {
      return;
    }

    Navigator.of(context).pushReplacementNamed('/home');
  }

  Widget get _content {
    switch (_bottomSelectType) {
      case BottomSelectType.TimelineMine:
        return widget.user == null
          ? _signInContainer()
          : MineTimeline(user: widget.user);
      case BottomSelectType.TimelineAll:
        return AllTimeline(
          user: widget.user,
          status: widget.status,
        );
      case BottomSelectType.Summary:
        return Summary(
          user: widget.user,
        );
      case BottomSelectType.Setting:
        return Setting(
          user: widget.user,
          setUser: widget.setUser,
        );
    }

    throw '考慮していないTypeです。 $_bottomSelectType';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> primaryAnimation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            child: child,
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
          );
        },
        child: _content,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).backgroundColor,
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {
                    if (_bottomSelectType == BottomSelectType.TimelineMine) {
                      return;
                    }

                    _updateBottomSelectType(BottomSelectType.TimelineMine);
                  },
                  icon: Icon(
                    Icons.home,
                    size: 30,
                    color: _bottomSelectType == BottomSelectType.TimelineMine
                      ? Colors.white
                      : Theme.of(context).disabledColor,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {
                    if (_bottomSelectType == BottomSelectType.TimelineAll) {
                      return;
                    }

                    _updateBottomSelectType(BottomSelectType.TimelineAll);
                  },
                  icon: Icon(
                    Icons.people,
                    size: 32,
                    color: _bottomSelectType == BottomSelectType.TimelineAll
                      ? Colors.white
                      : Theme.of(context).disabledColor,
                  ),
                ),
              ),
              Container(
                width: 88,
                height: 40,
              ),
              Expanded(
                flex: 1,
                child: widget.user == null
                    ? Container(height: 0)
                    : IconButton(
                  onPressed: () {
                    if (_bottomSelectType == BottomSelectType.Summary) {
                      return;
                    }

                    _updateBottomSelectType(BottomSelectType.Summary);
                  },
                  icon: Icon(
                    Icons.equalizer,
                    size: 32,
                    color: _bottomSelectType == BottomSelectType.Summary
                        ? Colors.white
                        : Theme.of(context).disabledColor,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: widget.user == null
                  ? Container(height: 0)
                  : IconButton(
                    onPressed: () {
                      if (_bottomSelectType == BottomSelectType.Setting) {
                        return;
                      }

                      _updateBottomSelectType(BottomSelectType.Setting);
                    },
                    icon: Icon(
                      Icons.settings,
                      size: 28,
                      color: _bottomSelectType == BottomSelectType.Setting
                          ? Colors.white
                          : Theme.of(context).disabledColor,
                    ),
                  ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.user == null ? null : _movePostPage,
        child: Opacity(
          opacity: widget.user == null ? 0.4 : 1,
          child: Image.asset(
            'assets/images/upload-icon.png',
            width: 48,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
    );
  }

  Widget _signInContainer() =>
    Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'お酒を投稿するには\nアカウント認証が必要です。',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              Padding(padding: EdgeInsets.only(bottom: 32)),

              _enableAppleSignIn
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      width: 250,
                      height: 40,
                      child: RaisedButton(
                        onPressed: () => _signIn(AuthType.Apple),
                        child: Row(
                          children: [
                            Padding(padding: EdgeInsets.only(left: 4)),
                            Image.asset(
                              'assets/images/apple-logo.png',
                              width: 18,
                            ),
                            Padding(padding: EdgeInsets.only(right: 24)),
                            Text(
                              'Sign in with Apple',
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        color: Colors.white,
                        textColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  )
                : Container(height: 0),

              Container(
                width: 250,
                height: 40,
                child: RaisedButton(
                  onPressed: () => _signIn(AuthType.Google),
                  child: Row(
                    children: [
                      Padding(padding: EdgeInsets.only(left: 4)),
                      Image.asset(
                        'assets/images/google-logo.png',
                        width: 18,
                      ),
                      Padding(padding: EdgeInsets.only(right: 24)),
                      Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  color: Colors.white,
                  textColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: 32)),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '※',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Padding(padding: EdgeInsets.only(right: 4)),
                  Text(
                    'プライバシーポリシーに\n同意の上認証をしてください。',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(bottom: 8)),

              FlatButton(
                child: Text(
                  'プライバシーポリシーを見る',
                  style: Theme.of(context).textTheme.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
                onPressed: () => launch('https://cellar.sesta.dev/policy'),
              ),
              Padding(padding: EdgeInsets.only(bottom: 80)),
            ]
          ),
          _loadingSignIn ? Container(
            padding: EdgeInsets.only(bottom: 80),
            color: Colors.black38,
            alignment: Alignment.center,
            child: Lottie.asset(
              'assets/lottie/loading.json',
              width: 80,
              height: 80,
            )
          ) : Container(),
        ],
      ),
    );
}
