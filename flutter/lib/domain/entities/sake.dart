import 'package:bacchus/repository/provider/firestore.dart';

class Sake {
  String name;
  String thumbImagePath;
  List<String> imagePaths;
  DateTime updateDatetime;

  Sake(
      this.name,
      this.thumbImagePath,
      this.imagePaths,
      this.updateDatetime,
  );

  addStore() {
    addData('sakes', {
      'imagePaths': imagePaths,
      'timestamp': updateDatetime.millisecondsSinceEpoch,
      'thumbImagePath': thumbImagePath,
    });
  }

  @override
  String toString() {
    return 'name: $name, '
        'updateDatetime: ${updateDatetime.toString()}, '
        'imageLength ${imagePaths.length}';
  }
}