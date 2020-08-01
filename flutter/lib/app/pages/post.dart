import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entities/status.dart';
import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/domain/entities/user.dart';
import 'package:cellar/domain/models/post.dart';
import 'package:cellar/repository/analytics_repository.dart';

import 'package:cellar/app/widget/drink_form.dart';
import 'package:cellar/app/widget/atoms/normal_text.dart';

class PostPage extends StatefulWidget {
  PostPage({
    Key key,
    this.status,
    this.user,
  }) : super(key: key);

  final Status status;
  final User user;

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<Asset> _imageAssets = [];
  List<List<int>> _images = [];
  DrinkType _drinkType;
  SubDrinkType _subDrinkType = SubDrinkType.Empty;
  int _score = 3;
  bool _loading = false;

  final _nameController = TextEditingController();
  final _memoController = TextEditingController();
  final _priceController = TextEditingController();
  final _placeController = TextEditingController();

  @override
  initState() {
    super.initState();

    _nameController.addListener(() => setState(() {}));

    // 初期化が終わってからにするために少し遅らせる
    Future.delayed(Duration(milliseconds: 300))
      .then((_) => _getImageList());
  }

  get disablePost {
    return _images.length == 0
        || _nameController.text == ''
        || _drinkType == null;
  }

  _updateDrinkType(DrinkType drinkType) {
    setState(() {
      _drinkType = drinkType;
      _subDrinkType = SubDrinkType.Empty;
    });
  }

  _updateSubDrinkType(SubDrinkType subDrinkType) {
    setState(() {
      _subDrinkType = subDrinkType;
    });
  }

  _updateScore(int score) {
    setState(() {
      _score = score;
    });
  }

  _confirmOpenSetting() {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
        AlertDialog(
          title: NormalText(
            "設定に移動してよろしいですか？",
            bold: true,
          ),
          content: NormalText(
            'アプリの写真へのアクセスが\n許可されていません。',
            multiLine: true,
          ),
          actions: <Widget>[
            // ボタン領域
            FlatButton(
              child: Text(
                'やめる',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text(
                '設定をひらく',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
            ),
          ],
        ),
    );
  }

  Future<void> _getImageList() async {
    final status = await Permission.photos.status;
    if (status == PermissionStatus.denied) {
      _confirmOpenSetting();
      return;
    }

    List<Asset> resultList;
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5 - _images.length,
        enableCamera: true,
      );
    } catch (e) {
      return;
    }

    if (resultList == null || resultList.length == 0) {
      return;
    }

    setState(() {
      _loading = true;
    });

    List<List<int>> images = _images;
    await Future.forEach(resultList, (Asset result) async {
      final data = await result.getByteData();
      images.add(data.buffer.asUint8List());
    });

    setState(() {
      _imageAssets = _imageAssets + resultList;
      _images = images;
      _loading = false;
    });
  }


  _removeImage(int index) {
    setState(() {
      _imageAssets.removeAt(index);
      _images.removeAt(index);
    });
  }

  Future<void> _postDrink() async {
    if (disablePost) {
      return;
    }

    setState(() {
      _loading = true;
    });

    await post(
      widget.user,
      _imageAssets,
      _nameController.text,
      _drinkType,
      _subDrinkType,
      _score,
      _memoController.text,
      _priceController.text == '' ? 0 : int.parse(_priceController.text),
      _placeController.text,
    );

    await widget.user.incrementUploadCount(_drinkType);
    await widget.status.incrementUploadCount(_drinkType);

    AnalyticsRepository().sendEvent(EventType.PostDrink, {});
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final List<SubDrinkType> subDrinkTypes = _drinkType == null ? [SubDrinkType.Empty] : _drinkType.subDrinkTypes;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '投稿',
        ),
        elevation: 0,
        leading:  IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: [
                ImagePreview(
                  images: _images,
                  addImage: _getImageList,
                  removeImage: _removeImage,
                ),
                Padding(padding: EdgeInsets.only(bottom: 32)),

                DrinkForm(
                  user: widget.user,
                  nameController: _nameController,
                  priceController: _priceController,
                  placeController: _placeController,
                  memoController: _memoController,
                  score: _score,
                  drinkType: _drinkType,
                  subDrinkType: _subDrinkType,
                  updateDrinkType: _updateDrinkType,
                  updateSubDrinkType: _updateSubDrinkType,
                  updateScore: _updateScore,
                ),
                Padding(padding: EdgeInsets.only(bottom: 64)),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      padding: EdgeInsets.all(16),
                      onPressed: disablePost ? null : _postDrink,
                      child: NormalText(
                        '投稿する',
                        bold: true,
                      ),
                      color: Theme.of(context).accentColor,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 120)),
              ],
            ),
          ),
          _loading ? Container(
            color: Colors.black38,
            alignment: Alignment.center,
            child: Lottie.asset(
              'assets/lottie/loading.json',
              width: 80,
              height: 80,
            )
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
    this.removeImage,
  }) : super(key: key);

  final List<List<int>> images;
  final addImage;
  final removeImage;

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  List<int> _bigImage;

  _updateIndex(image) {
    setState(() {
      _bigImage = image;
    });
  }

  _removeImage(int index) {
    widget.removeImage(index);

    setState(() {
      _bigImage = widget.images.length == 0 ? null : widget.images[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_bigImage == null && widget.images.length > 0) {
      setState(() {
        _bigImage = widget.images[0];
      });
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AspectRatio(
            aspectRatio: IMAGE_ASPECT_RATIO,
            child: _bigImage == null ? (
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
                  image: MemoryImage(_bigImage),
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
                content = Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    GestureDetector(
                      child: AspectRatio(
                        aspectRatio: IMAGE_ASPECT_RATIO,
                        child: Material(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          clipBehavior: Clip.antiAlias,
                          child: Image(
                            image: MemoryImage(widget.images[index]),
                            fit: BoxFit.cover,
                            color: Color.fromRGBO(255, 255, 255, widget.images[index] == _bigImage ? 1 : 0.3),
                            colorBlendMode: BlendMode.modulate,
                          ),
                        ),
                      ),
                      onTap: () => _updateIndex(widget.images[index]),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SizedBox(
                          height: 28,
                          width: 28,
                          child: IconButton(
                            onPressed: () => _removeImage(index),
                            padding: EdgeInsets.all(2),
                            icon: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white
                            ),
                            color: Colors.orangeAccent,
                            splashColor: Colors.transparent,
                          ),
                        ),
                      )
                    ),
                  ],
                );
              }

              if (index == widget.images.length) {
                content = GestureDetector(
                  child: AspectRatio(
                    aspectRatio: IMAGE_ASPECT_RATIO,
                    child: Material(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      clipBehavior: Clip.antiAlias,
                      color: Theme.of(context).primaryColorLight,
                      child: Icon(Icons.add, color: Colors.black87),
                    ),
                  ),
                  onTap: widget.addImage,
                );
              }

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 4, right: 4),
                  child: content,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
