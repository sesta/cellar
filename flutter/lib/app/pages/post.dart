import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/domain/entities/user.dart';
import 'package:cellar/domain/models/post.dart';
import 'package:cellar/app/widget/atoms/normal_text.dart';
import 'package:cellar/app/widget/atoms/normal_text_field.dart';

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
  SubDrinkType subDrinkType = SubDrinkType.Empty;
  int score = 3;
  bool uploading = false;

  final nameController = TextEditingController();
  final memoController = TextEditingController();
  final priceController = TextEditingController();
  final placeController = TextEditingController();

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
      this.subDrinkType = SubDrinkType.Empty;
    });
  }

  void _updateSubDrinkType(SubDrinkType subDrinkType) {
    setState(() {
      this.subDrinkType = subDrinkType;
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
                  child: NormalText('どの写真を使いますか'),
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
  }

  void _postDrink() async {
    if (
      images.length == 0
      || nameController.text == ''
      || drinkType == null
    ) {
      return;
    }

    setState(() {
      this.uploading = true;
    });

    await post(
      widget.user.id,
      widget.user.userName,
      imageAssets,
      nameController.text,
      drinkType,
      subDrinkType,
      score,
      memoController.text,
      priceController.text == '' ? 0 : int.parse(priceController.text),
      placeController.text,
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final List<SubDrinkType> subDrinkTypes = drinkType == null ? [SubDrinkType.Empty] : drinkTypeMapToSub[drinkType];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '投稿',
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: [
                ImagePreview(images: images, addImage: _getImageList),

                Padding(
                  padding: EdgeInsets.only(top: 32, right: 16, left: 16, bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      NormalText('名前 *'),
                      NormalTextField(
                        nameController,
                        bold: true
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 24)),

                      NormalText('評価 *'),
                      Padding(padding: const EdgeInsets.only(bottom: 8)),
                      Row(
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
                      Padding(padding: EdgeInsets.only(bottom: 24)),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              NormalText('種類 *'),
                              DropdownButton(
                                value: drinkType,
                                onChanged: _updateDrinkType,
                                icon: Icon(Icons.arrow_drop_down),
                                underline: Container(
                                  height: 1,
                                  color: Colors.white38,
                                ),
                                items: DrinkType.values.map((type) =>
                                  DropdownMenuItem(
                                    value: type,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: 80,
                                      ),
                                      child: NormalText(drinkTypeMapToLabel[type], bold: true),
                                    ),
                                  )
                                ).toList(),
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(right: 24)),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              NormalText('種類の詳細'),
                              DropdownButton(
                                value: subDrinkType,
                                onChanged: _updateSubDrinkType,
                                icon: Icon(Icons.arrow_drop_down),
                                underline: Container(
                                  height: 1,
                                  color: Colors.white38,
                                ),
                                items: subDrinkTypes.map((type) =>
                                  DropdownMenuItem(
                                    value: type,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: 100,
                                      ),
                                      child: NormalText(subDrinkTypeMapToLabel[type], bold: true)
                                    ),
                                  )
                                ).toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 24)),

                      Row(
                        children: <Widget>[
                          Container(
                            width: 104,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                NormalText('価格'),
                                NormalTextField(
                                  priceController,
                                  bold: true,
                                  inputType: InputType.Number,
                                ),
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(right: 24)),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                NormalText('購入した場所'),
                                NormalTextField(
                                  placeController,
                                  bold: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 24)),

                      NormalText('メモ'),
                      NormalTextField(
                        memoController,
                        bold: true,
                        maxLines: 3,
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 64),
                        child: Center(
                          child: RaisedButton(
                            onPressed: _postDrink,
                            child: Text(
                              '投稿する',
                              style: TextStyle(
                                fontSize: 18,
                            ),
                            ),
                            color: Theme.of(context).accentColor,
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
          uploading ? Container(
            color: Colors.black38,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ) : Container(),
        ],
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
