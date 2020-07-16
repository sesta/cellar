import 'dart:async';

import 'package:cellar/domain/entities/drink.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestoreInstance = Firestore.instance;

Future<void> saveData(
  String documentName,
  Object data,
  [String documentId]
) async {
  await firestoreInstance
    .collection(documentName)
    .document(documentId)
    .setData(data);
}

Future<DocumentSnapshot> getDocument(
  String documentName,
  String documentId,
) async {
  return await firestoreInstance
      .collection(documentName)
      .document(documentId)
      .get();
}

Future<List<DocumentSnapshot>> getDocuments(String documentName, {
  List<String> whereKeys,
  List<dynamic> whereEqualValues,
  String orderKey,
  bool isDeskOrder = false,
  int limit = 50,
}) async {
  CollectionReference ref = firestoreInstance
    .collection(documentName);

  Query query = ref;
  if (whereKeys != null
    && whereEqualValues != null
    && whereKeys.length > 0
    && whereKeys.length == whereEqualValues.length
  ) {
    List.generate(whereKeys.length, (index) {
      query = query.where(
        whereKeys[index],
        isEqualTo: whereEqualValues[index],
      );
    });
  }
  if (orderKey != null) {
    query = query.orderBy(orderKey, descending: isDeskOrder);
  }
  query = query.limit(limit);

  final snapshot = await query.getDocuments();
  return snapshot.documents;
}

Future<void> incrementUploadCount(
    DrinkType drinkType,
    ) async {
  return await firestoreInstance
      .collection('status')
      .document('production')
      .collection('drinkTypes')
      .document(drinkType.index.toString())
      .updateData({
    'uploadCount': FieldValue.increment(1),
  });
}

Future<List<DocumentSnapshot>> getUploadCounts() async {
  final snapshot = await firestoreInstance
    .collection('status')
    .document('production')
    .collection('drinkTypes')
    .getDocuments();

  return snapshot.documents;
}

Future<void> deleteData(
  String documentName,
  String documentId
) async {
  await firestoreInstance
    .collection(documentName)
    .document(documentId)
    .delete();
}

Future<void> updateDataBatch(
  String collectionName,
  Object data,
  {
    List<String> whereKeys,
    List<dynamic> whereEqualValues,
  }
) async {
  final batch = firestoreInstance.batch();
  Query query = firestoreInstance
    .collection(collectionName);

  if (whereKeys != null
    && whereEqualValues != null
    && whereKeys.length > 0
    && whereKeys.length == whereEqualValues.length
  ) {
    List.generate(whereKeys.length, (index) {
      query = query.where(
        whereKeys[index],
        isEqualTo: whereEqualValues[index],
      );
    });
  }

  final snapshot = await query.getDocuments();
  snapshot.documents.forEach((DocumentSnapshot document) {
    batch.updateData(document.reference, data);
  });

  batch.commit();
}