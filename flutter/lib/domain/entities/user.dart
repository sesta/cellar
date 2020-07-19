import 'dart:async';

import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/repository/drink_repository.dart';
import 'package:cellar/repository/user_repository.dart';

class User {
  String userId;
  String userName;
  List<int> drinkTypeUploadCounts;

  User(
    this.userId,
    this.userName,
    {
      this.drinkTypeUploadCounts,
    }
  ){
    if (this.drinkTypeUploadCounts == null) {
      this.drinkTypeUploadCounts = List.generate(DrinkType.values.length, (_) => 0);
    }
  }

  int get uploadCount {
    return drinkTypeUploadCounts.reduce((sum, count) => sum + count);
  }

  List<DrinkType> get drinkTypesByMany {
    final types = List.from(DrinkType.values);
    types.sort((typeA, typeB) => drinkTypeUploadCounts[typeB.index].compareTo(drinkTypeUploadCounts[typeA.index]));

    return types.cast<DrinkType>();
  }

  Future<void> incrementUploadCount(DrinkType drinkType) async {
    drinkTypeUploadCounts[drinkType.index] ++;
    await UserRepository().updateUserUploadCount(userId, drinkTypeUploadCounts);
  }

  Future<void> decrementUploadCount(DrinkType drinkType) async {
    if (drinkTypeUploadCounts[drinkType.index] > 0) {
      drinkTypeUploadCounts[drinkType.index] --;
      await UserRepository().updateUserUploadCount(userId, drinkTypeUploadCounts);
    }
  }

  Future<void> create() async {
    await UserRepository().createUser(userId, {
      'userName': userName,
      'drinkTypeUploadCounts': drinkTypeUploadCounts,
    });
  }

  Future<void> updateName() async {
    await UserRepository().updateUserName(userId, userName);
    // batch処理なので、awaitしない
    DrinkRepository().updateUserName(userId, userName);
  }

  Future<void> updateUploadCount() async {
    await UserRepository().updateUserUploadCount(userId, drinkTypeUploadCounts);
    // TODO: statusも更新する
  }

  @override
  String toString() {
    return 'userId: ${this.userId}, userName: ${this.userName}, '
      'uploadCount: ${this.uploadCount}, '
      'drinkTypeUploadCounts: ${this.drinkTypeUploadCounts.toString()}';
  }
}
