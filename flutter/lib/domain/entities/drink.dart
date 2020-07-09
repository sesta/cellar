import 'dart:async';
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
  DateTime postDatetime;

  String thumbImagePath;
  List<String> imagePaths;
  String thumbImageUrl;
  List<String> imageUrls;
  int firstImageWidth;
  int firstImageHeight;

  Drink(
      this.userId,
      this.userName,
      this.drinkName,
      this.drinkType,
      this.score,
      this.memo,
      this.price,
      this.place,
      this.postDatetime,
      this.thumbImagePath,
      this.imagePaths,
      this.firstImageWidth,
      this.firstImageHeight,
  );

  init() async {
    thumbImageUrl = await getDataUrl(thumbImagePath);
  }

  getImageUrls() async {
    imageUrls = [];
    await Future.forEach(imagePaths, (path) async {
      imageUrls.add(await getDataUrl(path));
    });
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
      'postTimestamp': postDatetime.millisecondsSinceEpoch,
      'thumbImagePath': thumbImagePath,
      'imagePaths': imagePaths,
      'firstImageWidth': firstImageWidth,
      'firstImageHeight': firstImageHeight,
    });
  }

  @override
  String toString() {
    return 'drinkName: $drinkName, '
        'postDatetime: ${postDatetime.toString()}, '
        'imageLength ${imagePaths.length}';
  }
}
