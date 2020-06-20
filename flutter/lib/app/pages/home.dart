import 'package:flutter/material.dart';

import 'package:bacchus/app/widget/image_grid.dart';
import 'package:bacchus/domain/models/timeline.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();

    getTimelineImageUrls().then((urls) {
      setState(() {
        imageUrls = urls;
      });
    });
  }

  void _movePostPage() async {
    final isPosted = await Navigator.of(context).pushNamed('/post');

    if (isPosted != null) {
      getTimelineImageUrls().then((urls) {
        setState(() {
          imageUrls = urls;
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
      body: imageUrls.length == 0 ?
      Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Download中')
              ]
          )
      ) :
      ImageGrid(imageUrls: imageUrls),
      floatingActionButton: FloatingActionButton(
        onPressed: _movePostPage,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
