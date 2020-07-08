import 'package:cellar/app/widget/atoms/main_text.dart';
import 'package:cellar/app/widget/atoms/normal_text.dart';
import 'package:flutter/material.dart';

import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/app/widget/atoms/label_test.dart';

class DrinkPage extends StatelessWidget {
  final Drink drink;
  DrinkPage({this.drink});

  @override
  Widget build(BuildContext context) {
    if (drink.imageUrls == null) {
      drink.getImageUrls();
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(drink.imagePaths.length, (index) {
                      if (index == 0) {
                        return Hero(
                          tag: drink.thumbImageUrl,
                          child: GestureDetector(
                            onVerticalDragEnd: (event) {
                              if (event.velocity.pixelsPerSecond.dy > 100) {
                                Navigator.of(context).pop(true);
                              }
                            },
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image(
                                image: NetworkImage(drink.thumbImageUrl),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      }

                      if (drink.imageUrls == null) {
                        return AspectRatio(
                          aspectRatio: 1,
                          child: Image(
                            image: NetworkImage(drink.thumbImageUrl),
                            fit: BoxFit.contain,
                          ),
                        );
                      }

                      return AspectRatio(
                        aspectRatio: 1,
                        child: Image(
                          image: NetworkImage(drink.imageUrls[index]),
                          fit: BoxFit.contain,
                        ),
                      );
                    }).toList(),
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
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  Expanded(
                    child: NormalText(drink.userName),
                  ),
                  NormalText(drink.postDatetimeString),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 16,
                right: 16,
              ),
              child: MainText(
                drink.drinkName,
                bold: true,
                multiLine: true,
                textAlign: TextAlign.center,
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
                  NormalText(
                    drink.memo,
                    multiLine: true,
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
