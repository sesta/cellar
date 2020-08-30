import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:lottie/lottie.dart';

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
  List<Drink> _drinks = [];
  Map<DrinkType, double> scoreAverageMap= {};

  bool loading = true;

  @override
  void initState() {
    super.initState();

    _calc();
  }

  Future<void> _calc() async {
    _drinks = await DrinkRepository().getUserAllDrinks(widget.user.userId);

    _drinks.forEach((drink) {
      if (scoreAverageMap[drink.drinkType] == null) {
        scoreAverageMap[drink.drinkType] = 0;
      }

      scoreAverageMap[drink.drinkType] += drink.score;
    });

    scoreAverageMap.forEach((key, value) {
      scoreAverageMap[key] /= widget.user.uploadCounts[key];
    });

    setState(() {
      loading = false;
    });
  }

  List<charts.Series<DrinkType, String>> get _postCountRateData {
    final List<DrinkType> data = widget.user.drinkTypesByMany
      .where((drinkType) => widget.user.uploadCounts[drinkType] > 0)
      .toList();

    return [
      charts.Series<DrinkType, String>(
        id: 'Drinks',
        domainFn: (drinkType, _) => drinkType.label,
        measureFn: (drinkType, _) => widget.user.uploadCounts[drinkType],
        data: data,
        labelAccessorFn: (drinkType, _) {
          final rate = (widget.user.uploadCounts[drinkType]/widget.user.uploadCount*100).toStringAsFixed(0);
          return '${drinkType.label}\n$rate%';
        },
        colorFn: (drinkType, _) => charts.ColorUtil.fromDartColor(
          Theme.of(context).primaryColorDark,
        ),
        outsideLabelStyleAccessorFn: (drinkType, _) => charts.TextStyleSpec(
          color: charts.MaterialPalette.white
        ),
      )
    ];
  }

  List<charts.Series<DrinkType, String>> get _scoreAverageData {
    final List<DrinkType> data = widget.user.drinkTypesByMany
        .where((drinkType) => widget.user.uploadCounts[drinkType] > 0)
        .toList();

    return [
      charts.Series<DrinkType, String>(
        id: 'Drinks',
        domainFn: (drinkType, _) => '${drinkType.label}\n${scoreAverageMap[drinkType]}',
        measureFn: (drinkType, _) => scoreAverageMap[drinkType],
        data: data,
        colorFn: (drinkType, _) => charts.ColorUtil.fromDartColor(
          Theme.of(context).primaryColorDark,
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
              '投稿率',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Padding(padding: EdgeInsets.only(bottom: 16)),
            Container(
              height: 280,
              child: charts.PieChart(
                _postCountRateData,
                animate: true,
                defaultRenderer: charts.ArcRendererConfig(
                  arcRendererDecorators: [
                    charts.ArcLabelDecorator()
                  ],
                  strokeWidthPx: 1,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 32)),

            Text(
              'スコア',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Padding(padding: EdgeInsets.only(bottom: 16)),
            Container(
              height: 200,
              child: loading
                ? Center(
                    child: Lottie.asset(
                      'assets/lottie/loading.json',
                      width: 80,
                      height: 80,
                    ),
                  )
                : charts.BarChart(
                    _scoreAverageData,
                    animate: true,
                    domainAxis: charts.OrdinalAxisSpec(
                      renderSpec: charts.SmallTickRendererSpec(
                        labelStyle: charts.TextStyleSpec(
                          color: charts.MaterialPalette.white
                        ),
                      ),
                    ),
                    primaryMeasureAxis: charts.NumericAxisSpec(
                      tickProviderSpec: charts.BasicNumericTickProviderSpec(
                        desiredTickCount: 6
                      ),
                      renderSpec: charts.GridlineRendererSpec(
                        labelStyle: charts.TextStyleSpec(
                          color: charts.MaterialPalette.white
                        ),
                      ),
                    ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 200)),
          ],
        )
      ),
    );
  }
}
