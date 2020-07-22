import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:cellar/domain/entities/status.dart';
import 'package:cellar/domain/entities/user.dart';
import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/domain/models/timeline.dart';

import 'package:cellar/app/widget/drink_grid.dart';
import 'package:cellar/app/widget/atoms/label_test.dart';
import 'package:cellar/app/widget/atoms/normal_text.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
    this.user,
    this.status,
  }) : super(key: key);

  final Status status;
  final User user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TimelineType timelineType = TimelineType.Mine;
  DrinkType drinkType;
  OrderType orderType = OrderType.Newer;
  bool loading = true;
  List<Drink> publicAllDrinks;
  List<Drink> mineAllDrinks;
  Map<DrinkType, List<Drink>> publicDrinkMap = {};
  Map<DrinkType, List<Drink>> mineDrinkMap = {};

  ScrollController _scrollController = new ScrollController();

  @override
  initState() {
    super.initState();

    _updateTimeline();
  }

  _movePostPage() async {
    final isPosted = await Navigator.of(context).pushNamed('/post');

    if (isPosted != null) {
      _updateTimeline();
    }
  }

  Future<void> _updateTimeline() async {
    if (_getTargetDrinks(drinkType) == null) {
      final drinks = await getTimelineDrinks(
        timelineType,
        orderType,
        drinkType: drinkType,
        userId: widget.user.userId,
      );
      _setDrinks(drinks);
    }
  }

  _setDrinks(List<Drink> drinks) {
    if (drinkType == null) {
      switch(timelineType) {
        case TimelineType.All:
          setState(() {
            this.publicAllDrinks = drinks;
          });
          return;
        case TimelineType.Mine:
          setState(() {
            this.mineAllDrinks = drinks;
          });
          return;
      }
    }

    switch(timelineType) {
      case TimelineType.All:
        setState(() {
          this.publicDrinkMap[drinkType] = drinks;
        });
        return;
      case TimelineType.Mine:
        setState(() {
          this.mineDrinkMap[drinkType] = drinks;
        });
        return;
    }

    throw '予期せぬtypeです。 $timelineType';
  }

  _updateTimelineType(TimelineType timelineType) {
    if (this.timelineType == timelineType) {
      return;
    }

    setState(() {
      this.timelineType = timelineType;
      this.drinkType = null;
    });

    _updateTimeline();
  }

  _updateDrinkType(DrinkType drinkType, int index) {
    if (this.drinkType == drinkType) {
      return;
    }

    setState(() {
      this.drinkType = drinkType;
    });

    if (index != null) {
      _scrollController.animateTo(
        min(index * 80.0, _scrollController.position.maxScrollExtent),
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
    _updateTimeline();
  }

  _updateOrderType(OrderType orderType) {
    if (this.orderType == orderType) {
      return;
    }

    setState(() {
      this.orderType = orderType;
    });

    _updateTimeline();
  }

  Future<void> _refresh() async {
    await _updateTimeline();
  }

  int getUploadCount(DrinkType drinkType) {
    if (drinkType == null) {
      switch(timelineType) {
        case TimelineType.All:
          return widget.status.uploadCount;
        case TimelineType.Mine:
          return widget.user.uploadCount;
      }
    }

    switch(timelineType) {
      case TimelineType.All:
        return widget.status.drinkTypeUploadCounts[drinkType.index];
      case TimelineType.Mine:
        return widget.user.drinkTypeUploadCounts[drinkType.index];
    }

    throw 'timelineTypeの考慮漏れです';
  }

  _updateDrink(int index, bool isDelete) {
    if (isDelete) {
      return;
    }

    setState(() {});
  }

  List<Drink> _getTargetDrinks(DrinkType targetDrinkType) {
    if (targetDrinkType == null) {
      switch(timelineType) {
        case TimelineType.All: return publicAllDrinks;
        case TimelineType.Mine: return mineAllDrinks;
      }
    }

    switch(timelineType) {
      case TimelineType.All: return publicDrinkMap[targetDrinkType];
      case TimelineType.Mine: return mineDrinkMap[targetDrinkType];
    }

    throw '予期せぬtypeです。 $timelineType';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
            ),
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                'Cellar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 16)),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    children: <Widget>[
                      ButtonTheme(
                        minWidth: 80,
                        child: FlatButton(
                          textColor: drinkType == null
                            ? Colors.white
                            : Colors.white38,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: <Widget>[
                              NormalText(
                                '全て',
                                bold: drinkType == null,
                              ),
                              Padding(padding: EdgeInsets.only(right: 4)),
                              LabelText(
                                getUploadCount(null).toString(),
                                size: 'small',
                                single: true,
                              ),
                            ],
                          ),
                          onPressed: () => _updateDrinkType(null, null),
                        ),
                      ),
                      ...widget.user.drinkTypesByMany.map((userDrinkType) {
                        final count = getUploadCount(userDrinkType);
                        if (count == 0) {
                          return Container();
                        }

                        return ButtonTheme(
                          minWidth: 80,
                          child: FlatButton(
                            textColor: drinkType == userDrinkType
                                ? Colors.white
                                : Colors.white38,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: <Widget>[
                                NormalText(
                                  userDrinkType.label,
                                  bold: drinkType == userDrinkType,
                                ),
                                Padding(padding: EdgeInsets.only(right: 4)),
                                LabelText(
                                  count.toString(),
                                  size: 'small',
                                  single: true,
                                ),
                              ],
                            ),
                            onPressed: () => _updateDrinkType(userDrinkType, null),
                          ),
                        );
                      }).toList()
                    ],
                  ),
                ),
              ),
              PopupMenuButton(
                onSelected: _updateOrderType,
                icon: Icon(Icons.sort),
                itemBuilder: (BuildContext context) =>
                  OrderType.values.map((type) =>
                    PopupMenuItem(
                      value: type,
                      child: NormalText(
                        type.label,
                        bold: type == orderType,
                      ),
                    )
                  ).toList(),
                ),
            ],
          ),
          Expanded(
            child: CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1,
                enableInfiniteScroll: false,
                onPageChanged: (int index, _) {
                  if (index == 0) {
                    _updateDrinkType(null, 0);
                    return;
                  }

                  _updateDrinkType(widget.user.drinkTypesByMany[index - 1], index);
                },
              ),
              items: [
                Timeline(null),
                ...widget.user.drinkTypesByMany
                  .where((type) => getUploadCount(type) > 0)
                  .map((type) => Timeline(type))
                  .toList()
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).accentColor,
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () => _updateTimelineType(TimelineType.Mine),
                  icon: Icon(
                    Icons.home,
                    size: 32,
                    color: timelineType == TimelineType.Mine
                      ? Colors.white
                      : Theme.of(context).primaryColorLight,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () => _updateTimelineType(TimelineType.All),
                  icon: Icon(
                    Icons.people,
                    size: 32,
                    color: timelineType == TimelineType.All
                      ? Colors.white
                      : Theme.of(context).primaryColorLight,
                  ),
                ),
              ),
              Container(
                width: 88,
                height: 40,
              ),
              Expanded(
                flex: 1,
                child: Container(height: 0),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pushNamed('/setting'),
                  icon: Icon(
                    Icons.settings,
                    size: 32,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _movePostPage,
        tooltip: 'Increment',
        backgroundColor: Theme.of(context).accentColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget Timeline(DrinkType targetDrinkType) {
    final drinks = _getTargetDrinks(targetDrinkType);

    if (drinks == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        ],
      );
    }

    Widget content = SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 200,
          bottom: 100,
        ),
        child: Column(
          children: <Widget>[
            NormalText('投稿したお酒が表示されます'),
          ],
        ),
      ),
    );
    if (drinks.length > 0) {
      content = DrinkGrid(drinks: drinks, updateDrink: _updateDrink);
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: content,
    );
  }
}
