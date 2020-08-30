import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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
    });
  }

  List<charts.Series<_ChartData, int>> get _seriesList {
    final List<_ChartData> data = widget.user.uploadCounts.entries
      .map((entry) => _ChartData(entry.key, entry.value))
      .where((chartData) => chartData.uploadCount > 0)
      .toList();

    return [
      charts.Series<_ChartData, int>(
        id: 'Drinks',
        domainFn: (_ChartData chartData, _) => chartData.drinkType.index,
        measureFn: (_ChartData chartData, _) => chartData.uploadCount,
        data: data,
        labelAccessorFn: (_ChartData chartData, _) => chartData.drinkType.label,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: charts.PieChart(
        _seriesList,
        animate: true,
        defaultRenderer: charts.ArcRendererConfig(
          arcRendererDecorators: [
            charts.ArcLabelDecorator(
              labelPosition: charts.ArcLabelPosition.inside,
            )
          ]
        ),
      )
    );
  }
}

class _ChartData {
  final DrinkType drinkType;
  final int uploadCount;

  _ChartData(this.drinkType, this.uploadCount);

  @override
  String toString() {
    return '$drinkType : $uploadCount';
  }
}
