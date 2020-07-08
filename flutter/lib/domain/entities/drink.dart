import 'package:intl/intl.dart';

import 'package:cellar/repository/provider/firestore.dart';
import 'package:cellar/repository/provider/storage.dart';


enum DrinkType {
  Sake,
  Wine,
  Whisky
}

class Drink {
  String userId;
  String userName;
  String drinkName;
  DrinkType drinkType;
  int score;
  String memo;
  int price;
  String place;


  String thumbImagePath;
  List<String> imagePaths;
  DateTime postDatetime;
  String thumbImageUrl;

  Drink(
      this.userId,
      this.userName,
      this.drinkName,
      this.drinkType,
      this.score,
      this.memo,
      this.price,
      this.place,
      this.thumbImagePath,
      this.imagePaths,
      this.postDatetime,
  );

  init() async {
    thumbImageUrl = await getDataUrl(thumbImagePath);
  }

  get drinkTypeLabel {
    switch(drinkType) {
      case DrinkType.Sake:
        return '日本酒';
      case DrinkType.Wine:
        return 'ワイン';
      case DrinkType.Whisky:
        return 'ウイスキー';
    }
  }

  get priceString {
    final formatter = NumberFormat('#,###');
    return "¥${formatter.format(price)}";
  }

  get postDatetimeString {
    final formatter = DateFormat('yyyy/MM/dd');
    return formatter.format(postDatetime);
  }

  addStore() {
    addData('drinks', {
      'userId': userId,
      'userName': userName,
      'drinkName': drinkName,
      'drinkTypeIndex': drinkType.index,
      'score': score,
      'memo': memo,
      'price': price,
      'place': place,
      'thumbImagePath': thumbImagePath,
      'imagePaths': imagePaths,
      'postTimestamp': postDatetime.millisecondsSinceEpoch,
    });
  }

  @override
  String toString() {
    return 'drinkName: $drinkName, '
        'postDatetime: ${postDatetime.toString()}, '
        'imageLength ${imagePaths.length}';
  }
}
