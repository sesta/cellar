import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

import 'package:bacchus/domain/entities/user.dart';
import 'package:bacchus/domain/models/post.dart';

class PostPage extends StatefulWidget {
  PostPage({Key key, this.user}) : super(key: key);

  final User user;

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<Asset> imageAssets = [];
  List<List<int>> images = [];

  @override
  void initState() {
    super.initState();

    _getImageList();
  }

  void _getImageList() async {
    List<Asset> resultList;
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
      );
    } catch (e) {
      return ;
    }

    if (resultList == null || resultList.length == 0) {
      return ;
    }

    List<List<int>> images = [];
    await Future.forEach(resultList, (Asset result) async {
      final data = await result.getByteData();
      images.add(data.buffer.asUint8List());
    });

    setState(() {
      this.imageAssets = resultList;
      this.images = images;
    });
  }

  void _postSake() async {
    if (images.length == 0) {
      return;
    }

    await post(widget.user.id, imageAssets);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('酒の投稿'),
      ),
      body: Column(
        children: [
          images.length > 0 ? Column(
            children: images.map<Widget>((List<int> image) {
              return Image(
                image: MemoryImage(image),
              );
            }).toList(),
          ) : Text('12'),
          FlatButton(
            onPressed: _postSake,
            child: Text('投稿する'),
          ),
        ]
      ),
    );
  }
}
