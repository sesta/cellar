import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

final firestoreInstance = Firestore.instance;

Future<void> addDate(String documentName, Object data) async {
  await firestoreInstance
    .collection(documentName)
    .document()
    .setData(data);
}

Future<List<DocumentSnapshot>> getAll(String documentName) async {
  // TODO: LIMITを設ける
  final snapshot = await firestoreInstance
    .collection(documentName)
    .getDocuments();
  return snapshot.documents;
}
