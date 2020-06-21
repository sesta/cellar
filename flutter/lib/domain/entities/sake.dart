import 'package:bacchus/repository/provider/firestore.dart';
import 'package:bacchus/repository/provider/storage.dart';

class Sake {
  String userId;
  String name;
  String thumbImagePath;
  List<String> imagePaths;
  DateTime updateDatetime;
  String _thumbImageUrl = '';

  Sake(
      this.userId,
      this.name,
      this.thumbImagePath,
      this.imagePaths,
      this.updateDatetime,
  );

  get thumbImageUrl async {
    if (_thumbImageUrl != '') {
      return _thumbImageUrl;
    }

    _thumbImageUrl = await getDataUrl(thumbImagePath);
    return _thumbImageUrl;
  }

  addStore() {
    addData('sakes', {
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
