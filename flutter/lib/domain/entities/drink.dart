import 'package:bacchus/repository/provider/firestore.dart';
import 'package:bacchus/repository/provider/storage.dart';

class Drink {
  String userId;
  String name;
  String thumbImagePath;
  List<String> imagePaths;
  DateTime updateDatetime;
  String thumbImageUrl;

  Drink(
      this.userId,
      this.name,
      this.thumbImagePath,
      this.imagePaths,
      this.updateDatetime,
  );

  init() async {
    thumbImageUrl = await getDataUrl(thumbImagePath);
  }

  addStore() {
    addData('drinks', {
      'userId': userId,
      'name': name,
      'thumbImagePath': thumbImagePath,
      'imagePaths': imagePaths,
      'timestamp': updateDatetime.millisecondsSinceEpoch,
    });
  }

  @override
  String toString() {
    return 'name: $name, '
        'updateDatetime: ${updateDatetime.toString()}, '
        'imageLength ${imagePaths.length}';
  }
}
