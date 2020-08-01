import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:cellar/domain/entities/user.dart';

import 'package:cellar/app/widget/atoms/normal_text.dart';
import 'package:cellar/app/widget/atoms/normal_text_field.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({
    Key key,
    this.userId,
    this.setUser,
  }) : super(key: key);

  final String userId;
  final setUser;

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  bool _loading = false;

  _createUser(String userName) async {
    if (userName == '') {
      return;
    }

    setState(() {
      _loading = true;
    });

    final user = User(widget.userId, userName);
    await user.create();
    await widget.setUser(user);
    Navigator.of(context).pop();
    // ユーザー情報を渡し直すためreplace
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新規登録'),
        elevation: 0,
        leading:  IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: UserForm(createUser: _createUser),
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
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          NormalText('ニックネーム'),
          NormalTextField(
            _nameController,
            onChanged: (_) => setState(() {}),
            bold: true,
          ),
          Padding(padding: EdgeInsets.only(bottom: 32)),

          SizedBox(
            width: double.infinity,
            child: RaisedButton(
              padding: EdgeInsets.all(12),
              onPressed: _nameController.text == ''
                ? null
                : () => widget.createUser(_nameController.text),
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
