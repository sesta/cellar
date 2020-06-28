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

enum DrinkType { Wine, Nihonshu, Whisky }

class _PostPageState extends State<PostPage> {
  List<Asset> imageAssets = [];
  List<List<int>> images = [];
  DrinkType drinkType;

  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _getImageList();
  }

  void _updateDrinkType(DrinkType drinkType) {
    setState(() {
      this.drinkType = drinkType;
    });
  }

  void _getImageList() async {
    List<Asset> resultList;
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5 - this.images.length,
      );
    } catch (e) {
      return ;
    }

    if (resultList == null || resultList.length == 0) {
      return ;
    }

    List<List<int>> images = this.images;
    await Future.forEach(resultList, (Asset result) async {
      final data = await result.getByteData();
      images.add(data.buffer.asUint8List());
    });

    setState(() {
      this.imageAssets = this.imageAssets + resultList;
      this.images = images;
    });
  }

  void _postSake() async {
    if (images.length == 0) {
      return;
    }

    if (nameController.text == '') {
      return;
    }

    await post(widget.user.id, imageAssets, nameController.text);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('お酒の記録'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ImagePreview(images: images, addImage: _getImageList),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'お酒の名前',
                    ),
                  ),
                  DropdownButton(
                    value: drinkType,
                    onChanged: _updateDrinkType,
                    icon: Icon(Icons.arrow_drop_down),
                    items: [
                      DropdownMenuItem(
                        value: DrinkType.Nihonshu,
                        child: Text('日本酒'),
                      ),
                      DropdownMenuItem(
                        value: DrinkType.Wine,
                        child: Text('ワイン'),
                      ),
                      DropdownMenuItem(
                        value: DrinkType.Whisky,
                        child: Text('ウィスキー'),
                      ),
                    ],
                  ),
                  RaisedButton(
                    onPressed: _postSake,
                    child: Text('投稿する'),
                    color: Theme.of(context).primaryColorDark,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),

          ]
        ),
      ),
    );
  }
}

class ImagePreview extends StatefulWidget {
  ImagePreview({
    Key key,
    this.images,
    this.addImage,
  }) : super(key: key);

  final List<List<int>> images;
  final addImage;

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  List<int> bigImage;

  _updateIndex(image) {
    setState(() {
      this.bigImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (bigImage == null && widget.images.length > 0) {
      setState(() {
        this.bigImage = widget.images[0];
      });
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: bigImage == null ? (
            GestureDetector(
              child: Material(
                color: Colors.black26,
                child: Icon(Icons.add, size: 48),
              ),
              onTap: widget.addImage,
            )
          ) : (
            Image(
              image: MemoryImage(bigImage),
              fit: BoxFit.cover,
            )
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          padding: EdgeInsets.all(16),
          childAspectRatio: 1,
          children: List.generate(widget.images.length + 1, (i)=> i).map<Widget>((index) => index < widget.images.length ? (
            GestureDetector(
              child: Material(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                clipBehavior: Clip.antiAlias,
                child: Image(
                  image: MemoryImage(widget.images[index]),
                  fit: BoxFit.cover,
                  color: Color.fromRGBO(255, 255, 255, widget.images[index] == bigImage ? 0.76 : 1),
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
              onTap: () => _updateIndex(widget.images[index]),
            )
          ) : (
            GestureDetector(
              child: Material(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                clipBehavior: Clip.antiAlias,
                color: Colors.black26,
                child: Icon(Icons.add),
              ),
              onTap: widget.addImage,
            )
          )).toList(),
        ),
      ],
    );
  }
}
