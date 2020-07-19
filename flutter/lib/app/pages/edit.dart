import 'package:cellar/domain/entities/status.dart';
import 'package:flutter/material.dart';

import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/domain/entities/user.dart';

import 'package:cellar/app/widget/atoms/normal_text.dart';
import 'package:cellar/app/widget/atoms/normal_text_field.dart';

class EditPage extends StatefulWidget {
  EditPage({
    Key key,
    this.status,
    this.user,
    this.drink,
  }) : super(key: key);

  final Status status;
  final User user;
  final Drink drink;

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  DrinkType drinkType;
  SubDrinkType subDrinkType = SubDrinkType.Empty;
  int score = 3;
  bool uploading = false;

  final nameController = TextEditingController();
  final memoController = TextEditingController();
  final priceController = TextEditingController();
  final placeController = TextEditingController();

  @override
  initState() {
    super.initState();

    nameController.text = widget.drink.drinkName;
    memoController.text = widget.drink.memo;
    placeController.text = widget.drink.place;

    if (widget.drink.price > 0) {
      priceController.text = widget.drink.price.toString();
    }

    setState(() {
      this.drinkType = widget.drink.drinkType;
      this.subDrinkType = widget.drink.subDrinkType;
      this.score = widget.drink.score;
    });
  }

  _updateDrinkType(DrinkType drinkType) {
    setState(() {
      this.drinkType = drinkType;
      this.subDrinkType = SubDrinkType.Empty;
    });
  }

  _updateSubDrinkType(SubDrinkType subDrinkType) {
    setState(() {
      this.subDrinkType = subDrinkType;
    });
  }

  _updateScore(int score) {
    setState(() {
      this.score = score;
    });
  }

  get disablePost {
    return nameController.text == ''
      || drinkType == null;
  }

  _updateDrink() async {
    if (disablePost) {
      return;
    }

    setState(() {
      this.uploading = true;
    });

    final oldDrinkType = widget.drink.drinkType;

    await widget.drink.update(
      nameController.text,
      drinkType,
      subDrinkType,
      score,
      memoController.text,
      priceController.text == '' ? 0 : int.parse(priceController.text),
      placeController.text,
    );
    if (drinkType != oldDrinkType) {
      await widget.user.moveUploadCount(oldDrinkType, drinkType);
      await widget.status.moveUploadCount(oldDrinkType, drinkType);
    }

    Navigator.of(context).pop(false);
  }

  _confirmDelete() async { // カメラは大変なのであとで
    final isDelete = await showModalBottomSheet<bool>(
        context: context,
        builder: (BuildContext context){
          return Container(
            height: 240,
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: NormalText(
                    '削除した投稿は復元できません。\n本当に削除してよろしいですか？',
                    multiLine: true,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        '削除する',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      color: Colors.redAccent,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(right: 32)),
                    RaisedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'やめる',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      color: Theme.of(context).accentColor,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }
    );

    if (isDelete == null || !isDelete) {
      return;
    }

    setState(() {
      this.uploading = true;
    });

    await widget.drink.delete();
    await widget.user.decrementUploadCount(drinkType);
    await widget.status.decrementUploadCount(drinkType);

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final List<SubDrinkType> subDrinkTypes = drinkType == null ? [SubDrinkType.Empty] : drinkTypeMapToSub[drinkType];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '編集',
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: [

                Padding(
                  padding: EdgeInsets.only(top: 32, right: 16, left: 16, bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      NormalText('名前 *'),
                      NormalTextField(
                          nameController,
                          onChanged: (_) => setState(() {}),
                          bold: true,
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
                                items: widget.user.drinkTypesByMany.map((DrinkType type) =>
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                              onPressed: _confirmDelete,
                              child: Text(
                                '削除する',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              color: Colors.redAccent,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(right: 32)),
                            RaisedButton(
                              onPressed: disablePost ? null : _updateDrink,
                              child: Text(
                                '更新する',
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
                          ],
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
