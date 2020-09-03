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
  List<DrinkType> _drinkTypes;
  List<Drink> _drinks = [];
  Map<DrinkType, double> scoreAverageMap= {};

  bool loading = true;

  @override
  void initState() {
    super.initState();

    _drinkTypes = widget.user.drinkTypesByMany
      .where((drinkType) => widget.user.uploadCounts[drinkType] > 0)
      .toList();
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

  List<charts.Series<DrinkType, String>> get _postCountRateData =>
    [
      charts.Series<DrinkType, String>(
        id: 'Drinks',
        domainFn: (drinkType, _) => drinkType.label,
        measureFn: (drinkType, _) => widget.user.uploadCounts[drinkType],
        data: _drinkTypes,
        labelAccessorFn: (drinkType, _) {
          final rate = (widget.user.uploadCounts[drinkType]/widget.user.uploadCount*100).toStringAsFixed(0);
          return '$rate%\n${drinkType.label}';
        },
        colorFn: (drinkType, _) => charts.ColorUtil.fromDartColor(
          Theme.of(context).primaryColorDark,
        ),
        outsideLabelStyleAccessorFn: (drinkType, _) => charts.TextStyleSpec(
          color: charts.MaterialPalette.white
        ),
      )
    ];

  List<charts.Series<DrinkType, String>> get _scoreAverageData =>
    [
      charts.Series<DrinkType, String>(
        id: 'Drinks',
        domainFn: (drinkType, _) => '${scoreAverageMap[drinkType].toStringAsFixed(1)}\n${drinkType.label}',
        measureFn: (drinkType, _) => scoreAverageMap[drinkType],
        data: _drinkTypes,
        colorFn: (drinkType, _) => charts.ColorUtil.fromDartColor(
          Theme.of(context).primaryColorDark,
        ),
      )
    ];

  @override
  Widget build(BuildContext context) {
    if (widget.user.uploadCount == 0) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Text(
            '飲んだお酒を投稿してみましょう',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      );
    }

    return Container(
      alignment: Alignment.topLeft,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).padding.top + 32,
            horizontal: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '投稿の割合',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Padding(padding: EdgeInsets.only(bottom: 16)),
              Container(
                height: 280,
                child: loading
                  ? Center(
                      child: Lottie.asset(
                        'assets/lottie/loading.json',
                        width: 80,
                        height: 80,
                      ),
                    )
                  : charts.PieChart(
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
                height: 20.0 + 60 * _drinkTypes.length,
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
                      vertical: false,
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
            ],
          )
        ),
      ),
    );
  }
}
