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

  @override
  String toString() {
    return 'uploadCounts: $drinkTypeUploadCounts';
  }
}
