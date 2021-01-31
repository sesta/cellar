import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cellar/domain/entity/entities.dart';

import 'package:cellar/app/widget/atoms/text_input.dart';

class DrinkForm extends StatelessWidget {
  DrinkForm({
    @required this.user,
    @required this.drinkDateTime,
    @required this.isPrivate,
    @required this.nameController,
    @required this.priceController,
    @required this.placeController,
    @required this.originController,
    @required this.memoController,
    @required this.score,
    @required this.drinkType,
    @required this.subDrinkType,
    @required this.updateDrinkDateTime,
    @required this.updateIsPrivate,
    @required this.updateDrinkType,
    @required this.updateSubDrinkType,
    @required this.updateScore,
  });
  
  final User user;

  final DateTime drinkDateTime;
  final bool isPrivate;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController placeController;
  final TextEditingController originController;
  final TextEditingController memoController;
  final int score;
  final DrinkType drinkType;
  final SubDrinkType subDrinkType;

  final updateDrinkDateTime;
  final updateIsPrivate;
  final updateDrinkType;
  final updateSubDrinkType;
  final updateScore;

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime dateTime = await showDatePicker(
      context: context,
      initialDate: drinkDateTime,
      firstDate: DateTime(2016),
      lastDate: now,
      helpText: '飲んだ日を選択してください。',
    );

    if (dateTime != null) {
      // ソートの関係で同じ値を持ちたくないので、現在時刻をいれる
      updateDrinkDateTime(dateTime.add(Duration(
        hours: now.hour,
        minutes: now.minute,
        seconds: now.second,
        milliseconds: now.millisecond,
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<SubDrinkType> subDrinkTypes = drinkType == null ? [SubDrinkType.Empty] : drinkType.subDrinkTypes;
    final formatter = DateFormat('yyyy/MM/dd');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '飲んだ日 *',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  InkWell(
                    child: Container(
                      width: 104,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        formatter.format(drinkDateTime),
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Colors.white38,
                              width: 1,
                              style: BorderStyle.solid
                          ),
                        ),
                      ),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(right: 24)),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '公開設定 *',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  DropdownButton(
                    itemHeight: 56,
                    value: isPrivate,
                    onChanged: updateIsPrivate,
                    icon: Icon(Icons.arrow_drop_down),
                    underline: Container(
                      padding: EdgeInsets.only(bottom: 100),
                      height: 1,
                      color: Colors.white38,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: false,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: 24,
                          ),
                          child: Text(
                            '公開',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: true,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: 24,
                          ),
                          child: Text(
                            '非公開',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(bottom: 24)),

          Text(
            'お酒の名前 *',
            style: Theme.of(context).textTheme.subtitle2,
          ),
          TextInput(
            nameController,
            textStyle: Theme.of(context).textTheme.subtitle1,
          ),
          Padding(padding: EdgeInsets.only(bottom: 24)),

          Text(
            '評価 *',
            style: Theme.of(context).textTheme.subtitle2,
          ),
          Padding(padding: const EdgeInsets.only(bottom: 8)),
          Row(
            children: List.generate(5, (i)=> i).map<Widget>((index) =>
              SizedBox(
                height: 32,
                width: 32,
                child: IconButton(
                  padding: EdgeInsets.all(4),
                  onPressed: () => updateScore(index + 1),
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
                  Text(
                    '種類 *',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  DropdownButton(
                    itemHeight: 56,
                    value: drinkType,
                    onChanged: updateDrinkType,
                    icon: Icon(Icons.arrow_drop_down),
                    underline: Container(
                      height: 1,
                      color: Colors.white38,
                    ),
                    items: user.drinkTypesByMany.map((DrinkType type) =>
                      DropdownMenuItem(
                        value: type,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: 80,
                            minHeight: 24,
                          ),
                          child: Text(
                            type.label,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
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
                  Text(
                    '種類の詳細',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  DropdownButton(
                    itemHeight: 56,
                    value: subDrinkType,
                    onChanged: updateSubDrinkType,
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
                            minHeight: 24,
                          ),
                          child: Text(
                            type.label,
                            style: Theme.of(context).textTheme.subtitle1,
                          )
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '原産地',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    TextInput(
                      originController,
                      textStyle: Theme.of(context).textTheme.subtitle1,
                      placeholder: 'イタリア、新潟',
                    ),
                  ],
                ),
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
                    Text(
                      '価格',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    TextInput(
                      priceController,
                      textStyle: Theme.of(context).textTheme.subtitle1,
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
                    Text(
                      '購入した場所',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    TextInput(
                      placeController,
                      textStyle: Theme.of(context).textTheme.subtitle1,
                      placeholder: 'Amazon、飲食店、プレゼント',
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(bottom: 24)),

          Text(
            'メモ',
            style: Theme.of(context).textTheme.subtitle2,
          ),
          TextInput(
            memoController,
            textStyle: Theme.of(context).textTheme.bodyText1,
            maxLines: 3,
            placeholder: '辛口だけど飲みやすい\nチーズと合う',
          ),
        ],
      ),
    );
  }
}
