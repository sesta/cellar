import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cellar/domain/entity/entities.dart';

import 'package:cellar/app/widget/atoms/normal_text.dart';
import 'package:cellar/app/widget/atoms/normal_text_field.dart';

class DrinkForm extends StatelessWidget {
  DrinkForm({
    @required this.user,
    @required this.drinkDateTime,
    @required this.nameController,
    @required this.priceController,
    @required this.placeController,
    @required this.memoController,
    @required this.score,
    @required this.drinkType,
    @required this.subDrinkType,
    @required this.updateDrinkDateTime,
    @required this.updateDrinkType,
    @required this.updateSubDrinkType,
    @required this.updateScore,
  });
  
  final User user;

  final DateTime drinkDateTime;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController placeController;
  final TextEditingController memoController;
  final int score;
  final DrinkType drinkType;
  final SubDrinkType subDrinkType;

  final updateDrinkDateTime;
  final updateDrinkType;
  final updateSubDrinkType;
  final updateScore;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime dateTime = await showDatePicker(
      context: context,
      initialDate: drinkDateTime,
      firstDate: DateTime(2016),
      lastDate: DateTime.now(),
      helpText: '飲んだ日を選択してください。',
    );

    if (dateTime != null) {
      updateDrinkDateTime(dateTime);
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
          NormalText('飲んだ日 *'),
          InkWell(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: NormalText(
                formatter.format(drinkDateTime),
                bold: true,
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
          Padding(padding: EdgeInsets.only(bottom: 24)),

          NormalText('名前 *'),
          NormalTextField(
            nameController,
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
                  NormalText('種類 *'),
                  DropdownButton(
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
                          ),
                          child: NormalText(type.label, bold: true),
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
                          ),
                          child: NormalText(type.label, bold: true)
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
                      placeholder: 'Amazon、飲食店、プレゼント',
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
            placeholder: '辛口だけど飲みやすい\nチーズと合う',
          ),
        ],
      ),
    );
  }
}
