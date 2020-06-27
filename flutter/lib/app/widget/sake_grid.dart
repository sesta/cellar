import 'package:flutter/material.dart';

import 'package:bacchus/domain/entities/sake.dart';

class SakeGrid extends StatelessWidget {
  final List<Sake> sakes;
  SakeGrid({this.sakes});

  @override
  Widget build(BuildContext context) {
    print(sakes);
    return GridView.count(
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: sakes.map<Widget>((sake) {
        return Hero(
          tag: sake.thumbImageUrl,
          child: FlatButton(
            child: Image(
              image: NetworkImage(sake.thumbImageUrl),
            ),
            onPressed: () => Navigator.of(context).pushNamed('/sake', arguments: sake.thumbImageUrl),
          )
        );
      }).toList(),
    );
  }
}