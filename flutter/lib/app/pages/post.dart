import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:mlkit/mlkit.dart';

import 'package:bacchus/domain/entities/drink.dart';
import 'package:bacchus/domain/entities/user.dart';
import 'package:bacchus/domain/models/post.dart';

enum UploadMethods {
  Camera,
  Library,
}

class PostPage extends StatefulWidget {
  PostPage({Key key, this.user}) : super(key: key);

  final User user;

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<Asset> imageAssets = [];
  List<List<int>> images = [];
  DrinkType drinkType;
  int score = 3;
  FirebaseVisionLabelDetector labelDetector = FirebaseVisionLabelDetector.instance;

  final nameController = TextEditingController();
  final memoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 初期化が終わってからにするために少し遅らせる
    Future.delayed(Duration(milliseconds: 300))
      .then((_) => _getImageList());
  }

  void _updateDrinkType(DrinkType drinkType) {
    setState(() {
      this.drinkType = drinkType;
    });
  }

  void _updateScore(int score) {
    setState(() {
      this.score = score;
    });
  }

  void _selectUploadMethod() async { // カメラは大変なのであとで
    final uploadMethod = await showModalBottomSheet<UploadMethods>(
        context: context,
        builder: (BuildContext context){
          return Container(
            height: 180,
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TitleText('どの写真を使いますか'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.pop(context, UploadMethods.Camera),
                      child: Text(
                        '写真を撮る',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ),
                    FlatButton(
                      onPressed: () => Navigator.pop(context, UploadMethods.Library),
                      child: Text(
                        'カメラロール',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ),
                  ],
                )
              ],
            ),
          );
        }
    );

    switch(uploadMethod) {
      case UploadMethods.Camera:
        print('camera');
        break;
      case UploadMethods.Library:
        _getImageList();
        break;
    }
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

    final List<VisionLabel> labels = await labelDetector.detectFromBinary(images[0]);
    DrinkType detectedDrinkType;
    labels.firstWhere((VisionLabel label) {
      if (label.label == 'Wine') {
        detectedDrinkType = DrinkType.Wine;
        return true;
      }

      return false;
    }, orElse: () => null);
    if (detectedDrinkType != null) {
      setState(() {
        this.drinkType = detectedDrinkType;
      });
    }
  }

  void _postDrink() async {
    if (
      images.length == 0
      || nameController.text == ''
      || drinkType == null
    ) {
      return;
    }

    await post(
      widget.user.id,
      imageAssets,
      nameController.text,
      drinkType,
      memoController.text,
    );
    Navigator.of(context).pop(true);
  }

  Widget NormalText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget TitleText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '投稿',
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          color: Colors.black87,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ImagePreview(images: images, addImage: _getImageList),
            Padding(
              padding: EdgeInsets.only(top: 32, right: 16, left: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TitleText('種類'),
                          DropdownButton(
                            value: drinkType,
                            onChanged: _updateDrinkType,
                            icon: Icon(Icons.arrow_drop_down),
                            underline: Container(
                              height: 1,
                              color: Colors.black38,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: DrinkType.Sake,
                                child: NormalText('日本酒'),
                              ),
                              DropdownMenuItem(
                                value: DrinkType.Wine,
                                child: NormalText('ワイン'),
                              ),
                              DropdownMenuItem(
                                value: DrinkType.Whisky,
                                child: NormalText('ウィスキー'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TitleText('評価'),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: List.generate(5, (i)=> i).map<Widget>((index) =>
                                  SizedBox(
                                    height: 32,
                                    width: 32,
                                    child: IconButton(
                                      padding: EdgeInsets.all(4),
                                      onPressed: () => _updateScore(index + 1),
                                      icon: Icon(index < score ? Icons.star : Icons.star_border),
                                      color: Colors.orangeAccent,
                                    ),
                                  )
                                ).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: TitleText('名前')
                  ),
                  TextField(
                    controller: nameController,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: TitleText('メモ')
                  ),
                  TextField(
                    controller: memoController,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(
                      child: RaisedButton(
                        onPressed: _postDrink,
                        child: Text(
                          '投稿する',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AspectRatio(
            aspectRatio: 1,
            child: bigImage == null ? (
              GestureDetector(
                child: Material(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  clipBehavior: Clip.antiAlias,
                  color: Theme.of(context).primaryColorLight,
                  child: Icon(Icons.add, size: 48, color: Colors.black87),
                ),
                onTap: widget.addImage,
              )
            ) : (
              Material(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                clipBehavior: Clip.antiAlias,
                child: Image(
                  image: MemoryImage(bigImage),
                  fit: BoxFit.cover,
                ),
              )
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Row(
            children: List.generate(5, (i)=> i).map<Widget>((index) {
              Widget content = Material();
              if (index < widget.images.length) {
                content = GestureDetector(
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
                );
              }

              if (index == widget.images.length) {
                content = GestureDetector(
                  child: Material(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    clipBehavior: Clip.antiAlias,
                    color: Theme.of(context).primaryColorLight,
                    child: Icon(Icons.add, color: Colors.black87),
                  ),
                  onTap: widget.addImage,
                );
              }

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 4, right: 4),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: content,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
