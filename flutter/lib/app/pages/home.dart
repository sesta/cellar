import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/domain/models/timeline.dart';
import 'package:cellar/repository/repositories.dart';

import 'package:cellar/app/widget/mine_timeline.dart';
import 'package:cellar/app/widget/all_timeline.dart';

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
  TimelineType _timelineType = TimelineType.Mine;

  bool _loadingSignIn = false;
  bool _enableAppleSignIn = false;

  @override
  initState() {
    super.initState();

    AuthRepository().enableAppleSignIn.then((enable) => setState(() {
      _enableAppleSignIn = enable;
    }));
  }

  _updateTimelineType(TimelineType timelineType) {
    if (_timelineType == timelineType) {
      return;
    }

    setState(() {
      _timelineType = timelineType;
    });

    AnalyticsRepository().sendEvent(
      EventType.ChangeTimelineType,
      {
        'timelineType': timelineType.toString(),
      },
    );
  }

  Future<void> _signIn(AuthType authType) async {
    final userId = await AuthRepository().signIn(authType);
    if (userId == null) {
      print('SignInに失敗しました');

      setState(() {
        this._loadingSignIn = false;
      });
      return;
    }

    final user = await UserRepository().getUser(userId);
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

    // TODO: 自分のTimelineを表示するようにする
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget = AllTimeline(
      user: widget.user,
      status: widget.status,
    );
    if (_timelineType == TimelineType.Mine) {
      bodyWidget = widget.user == null
        ? _signInContainer()
        : MineTimeline(user: widget.user);
    }

    return Scaffold(
      body: bodyWidget,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {
                    if (_timelineType == TimelineType.Mine) {
                      return;
                    }

                    _updateTimelineType(TimelineType.Mine);
                  },
                  icon: Icon(
                    Icons.home,
                    size: 30,
                    color: _timelineType == TimelineType.Mine
                      ? Colors.white
                      : Theme.of(context).primaryColorLight,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {
                    if (_timelineType == TimelineType.All) {
                      return;
                    }

                    _updateTimelineType(TimelineType.All);
                  },
                  icon: Icon(
                    Icons.people,
                    size: 32,
                    color: _timelineType == TimelineType.All
                      ? Colors.white
                      : Theme.of(context).primaryColorLight,
                  ),
                ),
              ),
              Container(
                width: 88,
                height: 40,
              ),
              Expanded(
                flex: 1,
                child: Container(height: 0),
              ),
              Expanded(
                flex: 1,
                child: widget.user == null
                  ? Container(height: 0)
                  : IconButton(
                    onPressed: () => Navigator.of(context).pushNamed('/setting'),
                    icon: Icon(
                      Icons.settings,
                      size: 28,
                      color: Theme.of(context).primaryColorLight,
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
    );
  }

  Widget _signInContainer() =>
    Stack(
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
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AppleSignInButton(
                      onPressed: () => _signIn(AuthType.Apple),
                      style: AppleButtonStyle.white,
                    ),
                )
              : Container(height: 0),
            GoogleSignInButton(
              onPressed: () => _signIn(AuthType.Google),
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

            FlatButton(
              child: Text(
                'プライバシーポリシー',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
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
    );
}
