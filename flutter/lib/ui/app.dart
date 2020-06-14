import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    // TODO: 画像の容量をどうにかする
    // TODO: 画像の内容をチェックする
    ByteData byteData = await resultList[0].getByteData();
    List<int> imageData = byteData.buffer.asUint8List();
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    final StorageReference storageReference = FirebaseStorage().ref().child('upload_images').child('image_$timestamp');
    final StorageUploadTask uploadTask = storageReference.putData(
      imageData,
      StorageMetadata(
        contentType: "image/jpeg",
      )
    );
    StorageTaskSnapshot snapshot = await uploadTask.onComplete;

    if (snapshot.error == null) {
      String url = await snapshot.ref.getDownloadURL();
      Firestore.instance.collection('posts').document()
        .setData({
          'timestapm': timestamp,
          'imagePath': url,
        });
    } else {
      print('error: $snapshot.error');
    }
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