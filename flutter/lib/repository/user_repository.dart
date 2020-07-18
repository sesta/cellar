import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entities/user.dart';
import 'package:cellar/repository/provider/firestore.dart';

class UserRepository extends DB {
  Future<User> getUser(
      String userId,
  ) async {
    final snapshot = await db.collection(USER_COLLECTION_NAME)
      .document(userId)
      .get();

    if (snapshot.data == null) {
      return null;
    }

    return _toEntity(userId, snapshot);
  }

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

  Future<User> _toEntity(
    String userId,
    DocumentSnapshot rawData,
  ) async {
    return User(
      userId,
      rawData['userName'],
      drinkTypeUploadCounts: rawData['drinkTypeUploadCounts'].cast<int>(),
    );
  }
}