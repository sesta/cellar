import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/domain/models/post.dart';
import 'package:cellar/repository/repositories.dart';

import 'package:cellar/app/widget/drink_form.dart';
import 'package:cellar/app/widget/atoms/toast.dart';

class PostPage extends StatefulWidget {
  PostPage({
    Key key,
    @required this.status,
    @required this.user,
  }) : super(key: key);

  final Status status;
  final User user;

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<List<int>> _imageDataList = [];
  DateTime _drinkDateTime = DateTime.now();
  bool _isPrivate = false;
  DrinkType _drinkType;
  SubDrinkType _subDrinkType = SubDrinkType.Empty;
  int _score = 3;
  bool _loading = false;

  final _nameController = TextEditingController();
  final _memoController = TextEditingController();
  final _priceController = TextEditingController();
  final _placeController = TextEditingController();
  final _originController = TextEditingController();

  @override
  initState() {
    super.initState();

    // 内容が変わった時にボタンの状態が変わるようにする
    _nameController.addListener(() => setState(() {}));
    _memoController.addListener(() => setState(() {}));
    _priceController.addListener(() => setState(() {}));
    _placeController.addListener(() => setState(() {}));
    _originController.addListener(() => setState(() {}));

    SharedPreferences.getInstance().then((preferences) {
      final isPrivate = preferences.get('_isPrivate');
      if (isPrivate == null) {
        return;
      }
      setState(() {
        _isPrivate = preferences.get('_isPrivate');
      });
    });

    // 初期化が終わってからにするために少し遅らせる
    Future.delayed(Duration(milliseconds: 300))
      .then((_) => _getImageList());
  }

  get disablePost {
    return _imageDataList.length == 0
      || _nameController.text == ''
      || _nameController.text.length > 200
      || _drinkType == null
      || _originController.text.length > 100
      || _priceController.text.length > 30
      || _placeController.text.length > 100
      || _memoController.text.length > 1000;
  }

  _updateDrinkDateTime(DateTime drinkDateTime) {
    setState(() {
      _drinkDateTime = drinkDateTime;
    });
  }

  _updateIsPrivate(bool isPrivate) {
    setState(() {
      _isPrivate = isPrivate;
    });
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
          title: Text(
            "設定に移動してよろしいですか？",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          content: Text(
            'アプリの写真へのアクセスが\n許可されていません。',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          actions: <Widget>[
            // ボタン領域
            TextButton(
              child: Text(
                'やめる',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
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
    final status = await Permission.photos.request();
    if (status == PermissionStatus.denied) {
      _confirmOpenSetting();
      return;
    }

    List<XFile> resultList;
    final ImagePicker _picker = ImagePicker();
    try {
      resultList = await _picker.pickMultiImage();
    } catch (e) {
      return;
    }

    if (resultList == null || resultList.length == 0) {
      return;
    }

    setState(() {
      _loading = true;
    });

    List<List<int>> imageDataList = _imageDataList;
    await Future.forEach(resultList, (XFile result) async {
      final bytes = await result.readAsBytes();
      imageDataList.add(bytes);
    });

    setState(() {
      _imageDataList = imageDataList;
      _loading = false;
    });
  }


  _removeImage(int index) {
    setState(() {
      _imageDataList.removeAt(index);
    });
  }

  Future<void> _postDrink() async {
    if (disablePost) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await post(
        widget.user,
        _imageDataList,
        _drinkDateTime,
        _isPrivate,
        _nameController.text,
        _drinkType,
        _subDrinkType,
        _score,
        _memoController.text,
        _priceController.text == '' ? 0 : int.parse(_priceController.text),
        _placeController.text,
        _originController.text,
      );
    } catch (e, stackTrace) {
      showToast(context, '投稿に失敗しました。', isError: true);
      AlertRepository().send(
        '投稿に失敗しました。',
        stackTrace.toString(),
      );

      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      await widget.user.incrementUploadCount(_drinkType);
      if (!_isPrivate) {
        await widget.status.incrementUploadCount(_drinkType);
      }
    } catch (e, stackTrace) {
      AlertRepository().send(
        '投稿数の更新に失敗しました',
        stackTrace.toString().substring(0, 1000),
      );
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool('_isPrivate', _isPrivate);

    AnalyticsRepository().sendEvent(EventType.PostDrink, {});
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: [
                ImagePreview(
                  imageDataList: _imageDataList,
                  addImage: _getImageList,
                  removeImage: _removeImage,
                ),
                Padding(padding: EdgeInsets.only(bottom: 32)),

                DrinkForm(
                  user: widget.user,
                  drinkDateTime: _drinkDateTime,
                  isPrivate: _isPrivate,
                  nameController: _nameController,
                  priceController: _priceController,
                  placeController: _placeController,
                  originController: _originController,
                  memoController: _memoController,
                  score: _score,
                  drinkType: _drinkType,
                  subDrinkType: _subDrinkType,
                  updateDrinkDateTime: _updateDrinkDateTime,
                  updateIsPrivate: _updateIsPrivate,
                  updateDrinkType: _updateDrinkType,
                  updateSubDrinkType: _updateSubDrinkType,
                  updateScore: _updateScore,
                ),
                Padding(padding: EdgeInsets.only(bottom: 64)),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: disablePost ? null : _postDrink,
                      child: Text(
                        '投稿する',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        textStyle: TextStyle(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
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
    this.imageDataList,
    this.addImage,
    this.removeImage,
  }) : super(key: key);

  final List<List<int>> imageDataList;
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
      _bigImage = widget.imageDataList.length == 0 ? null : widget.imageDataList[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_bigImage == null && widget.imageDataList.length > 0) {
      setState(() {
        _bigImage = widget.imageDataList[0];
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
                  color: Theme.of(context).primaryColorDark,
                  child: Icon(Icons.add, size: 48, color: Colors.white),
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
              if (index < widget.imageDataList.length) {
                content = Stack(
                  children: <Widget>[
                    GestureDetector(
                      child: AspectRatio(
                        aspectRatio: IMAGE_ASPECT_RATIO,
                        child: Material(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          clipBehavior: Clip.antiAlias,
                          child: Image(
                            image: MemoryImage(widget.imageDataList[index]),
                            fit: BoxFit.cover,
                            color: Color.fromRGBO(255, 255, 255, widget.imageDataList[index] == _bigImage ? 1 : 0.3),
                            colorBlendMode: BlendMode.modulate,
                          ),
                        ),
                      ),
                      onTap: () => _updateIndex(widget.imageDataList[index]),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          color: Colors.black,
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

              if (index == widget.imageDataList.length) {
                content = GestureDetector(
                  child: AspectRatio(
                    aspectRatio: IMAGE_ASPECT_RATIO,
                    child: Material(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      clipBehavior: Clip.antiAlias,
                      color: Theme.of(context).primaryColorDark,
                      child: Icon(Icons.add, color: Colors.white),
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
