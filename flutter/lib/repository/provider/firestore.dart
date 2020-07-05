import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

final firestoreInstance = Firestore.instance;

Future<void> addData(
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
  String whereKey,
  String whereEqualValue,
  String orderKey,
  bool isDeskOrder = false,
  int limit = 50,
}) async {
  CollectionReference ref = firestoreInstance
    .collection(documentName);

  Query query = ref;
  if (whereKey != null && whereEqualValue != null) {
    query = query.where(
      whereKey,
      isEqualTo: whereEqualValue,
    );
  }
  if (orderKey != null) {
    query = query.orderBy(orderKey, descending: isDeskOrder);
  }
  query = query.limit(limit);

  final snapshot = await query.getDocuments();
  return snapshot.documents;
}
