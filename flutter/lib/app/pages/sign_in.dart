import 'package:cellar/app/widget/atoms/main_text.dart';
import 'package:cellar/app/widget/atoms/normal_text.dart';
import 'package:cellar/app/widget/atoms/normal_text_field.dart';
import 'package:flutter/material.dart';

import 'package:cellar/repository/provider/auth.dart';
import 'package:cellar/domain/entities/user.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.setUser}) : super(key: key);

  final setUser;

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignInPage> {
  String userId;

  void _checkSignIn() async {
    final firebaseUser = await signIn();
    if (firebaseUser == null) {
      print('SignInに失敗しました');
      return;
    }

    final user = await getSignInUser();
    if (user != null) {
      widget.setUser(user);
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }

    setState(() {
      this.userId = firebaseUser.uid;
    });
  }

  void _createUser(String userName) async {
    if (userId == null || userName == '') {
      return;
    }

    final user = User(userId, userName);
    await user.save();
    widget.setUser(user);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userId == null ? 'ログイン' : '新規登録'),
      ),
      body: Center(
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
            bold: true,
          ),
          Padding(padding: EdgeInsets.only(bottom: 48)),

          Center(
            child: RaisedButton(
              onPressed: () => widget.createUser(nameController.text),
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
