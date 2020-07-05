import 'package:flutter/material.dart';

import 'package:bacchus/domain/entities/drink.dart';


class LabelText extends StatelessWidget {
  final String text;
  LabelText(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: EdgeInsets.only(
        right: 6,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(14.0)),
        color: Colors.black38,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}

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
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      drink.userName,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    drink.updateDatetimeString,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 24,
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
                    padding: EdgeInsets.only(left: 4, right: 4),
                    child: Icon(
                      index < drink.score ? Icons.star : Icons.star_border,
                      color: Colors.orangeAccent,
                    ),
                  )
                ).toList(),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(
                top: 32,
                left: 16,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      children: <Widget>[
                        LabelText(drink.drinkTypeLabel),
                        drink.price == 0 ? Container() : LabelText(drink.priceString),
                        drink.place == '' ? Container() : LabelText(drink.place),
                      ],
                    ),
                  ),
                  Text(
                    drink.memo,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            )
          ]
        ),
      )
    );
  }
}
