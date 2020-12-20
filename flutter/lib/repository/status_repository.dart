import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/repositories.dart';
import 'package:cellar/repository/provider/firestore.dart';

class StatusRepository extends DB {
  static String _environment = kReleaseMode ? 'production' : 'development';

  Future<Status> getStatus() async {
    final statusRef = db.collection(STATUS_COLLECTION_NAME)
      .doc(_environment);
    final statusData = await statusRef.get();
    final drinkTypesData = await statusRef.collection('uploadCounts')
      .get();

    return _toEntity(
      statusData,
      drinkTypesData.docs,
    );
  }

  Future<void> incrementUploadCount(
    DrinkType drinkType,
  ) async {
    await db.collection(STATUS_COLLECTION_NAME)
      .doc(_environment)
      .collection('uploadCounts')
      .doc(drinkType.toString())
      .update({
        'uploadCount': FieldValue.increment(1),
      });
  }

  Future<void> decrementUploadCount(
    DrinkType drinkType,
  ) async {
    await db.collection(STATUS_COLLECTION_NAME)
      .doc(_environment)
      .collection('uploadCounts')
      .doc(drinkType.toString())
      .update({
        'uploadCount': FieldValue.increment(-1),
      });
  }

  Status _toEntity(
    DocumentSnapshot statusData,
    List<DocumentSnapshot> drinkTypesData,
  ) {
    Map<DrinkType, int> counts = {};
    drinkTypesData.forEach((data) {
      final drinkType = DrinkRepository().toDrinkType(data.id);
      if (drinkType == null) {
        return;
      }

      counts[drinkType] = data.get('uploadCount');
    });

    return Status(
      counts,
      statusData.get('requiredVersion'),
      statusData.get('isMaintenance'),
      statusData.get('maintenanceMessage'),
      statusData.get('slackUrl'),
    );
  }
}
