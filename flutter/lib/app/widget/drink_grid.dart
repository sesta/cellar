import 'package:cellar/app/widget/atoms/normal_text.dart';
import 'package:flutter/material.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entities/drink.dart';

class DrinkGrid extends StatelessWidget {
  final List<Drink> drinks;
  final updateDrink;
  DrinkGrid({
    this.drinks,
    this.updateDrink,
  });

  _pop(BuildContext context, int index, Drink drink) async {
    final isDelete = await Navigator.of(context).pushNamed('/drink', arguments: drink);
    updateDrink(index, isDelete);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> drinkWidgets = [];
    drinks.asMap().forEach((index, drink) {
      drinkWidgets.add(GestureDetector(
        child: GridItem(drink),
        onTap: () => _pop(context, index, drink),
      ));
    });

    return GridView.count(
      physics: AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 64,
      ),
      childAspectRatio: IMAGE_ASPECT_RATIO,
      children: drinkWidgets,
    );
  }
}

class GridItem extends StatelessWidget {
  GridItem(this.drink);
  final Drink drink;

  @override
  Widget build(BuildContext context) {
    return GridTile(
      footer: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(4))),
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: Colors.black38,
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NormalText(drink.drinkName, bold: true),
              Padding(padding: EdgeInsets.only(bottom: 4)),
              Row(
                children: List.generate(5, (i)=> i).map<Widget>((index) =>
                  Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      index < drink.score ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.orangeAccent,
                    ),
                  )
                ).toList(),
              ),
            ],
          ),
        ),
      ),
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        clipBehavior: Clip.antiAlias,
        child: Hero(
          tag: drink.thumbImagePath,
          child: Image(
            image: NetworkImage(
              drink.thumbImageUrl,
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
