import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/domain/models/timeline.dart';
import 'package:cellar/repository/analytics_repository.dart';

import 'package:cellar/app/widget/atoms/badge.dart';
import 'package:cellar/app/widget/drink_grid.dart';

class MineTimeline extends StatefulWidget {
  MineTimeline({
    Key key,
    @required this.user,
  }) : super(key: key);

  final User user;

  @override
  _MineTimelineState createState() => _MineTimelineState();
}

class _MineTimelineState extends State<MineTimeline> with SingleTickerProviderStateMixin {
  DrinkType _drinkType;
  OrderType _orderType = OrderType.Newer;

  List<Drink> _allDrinks;
  Map<DrinkType, List<Drink>> _drinkMap = {};

  TabController _tabController;

  @override
  initState() {
    super.initState();

    _tabController = TabController(
      vsync: this,
      length: _postedDrinkTypeEntries.length + 1,
    );
    _tabController.addListener(() {
      // タブを押した時に連続で発生するので最後の物だけ実行
      if (_tabController.indexIsChanging) {
        return;
      }

      if (_tabController.index == 0) {
        _updateDrinkType(null);
      }

      final drinkType = _postedDrinkTypeEntries.toList()[_tabController.index - 1].value;
      _updateDrinkType(drinkType);
    });

    _updateTimeline();
  }

  Iterable<MapEntry<int, DrinkType>> get _postedDrinkTypeEntries =>
    widget.user.drinkTypesByMany
      .where((drinkType) => _getUploadCount(drinkType) > 0)
      .toList()
      .asMap()
      .entries;

  Future<void> _updateTimeline({ bool isForceUpdate }) async {
    if (
      _getTargetDrinks(_drinkType) != null
      && isForceUpdate != true
    ) {
      return;
    }

    // 取得中に他のリストに切り替わることがあるため
    // 取得開始時のtypeを持っておく
    final drinkType = _drinkType;
    final orderType = _orderType;

    final drinks = await getTimelineDrinks(
      TimelineType.Mine,
      _orderType,
      drinkType: _drinkType,
      userId: widget.user.userId,
    );

    // 並び順が変わっていたら保存しない
    if (orderType != _orderType) {
      return;
    }
    _setDrinks(drinks, drinkType);
  }

  Future<void> _refresh() async {
    _setDrinks(null, _drinkType);

    AnalyticsRepository().sendEvent(
      EventType.ReloadTimeline,
      {
        'timelineType': TimelineType.Mine.toString(),
        'drinkType': _drinkType.toString(),
        'orderType': _orderType.toString(),
      },
    );
    await _updateTimeline(isForceUpdate: true);
  }

  _setDrinks(
    List<Drink> drinks,
    DrinkType drinkType,
  ) {
    if (drinkType == null) {
      setState(() {
        _allDrinks = drinks;
      });
      return;
    }

    setState(() {
      _drinkMap[drinkType] = drinks;
    });
  }

  _updateDrinkType(DrinkType drinkType) {
    if (_drinkType == drinkType) {
      return;
    }

    setState(() {
      _drinkType = drinkType;
    });

    AnalyticsRepository().sendEvent(
      EventType.ChangeDrinkType,
      {
        'timelineType': TimelineType.Mine.toString(),
        'drinkType': drinkType.toString(),
        'orderType': _orderType.toString(),
      },
    );
    _updateTimeline();
  }

  _updateOrderType(OrderType orderType) {
    if (_orderType == orderType) {
      return;
    }

    setState(() {
      _orderType = orderType;
      _allDrinks = null;
      _drinkMap = {};
    });

    AnalyticsRepository().sendEvent(
      EventType.ChangeOrderType,
      {
        'timelineType': TimelineType.Mine.toString(),
        'drinkType': _drinkType.toString(),
        'orderType': orderType.toString(),
      },
    );
    _updateTimeline();
  }

  _updateDrink() {
    // editなどによるDrinkの更新を反映させるため
    setState(() {});
  }

  int _getUploadCount(DrinkType drinkType) {
    if (drinkType == null) {
      return widget.user.uploadCount;
    }

    return widget.user.uploadCounts[drinkType];
  }

  List<Drink> _getTargetDrinks(DrinkType drinkType) {
    if (drinkType == null) {
      return _allDrinks;
    }

    return _drinkMap[drinkType];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top),
        ),
        _drinkTypeList(),
        Expanded(
          child: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  _timeline(null),
                  ..._postedDrinkTypeEntries
                      .map((entry) => _timeline(entry.value))
                      .toList()
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: _orderMenu(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timeline(DrinkType targetDrinkType) {
    final drinks = _getTargetDrinks(targetDrinkType);

    if (drinks == null) {
      return Padding(
        padding: EdgeInsets.only(bottom: 40),
        child: Center(
          child: Lottie.asset(
            'assets/lottie/loading.json',
            width: 80,
            height: 80,
          ),
        ),
      );
    }

    if (drinks.length == 0) {
      return Padding(
        padding: EdgeInsets.only(bottom: 40),
        child: Center(
          child: Text(
            '飲んだお酒を投稿してみましょう',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: DrinkGrid(drinks: drinks, updateDrink: _updateDrink),
    );
  }

  Widget _drinkTypeList() =>
    TabBar(
      controller: _tabController,
      isScrollable: true,
      tabs: <Widget>[
        Tab(
          child: Row(
            children: <Widget>[
              Text(
                '全て',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Padding(padding: EdgeInsets.only(right: 4)),
              Badge(_getUploadCount(null).toString()),
            ],
          ),
        ),
        ..._postedDrinkTypeEntries.map((entry) {
          final userDrinkType = entry.value;

          return Tab(
            child: Row(
              children: <Widget>[
                Text(
                  userDrinkType.label,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                Padding(padding: EdgeInsets.only(right: 4)),
                Badge(_getUploadCount(userDrinkType).toString()),
              ],
            ),
          );
        }).toList()
      ],
    );

  Widget _orderMenu() =>
    Container(
      height: 40,
      width: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            _orderType.label,
            style: Theme.of(context).textTheme.caption.copyWith(
              height: 1,
            ),
          ),

          PopupMenuButton(
            onSelected: _updateOrderType,
            icon: Icon(
              Icons.sort,
              size: 20,
            ),
            itemBuilder: (BuildContext context) =>
              OrderType.values.map((orderType) =>
                PopupMenuItem(
                  height: 40,
                  value: orderType,
                  child: Text(
                    orderType.label,
                    style: Theme.of(context).textTheme.caption,
                  ),
                )
              ).toList(),
          ),
          Padding(padding: EdgeInsets.only(right: 8)),
        ],
      ),
    );
}
