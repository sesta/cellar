import 'package:flutter/material.dart';

import 'package:cellar/domain/entities/user.dart';
import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/domain/models/timeline.dart';

import 'package:cellar/app/widget/drink_grid.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.user}) : super(key: key);

  final User user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Drink> drinks = [];
  TimelineType timelineType = TimelineType.Mine;

  @override
  void initState() {
    super.initState();

    _updateTimeline();
  }

  void _movePostPage() async {
    final isPosted = await Navigator.of(context).pushNamed('/post');

    if (isPosted != null) {
      _updateTimeline();
    }
  }

  void _updateTimeline() {
    getTimelineImageUrls(
      timelineType,
      userId: widget.user.id,
    ).then((drinks) {
      setState(() {
        this.drinks = drinks;
      });
    });
  }

  void _updateTimelineType(TimelineType timelineType) {
    if (this.timelineType == timelineType) {
      return;
    }

    setState(() {
      this.timelineType = timelineType;
      this.drinks = [];
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
              left: 16,
              right: 16,
            ),
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                'Cellar',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          drinks.length == 0 ?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                )
              ],
            ) :
            DrinkGrid(drinks: drinks),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor,
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
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _movePostPage,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
