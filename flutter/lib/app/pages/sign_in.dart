import 'package:flutter/material.dart';

import 'package:cellar/domain/entities/user.dart';
import 'package:cellar/repository/user_repository.dart';
import 'package:cellar/repository/provider/auth.dart';

import 'package:cellar/app/widget/atoms/normal_text.dart';
import 'package:cellar/app/widget/atoms/normal_text_field.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.setUser}) : super(key: key);

  final setUser;

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignInPage> {
  String userId;
  bool loading = false;

  _checkSignIn() async {
    setState(() {
      this.loading = true;
    });

    final firebaseUser = await signIn();
    if (firebaseUser == null) {
      print('SignInに失敗しました');
      setState(() {
        this.loading = false;
      });
      return;
    }

    final userId = await getSignInUserId();
    final user = await UserRepository().getUser(userId);
    if (user != null) {
      widget.setUser(user);
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }

    setState(() {
      this.userId = firebaseUser.uid;
      this.loading = false;
    });
  }

  _createUser(String userName) async {
    if (userId == null || userName == '') {
      return;
    }

    setState(() {
      this.loading = true;
    });

    final user = User(userId, userName);
    await user.create();
    widget.setUser(user);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userId == null ? 'ログイン' : '新規登録'),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: userId == null ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                NormalText(
                  'Cellarの利用には\nアカウント認証が必要です。',
                  multiLine: true,
                ),
                Padding(padding: EdgeInsets.only(bottom: 32)),
                RaisedButton(
                  onPressed: _checkSignIn,
                  child: Text(
                    'Googleで認証する',
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
              ]
            ) : UserForm(createUser: _createUser),
          ),
          loading ? Container(
            color: Colors.black38,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ) : Container(),
        ],
      )
    );
  }
}

class UserForm extends StatefulWidget {
  UserForm({
    Key key,
    this.createUser
  }) : super(key: key);

  final createUser;

  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          NormalText('ニックネーム'),
          NormalTextField(
            nameController,
            onChanged: (_) => setState(() {}),
            bold: true,
          ),
          Padding(padding: EdgeInsets.only(bottom: 48)),

          Center(
            child: RaisedButton(
              onPressed: nameController.text == ''
                ? null
                : () => widget.createUser(nameController.text),
              child: Text(
                '登録を完了する',
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
          ),
        ],
      ),
    );
  }
}
