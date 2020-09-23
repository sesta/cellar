import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/provider/firestore.dart';

class UserRepository extends DB {
  Future<User> getUser(
      String userId,
  ) async {
    final snapshot = await db.collection(USER_COLLECTION_NAME)
      .doc(userId)
      .get();

    if (snapshot.data == null) {
      return null;
    }

    return _toEntity(userId, snapshot);
  }

  Future<void> createUser(User user) async {
    await db.collection(USER_COLLECTION_NAME)
      .doc(user.userId)
      .set({
        'userName': user.userName,
        'uploadCounts': {},
        'isDeveloper': false, // 管理画面からのみtrueにできる
      });
  }

  Future<void> updateUserName(
    String userId,
    String userName,
  ) async {
    await db.collection(USER_COLLECTION_NAME)
      .doc(userId)
      .update({ 'userName': userName });
  }

  Future<void> updateUserUploadCount(
    String userId,
    Map<DrinkType, int> uploadCounts,
  ) async {
    Map<String, int> counts = {};
    DrinkType.values.forEach((drinkType) {
      if (uploadCounts[drinkType] > 0) {
        counts[drinkType.toString()] = uploadCounts[drinkType];
      }
    });

    await db.collection(USER_COLLECTION_NAME)
      .doc(userId)
      .update({ 'uploadCounts': counts });
  }

  Future<User> _toEntity(
    String userId,
    DocumentSnapshot rawData,
  ) async {
    Map<DrinkType, int> counts = {};
    DrinkType.values.forEach((drinkType) {
      // 新しいDrinkTypeが追加される可能性があるので、存在しない場合を考慮する
      counts[drinkType] = rawData.get('uploadCounts')[drinkType.toString()] != null
        ? rawData.get('uploadCounts')[drinkType.toString()]
        : 0;
    });

    return User(
      userId,
      rawData.get('userName'),
      uploadCounts: counts,
      isDeveloper: rawData.get('isDeveloper') == null ? false : rawData.get('isDeveloper'),
    );
  }
}
