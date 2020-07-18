import 'dart:async';

import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/repository/provider/firestore.dart';

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

  incrementUploadCount(DrinkType drinkType) {
    this.drinkTypeUploadCounts[drinkType.index] ++;
  }

  Future<void> save() async {
    await saveData('users', {
      'userName': userName,
      'drinkTypeUploadCounts': drinkTypeUploadCounts,
    }, userId);
    updateDataBatch(
      'drinks',
      {
        'userName': userName,
      },
      whereKeys: ['userId'],
      whereEqualValues: [userId],
    );
  }

  @override
  String toString() {
    return 'userId: ${this.userId}, userName: ${this.userName}, '
      'uploadCount: ${this.uploadCount}, '
      'drinkTypeUploadCounts: ${this.drinkTypeUploadCounts.toString()}';
  }
}
