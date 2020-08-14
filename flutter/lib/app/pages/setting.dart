import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/repositories.dart';

import 'package:cellar/app/widget/atoms/text_input.dart';

class SettingPage extends StatefulWidget {
  SettingPage({
    Key key,
    @required this.user,
    @required this.setUser,
  }) : super(key: key);

  final User user;
  final setUser;

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<SettingPage> {
  bool _loading = false;
  final _nameController = TextEditingController();

  @override
  initState() {
    super.initState();

    _nameController.text = widget.user.userName;
  }

  _saveUser() async {
    if (disableSave) {
      return;
    }

    setState(() {
      _loading = true;
    });

    widget.user.userName = _nameController.text;
    await widget.user.updateName();

    AnalyticsRepository().sendEvent(EventType.EditUserName, {});
    Navigator.of(context).pop();
  }

  get disableSave {
    return _nameController.text == '';
  }

  Future<void> _confirmSignOut() async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            title: Text(
              "ログアウトしてよろしいですか？",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            actions: <Widget>[
              // ボタン領域
              FlatButton(
                child: Text(
                  'やめる',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text(
                  'ログアウトする',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _signOut();
                },
              ),
            ],
          ),
    );
  }

  Future<void> _signOut() async {
    setState(() {
      _loading = true;
    });
    await AuthRepository().signOut();
    widget.setUser(null);
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('設定'),
        elevation: 0,
        leading:  IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 36)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 24)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'ニックネーム',
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                          TextInput(
                            _nameController,
                            onChanged: (_) => setState(() {}),
                            textStyle: Theme.of(context).textTheme.subtitle1,
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(right: 24)),

                    RaisedButton(
                      padding: EdgeInsets.all(12),
                      onPressed: disableSave ? null : _saveUser,
                      child: Text(
                        '更新',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      color: Theme.of(context).accentColor,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(right: 24)),
                  ],
                ),
                Padding(padding: EdgeInsets.only(bottom: 64)),

                FlatButton(
                  child: Text(
                    'プライバシーポリシー',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  onPressed: () => launch('https://cellar.sesta.dev/policy'),
                ),
                Padding(padding: EdgeInsets.only(bottom: 16)),

                FlatButton(
                  child: Text(
                    '問い合わせ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  onPressed: () => launch('https://docs.google.com/forms/d/e/1FAIpQLSeKVQjfLEyIV-EI0wWmDK0iHk_R3E0ARu5a0nH1WgBsMrrJmw/viewform?usp=sf_link'),
                ),
                Padding(padding: EdgeInsets.only(bottom: 16)),

                FlatButton(
                  child: Text(
                    'ログアウト',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  onPressed: _confirmSignOut,
                ),
              ],
            ),
          ),
          _loading ? Container(
            color: Colors.black38,
            alignment: Alignment.center,
            child: Lottie.asset(
              'assets/lottie/loading.json',
              width: 80,
              height: 80,
            ),
          ) : Container(),
        ],
      )
    );
  }
}
