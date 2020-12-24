import 'package:intl/intl.dart';

import 'package:cellar/repository/repositories.dart';

class Drink {
  String drinkId;
  String userId;
  String userName;
  bool isPrivate;
  DateTime drinkDateTime;
  String drinkName;
  DrinkType drinkType;
  SubDrinkType subDrinkType;
  int score;
  String memo;
  int price;
  String place;
  String origin;
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
    this.isPrivate,
    this.drinkDateTime,
    this.drinkName,
    this.drinkType,
    this.subDrinkType,
    this.score,
    this.memo,
    this.price,
    this.place,
    this.origin,
    this.postDatetime,
    this.thumbImagePath,
    this.imagePaths,
    this.firstImageWidth,
    this.firstImageHeight,
    {
      this.drinkId,
    }
  );

  Future<void> init() async {
    thumbImageUrl = await StorageRepository().getUrl(thumbImagePath);
  }

  getImageUrls() async {
    imageUrls = [];
    await Future.forEach(imagePaths, (path) async {
      imageUrls.add(await StorageRepository().getUrl(path));
    });
  }

  get priceString {
    final formatter = NumberFormat('#,###');
    return "¥${formatter.format(price)}";
  }

  get drinkDatetimeString {
    final formatter = DateFormat('yyyy/MM/dd');
    return formatter.format(drinkDateTime);
  }

  Future<void> create() async {
    await DrinkRepository().createDrink(this);
  }

  Future<void> update(
    DateTime drinkDateTime,
    bool isPrivate,
    String drinkName,
    DrinkType drinkType,
    SubDrinkType subDrinkType,
    int score,
    String memo,
    int price,
    String place,
    String origin,
  ) async{
    if (drinkId == null) {
      throw '更新するためにはdrinkIdが必要です';
    }

    this.drinkDateTime = drinkDateTime;
    this.isPrivate = isPrivate;
    this.drinkName = drinkName;
    this.drinkType = drinkType;
    this.subDrinkType = subDrinkType;
    this.score = score;
    this.memo = memo;
    this.price = price;
    this.place = place;
    this.origin = origin;

    await DrinkRepository().updateDrink(this);
  }

  Future<void> delete() async{
    if (drinkId == null) {
      throw '削除するためにはdrinkIdが必要です';
    }

    await DrinkRepository().deleteDrink(drinkId);
  }

  @override
  String toString() {
    return 'drinkName: $drinkName, '
        'postDatetime: ${postDatetime.toString()}, '
        'imageLength ${imagePaths.length}';
  }
}

enum DrinkType {
  Sake,
  Shochu,
  Umeshu,
  Beer,
  Wine,
  Cidre,
  Brandy,
  Whisky,
  Vodka,
  Gin,
  Liqueur,
  Chuhai,
  Highball,
  Cocktail,
  Other,
}

extension DrinkTypeExtension on DrinkType {
  String get label {
    switch(this) {
      case DrinkType.Sake: return '日本酒';
      case DrinkType.Shochu: return '焼酎';
      case DrinkType.Umeshu: return '梅酒';
      case DrinkType.Beer: return 'ビール';
      case DrinkType.Wine: return 'ワイン';
      case DrinkType.Cidre: return 'シードル';
      case DrinkType.Brandy: return 'ブランデー';
      case DrinkType.Whisky: return 'ウイスキー';
      case DrinkType.Vodka: return 'ウォッカ';
      case DrinkType.Gin: return 'ジン';
      case DrinkType.Liqueur: return 'リキュール';
      case DrinkType.Chuhai: return 'チューハイ';
      case DrinkType.Highball: return 'ハイボール';
      case DrinkType.Cocktail: return 'カクテル ';
      case DrinkType.Other: return 'その他';
    }

    throw '予期せぬDrinkTypeです: $this';
  }

