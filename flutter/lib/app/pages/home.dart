import 'dart:async';

import 'package:cellar/app/widget/atoms/label_test.dart';
import 'package:cellar/repository/provider/firestore.dart';
import 'package:flutter/material.dart';

import 'package:cellar/domain/entities/user.dart';
import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/domain/models/timeline.dart';

import 'package:cellar/app/widget/drink_grid.dart';
import 'package:cellar/app/widget/atoms/normal_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.user}) : super(key: key);

  final User user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Drink> drinks = [];
  TimelineType timelineType = TimelineType.Mine;
  DrinkType drinkType;
  bool loading = true;
  int uploadCount = 0;
  List<int> uploadCounts = List.generate(DrinkType.values.length, (_) => 0);

  @override
  void initState() {
    super.initState();

    _updateTimeline();
    getUploadCounts().then((rawData) {
      int count = 0;
      rawData.sort((DocumentSnapshot dataA, DocumentSnapshot dataB) {
        final idA = int.parse(dataA.documentID);
        final idB = int.parse(dataB.documentID);
        return idA.compareTo(idB);
      });

      setState(() {
        this.uploadCounts = rawData.map((data) {
          count += data['uploadCount'];
          return data['uploadCount'];
        }).toList().cast<int>();
        this.uploadCount = count;
      });
    });
  }

  void _movePostPage() async {
    final isPosted = await Navigator.of(context).pushNamed('/post');

    if (isPosted != null) {
      _updateTimeline();
    }
  }

  Future<void> _updateTimeline() async {
    setState(() {
      this.loading = true;
      this.drinks = [];
    });

    final drinks = await getTimelineImageUrls(
      timelineType,
      drinkType: drinkType,
      userId: widget.user.userId,
    );

    setState(() {
      this.drinks = drinks;
      this.loading = false;
    });
  }

  void _updateTimelineType(TimelineType timelineType) {
    if (this.timelineType == timelineType) {
      return;
    }

    setState(() {
      this.timelineType = timelineType;
      this.drinkType = null;
    });

    _updateTimeline();
  }

  void _updateDrinkType(DrinkType drinkType) {
    if (this.drinkType == drinkType) {
      return;
    }

    setState(() {
      this.drinkType = drinkType;
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
          return uploadCount;
        case TimelineType.Mine:
          return widget.user.uploadCount;
      }
    }

    switch(timelineType) {
      case TimelineType.All:
        return uploadCounts[drinkType.index];
      case TimelineType.Mine:
        return widget.user.drinkTypeUploadCounts[drinkType.index];
    }

    throw 'timelineTypeの考慮漏れです';
  }

  _updateDrink(int index, bool isDelete) {
    if (isDelete) {
      setState(() {
        this.drinks.removeAt(index);
      });
      return;
    }

    setState(() {});
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
          Container(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                ButtonTheme(
                  minWidth: 40,
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
                    onPressed: () => _updateDrinkType(null),
                  ),
                ),
                ...widget.user.drinkTypesByMany.map((userDrinkType) {
                  final count = getUploadCount(userDrinkType);
                  if (count == 0) {
                    return Container();
                  }

                  return ButtonTheme(
                    minWidth: 40,
                    child: FlatButton(
                      textColor: drinkType == userDrinkType
                          ? Colors.white
                          : Colors.white38,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: <Widget>[
                          NormalText(
                            drinkTypeMapToLabel[userDrinkType],
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
                      onPressed: () => _updateDrinkType(userDrinkType),
                    ),
                  );
                }).toList()
              ],
            ),
          ),
          Expanded(
            child: loading
              ? Row(
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
              )
              : RefreshIndicator(
                onRefresh: _refresh,
                child: drinks.length == 0
                  ? SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 64,
                        bottom: 300,
                      ),
                      child: NormalText('見つかりませんでした'),
                    ),
                  )
                  : DrinkGrid(drinks: drinks, updateDrink: _updateDrink),
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
                flex: 2,
                child: Icon( // 場所の調整のために見えない要素を置く
                  Icons.no_sim,
                  size: 32,
                  color: Colors.transparent,
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
}
