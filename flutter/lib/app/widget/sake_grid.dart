import 'package:flutter/material.dart';

import 'package:bacchus/domain/entities/sake.dart';

class SakeGrid extends StatelessWidget {
  final List<Sake> sakes;
  SakeGrid({this.sakes});

  @override
  Widget build(BuildContext context) {
    print(sakes);
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
            child: Material(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.antiAlias,
              child: Image(
                image: NetworkImage(sake.thumbImageUrl),
                fit: BoxFit.cover,
              ),
            ),
            onTap: () => Navigator.of(context).pushNamed('/sake', arguments: sake.thumbImageUrl),
          ),
        );
      }).toList(),
    );
  }
}
