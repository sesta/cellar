import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/repositories.dart';

import 'package:cellar/app/widget/drink_form.dart';
import 'package:cellar/app/widget/atoms/toast.dart';

class EditPage extends StatefulWidget {
  EditPage({
    Key key,
    @required this.status,
    @required this.user,
    @required this.drink,
  }) : super(key: key);

  final Status status;
  final User user;
  final Drink drink;

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  DateTime _drinkDateTime;
  bool _isPrivate;
  DrinkType _drinkType;
  SubDrinkType _subDrinkType = SubDrinkType.Empty;
  int _score = 3;
  bool _uploading = false;

  final _nameController = TextEditingController();
  final _memoController = TextEditingController();
  final _priceController = TextEditingController();
  final _placeController = TextEditingController();
  final _originController = TextEditingController();

  @override
  initState() {
    super.initState();

    _nameController.text = widget.drink.drinkName;
    _memoController.text = widget.drink.memo;
    _placeController.text = widget.drink.place;
    _originController.text = widget.drink.origin;
    if (widget.drink.price > 0) {
      _priceController.text = widget.drink.price.toString();
    }

    // 内容が変わった時にボタンの状態が変わるようにする
    _nameController.addListener(() => setState(() {}));
    _memoController.addListener(() => setState(() {}));
    _priceController.addListener(() => setState(() {}));
    _placeController.addListener(() => setState(() {}));
    _originController.addListener(() => setState(() {}));

    setState(() {
      _drinkDateTime = widget.drink.drinkDateTime;
      _isPrivate = widget.drink.isPrivate;
      _drinkType = widget.drink.drinkType;
      _subDrinkType = widget.drink.subDrinkType;
      _score = widget.drink.score;
    });
  }

  get _disablePost {
    return _nameController.text == ''
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

  Future<void> _updateDrink() async {
    if (_disablePost) {
      return;
    }

    setState(() {
      _uploading = true;
    });

    final oldDrinkType = widget.drink.drinkType;
    final oldIsPrivate = widget.drink.isPrivate;

    try {
      await widget.drink.update(
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
      showToast(context, '更新に失敗しました。', isError: true);
      AlertRepository().send(
        'お酒の更新に失敗しました。',
        stackTrace.toString().substring(0, 1000),
      );

      return;
    }

    try {
      if (_drinkType != oldDrinkType) {
        await widget.user.moveUploadCount(oldDrinkType, _drinkType);
        await widget.status.moveUploadCount(oldDrinkType, _drinkType);
      }
      if (_isPrivate != oldIsPrivate) {
        if (_isPrivate) {
          // 非公開になったということなので、古いDrinkTypeを-1する
          await widget.status.decrementUploadCount(oldDrinkType);
        }

        if (oldIsPrivate) {
          // 公開になったということなので、新しいDrinkTypeを+1する
          await widget.status.incrementUploadCount(oldDrinkType);
        }
      }
    } catch (e, stackTrace) {
      AlertRepository().send(
        '投稿数の更新に失敗しました',
        stackTrace.toString().substring(0, 1000),
      );
    }

    AnalyticsRepository().sendEvent(
      EventType.EditDrink,
      { 'drinkId': widget.drink.drinkId },
    );
    Navigator.of(context).pop(false);
  }

  Future<void> _confirmDelete() async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            backgroundColor: Theme.of(context).backgroundColor,
            title: Text(
              "本当に削除してよろしいですか？",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            content: Text(
              '削除した投稿は復元できません。',
              style: Theme.of(context).textTheme.bodyText2,
            ),
            actions: <Widget>[
              // ボタン領域
              TextButton(
                child: Text(
                  'やめる',
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  '削除する',
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: Theme.of(context).errorColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _delete();
                },
              ),
            ],
          ),
    );
  }

  Future<void> _delete() async {
    setState(() {
      _uploading = true;
    });

    try {
      await widget.drink.delete();
    } catch (e, stackTrace) {
      showToast(context, '削除に失敗しました。', isError: true);
      AlertRepository().send(
      'お酒の削除に失敗しました。',
      stackTrace.toString().substring(0, 1000),
      );

      return;
    }

    try {
      await widget.user.decrementUploadCount(widget.drink.drinkType);
      if (!widget.drink.isPrivate) {
        await widget.status.decrementUploadCount(widget.drink.drinkType);
      }
    } catch (e, stackTrace) {
      AlertRepository().send(
      '投稿数の更新に失敗しました',
      stackTrace.toString().substring(0, 1000),
      );
    }

    AnalyticsRepository().sendEvent(
      EventType.DeleteDrink,
      { 'drinkId': widget.drink.drinkId },
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          '編集',
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(bottom: 24)),
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _confirmDelete,
                      child: Text(
                        '削除する',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).errorColor,
                        textStyle: TextStyle(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(right: 32)),
                    ElevatedButton(
                      onPressed: _disablePost ? null : _updateDrink,
                      child: Text(
                        '更新する',
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
                  ],
                ),
                Padding(padding: EdgeInsets.only(bottom: 64)),
              ],
            ),
          ),
          _uploading ? Container(
            color: Colors.black38,
            alignment: Alignment.center,
            child: Lottie.asset(
              'assets/lottie/loading.json',
              width: 80,
              height: 80,
            ),
          ) : Container(),
        ],
      ),
    );
  }
}
