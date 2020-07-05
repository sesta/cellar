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

Future<List<DocumentSnapshot>> getAll(String documentName, {
  int limit = 50,
}) async {
  final snapshot = await firestoreInstance
    .collection(documentName)
    .limit(limit)
    .getDocuments();
  return snapshot.documents;
}
