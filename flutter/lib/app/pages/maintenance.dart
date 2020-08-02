import 'package:flutter/material.dart';

import 'package:cellar/domain/entities/status.dart';

import 'package:cellar/app/widget/atoms/normal_text.dart';

class MaintenancePage extends StatelessWidget {
  MaintenancePage({
    Key key,
    this.status,
  }) : super(key: key);

  final Status status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/icon.png',
            width: 120,
          ),
          Container(padding: EdgeInsets.only(bottom: 32)),

          NormalText(
            '申し訳ありません、メンテナンス中です。\n復旧までお待ちください。',
            multiLine: true,
            bold: true,
          ),
        ],
      ),
    );
  }
}
