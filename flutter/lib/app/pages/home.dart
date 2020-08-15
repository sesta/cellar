import 'dart:math';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/domain/models/timeline.dart';
import 'package:cellar/repository/repositories.dart';

import 'package:cellar/app/widget/drink_grid.dart';
import 'package:cellar/app/widget/atoms/badge.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
    @required this.user,
    @required this.status,
    @required this.setUser,
  }) : super(key: key);

  final User user;
  final Status status;
  final setUser;

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

  bool _loadingSignIn = false;
  bool _enableAppleSignIn = false;

  @override
  initState() {
    super.initState();

    _updateTimeline();
    AuthRepository().enableAppleSignIn.then((enable) => setState(() {
      _enableAppleSignIn = enable;
    }));
  }

  Iterable<MapEntry<int, DrinkType>> get _postedDrinkTypeEntries {
    if (widget.user == null) {
      return DrinkType.values
        .where((drinkType) => _getUploadCount(drinkType) > 0)
        .toList()
        .asMap()
        .entries;
    }

    return widget.user.drinkTypesByMany
      .where((drinkType) => _getUploadCount(drinkType) > 0)
      .toList()
      .asMap()
      .entries;
  }

  Future<void> _updateTimeline({ bool isForceUpdate }) async {
    if (widget.user == null && _timelineType == TimelineType.Mine) {
      return;
    }

    if (
      _getTargetDrinks(_drinkType) != null
      && isForceUpdate != true
    ) {
      return;
    }

    // 取得中に他のリストに切り替わることがあるため
    // 取得開始時のtypeを持っておく
    final timelineType = _timelineType;
    final drinkType = _drinkType;
    final orderType = _orderType;

    final drinks = await getTimelineDrinks(
      _timelineType,
      _orderType,
      drinkType: _drinkType,
      userId: widget.user == null ? null : widget.user.userId,
    );

    // 並び順が変わっていたら保存しない
    if (orderType != _orderType) {
      return;
    }
    _setDrinks(drinks, timelineType, drinkType);
  }

  Future<void> _refresh() async {
    _setDrinks(null, _timelineType, _drinkType);

    AnalyticsRepository().sendEvent(
      EventType.ReloadTimeline,
      {
        'timelineType': _timelineType.toString(),
        'drinkType': _drinkType.toString(),
        'orderType': _orderType.toString(),
      },
    );
    await _updateTimeline(isForceUpdate: true);
  }

  _setDrinks(
    List<Drink> drinks,
    TimelineType timelineType,
    DrinkType drinkType,
  ) {
    if (drinkType == null) {
      switch(timelineType) {
        case TimelineType.All:
          setState(() {
            _publicAllDrinks = drinks;
          });
          return;
        case TimelineType.Mine:
          setState(() {
            _mineAllDrinks = drinks;
          });
          return;
      }
    }

    switch(timelineType) {
      case TimelineType.All:
        setState(() {
          _publicDrinkMap[drinkType] = drinks;
        });
        return;
      case TimelineType.Mine:
        setState(() {
          _mineDrinkMap[drinkType] = drinks;
        });
        return;
    }

    throw '予期せぬtypeです。 $timelineType';
  }

  _updateTimelineType(TimelineType timelineType) {
    if (_timelineType == timelineType) {
      return;
    }

    setState(() {
      _timelineType = timelineType;
      _drinkType = null;
    });

    AnalyticsRepository().sendEvent(
      EventType.ChangeTimelineType,
      {
        'timelineType': timelineType.toString(),
        'drinkType': _drinkType.toString(),
        'orderType': _orderType.toString(),
      },
    );
    _updateTimeline();
  }

  _updateDrinkType(DrinkType drinkType, String from) {
    if (_drinkType == drinkType) {
      return;
    }

    setState(() {
      _drinkType = drinkType;
    });

    AnalyticsRepository().sendEvent(
      EventType.ChangeDrinkType,
      {
        'timelineType': _timelineType.toString(),
        'drinkType': drinkType.toString(),
        'orderType': _orderType.toString(),
        'from': from,
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
      _publicAllDrinks = null;
      _mineAllDrinks = null;
      _publicDrinkMap = {};
      _mineDrinkMap = {};
    });

    AnalyticsRepository().sendEvent(
      EventType.ChangeOrderType,
      {
        'timelineType': _timelineType.toString(),
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

  _scrollToDrinkType(int index) {
    _scrollController.animateTo(
      min(index * 80.0, _scrollController.position.maxScrollExtent),
      curve: Curves.easeOut,
      duration: Duration(milliseconds: 300),
    );
  }

  Future<void> _signIn(AuthType authType) async {
    final userId = await AuthRepository().signIn(authType);
    if (userId == null) {
      print('SignInに失敗しました');

      setState(() {
        this._loadingSignIn = false;
      });
      return;
    }

    final user = await UserRepository().getUser(userId);
    setState(() {
      this._loadingSignIn = false;
    });

    if (user != null) {
      widget.setUser(user);
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }

    Navigator.of(context).pushNamed('/signUp', arguments: userId);
  }

  int _getUploadCount(DrinkType drinkType) {
    if (widget.user == null && _timelineType == TimelineType.Mine) {
      return 0;
    }

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
        return widget.status.uploadCounts[drinkType];
      case TimelineType.Mine:
        return widget.user.uploadCounts[drinkType];
    }

    throw 'timelineTypeの考慮漏れです';
  }

  List<Drink> _getTargetDrinks(DrinkType drinkType) {
    if (drinkType == null) {
      switch(_timelineType) {
        case TimelineType.All: return _publicAllDrinks;
        case TimelineType.Mine: return _mineAllDrinks;
      }
    }

    switch(_timelineType) {
      case TimelineType.All: return _publicDrinkMap[drinkType];
      case TimelineType.Mine: return _mineDrinkMap[drinkType];
    }

    throw '予期せぬtypeです。 $_timelineType';
  }

  Future<void> _movePostPage() async {
    final isPosted = await Navigator.of(context).pushNamed('/post');
    if (isPosted == null) {
      return;
    }

    setState(() {
      _mineAllDrinks = null;
      _mineDrinkMap = {};
    });
    _updateTimeline();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 40,
                  child: _drinkTypeList(),
                ),
              ),
            ],
          ),

          Expanded(
            child: Stack(
              children: [
                widget.user == null && _timelineType == TimelineType.Mine
                  ? _signInContainer()
                  : CarouselSlider(
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
                          _updateDrinkType(null, 'carousel');
                          _scrollToDrinkType(0);
                          return;
                        }

                        final targetDrinkTypes = _postedDrinkTypeEntries.toList();
                        _updateDrinkType(targetDrinkTypes[index - 1].value, 'carousel');
                        _scrollToDrinkType(index);
                      },
                    ),
                    items: [
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
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).accentColor,
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {
                    if (_timelineType == TimelineType.Mine) {
                      return;
                    }

                    _updateTimelineType(TimelineType.Mine);
                    _scrollToDrinkType(0);
                    if (widget.user != null) {
                      _carouselController.jumpToPage(0);
                    }
                  },
                  icon: Icon(
                    Icons.home,
                    size: 30,
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
                    if (_timelineType == TimelineType.All) {
                      return;
                    }

                    _updateTimelineType(TimelineType.All);
                    _scrollToDrinkType(0);
                    if (widget.user != null) {
                      _carouselController.jumpToPage(0);
                    }
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
                child: widget.user == null
                  ? Container(height: 0)
                  : IconButton(
                    onPressed: () => Navigator.of(context).pushNamed('/setting'),
                    icon: Icon(
                      Icons.settings,
                      size: 28,
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.user == null ? null : _movePostPage,
        backgroundColor: Theme.of(context).accentColor,
        child: Opacity(
          opacity: widget.user == null ? 0.4 : 1,
          child: Image.asset(
            'assets/images/upload-icon.png',
            width: 48,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
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
          child: _timelineType == TimelineType.Mine
            ? Text(
                '飲んだお酒を投稿してみましょう',
                style: Theme.of(context).textTheme.subtitle1,
              )
            : Text(
                'お酒が見つかりませんでした',
                style: Theme.of(context).textTheme.subtitle1,
              )
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: DrinkGrid(drinks: drinks, updateDrink: _updateDrink),
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
                Text(
                  '全て',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Padding(padding: EdgeInsets.only(right: 4)),
                Badge(_getUploadCount(null).toString()),
              ],
            ),
            onPressed: () {
              _updateDrinkType(null, 'button');
              _carouselController.animateToPage(
                0,
                curve: Curves.easeOut,
                duration: Duration(milliseconds: 300),
              );
            },
          ),
        ),
        ..._postedDrinkTypeEntries.map((entry) {
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
                  Text(
                    userDrinkType.label,
                    style: _drinkType == userDrinkType
                      ? Theme.of(context).textTheme.subtitle1
                      : Theme.of(context).textTheme.subtitle2,
                  ),
                  Padding(padding: EdgeInsets.only(right: 4)),
                  Badge(_getUploadCount(userDrinkType).toString()),
                ],
              ),
              onPressed: () {
                _updateDrinkType(userDrinkType, 'button');
                _carouselController.animateToPage(index + 1);
              },
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

  Widget _signInContainer() =>
    Stack(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'お酒を投稿するには\nアカウント認証が必要です。',
              style: Theme.of(context).textTheme.bodyText2,
            ),
            Padding(padding: EdgeInsets.only(bottom: 32)),

            _enableAppleSignIn
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AppleSignInButton(
                      onPressed: () => _signIn(AuthType.Apple),
                      style: AppleButtonStyle.white,
                    ),
                )
              : Container(height: 0),
            GoogleSignInButton(
              onPressed: () => _signIn(AuthType.Google),
            ),
            Padding(padding: EdgeInsets.only(bottom: 32)),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '※',
                  style: Theme.of(context).textTheme.caption,
                ),
                Padding(padding: EdgeInsets.only(right: 4)),
                Text(
                  'プライバシーポリシーに\n同意の上認証をしてください。',
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),

            FlatButton(
              child: Text(
                'プライバシーポリシー',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () => launch('https://cellar.sesta.dev/policy'),
            ),
            Padding(padding: EdgeInsets.only(bottom: 80)),
          ]
        ),
        _loadingSignIn ? Container(
          padding: EdgeInsets.only(bottom: 80),
          color: Colors.black38,
          alignment: Alignment.center,
          child: Lottie.asset(
            'assets/lottie/loading.json',
            width: 80,
            height: 80,
          )
        ) : Container(),
      ],
    );
}
