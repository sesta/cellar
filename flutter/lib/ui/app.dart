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
  String imageUrl;

  @override
  void initState() {
    super.initState();
    final StorageReference storageReference = FirebaseStorage().ref().child('post_images/image_1592094238094');
    storageReference.getDownloadURL().then((url) {
      print(url);
      setState(() {
        imageUrl = url;
      });
    });
  }

  void _getImageList() async {
    var resultList = await MultiImagePicker.pickImages(
      maxImages: 10,
    );

    const String BASE_IMAGE_PATH =  'post_images';

    // TODO: 画像の容量をどうにかする
    // TODO: 画像の内容をチェックする
    ByteData byteData = await resultList[0].getByteData();
    List<int> imageData = byteData.buffer.asUint8List();
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    final String imageName = 'image_$timestamp';
    final StorageReference storageReference = FirebaseStorage().ref().child('$BASE_IMAGE_PATH/$imageName');
    final StorageUploadTask uploadTask = storageReference.putData(
      imageData,
      StorageMetadata(
        contentType: "image/jpeg",
      )
    );
    StorageTaskSnapshot snapshot = await uploadTask.onComplete;

    if (snapshot.error == null) {
      print('upload success');
      Firestore.instance.collection('posts').document()
        .setData({
          'timestamp': timestamp,
          'imagePath': '$BASE_IMAGE_PATH/$imageName',
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
            imageUrl == null ?
              null :
              Image(
                image: NetworkImage(imageUrl),
              )
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
