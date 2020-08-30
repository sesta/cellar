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
    final List<_ChartData> data = widget.user.drinkTypesByMany
      .map((drinkType) => _ChartData(drinkType, widget.user.uploadCounts[drinkType]))
      .where((chartData) => chartData.uploadCount > 0)
      .toList();

    return [
      charts.Series<_ChartData, int>(
        id: 'Drinks',
        domainFn: (_ChartData chartData, _) => chartData.drinkType.index,
        measureFn: (_ChartData chartData, _) => chartData.uploadCount,
        data: data,
        labelAccessorFn: (_ChartData chartData, _) {
          final rate = (chartData.uploadCount/widget.user.uploadCount*100).toStringAsFixed(0);
          return '${chartData.drinkType.label}\n$rate%';
        },
        colorFn: (_ChartData chartData, _) => charts.ColorUtil.fromDartColor(
          Theme.of(context).backgroundColor,
        ),
        outsideLabelStyleAccessorFn: (_ChartData chartData, _) => charts.TextStyleSpec(
          color: charts.MaterialPalette.white
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).padding.top + 32,
          horizontal: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '種類ごとの投稿の割合',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Padding(padding: EdgeInsets.only(bottom: 8)),

            Container(
              height: 280,
              child: charts.PieChart(
                _seriesList,
                animate: true,
                defaultRenderer: charts.ArcRendererConfig(
                  arcRendererDecorators: [
                    charts.ArcLabelDecorator()
                  ],
                  strokeWidthPx: 1,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 400)),
          ],
        )
      ),
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