  List<SubDrinkType> get subDrinkTypes {
    switch(this) {
      case DrinkType.Sake: return [
        SubDrinkType.Empty,
        SubDrinkType.SakeDaiginjo,
        SubDrinkType.SakeGinjo,
        SubDrinkType.SakeTokubetuHonzojo,
        SubDrinkType.SakeHonzojo,
        SubDrinkType.SakeJunmaiDaiginjo,
        SubDrinkType.SakeJunmaiGinjo,
        SubDrinkType.SakeTokubetsuJunmai,
        SubDrinkType.SakeJunmai,
      ];
      case DrinkType.Shochu: return [
        SubDrinkType.Empty,
        SubDrinkType.ShochuKome,
        SubDrinkType.ShochuMugi,
        SubDrinkType.ShochuImo,
        SubDrinkType.ShochuKokuto,
        SubDrinkType.ShochuSoba,
        SubDrinkType.ShochuKuri,
        SubDrinkType.ShochuPotato,
        SubDrinkType.ShochuToumorokoshi,
        SubDrinkType.ShochuAwamori,
      ];
      case DrinkType.Umeshu: return [
        SubDrinkType.Empty,
      ];
      case DrinkType.Beer: return [
        SubDrinkType.Empty,
        SubDrinkType.BeerBohemianPilsner,
        SubDrinkType.BeerGermanPilsner,
        SubDrinkType.BeerSchwarz,
        SubDrinkType.BeerDortmunder,
        SubDrinkType.BeerAmericanLager,
        SubDrinkType.BeerViennaLager,
        SubDrinkType.BeerDoppelbock,
        SubDrinkType.BeerPaleAle,
        SubDrinkType.BeerIpa,
        SubDrinkType.BeerStout,
        SubDrinkType.BeerTrappist,
        SubDrinkType.BeerWhiteAle,
        SubDrinkType.BeerBarleyWine,
        SubDrinkType.BeerWeizen,
        SubDrinkType.BeerPorter,
        SubDrinkType.BeerFlandersAle,
        SubDrinkType.BeerHefeweizen,
        SubDrinkType.BeerScotchAle,
      ];
      case DrinkType.Wine: return [
        SubDrinkType.Empty,
        SubDrinkType.WineWhite,
        SubDrinkType.WineRed,
        SubDrinkType.WineRose,
        SubDrinkType.WineSparkling,
        SubDrinkType.WineDessert,
      ];
      case DrinkType.Cidre: return [
        SubDrinkType.Empty,
      ];
      case DrinkType.Brandy: return [
        SubDrinkType.Empty,
        SubDrinkType.BrandyCognac,
        SubDrinkType.BrandyArmagnac,
        SubDrinkType.BrandyCalvados,
      ];
      case DrinkType.Whisky: return [
        SubDrinkType.Empty,
        SubDrinkType.WhiskyScotch,
        SubDrinkType.WhiskyCanadian,
        SubDrinkType.WhiskyIrish,
        SubDrinkType.WhiskyAmerican,
        SubDrinkType.WhiskyJapanese,
      ];
      case DrinkType.Vodka: return [
        SubDrinkType.Empty,
      ];
      case DrinkType.Gin: return [
        SubDrinkType.Empty,
        SubDrinkType.GinDry,
        SubDrinkType.GinJenever,
        SubDrinkType.GinOldTom,
        SubDrinkType.GinSteinhager,
      ];
      case DrinkType.Liqueur: return [
        SubDrinkType.Empty,
      ];
      case DrinkType.Chuhai: return [
        SubDrinkType.Empty,
      ];
      case DrinkType.Highball: return [
        SubDrinkType.Empty,
      ];
      case DrinkType.Cocktail: return [
        SubDrinkType.Empty,
      ];
      case DrinkType.Other: return [
        SubDrinkType.Empty,
      ];
    }

    throw '予期せぬDrinkTypeです: $this';
  }
}

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
  BeerBohemianPilsner,
  BeerGermanPilsner,
  BeerSchwarz,
  BeerDortmunder,
  BeerAmericanLager,
  BeerViennaLager,
  BeerDoppelbock,
  BeerPaleAle,
  BeerIpa,
  BeerStout,
  BeerTrappist,
  BeerWhiteAle,
  BeerBarleyWine,
  BeerWeizen,
  BeerPorter,
  BeerFlandersAle,
  BeerHefeweizen,
  BeerScotchAle,
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
  Empty,
}

