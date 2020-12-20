import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/repositories.dart';
import 'package:cellar/repository/provider/firestore.dart';

class DrinkRepository extends DB {
  Future<void> createDrink(
    Drink drink,
  ) async {
    await db.collection(DRINK_COLLECTION_NAME)
      .doc()
      .set({
        'userId': drink.userId,
        'userName': drink.userName,
        'isPrivate': drink.isPrivate,
        'drinkTimestamp': drink.drinkDateTime.millisecondsSinceEpoch,
        'drinkName': drink.drinkName,
        'drinkType': drink.drinkType.toString(),
        'subDrinkType': drink.subDrinkType.toString(),
        'score': drink.score,
        'memo': drink.memo,
        'price': drink.price,
        'place': drink.place,
        'origin': drink.origin,
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
    Drink lastDrink,
  ) async {
    Query query = db.collection(DRINK_COLLECTION_NAME);

    query = _buildQuery(
      query,
      drinkType,
      isDescTimestamp,
      isOrderByScore,
      lastDrink,
    );

    final snapshot = await query.get();
    return _toEntities(snapshot.docs);
  }

  Future<List<Drink>> getUserDrinks (
    String userId,
    DrinkType drinkType,
    bool isDescTimestamp,
    bool isOrderByScore,
    Drink lastDrink,
  ) async {
    Query query = db.collection(DRINK_COLLECTION_NAME)
      .where('userId', isEqualTo: userId);

    query = _buildQuery(
      query,
      drinkType,
      isDescTimestamp,
      isOrderByScore,
      lastDrink,
    );

    final snapshot = await query.get();
    return _toEntities(snapshot.docs);
  }

  Future<List<Drink>> getUserAllDrinks (
    String userId,
  ) async {
    final snapshot = await db.collection(DRINK_COLLECTION_NAME)
      .where('userId', isEqualTo: userId)
      .get();

    return _toEntities(snapshot.docs);
  }

  Future<void> updateDrink (
    Drink drink,
  ) async {
    await db.collection(DRINK_COLLECTION_NAME)
      .doc(drink.drinkId)
      .update({
        'isPrivate': drink.isPrivate,
        'drinkTimestamp': drink.drinkDateTime.millisecondsSinceEpoch,
        'drinkName': drink.drinkName,
        'drinkType': drink.drinkType.toString(),
        'subDrinkType': drink.subDrinkType.toString(),
        'score': drink.score,
        'memo': drink.memo,
        'price': drink.price,
        'place': drink.place,
        'origin': drink.origin,
      });
  }

  Future<void> updateUserName (
    String userId,
    String userName,
  ) async {
    final snapshot = await db.collection(DRINK_COLLECTION_NAME)
      .where('userId', isEqualTo: userId)
      .get();

    final batch = db.batch();
    snapshot.docs.forEach((DocumentSnapshot document) {
      batch.update(document.reference, { 'userName': userName });
    });

    batch.commit();
  }

  Future<void> deleteDrink(
    String drinkId,
  ) async {
    await db.collection(DRINK_COLLECTION_NAME)
      .doc(drinkId)
      .delete();
  }

  Query _buildQuery(
    Query query,
    DrinkType drinkType,
    bool isDescTimestamp,
    bool isOrderByScore,
    Drink lastDrink,
  ) {
    if (drinkType != null) {
      query = query.where(
        'drinkType',
        isEqualTo: drinkType.toString(),
      );
    }

    if (isOrderByScore) {
      query = query.orderBy('score', descending: isDescTimestamp);
    }
    query = query.orderBy('drinkTimestamp', descending: isDescTimestamp);

    if (lastDrink != null) {
      final direction = isDescTimestamp ? -1 : 1;
      final startValues = isOrderByScore
        ? [lastDrink.score, lastDrink.drinkDateTime.millisecondsSinceEpoch + direction]
        : [lastDrink.drinkDateTime.millisecondsSinceEpoch + direction];
      query = query.startAt(startValues);
    }

    query = query.limit(PAGE_LIMIT);

    return query;
  }

  Future<List<Drink>> _toEntities(List<DocumentSnapshot> rawData) async {
    final drinks = rawData.map((data) {
      final drinkType = toDrinkType(data.get('drinkType'));
      final subDrinkType = _toSubDrinkType(data.get('subDrinkType'));
      if (drinkType == null || subDrinkType == null) {
        return null;
      }

      var origin = '';
      try {
        origin = data.get('origin');
      } catch (e) {
        // originはkeyが存在しないことがあるので、握り潰す
      }

      var isPrivate = false;
      try {
        isPrivate = data.get('isPrivate');
      } catch (e) {
        // isPrivate、握り潰す
      }

      return Drink(
        data.get('userId'),
        data.get('userName'),
        isPrivate,
        DateTime.fromMicrosecondsSinceEpoch(data.get('drinkTimestamp') * 1000),
        data.get('drinkName'),
        drinkType,
        subDrinkType,
        data.get('score'),
        data.get('memo'),
        data.get('price'),
        data.get('place'),
        origin,
        DateTime.fromMicrosecondsSinceEpoch(data.get('postTimestamp') * 1000),
        data.get('thumbImagePath'),
        data.get('imagePaths').cast<String>(),
        data.get('firstImageWidth'),
        data.get('firstImageHeight'),
        drinkId: data.id,
      );
    }).where((drink) => drink != null).toList();

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

    // DrinkTypeが定義されている人とされていない人がいる可能性があるので
    // 定義されていないものが来ることを許容する
    AlertRepository().send(
      'DrinkTypeの変換に失敗しました',
      rawDrinkType,
    );
    return null;
  }

  SubDrinkType _toSubDrinkType(String rawSubDrinkType) {
    switch(rawSubDrinkType) {
      case 'SubDrinkType.SakeDaiginjo': return SubDrinkType.SakeDaiginjo;
      case 'SubDrinkType.SakeGinjo': return SubDrinkType.SakeGinjo;
      case 'SubDrinkType.SakeTokubetuHonzojo': return SubDrinkType.SakeTokubetuHonzojo;
      case 'SubDrinkType.SakeHonzojo': return SubDrinkType.SakeHonzojo;
      case 'SubDrinkType.SakeJunmaiDaiginjo': return SubDrinkType.SakeJunmaiDaiginjo;
      case 'SubDrinkType.SakeJunmaiGinjo': return SubDrinkType.SakeJunmaiGinjo;
      case 'SubDrinkType.SakeTokubetsuJunmai': return SubDrinkType.SakeTokubetsuJunmai;
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

    // DrinkTypeが定義されている人とされていない人がいる可能性があるので
    // 定義されていないものが来ることを許容する
    AlertRepository().send(
      'SubDrinkTypeの変換に失敗しました',
      rawSubDrinkType,
    );
    return null;
  }

  // 新しい変数を一気に追加したりする用
  // 容赦無く起き変わってしまうので、使うときは要注意
  //
  // 使い方
  // DrinkRepository().updateValue('isPrivate', false);
  Future<void> updateValue (
    String key,
    value,
  ) async {
    final snapshot = await db.collection(DRINK_COLLECTION_NAME)
      .get();

    final batch = db.batch();
    snapshot.docs.forEach((DocumentSnapshot document) {
      batch.update(document.reference, { key: value });
    });

    batch.commit();
  }
}
