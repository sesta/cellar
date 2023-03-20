import 'dart:math';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/repositories.dart';
import 'package:image/image.dart';

Future<void> post(
  User user,
  List<List<int>> imageDataList,
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

  final firstImage = decodeImage(imageDataList.first);
  final resizeRate = min(ORIGINAL_WIDTH_SIZE / firstImage.width, 1);
  final firstImageWidth = (firstImage.width * resizeRate).round();
  final firstImageHeight = (firstImage.height * resizeRate).round();

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

Future<void> uploadImage(List<int> imageData, String path, int expectWidthSize) async {
  final image = decodeImage(imageData);
  final double resizeRate = min(expectWidthSize / image.width, 1);
  final resizedImage = copyResize(image,
    width: (image.width * resizeRate).round(),
    height: (image.height * resizeRate).round(),
  );

  final error = await StorageRepository().uploadData(
    path,
    encodePng(resizedImage),
    'image/jpeg',
  );

  if (error != null) {
    throw new Exception('アップロードに失敗しました: error: $error');
  }
}

