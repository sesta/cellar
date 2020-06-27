import 'package:flutter/material.dart';

import 'package:bacchus/domain/entities/sake.dart';

class SakeGrid extends StatelessWidget {
  final List<Sake> sakes;
  SakeGrid({this.sakes});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      padding: EdgeInsets.all(8),
      childAspectRatio: 1,
      children: sakes.map<Widget>((sake) {
        return Hero(
          tag: sake.thumbImageUrl,
          child: GestureDetector(
            child: GridItem(name: sake.name, imageUrl: sake.thumbImageUrl),
            onTap: () => Navigator.of(context).pushNamed('/sake', arguments: sake.thumbImageUrl),
          ),
        );
      }).toList(),
    );
  }
}

class GridItem extends StatelessWidget {
  GridItem({
    Key key,
    this.name,
    this.imageUrl,
  });
  final String name;
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
          title: Text(name)
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
