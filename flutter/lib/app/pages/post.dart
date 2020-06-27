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
        maxImages: 5,
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
          images.length > 0 ? ImagePreview(images: images) : Text('12'),
          FlatButton(
            onPressed: _postSake,
            child: Text('投稿する'),
          ),
        ]
      ),
    );
  }
}

class ImagePreview extends StatefulWidget {
  ImagePreview({
    Key key,
    this.images,
  }) : super(key: key);

  final List<List<int>> images;

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  List<int> bigImage;

  @override
  void initState() {
    super.initState();

    setState(() {
      this.bigImage = widget.images[0];
    });
  }

  _updateIndex(image) {
    setState(() {
      this.bigImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Image(
            image: MemoryImage(bigImage),
            fit: BoxFit.cover,
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          padding: EdgeInsets.all(8),
          childAspectRatio: 1,
          children: widget.images.map<Widget>((image) {
            return GestureDetector(
              child: Material(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                clipBehavior: Clip.antiAlias,
                child: Image(
                  image: MemoryImage(image),
                  fit: BoxFit.cover,
                  color: Color.fromRGBO(255, 255, 255, image == bigImage ? 0.76 : 1),
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
              onTap: () => _updateIndex(image),
            );
          }).toList(),
        ),
      ],
    );
  }
}
