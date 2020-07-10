import 'dart:async';
import 'package:intl/intl.dart';

import 'package:cellar/repository/provider/firestore.dart';
import 'package:cellar/repository/provider/storage.dart';


enum DrinkType {
  Sake,
  Shochu,
  Beer,
  Wine,
  Cidre,
  Brandy,
  Whisky,
  Vodka,
  Gin,
  Liqueur,
  Other,
}

final drinkTypeMapToLabel = {
  DrinkType.Sake: '日本酒',
  DrinkType.Shochu: '焼酎',
  DrinkType.Beer: 'ビール',
  DrinkType.Wine: 'ワイン',
  DrinkType.Cidre: 'シードル',
  DrinkType.Brandy: 'ブランデー',
  DrinkType.Whisky: 'ウイスキー',
  DrinkType.Vodka: 'ウォッカ',
  DrinkType.Gin: 'ジン',
  DrinkType.Liqueur: 'リキュール',
  DrinkType.Other: 'その他',
};

enum SubDrinkType {
  SakeDaiginjo,
  SakeGinjo,
  SakeTokubetuHonzojo,
  SakeHonzojo,
  SakeJunmaiDaiginjo,
  SakeJunmaiGinjo,
  SakeTokubetsuJunmai,
  SakeJunmai,
  ShochuKome,
  ShochuMugi,
  ShochuImo,
  ShochuKokuto,
  ShochuSoba,
  ShochuKuri,
  ShochuPotato,
  ShochuToumorokoshi,
  ShochuAwamori,
  BeerLager,
  BeerAle,
  WineRed,
  WineWhite,
  WineRose,
  WineSparkling,
  WineDessert,
  BrandyCognac,
  BrandyArmagnac,
  BrandyCalvados,
  WhiskyScotch,
  WhiskyCanadian,
  WhiskyIrish,
  WhiskyAmerican,
  WhiskyJapanese,
  GinDry,
  GinJenever,
  GinOldTom,
  GinSteinhager,
}

final subDrinkTypeMapToLabel = {
  SubDrinkType.SakeDaiginjo: '大吟醸酒',
  SubDrinkType.SakeGinjo: '吟醸酒',
  SubDrinkType.SakeTokubetuHonzojo: '特別本醸造酒',
  SubDrinkType.SakeHonzojo: '本醸造酒',
  SubDrinkType.SakeJunmaiDaiginjo: '純米大吟醸酒',
  SubDrinkType.SakeJunmaiGinjo: '純米吟醸酒',
  SubDrinkType.SakeTokubetsuJunmai: '特別純米酒',
  SubDrinkType.SakeJunmai: '純米酒',

  SubDrinkType.ShochuKome: '米焼酎',
  SubDrinkType.ShochuMugi: '麦焼酎',
  SubDrinkType.ShochuImo: '芋焼酎',
  SubDrinkType.ShochuKokuto: '黒糖焼酎',
  SubDrinkType.ShochuSoba: 'そば焼酎',
  SubDrinkType.ShochuKuri: '栗焼酎',
  SubDrinkType.ShochuPotato: 'ジャガイモ焼酎',
  SubDrinkType.ShochuToumorokoshi: 'トウモロコシ焼酎',
  SubDrinkType.ShochuAwamori: '泡盛',

  SubDrinkType.BeerLager: 'エール',
  SubDrinkType.BeerAle: 'ラガー',

  SubDrinkType.WineRed: '赤ワイン',
  SubDrinkType.WineWhite: '白ワイン',
  SubDrinkType.WineRose: 'ロゼワイン',
  SubDrinkType.WineSparkling: 'スパークリングワイン',
  SubDrinkType.WineDessert: 'デザートワイン',

  SubDrinkType.BrandyCognac: 'コニャック',
  SubDrinkType.BrandyArmagnac: 'アルマニャック',
  SubDrinkType.BrandyCalvados: 'カルバドス',

  SubDrinkType.WhiskyScotch: 'スコッチウイスキー',
  SubDrinkType.WhiskyCanadian: 'カナディアンウイスキー',
  SubDrinkType.WhiskyIrish: 'アイリッシュウイスキー',
  SubDrinkType.WhiskyAmerican: 'アメリカンウイスキー',
  SubDrinkType.WhiskyJapanese: 'ジャパニーズウイスキー',

  SubDrinkType.GinDry: 'ドライ・ジン',
  SubDrinkType.GinJenever: 'イェネーバ',
  SubDrinkType.GinOldTom: 'オールド・トム・ジン',
  SubDrinkType.GinSteinhager: 'シュタインヘーガー',
};

final drinkTypeMapToSub = {
  DrinkType.Sake: [
    SubDrinkType.SakeDaiginjo,
    SubDrinkType.SakeGinjo,
    SubDrinkType.SakeTokubetuHonzojo,
    SubDrinkType.SakeHonzojo,
    SubDrinkType.SakeJunmaiDaiginjo,
    SubDrinkType.SakeJunmaiGinjo,
    SubDrinkType.SakeTokubetsuJunmai,
    SubDrinkType.SakeJunmai,
  ],
  DrinkType.Shochu: [
    SubDrinkType.ShochuKome,
    SubDrinkType.ShochuMugi,
    SubDrinkType.ShochuImo,
    SubDrinkType.ShochuKokuto,
    SubDrinkType.ShochuSoba,
    SubDrinkType.ShochuKuri,
    SubDrinkType.ShochuPotato,
    SubDrinkType.ShochuToumorokoshi,
    SubDrinkType.ShochuAwamori,
  ],
  DrinkType.Beer: [
    SubDrinkType.BeerLager,
    SubDrinkType.BeerAle,
  ],
  DrinkType.Wine: [
    SubDrinkType.WineWhite,
    SubDrinkType.WineRed,
    SubDrinkType.WineRose,
    SubDrinkType.WineSparkling,
    SubDrinkType.WineDessert,
  ],
  DrinkType.Cidre: [],
  DrinkType.Brandy: [
    SubDrinkType.BrandyCognac,
    SubDrinkType.BrandyArmagnac,
    SubDrinkType.BrandyCalvados,
  ],
  DrinkType.Whisky: [
    SubDrinkType.WhiskyScotch,
    SubDrinkType.WhiskyCanadian,
    SubDrinkType.WhiskyIrish,
    SubDrinkType.WhiskyAmerican,
    SubDrinkType.WhiskyJapanese,
  ],
  DrinkType.Vodka: [],
  DrinkType.Gin: [
    SubDrinkType.GinDry,
    SubDrinkType.GinJenever,
    SubDrinkType.GinOldTom,
    SubDrinkType.GinSteinhager,
  ],
  DrinkType.Liqueur: [],
  DrinkType.Other: [],
};

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
    return drinkTypeMapToLabel[drinkType];
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
