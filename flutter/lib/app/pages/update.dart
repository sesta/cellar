import 'package:flutter/material.dart';

import 'package:cellar/domain/entity/entities.dart';

class UpdatePage extends StatelessWidget {
  UpdatePage({
    Key key,
    @required this.status,
  }) : super(key: key);

  final Status status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/icon.png',
            width: 120,
          ),
          Container(padding: EdgeInsets.only(bottom: 32)),

          Text(
            status.maintenanceMessage == ''
              ? 'アプリのバージョンを更新する必要があります。\nアプリストアから更新を行ってください。'
              : status.maintenanceMessage,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}
