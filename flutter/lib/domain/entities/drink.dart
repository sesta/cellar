import 'package:intl/intl.dart';

import 'package:bacchus/repository/provider/firestore.dart';
import 'package:bacchus/repository/provider/storage.dart';


enum DrinkType {
  Sake,
  Wine,
  Whisky
}

class Drink {
  String userId;
  String userName;
  String name;
  DrinkType drinkType;
  int score;
  String memo;
  int price;
  String place;


  String thumbImagePath;
  List<String> imagePaths;
  DateTime updateDatetime;
  String thumbImageUrl;

  Drink(
      this.userId,
      this.userName,
      this.name,
      this.drinkType,
      this.score,
      this.memo,
      this.price,
      this.place,
      this.thumbImagePath,
      this.imagePaths,
      this.updateDatetime,
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

  get updateDatetimeString {
    final formatter = DateFormat('yyyy/MM/dd');
    return formatter.format(updateDatetime);
  }

  addStore() {
    addData('drinks', {
      'userId': userId,
      'userName': userName,
      'name': name,
      'drinkTypeIndex': drinkType.index,
      'score': score,
      'memo': memo,
      'price': price,
      'place': place,
      'thumbImagePath': thumbImagePath,
      'imagePaths': imagePaths,
      'timestamp': updateDatetime.millisecondsSinceEpoch,
    });
  }

  @override
  String toString() {
    return 'name: $name, '
        'updateDatetime: ${updateDatetime.toString()}, '
        'imageLength ${imagePaths.length}';
  }
}
