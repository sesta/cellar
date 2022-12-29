import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/repositories.dart';

import 'package:cellar/app/widget/atoms/text_input.dart';
import 'package:cellar/app/widget/atoms/toast.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({
    Key key,
    @required this.userId,
    @required this.setUser,
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

    try {
      await user.create();
    } catch (e, stackTrace) {
      showToast(context, 'ユーザーの登録に失敗しました', isError: true);
      AlertRepository().send(
        'ユーザーの作成に失敗しました',
        stackTrace.toString().substring(0, 1000),
      );

      setState(() {
        _loading = false;
      });
      return;
    }

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
          Text(
            'ニックネーム',
            style: Theme.of(context).textTheme.subtitle2,
          ),
          TextInput(
            _nameController,
            onChanged: (_) => setState(() {}),
            textStyle: Theme.of(context).textTheme.subtitle1,
          ),
          Padding(padding: EdgeInsets.only(bottom: 32)),

          SizedBox(
            width: double.infinity,
            // padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32) を入れる
            child: ElevatedButton(
              onPressed: _nameController.text == ''
                ? null
                : () => widget.createUser(_nameController.text),
              child: Text(
                '登録を完了する',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                textStyle: TextStyle(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
