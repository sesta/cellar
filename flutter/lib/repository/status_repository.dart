import 'dart:async';
import 'package:cellar/repository/drink_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entities/status.dart';
import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/repository/provider/firestore.dart';

class StatusRepository extends DB {
  static String _environment = kReleaseMode ? 'production' : 'development';

  Future<Status> getStatus() async {
    final statusRef = db.collection(STATUS_COLLECTION_NAME)
      .document(_environment);
    final drinkTypesData = await statusRef.collection('uploadCounts')
      .getDocuments();

    return _toEntity(drinkTypesData.documents);
  }

  Future<void> incrementUploadCount(
    DrinkType drinkType,
  ) async {
    await db.collection(STATUS_COLLECTION_NAME)
      .document(_environment)
      .collection('uploadCounts')
      .document(drinkType.toString())
      .updateData({
        'uploadCount': FieldValue.increment(1),
      });
  }

  Future<void> decrementUploadCount(
    DrinkType drinkType,
  ) async {
    await db.collection(STATUS_COLLECTION_NAME)
      .document(_environment)
      .collection('uploadCounts')
      .document(drinkType.toString())
      .updateData({
        'uploadCount': FieldValue.increment(-1),
      });
  }

  Status _toEntity(
    List<DocumentSnapshot> drinkTypesData,
  ) {
    Map<DrinkType, int> counts = {};
    drinkTypesData.forEach((data) {
      final drinkType = DrinkRepository().toDrinkType(data.documentID);
      if (drinkType == null) {
        return;
      }

      counts[drinkType] = data['uploadCount'];
    });

    return Status(counts);
  }
}
