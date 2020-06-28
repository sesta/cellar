import 'package:flutter/material.dart';

import 'package:bacchus/domain/entities/drink.dart';
import 'package:bacchus/domain/models/timeline.dart';

import 'package:bacchus/app/widget/sake_grid.dart';

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
      appBar: AppBar(
        title: Text('Bacchus'),
        centerTitle: false,
        elevation: 0,
      ),
      body: drinks.length == 0 ?
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
        SakeGrid(drinks: drinks),
      floatingActionButton: FloatingActionButton(
        onPressed: _movePostPage,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
