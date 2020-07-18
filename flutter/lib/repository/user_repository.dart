import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/repository/provider/firestore.dart';

class UserRepository extends DB {
  Future<void> createUser(
    String userId,
    Object initialData,
  ) async {
    await db.collection(USER_COLLECTION_NAME)
      .document(userId)
      .setData(initialData);
  }

  Future<void> updateUserName(
    String userId,
    String userName,
  ) async {
    await db.collection(USER_COLLECTION_NAME)
      .document(userId)
      .updateData({ 'userName': userName });
  }

  Future<void> updateUserUploadCount(
    String userId,
    List<int> drinkTypeUploadCounts,
  ) async {
    await db.collection(USER_COLLECTION_NAME)
      .document(userId)
      .updateData({ 'drinkTypeUploadCounts': drinkTypeUploadCounts });
  }
}