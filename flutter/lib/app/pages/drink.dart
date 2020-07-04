import 'package:flutter/material.dart';

import 'package:bacchus/domain/entities/drink.dart';

class DrinkPage extends StatelessWidget {
  final Drink drink;
  DrinkPage({this.drink});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Hero(
                  tag: drink.thumbImageUrl,
                  child: GestureDetector(
                    onVerticalDragEnd: (event) {
                      if (event.velocity.pixelsPerSecond.dy > 100) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: Image(
                      image: NetworkImage(drink.thumbImageUrl),
                    ),
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
                drink.drinkTypeLabel
                + (drink.price == 0 ? '' : "・${drink.priceString}")
                + (drink.place == '' ? '' : "・${drink.place}"),
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i)=> i).map<Widget>((index) =>
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      index < drink.score ? Icons.star : Icons.star_border,
                      color: Colors.orangeAccent,
                    ),
                  )
                ).toList(),
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
        ),
      )
    );
  }
}
