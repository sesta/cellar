import 'package:flutter/material.dart';

import 'package:bacchus/domain/entities/drink.dart';

class DrinkPage extends StatelessWidget {
  final Drink drink;
  DrinkPage({this.drink});

  @override
  Widget build(BuildContext context) {
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
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: 16,
                ),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.black87.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 24,
                      color: Colors.white
                    ),
                    padding: EdgeInsets.all(8),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 32,
              left: 16,
              right: 16,
            ),
            child: Text(
              drink.drinkTypeLabel,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 8,
              left: 16,
              right: 16,
            ),
            child: Text(
              drink.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 8,
              left: 16,
              right: 16,
            ),
            child: Text(
              '評価',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 24,
              left: 16,
              right: 16,
            ),
            child: Text(
              drink.memo,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          )
        ]
      )
    );
  }
}
