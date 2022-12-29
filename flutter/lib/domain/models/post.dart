import 'dart:math';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/repositories.dart';

class ImageData {
  List<int> data;
  double width;
  double height;

  ImageData(
    this.data,
    this.width,
    this.height,
  );
}

Future<void> post(
  User user,
  List<ImageData> imageDataList,
  DateTime drinkDateTime,
  bool isPrivate,
  String drinkName,
  DrinkType drinkType,
  SubDrinkType subDrinkType,
  int score,
  String memo,
  int price,
  String place,
  String origin,
) async {
  final nowDatetime = DateTime.now();
  final imageDirectory = '$BASE_IMAGE_PATH/${user.userId}/${nowDatetime.millisecondsSinceEpoch}';

  // TODO: 識別子にタイムスタンプ以外も追加する
  final String thumbImagePath = '$imageDirectory/thumb';
  await uploadImage(imageDataList.first, thumbImagePath, THUMB_WIDTH_SIZE);

  final List<String> imagePaths = [];
  for (int index = 0 ; index < imageDataList.length ; index++) {
    final String originalImagePath = '$imageDirectory/original-$index';
    await uploadImage(imageDataList[index], originalImagePath, ORIGINAL_WIDTH_SIZE);
    imagePaths.add(originalImagePath);
  }

  final resizeRate = min(ORIGINAL_WIDTH_SIZE / imageDataList.first.width, 1);
  final firstImageWidth = (imageDataList.first.width * resizeRate).round();
  final firstImageHeight = (imageDataList.first.height * resizeRate).round();

  final drink = Drink(
    user.userId,
    user.userName,
    isPrivate,
    drinkDateTime,
    drinkName,
    drinkType,
    subDrinkType,
    score,
    memo,
    price,
    place,
    origin,
    nowDatetime,
    thumbImagePath,
    imagePaths,
    firstImageWidth,
    firstImageHeight,
  );
  await drink.create();
}

Future<void> uploadImage(ImageData imageData, String path, int expectWidthSize) async {
  double resizeRate = min(expectWidthSize / imageData.width, 1);
  // TODO: サイズを変更する処理を入れる
  final int error = await StorageRepository().uploadData(
    path,
    imageData.data,
    'image/jpeg',
  );

  if (error != null) {
    throw new Exception('アップロードに失敗しました: error: $error');
  }
}

