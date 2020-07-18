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
