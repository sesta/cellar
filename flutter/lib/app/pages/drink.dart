import 'package:flutter/material.dart';

import 'package:bacchus/domain/entities/drink.dart';

class DrinkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Drink drink = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Hero(
                tag: drink.thumbImageUrl,
                child: Image(
                  image: NetworkImage(drink.thumbImageUrl),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                padding: EdgeInsets.only(top: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(drink.name)
        ]
      )
    );
  }
}
