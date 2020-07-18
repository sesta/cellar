import 'dart:async';
import 'package:cellar/domain/entities/drink.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/repository/provider/firestore.dart';

class DrinkRepository extends DB {
  Future<List<DocumentSnapshot>> getPublicDrinks (
      DrinkType drinkType,
    ) async {
    CollectionReference ref = firestoreInstance
      .collection(DRINK_COLLECTION_NAME);

    Query query = ref;
    if (drinkType != null) {
      query = query.where(
        'drinkTypeIndex',
        isEqualTo: drinkType.index,
      );
    }

    query = query.orderBy('postTimestamp', descending: true);
    query = query.limit(PAGE_LIMIT);

    final snapshot = await query.getDocuments();
    return snapshot.documents;
  }
}
