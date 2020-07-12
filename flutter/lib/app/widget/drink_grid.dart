import 'package:flutter/material.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entities/drink.dart';

class DrinkGrid extends StatelessWidget {
  final List<Drink> drinks;
  DrinkGrid({this.drinks});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      padding: EdgeInsets.all(16),
      childAspectRatio: IMAGE_ASPECT_RATIO,
      children: drinks.map<Widget>((drink) {
        return Hero(
          tag: drink.thumbImageUrl,
          child: GestureDetector(
            child: GridItem(drinkName: drink.drinkName, imageUrl: drink.thumbImageUrl),
            onTap: () => Navigator.of(context).pushNamed('/drink', arguments: drink),
          ),
        );
      }).toList(),
    );
  }
}

class GridItem extends StatelessWidget {
  GridItem({
    Key key,
    this.drinkName,
    this.imageUrl,
  });
  final String drinkName;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return GridTile(
      footer: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(4))),
        clipBehavior: Clip.antiAlias,
        child: GridTileBar(
          backgroundColor: Colors.black45,
          title: Text(drinkName)
        ),
      ),
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        clipBehavior: Clip.antiAlias,
        child: Image(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
