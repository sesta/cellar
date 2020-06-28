import 'package:bacchus/repository/provider/firestore.dart';
import 'package:bacchus/repository/provider/storage.dart';


enum DrinkType {
  Sake,
  Wine,
  Whisky
}

class Drink {
  String userId;
  String name;
  DrinkType drinkType;
  String thumbImagePath;
  List<String> imagePaths;
  DateTime updateDatetime;
  String thumbImageUrl;

  Drink(
      this.userId,
      this.name,
      this.drinkType,
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
      'drinkTypeIndex': drinkType.index,
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
