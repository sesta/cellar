import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/repositories.dart';

class Status {
  Map<DrinkType, int> uploadCounts;
  String requiredVersion;
  bool isMaintenanceMode;
  String maintenanceMessage;
  String slackUrl;

  Status(
    this.uploadCounts,
    this.requiredVersion,
    this.isMaintenanceMode,
    this.maintenanceMessage,
    this.slackUrl,
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
    return 'isMaintenanceMode: $isMaintenanceMode, uploadCounts: $uploadCounts';
  }
}
