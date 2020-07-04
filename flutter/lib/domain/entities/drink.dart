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
  String memo;
  String thumbImagePath;
  List<String> imagePaths;
  DateTime updateDatetime;
  String thumbImageUrl;

  Drink(
      this.userId,
      this.name,
      this.drinkType,
      this.memo,
      this.thumbImagePath,
      this.imagePaths,
      this.updateDatetime,
  );

  init() async {
    thumbImageUrl = await getDataUrl(thumbImagePath);
  }

  get drinkTypeLabel {
    switch(drinkType) {
      case DrinkType.Sake:
        return '日本酒';
      case DrinkType.Wine:
        return 'ワイン';
      case DrinkType.Whisky:
        return 'ウイスキー';
    }
  }

  addStore() {
    addData('drinks', {
      'userId': userId,
      'name': name,
      'drinkTypeIndex': drinkType.index,
      'memo': memo,
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
