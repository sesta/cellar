import 'dart:async';

import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/repository/repositories.dart';

class User {
  String userId;
  String userName;
  Map<DrinkType, int> uploadCounts;
  bool isDeveloper;

  User(
    this.userId,
    this.userName,
    {
      this.uploadCounts,
      this.isDeveloper = false,
    }
  ){
    if (this.uploadCounts == null) {
      Map<DrinkType, int> counts = {};
      DrinkType.values.forEach((drinkType) => counts[drinkType] = 0);
      this.uploadCounts = counts;
    }
  }

  int get uploadCount {
    return uploadCounts.values.reduce((sum, count) => sum + count);
  }

  List<DrinkType> get drinkTypesByMany {
    final types = List.from(DrinkType.values);
    types.sort((typeA, typeB) => uploadCounts[typeB].compareTo(uploadCounts[typeA]));

    return types.cast<DrinkType>();
  }

  Future<void> incrementUploadCount(DrinkType drinkType) async {
    uploadCounts[drinkType] ++;
    await UserRepository().updateUserUploadCount(userId, uploadCounts);
  }

  Future<void> decrementUploadCount(DrinkType drinkType) async {
    if (uploadCounts[drinkType] > 0) {
      uploadCounts[drinkType] --;
      await UserRepository().updateUserUploadCount(userId, uploadCounts);
    }
  }

  Future<void> moveUploadCount(
      DrinkType oldDrinkType,
      DrinkType newDrinkType,
  ) async {
    await decrementUploadCount(oldDrinkType);
    await incrementUploadCount(newDrinkType);
  }

  Future<void> create() async {
    await UserRepository().createUser(this);
  }

  Future<void> updateName() async {
    await UserRepository().updateUserName(userId, userName);
    // batch処理なので、awaitしない
    DrinkRepository().updateUserName(userId, userName);
  }

  @override
  String toString() {
    return 'userId: ${this.userId}, userName: ${this.userName}, '
      'uploadCount: ${this.uploadCount}, isDeveloper: $isDeveloper, '
      'drinkTypeUploadCounts: ${this.uploadCounts.toString()}';
  }
}
