import 'package:flutter/material.dart';

import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/drink_repository.dart';

class Summary extends StatefulWidget {
  Summary({
    Key key,
    @required this.user,
  }) : super(key: key);

  final User user;

  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  List<Drink> drinks = [];

  @override
  void initState() {
    super.initState();

    DrinkRepository().getUserAllDrinks(widget.user.userId).then((drinks) {
      setState(() {
        this.drinks = drinks;
      });
      print(drinks);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(widget.user.userId)
    );
  }
}
