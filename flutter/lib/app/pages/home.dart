import 'package:flutter/material.dart';

import 'package:bacchus/domain/entities/sake.dart';
import 'package:bacchus/domain/models/timeline.dart';

import 'package:bacchus/app/widget/sake_grid.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Sake> sakes = [];

  @override
  void initState() {
    super.initState();

    getTimelineImageUrls().then((sakes) {
      setState(() {
        this.sakes = sakes;
      });
    });
  }

  void _movePostPage() async {
    final isPosted = await Navigator.of(context).pushNamed('/post');

    if (isPosted != null) {
      getTimelineImageUrls().then((sakes) {
        setState(() {
          this.sakes = sakes;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: sakes.length == 0 ?
        Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Download中')
                ]
            )
        ) :
        SakeGrid(sakes: sakes),
      floatingActionButton: FloatingActionButton(
        onPressed: _movePostPage,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
