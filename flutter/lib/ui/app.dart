import 'package:flutter/material.dart';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bacchus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Bacchus Top'),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}



class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _getImageList() async {
    var resultList = await MultiImagePicker.pickImages(
      maxImages: 10,
    );

    print(resultList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '画像を選択できるだけ',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageList,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}