import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/repository/provider/firestore.dart';

class DrinkRepository extends DB {
  Future<void> createDrink(
    Drink drink,
  ) async {
    await db.collection(DRINK_COLLECTION_NAME)
      .document()
      .setData({
        'userId': drink.userId,
        'userName': drink.userName,
        'drinkName': drink.drinkName,
        'drinkType': drink.drinkType.toString(),
        'subDrinkType': drink.subDrinkType.toString(),
        'score': drink.score,
        'memo': drink.memo,
        'price': drink.price,
        'place': drink.place,
        'postTimestamp': drink.postDatetime.millisecondsSinceEpoch,
        'thumbImagePath': drink.thumbImagePath,
        'imagePaths': drink.imagePaths,
        'firstImageWidth': drink.firstImageWidth,
        'firstImageHeight': drink.firstImageHeight,
      });
  }

  Future<List<Drink>> getPublicDrinks (
    DrinkType drinkType,
    bool isDescTimestamp,
    bool isOrderByScore,
  ) async {
    Query query = db.collection(DRINK_COLLECTION_NAME);

    if (drinkType != null) {
      query = query.where(
        'drinkType',
        isEqualTo: drinkType.toString(),
      );
    }

    if (isOrderByScore) {
      query = query.orderBy('score', descending: isDescTimestamp);
    }
    query = query.orderBy('postTimestamp', descending: isDescTimestamp);
    query = query.limit(PAGE_LIMIT);

    final snapshot = await query.getDocuments();
    return _toEntities(snapshot.documents);
  }

  Future<List<Drink>> getUserDrinks (
    String userId,
    DrinkType drinkType,
    bool isDescTimestamp,
    bool isOrderByScore,
  ) async {
    Query query = db.collection(DRINK_COLLECTION_NAME)
      .where('userId', isEqualTo: userId);

    if (drinkType != null) {
      query = query.where(
        'drinkType',
        isEqualTo: drinkType.toString(),
      );
    }

    if (isOrderByScore) {
      query = query.orderBy('score', descending: isDescTimestamp);
    }
    query = query.orderBy('postTimestamp', descending: isDescTimestamp);
    query = query.limit(PAGE_LIMIT);

    final snapshot = await query.getDocuments();
    return _toEntities(snapshot.documents);
  }

  Future<void> updateDrink (
    Drink drink,
  ) async {
    await db.collection(DRINK_COLLECTION_NAME)
      .document(drink.drinkId)
      .updateData({
        'drinkName': drink.drinkName,
        'drinkType': drink.drinkType.toString(),
        'subDrinkType': drink.subDrinkType.toString(),
        'score': drink.score,
        'memo': drink.memo,
        'price': drink.price,
        'place': drink.place,
      });
  }

  Future<void> updateUserName (
    String userId,
    String userName,
  ) async {
    final snapshot = await db.collection(DRINK_COLLECTION_NAME)
      .where('userId', isEqualTo: userId)
      .getDocuments();

    final batch = db.batch();
    snapshot.documents.forEach((DocumentSnapshot document) {
      batch.updateData(document.reference, { 'userName': userName });
    });

    batch.commit();
  }

  Future<void> deleteDrink(
    String drinkId,
  ) async {
    await db.collection(DRINK_COLLECTION_NAME)
      .document(drinkId)
      .delete();
  }

  Future<List<Drink>> _toEntities(List<DocumentSnapshot> rawData) async {
    final drinks = rawData.map((data) => Drink(
      data['userId'],
      data['userName'],
      data['drinkName'],
      data['drinkType'] == null // 移行のための分岐
        ? DrinkType.values[data['drinkTypeIndex']]
        : toDrinkType(data['drinkType']),
      data['subDrinkType'] == null // 移行のための分岐
        ? SubDrinkType.values[data['subDrinkTypeIndex']]
        : _toSubDrinkType(data['subDrinkType']),
      data['score'],
      data['memo'],
      data['price'],
      data['place'],
      DateTime.fromMicrosecondsSinceEpoch(data['postTimestamp'] * 1000),
      data['thumbImagePath'],
      data['imagePaths'].cast<String>(),
      data['firstImageWidth'],
      data['firstImageHeight'],
      drinkId: data.documentID,
    )).toList();

    await Future.forEach(drinks, (drink) async {
      await drink.init();
    });

    return drinks;
  }

  DrinkType toDrinkType(String rawDrinkType) {
    switch(rawDrinkType) {
      case 'DrinkType.Sake': return DrinkType.Sake;
      case 'DrinkType.Shochu': return DrinkType.Shochu;
      case 'DrinkType.Umeshu': return DrinkType.Umeshu;
      case 'DrinkType.Beer': return DrinkType.Beer;
      case 'DrinkType.Wine': return DrinkType.Wine;
      case 'DrinkType.Cidre': return DrinkType.Cidre;
      case 'DrinkType.Brandy': return DrinkType.Brandy;
      case 'DrinkType.Whisky': return DrinkType.Whisky;
      case 'DrinkType.Vodka': return DrinkType.Vodka;
      case 'DrinkType.Gin': return DrinkType.Gin;
      case 'DrinkType.Liqueur': return DrinkType.Liqueur;
      case 'DrinkType.Chuhai': return DrinkType.Chuhai;
      case 'DrinkType.Highball': return DrinkType.Highball;
      case 'DrinkType.Cocktail': return DrinkType.Cocktail;
      case 'DrinkType.Other': return DrinkType.Other;
    }

    print('不明なTypeです。 $rawDrinkType');
    return null;
  }

