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
  TimelineType _timelineType = TimelineType.Mine;
  DrinkType _drinkType;
  OrderType _orderType = OrderType.Newer;
  List<Drink> _publicAllDrinks;
  List<Drink> _mineAllDrinks;
  Map<DrinkType, List<Drink>> _publicDrinkMap = {};
  Map<DrinkType, List<Drink>> _mineDrinkMap = {};

  ScrollController _scrollController = ScrollController();
  CarouselController _carouselController = CarouselController();

  @override
  initState() {
    super.initState();

    _updateTimeline();
  }

  Future<void> _movePostPage() async {
    final isPosted = await Navigator.of(context).pushNamed('/post');
    if (isPosted == null) {
      return;
    }

    setState(() {
      this._mineAllDrinks = null;
      this._mineDrinkMap = {};
    });
    _updateTimeline();
  }

  Future<void> _updateTimeline({ bool isForceUpdate }) async {
    if (
      _getTargetDrinks(_drinkType) != null
      && isForceUpdate != true
    ) {
      return;
    }

    final drinks = await getTimelineDrinks(
      _timelineType,
      _orderType,
      drinkType: _drinkType,
      userId: widget.user.userId,
    );
    _setDrinks(drinks);
  }

  _setDrinks(List<Drink> drinks) {
    if (_drinkType == null) {
      switch(_timelineType) {
        case TimelineType.All:
          setState(() {
            this._publicAllDrinks = drinks;
          });
          return;
        case TimelineType.Mine:
          setState(() {
            this._mineAllDrinks = drinks;
          });
          return;
      }
    }

    switch(_timelineType) {
      case TimelineType.All:
        setState(() {
          this._publicDrinkMap[_drinkType] = drinks;
        });
        return;
      case TimelineType.Mine:
        setState(() {
          this._mineDrinkMap[_drinkType] = drinks;
        });
        return;
    }

    throw '予期せぬtypeです。 $_timelineType';
  }

  _updateTimelineType(TimelineType timelineType) {
    if (this._timelineType == timelineType) {
      return;
    }

    setState(() {
      this._timelineType = timelineType;
      this._drinkType = null;
    });

    _updateTimeline();
  }

  _updateDrinkType(DrinkType drinkType) {
    if (this._drinkType == drinkType) {
      return;
    }

    setState(() {
      this._drinkType = drinkType;
    });

    _updateTimeline();
  }

  _scrollToDrinkType(int index) {
    _scrollController.animateTo(
      min(index * 80.0, _scrollController.position.maxScrollExtent),
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  _updateOrderType(OrderType orderType) {
    if (this._orderType == orderType) {
      return;
    }

    setState(() {
      this._orderType = orderType;
      this._publicAllDrinks = null;
      this._mineAllDrinks = null;
      this._publicDrinkMap = {};
      this._mineDrinkMap = {};
    });

    _updateTimeline();
  }

  Future<void> _refresh() async {
    _setDrinks(null);
    await _updateTimeline(isForceUpdate: true);
  }

  int _getUploadCount(DrinkType drinkType) {
    if (drinkType == null) {
      switch(_timelineType) {
        case TimelineType.All:
          return widget.status.uploadCount;
        case TimelineType.Mine:
          return widget.user.uploadCount;
      }
    }

    switch(_timelineType) {
      case TimelineType.All:
        return widget.status.drinkTypeUploadCounts[drinkType.index];
      case TimelineType.Mine:
        return widget.user.drinkTypeUploadCounts[drinkType.index];
    }

    throw 'timelineTypeの考慮漏れです';
  }

  _updateDrink(int index, bool isDelete) {
    // TODO: 全てのタイムラインから消すのは難しいので方法を考える
    setState(() {});
  }

  List<Drink> _getTargetDrinks(DrinkType targetDrinkType) {
    if (targetDrinkType == null) {
      switch(_timelineType) {
        case TimelineType.All: return _publicAllDrinks;
        case TimelineType.Mine: return _mineAllDrinks;
      }
    }

    switch(_timelineType) {
      case TimelineType.All: return _publicDrinkMap[targetDrinkType];
      case TimelineType.Mine: return _mineDrinkMap[targetDrinkType];
    }

    throw '予期せぬtypeです。 $_timelineType';
  }

  Iterable<MapEntry<int, DrinkType>> get _postedDrinksList {
    return widget.user.drinkTypesByMany
      .where((type) => _getUploadCount(type) > 0)
      .toList()
      .asMap()
      .entries;
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
                  child: _drinkTypeList(),
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
                        bold: type == _orderType,
                      ),
                    )
                  ).toList(),
                ),
            ],
          ),
          Expanded(
            child: CarouselSlider(
              carouselController: _carouselController,
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1,
                enableInfiniteScroll: false,
                onPageChanged: (int index, CarouselPageChangedReason reason) {
                  if (reason == CarouselPageChangedReason.controller) {
                    return;
                  }
                  if (index == 0) {
                    _updateDrinkType(null);
                    _scrollToDrinkType(0);
                    return;
                  }

                  final targetDrinkTypes = _postedDrinksList.toList();
                  _updateDrinkType(targetDrinkTypes[index - 1].value);
                  _scrollToDrinkType(index);
                },
              ),
              items: [
                _timeline(null),
                ..._postedDrinksList
                  .map((entry) => _timeline(entry.value))
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
                  onPressed: () {
                    _updateTimelineType(TimelineType.Mine);
                    _scrollToDrinkType(0);
                    _carouselController.jumpToPage(0);
                  },
                  icon: Icon(
                    Icons.home,
                    size: 32,
                    color: _timelineType == TimelineType.Mine
                      ? Colors.white
                      : Theme.of(context).primaryColorLight,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {
                    _updateTimelineType(TimelineType.All);
                    _scrollToDrinkType(0);
                    _carouselController.jumpToPage(0);
                  },
                  icon: Icon(
                    Icons.people,
                    size: 32,
                    color: _timelineType == TimelineType.All
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

  Widget _timeline(DrinkType targetDrinkType) {
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

  Widget _drinkTypeList() =>
    ListView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      children: <Widget>[
        ButtonTheme(
          minWidth: 80,
          child: FlatButton(
            textColor: _drinkType == null
                ? Colors.white
                : Colors.white38,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                NormalText(
                  '全て',
                  bold: _drinkType == null,
                ),
                Padding(padding: EdgeInsets.only(right: 4)),
                LabelText(
                  _getUploadCount(null).toString(),
                  size: 'small',
                  single: true,
                ),
              ],
            ),
            onPressed: () {
              _updateDrinkType(null);
              _carouselController.animateToPage(0);
            },
          ),
        ),
        ..._postedDrinksList.map((entry) {
          final index = entry.key;
          final userDrinkType = entry.value;

          return ButtonTheme(
            minWidth: 80,
            child: FlatButton(
              textColor: _drinkType == userDrinkType
                  ? Colors.white
                  : Colors.white38,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  NormalText(
                    userDrinkType.label,
                    bold: _drinkType == userDrinkType,
                  ),
                  Padding(padding: EdgeInsets.only(right: 4)),
                  LabelText(
                    _getUploadCount(userDrinkType).toString(),
                    size: 'small',
                    single: true,
                  ),
                ],
              ),
              onPressed: () {
                _updateDrinkType(userDrinkType);
                _carouselController.animateToPage(index + 1);
              },
            ),
          );
        }).toList()
      ],
    );
}
