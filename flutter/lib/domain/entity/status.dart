import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/repositories.dart';

class Status {
  Map<DrinkType, int> uploadCounts;
  bool isMaintenance;
  String maintenanceMessage;

  Status(
    this.uploadCounts,
    this.isMaintenance,
    this.maintenanceMessage,
  );

  int get uploadCount {
    return uploadCounts.values.reduce((sum, count) => sum + count);
  }

  Future<void> incrementUploadCount(DrinkType drinkType) async {
    uploadCounts[drinkType] ++;
    // DBの個数とずれるかもしれないが完全に同期できないので諦める
    await StatusRepository().incrementUploadCount(drinkType);
  }

  Future<void> decrementUploadCount(DrinkType drinkType) async {
    if (uploadCounts[drinkType] > 0) {
      uploadCounts[drinkType] --;
      // DBの個数とずれるかもしれないが完全に同期できないので諦める
      await StatusRepository().decrementUploadCount(drinkType);
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
    return 'isMaintenance: $isMaintenance, uploadCounts: $uploadCounts';
  }
}
