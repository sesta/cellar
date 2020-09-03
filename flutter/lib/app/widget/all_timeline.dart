import 'package:cellar/repository/alert_repository.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/domain/models/timeline.dart';
import 'package:cellar/repository/analytics_repository.dart';

import 'package:cellar/app/widget/drink_grid.dart';
import 'package:cellar/app/widget/drink_type_tab_bar.dart';
import 'package:cellar/app/widget/order_menu.dart';

class AllTimeline extends StatefulWidget {
  AllTimeline({
    Key key,
    @required this.user,
    @required this.status,
  }) : super(key: key);

  final User user;
  final Status status;

  @override
  _AllTimelineState createState() => _AllTimelineState();
}

class _AllTimelineState extends State<AllTimeline> with SingleTickerProviderStateMixin {
  DrinkType _drinkType;
  OrderType _orderType = OrderType.Newer;

  List<Drink> _allDrinks;
  Map<DrinkType, List<Drink>> _drinkMap = {};
  List<DrinkType> _postedDrinkTypes = [];

  TabController _tabController;

  bool _adding = false;

  @override
  initState() {
    super.initState();

    _postedDrinkTypes = DrinkType.values
      .where((drinkType) => _getUploadCount(drinkType) > 0)
      .toList();
    if (widget.user != null) {
      _postedDrinkTypes = widget.user.drinkTypesByMany
        .where((drinkType) => _getUploadCount(drinkType) > 0)
        .toList();
    }

    _tabController = TabController(
      vsync: this,
      length: _postedDrinkTypes.length + 1,
    );
    _tabController.addListener(() {
      // タブを押した時に連続で発生するので最後の物だけ実行
      if (_tabController.indexIsChanging) {
        return;
      }

      if (_tabController.index == 0) {
        _updateDrinkType(null);
        return;
      }

      final drinkType = _postedDrinkTypes[_tabController.index - 1];
      _updateDrinkType(drinkType);
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

    // 取得中に他のリストに切り替わることがあるため
    // 取得開始時のtypeを持っておく
    final drinkType = _drinkType;
    final orderType = _orderType;

    final drinks = await getTimelineDrinks(
      TimelineType.All,
      _orderType,
      drinkType: _drinkType,
      userId: null,
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
        'timelineType': TimelineType.All.toString(),
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
        'timelineType': TimelineType.All.toString(),
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
        'timelineType': TimelineType.All.toString(),
        'drinkType': _drinkType.toString(),
        'orderType': orderType.toString(),
      },
    );
    _updateTimeline();
  }

  int _getUploadCount(DrinkType drinkType) {
    if (drinkType == null) {
      return widget.status.uploadCount;
    }

    return widget.status.uploadCounts[drinkType];
  }

  List<Drink> _getTargetDrinks(DrinkType drinkType) {
    if (drinkType == null) {
      return _allDrinks;
    }

    return _drinkMap[drinkType];
  }

  Future<void> _addDrinks() async {
    final targetDrinks = _getTargetDrinks(_drinkType);
    if (
      _adding
      || targetDrinks.length >= _getUploadCount(_drinkType)
    ) {
      return;
    }
    // 追加のロードは並列で行えないようにする
    _adding = true;

    // 取得中に他のリストに切り替わることがあるため
    // 取得開始時のtypeを持っておく
    final drinkType = _drinkType;
    final orderType = _orderType;

    final drinks = await getTimelineDrinks(
      TimelineType.All,
      _orderType,
      drinkType: _drinkType,
      userId: null,
      lastDrink: targetDrinks.last,
    );

    // 並び順が変わっていたら保存しない
    if (orderType != _orderType) {
      return;
    }
    _setDrinks([...targetDrinks, ...drinks], drinkType);
    _adding = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          DrinkTypeTabBar(
            tabController: _tabController,
            drinkTypeTabs: [
              DrinkTypeTab(
                drinkType: null,
                count: _getUploadCount(null),
              ),
              ..._postedDrinkTypes.map((drinkType) =>
                DrinkTypeTab(
                  drinkType: drinkType,
                  count: _getUploadCount(drinkType),
                )
              ).toList(),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: [
                    _timeline(null),
                    ..._postedDrinkTypes
                      .map((drinkType) => _timeline(drinkType))
                      .toList()
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: OrderMenu(
                    selectedOrderType: _orderType,
                    updateOrderType: _updateOrderType,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            'お酒が見つかりませんでした',
            style: Theme.of(context).textTheme.subtitle1,
          )
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: DrinkGrid(
        drinks: drinks,
        addDrinks: _addDrinks,
      ),
    );
  }
}
