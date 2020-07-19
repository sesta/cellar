import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/repository/status_repository.dart';

class Status {
  List<int> drinkTypeUploadCounts;

  Status(
    this.drinkTypeUploadCounts,
  );

  int get uploadCount {
    return drinkTypeUploadCounts.reduce((sum, count) => sum + count);
  }

  Future<void> incrementUploadCount(DrinkType drinkType) async {
    drinkTypeUploadCounts[drinkType.index] ++;
    // DBの個数とずれるかもしれないが完全に同期できないので諦める
    await StatusRepository().incrementUploadCount(
      'production',
      drinkType,
    );
  }

  Future<void> decrementUploadCount(DrinkType drinkType) async {
    if (drinkTypeUploadCounts[drinkType.index] > 0) {
      drinkTypeUploadCounts[drinkType.index] --;
      // DBの個数とずれるかもしれないが完全に同期できないので諦める
      await StatusRepository().decrementUploadCount(
        'production',
        drinkType,
      );
    }
  }

  Future<void> moveUploadCount(
    DrinkType oldDrinkType,
    DrinkType newDrinkType,
  ) async {
    await decrementUploadCount(oldDrinkType);
    await incrementUploadCount(newDrinkType);
  }

  @override
  String toString() {
    return 'uploadCounts: $drinkTypeUploadCounts';
  }
}
