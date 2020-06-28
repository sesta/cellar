import 'package:flutter/material.dart';

import 'package:bacchus/domain/entities/sake.dart';

class DrinkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Sake sake = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Hero(
                tag: sake.thumbImageUrl,
                child: Image(
                  image: NetworkImage(sake.thumbImageUrl),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                padding: EdgeInsets.only(top: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(sake.name)
        ]
      )
    );
  }
}
