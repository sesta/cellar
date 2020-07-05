import 'package:flutter/material.dart';

import 'package:bacchus/repository/provider/auth.dart';
import 'package:bacchus/domain/entities/user.dart';

import 'package:bacchus/app/pages/home.dart';
import 'package:bacchus/app/widget/transitions/fade_in_route.dart';

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
    await user.addStore();
    widget.setUser(user);
    Navigator.pushReplacement(
      context,
      FadeInRoute(
        widget: HomePage(),
        opaque: true,
      ),
    );
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
            Text('Bacchusの利用には\nGoogleのログインが必要です。', textAlign: TextAlign.center),
            RaisedButton(
              onPressed: _checkSignIn,
              child: Text('Googleでログイン'),
              color: Theme.of(context).primaryColorDark,
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
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'ユーザー名',
            ),
          ),
          RaisedButton(
            onPressed: () => widget.createUser(nameController.text),
            child: Text('Googleでログイン'),
            color: Theme.of(context).primaryColorDark,
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