extension SubDrinkTypeExtension on SubDrinkType {
  String get label {
    switch(this) {
      case SubDrinkType.SakeDaiginjo: return '大吟醸酒';
      case SubDrinkType.SakeGinjo: return '吟醸酒';
      case SubDrinkType.SakeTokubetuHonzojo: return '特別本醸造酒';
      case SubDrinkType.SakeHonzojo: return '本醸造酒';
      case SubDrinkType.SakeJunmaiDaiginjo: return '純米大吟醸酒';
      case SubDrinkType.SakeJunmaiGinjo: return '純米吟醸酒';
      case SubDrinkType.SakeTokubetsuJunmai: return '特別純米酒';
      case SubDrinkType.SakeJunmai: return '純米酒';

      case SubDrinkType.ShochuKome: return '米焼酎';
      case SubDrinkType.ShochuMugi: return '麦焼酎';
      case SubDrinkType.ShochuImo: return '芋焼酎';
      case SubDrinkType.ShochuKokuto: return '黒糖焼酎';
      case SubDrinkType.ShochuSoba: return 'そば焼酎';
      case SubDrinkType.ShochuKuri: return '栗焼酎';
      case SubDrinkType.ShochuPotato: return 'ジャガイモ焼酎';
      case SubDrinkType.ShochuToumorokoshi: return 'トウモロコシ焼酎';
      case SubDrinkType.ShochuAwamori: return '泡盛';

      case SubDrinkType.BeerBohemianPilsner: return 'ボヘミアン・ピルスナー';
      case SubDrinkType.BeerGermanPilsner: return 'ジャーマン・ピルスナー';
      case SubDrinkType.BeerSchwarz: return 'シュバルツ';
      case SubDrinkType.BeerDortmunder: return 'ドルトムンダー';
      case SubDrinkType.BeerAmericanLager: return 'アメリカンラガー';
      case SubDrinkType.BeerViennaLager: return 'ウィンナーラガー';
      case SubDrinkType.BeerDoppelbock: return 'ドッペルボック';
      case SubDrinkType.BeerPaleAle: return 'ペールエール';
      case SubDrinkType.BeerIpa: return 'IPA';
      case SubDrinkType.BeerStout: return 'スタウト';
      case SubDrinkType.BeerTrappist: return '修道院ビール';
      case SubDrinkType.BeerWhiteAle: return 'ホワイトエール';
      case SubDrinkType.BeerBarleyWine: return 'バーレイワイン';
      case SubDrinkType.BeerWeizen: return 'ヴァイツェン';
      case SubDrinkType.BeerPorter: return 'ポーター';
      case SubDrinkType.BeerFlandersAle: return 'フランダース・エール';
      case SubDrinkType.BeerHefeweizen: return 'ヘーフェヴァイツェン';
      case SubDrinkType.BeerScotchAle: return 'スコッチエール';

      case SubDrinkType.WineRed: return '赤ワイン';
      case SubDrinkType.WineWhite: return '白ワイン';
      case SubDrinkType.WineRose: return 'ロゼワイン';
      case SubDrinkType.WineSparkling: return 'スパークリングワイン';
      case SubDrinkType.WineDessert: return 'デザートワイン';

      case SubDrinkType.BrandyCognac: return 'コニャック';
      case SubDrinkType.BrandyArmagnac: return 'アルマニャック';
      case SubDrinkType.BrandyCalvados: return 'カルバドス';

      case SubDrinkType.WhiskyScotch: return 'スコッチウイスキー';
      case SubDrinkType.WhiskyCanadian: return 'カナディアンウイスキー';
      case SubDrinkType.WhiskyIrish: return 'アイリッシュウイスキー';
      case SubDrinkType.WhiskyAmerican: return 'アメリカンウイスキー';
      case SubDrinkType.WhiskyJapanese: return 'ジャパニーズウイスキー';

      case SubDrinkType.GinDry: return 'ドライ・ジン';
      case SubDrinkType.GinJenever: return 'イェネーバ';
      case SubDrinkType.GinOldTom: return 'オールド・トム・ジン';
      case SubDrinkType.GinSteinhager: return 'シュタインヘーガー';

      case SubDrinkType.Empty: return '-';
    }

    throw '予期せぬDrinkTypeです: $this';
  }
}