  SubDrinkType _toSubDrinkType(String rawSubDrinkType) {
    switch(rawSubDrinkType) {
      case 'SubDrinkType.SakeDaiginjo': return SubDrinkType.SakeDaiginjo;
      case 'SubDrinkType.SakeGinjo': return SubDrinkType.SakeGinjo;
      case 'SubDrinkType.SakeTokubetuHonzoj': return SubDrinkType.SakeTokubetuHonzojo;
      case 'SubDrinkType.SakeHonzojo': return SubDrinkType.SakeHonzojo;
      case 'SubDrinkType.SakeJunmaiDaiginjo': return SubDrinkType.SakeJunmaiDaiginjo;
      case 'SubDrinkType.SakeJunmaiGinjo': return SubDrinkType.SakeJunmaiGinjo;
      case 'SubDrinkType.SakeTokubetsuJunma': return SubDrinkType.SakeTokubetsuJunmai;
      case 'SubDrinkType.SakeJunmai': return SubDrinkType.SakeJunmai;
      case 'SubDrinkType.ShochuKome': return SubDrinkType.ShochuKome;
      case 'SubDrinkType.ShochuMugi': return SubDrinkType.ShochuMugi;
      case 'SubDrinkType.ShochuImo': return SubDrinkType.ShochuImo;
      case 'SubDrinkType.ShochuKokuto': return SubDrinkType.ShochuKokuto;
      case 'SubDrinkType.ShochuSoba': return SubDrinkType.ShochuSoba;
      case 'SubDrinkType.ShochuKuri': return SubDrinkType.ShochuKuri;
      case 'SubDrinkType.ShochuPotato': return SubDrinkType.ShochuPotato;
      case 'SubDrinkType.ShochuToumorokoshi': return SubDrinkType.ShochuToumorokoshi;
      case 'SubDrinkType.ShochuAwamori': return SubDrinkType.ShochuAwamori;
      case 'SubDrinkType.BeerBohemianPilsne': return SubDrinkType.BeerBohemianPilsner;
      case 'SubDrinkType.BeerGermanPilsner': return SubDrinkType.BeerGermanPilsner;
      case 'SubDrinkType.BeerSchwarz': return SubDrinkType.BeerSchwarz;
      case 'SubDrinkType.BeerDortmunder': return SubDrinkType.BeerDortmunder;
      case 'SubDrinkType.BeerAmericanLager': return SubDrinkType.BeerAmericanLager;
      case 'SubDrinkType.BeerViennaLager': return SubDrinkType.BeerViennaLager;
      case 'SubDrinkType.BeerDoppelbock': return SubDrinkType.BeerDoppelbock;
      case 'SubDrinkType.BeerPaleAle': return SubDrinkType.BeerPaleAle;
      case 'SubDrinkType.BeerIpa': return SubDrinkType.BeerIpa;
      case 'SubDrinkType.BeerStout': return SubDrinkType.BeerStout;
      case 'SubDrinkType.BeerTrappist': return SubDrinkType.BeerTrappist;
      case 'SubDrinkType.BeerWhiteAle': return SubDrinkType.BeerWhiteAle;
      case 'SubDrinkType.BeerBarleyWine': return SubDrinkType.BeerBarleyWine;
      case 'SubDrinkType.BeerWeizen': return SubDrinkType.BeerWeizen;
      case 'SubDrinkType.BeerPorter': return SubDrinkType.BeerPorter;
      case 'SubDrinkType.BeerFlandersAle': return SubDrinkType.BeerFlandersAle;
      case 'SubDrinkType.BeerHefeweizen': return SubDrinkType.BeerHefeweizen;
      case 'SubDrinkType.BeerScotchAle': return SubDrinkType.BeerScotchAle;
      case 'SubDrinkType.WineWhite': return SubDrinkType.WineWhite;
      case 'SubDrinkType.WineRed': return SubDrinkType.WineRed;
      case 'SubDrinkType.WineRose': return SubDrinkType.WineRose;
      case 'SubDrinkType.WineSparkling': return SubDrinkType.WineSparkling;
      case 'SubDrinkType.WineDessert': return SubDrinkType.WineDessert;
      case 'SubDrinkType.BrandyCognac': return SubDrinkType.BrandyCognac;
      case 'SubDrinkType.BrandyArmagnac': return SubDrinkType.BrandyArmagnac;
      case 'SubDrinkType.BrandyCalvados': return SubDrinkType.BrandyCalvados;
      case 'SubDrinkType.WhiskyScotch': return SubDrinkType.WhiskyScotch;
      case 'SubDrinkType.WhiskyCanadian': return SubDrinkType.WhiskyCanadian;
      case 'SubDrinkType.WhiskyIrish': return SubDrinkType.WhiskyIrish;
      case 'SubDrinkType.WhiskyAmerican': return SubDrinkType.WhiskyAmerican;
      case 'SubDrinkType.WhiskyJapanese': return SubDrinkType.WhiskyJapanese;
      case 'SubDrinkType.GinDry': return SubDrinkType.GinDry;
      case 'SubDrinkType.GinJenever': return SubDrinkType.GinJenever;
      case 'SubDrinkType.GinOldTom': return SubDrinkType.GinOldTom;
      case 'SubDrinkType.GinSteinhager': return SubDrinkType.GinSteinhager;
      case 'SubDrinkType.Empty': return SubDrinkType.Empty;
    }

    throw '不明なTypeです。 $rawSubDrinkType';
  }
}
