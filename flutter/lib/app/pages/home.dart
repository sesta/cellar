import 'package:flutter/material.dart';

import 'package:bacchus/domain/entities/drink.dart';
import 'package:bacchus/domain/models/timeline.dart';

import 'package:bacchus/app/widget/drink_grid.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Drink> drinks = [];

  @override
  void initState() {
    super.initState();

    getTimelineImageUrls().then((drinks) {
      setState(() {
        this.drinks = drinks;
      });
    });
  }

  void _movePostPage() async {
    final isPosted = await Navigator.of(context).pushNamed('/post');

    if (isPosted != null) {
      getTimelineImageUrls().then((drinks) {
        setState(() {
          this.drinks = drinks;
        });
      });
    }
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
                'Bacchus',
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
                child: Icon(
                  Icons.home,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              Expanded(
                flex: 1,
                child: Icon(
                  Icons.people,
                  size: 32,
                  color: Theme.of(context).primaryColorLight,
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
