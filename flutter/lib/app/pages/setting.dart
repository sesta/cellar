import 'package:flutter/material.dart';

import 'package:cellar/domain/entities/user.dart';

import 'package:cellar/app/widget/atoms/normal_text.dart';
import 'package:cellar/app/widget/atoms/normal_text_field.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key key, this.user}) : super(key: key);

  final User user;

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<SettingPage> {
  bool loading = false;
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    nameController.text = widget.user.userName;
  }

  void _saveUser() async {
    if (disableSave) {
      return;
    }

    setState(() {
      this.loading = true;
    });

    widget.user.userName = nameController.text;
    await widget.user.save();

    Navigator.of(context).pop();
  }

  get disableSave {
    return nameController.text == '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('設定'),
        ),
        body: Stack(
          children: <Widget>[
            Padding(
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
                  ),
                ],
              ),
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
