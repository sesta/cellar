import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entity/entities.dart';

import 'package:cellar/app/widget/atoms/normal_text.dart';

class DrinkGrid extends StatelessWidget {
  final List<Drink> drinks;
  final updateDrink;
  DrinkGrid({
    @required this.drinks,
    @required this.updateDrink,
  });

  _pop(BuildContext context, int index, Drink drink) async {
    await Navigator.of(context).pushNamed('/drink', arguments: drink);
    updateDrink();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> drinkWidgets = [];
    drinks.asMap().forEach((index, drink) {
      drinkWidgets.add(GestureDetector(
        child: GridItem(drink: drink),
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
        bottom: 120,
      ),
      childAspectRatio: IMAGE_ASPECT_RATIO,
      children: drinkWidgets,
    );
  }
}

class GridItem extends StatefulWidget {
  GridItem({
    Key key,
    this.drink,
  }) : super(key: key);

  final Drink drink;

  @override
  _GridItemState createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  @override
  initState() {
    super.initState();

    if (widget.drink.thumbImageUrl == null) {
      widget.drink.init().then((_) => setState(() {}));
    }
  }

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
              NormalText(widget.drink.drinkName, bold: true),
              Padding(padding: EdgeInsets.only(bottom: 4)),
              Row(
                children: List.generate(5, (i)=> i).map<Widget>((index) =>
                  Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      index < widget.drink.score ? Icons.star : Icons.star_border,
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
          tag: widget.drink.thumbImagePath,
          child: widget.drink.thumbImageUrl == null
            ? Transform.scale( // なぜかsizeが指定できないので苦肉の策
                scale: 0.5,
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                ),
              )
            : Image(
                image: NetworkImage(
                  widget.drink.thumbImageUrl,
                ),
                fit: BoxFit.cover,
              ),
        ),
      ),
    );
  }
}
