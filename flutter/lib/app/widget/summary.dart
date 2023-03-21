import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
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
  Map<DrinkType, double> _scoreAverageMap= {};
  Map<String, List<Drink>> _postDateTimeMap = {};

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _drinkTypes = widget.user.drinkTypesByMany
      .where((drinkType) => widget.user.uploadCounts[drinkType] > 0)
      .toList();
    _calc();
  }

  String _formatDateTime(DateTime dateTime) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    return dateFormat.format(dateTime);
  }

  Future<void> _calc() async {
    _drinks = await DrinkRepository().getUserAllDrinks(widget.user.userId);

    _drinks.forEach((drink) {
      final datetimeString = _formatDateTime(drink.drinkDateTime);

      if (_scoreAverageMap[drink.drinkType] == null) {
        _scoreAverageMap[drink.drinkType] = 0;
      }
      _scoreAverageMap[drink.drinkType] += drink.score;

      if (_postDateTimeMap[datetimeString] == null) {
        _postDateTimeMap[datetimeString] = [];
      }
      _postDateTimeMap[datetimeString].add(drink);
    });

    _scoreAverageMap.forEach((key, value) {
      _scoreAverageMap[key] /= widget.user.uploadCounts[key];
    });

    setState(() {
      _loading = false;
    });
  }

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
              _postRate,
              Padding(padding: EdgeInsets.only(bottom: 32)),

              Text(
                'スコアの平均',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Padding(padding: EdgeInsets.only(bottom: 8)),
              _scoreAverage,
              Padding(padding: EdgeInsets.only(bottom: 48)),

              Text(
                '投稿した日',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Padding(padding: EdgeInsets.only(bottom: 8)),
              _postCalendar,
              Padding(padding: EdgeInsets.only(bottom: 64)),
            ],
          )
        ),
      ),
    );
  }

  Widget get _postCalendar =>
    TableCalendar(
      // TODO: 投稿した日を表示する
      firstDay: DateTime.utc(1920, 10, 16),
      lastDay: DateTime.utc(2030, 12, 31),
      locale: 'ja_JP',
      availableCalendarFormats: {
        CalendarFormat.month: 'Month'
      },
      focusedDay: DateTime.now(),
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.horizontalSwipe,
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        todayDecoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        weekendTextStyle: TextStyle().copyWith(color: Colors.orangeAccent),
        outsideDaysVisible: false,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle().copyWith(color: Colors.grey),
        weekendStyle: TextStyle().copyWith(color: Colors.orangeAccent[100]),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Colors.white,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Colors.white,
        ),
      ),
      eventLoader: (DateTime day) {
        DateFormat dateFormat = DateFormat('yyyy-MM-dd');
        return _postDateTimeMap[dateFormat.format(day)] ?? [];
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) {
            return Container();
          }
          return Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              height: 4,
              width: 100,
              color: Theme
                .of(context)
                .primaryColor,
            ),
          );
        },
      ),
      onDaySelected: (selectedDay, _) {
        DateFormat dateFormat = DateFormat('yyyy-MM-dd');
        final drinks = _postDateTimeMap[dateFormat.format(selectedDay)];
        if (drinks == null) {
          return;
        }

        Navigator.of(context).pushNamed('/drink', arguments: drinks[0]);
      },
    );

  Widget get _postRate =>
    Container(
      height: 280,
      child: _loading
        ? Center(
            child: Lottie.asset(
              'assets/lottie/loading.json',
              width: 80,
              height: 80,
            ),
          )
        : PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sections: _drinkTypes.map((drinkType) =>
                PieChartSectionData(
                  title: '${(widget.user.uploadCounts[drinkType]/widget.user.uploadCount*100).round()}%\n${drinkType.label}',
                  value: widget.user.uploadCounts[drinkType].toDouble(),
                  color: Theme.of(context).primaryColorDark,
                  radius: 140,
                  titlePositionPercentageOffset: 0.7,
                )
              ).toList(),
            )
          )
    );

  Widget get _scoreAverage =>
    Container(
      height: 20.0 + 44 * _drinkTypes.length,
      child: _loading
        ? Center(
            child: Lottie.asset(
              'assets/lottie/loading.json',
              width: 80,
              height: 80,
            ),
          )
        : RotatedBox(
            quarterTurns: 1,
            child: BarChart(
              BarChartData(
                maxY: 5,
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(),
                  leftTitles: AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 80,
                      getTitlesWidget: (x, _) {
                        return RotatedBox(
                          quarterTurns: 3,
                          child: Text(_drinkTypes[x.toInt()].label),
                        );
                      },
                    )
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (x, _) {
                        return RotatedBox(
                          quarterTurns: 3,
                          child: Text(x.toInt().toString()),
                        );
                      },
                    )
                  )
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                ),
                barGroups: _drinkTypes.asMap().entries.map((entry) =>
                  BarChartGroupData(
                    x: entry.key,
                    barRods: [BarChartRodData(
                      toY: _scoreAverageMap[entry.value],
                      color: Theme.of(context).primaryColorDark
                    )],
                  ),
                ).toList()
              )
            ),
        )
    );
}
