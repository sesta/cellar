import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/repository/provider/firestore.dart';

class DrinkRepository extends DB {
  Future<List<Drink>> getPublicDrinks (
    DrinkType drinkType,
  ) async {
    Query query = db.collection(DRINK_COLLECTION_NAME);

    if (drinkType != null) {
      query = query.where(
        'drinkTypeIndex',
        isEqualTo: drinkType.index,
      );
    }

    query = query.orderBy('postTimestamp', descending: true);
    query = query.limit(PAGE_LIMIT);

    final snapshot = await query.getDocuments();
    return _toEntities(snapshot.documents);
  }

  Future<List<Drink>> getUserDrinks (
    String userId,
    DrinkType drinkType,
  ) async {
    Query query = db.collection(DRINK_COLLECTION_NAME)
      .where('userId', isEqualTo: userId);

    if (drinkType != null) {
      query = query.where(
        'drinkTypeIndex',
        isEqualTo: drinkType.index,
      );
    }

    query = query.orderBy('postTimestamp', descending: true);
    query = query.limit(PAGE_LIMIT);

    final snapshot = await query.getDocuments();
    return _toEntities(snapshot.documents);
  }

  Future<List<Drink>> _toEntities(List<DocumentSnapshot> rawData) async {
    final drinks = rawData.map((data) => Drink(
      data['userId'],
      data['userName'],
      data['drinkName'],
      DrinkType.values[data['drinkTypeIndex']],
      SubDrinkType.values[data['subDrinkTypeIndex']],
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
}
