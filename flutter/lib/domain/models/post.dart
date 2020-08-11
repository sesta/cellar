import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:multi_image_picker/multi_image_picker.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/domain/entities/user.dart';
import 'package:cellar/repository/storage_repository.dart';

Future<void> post(
  User user,
  List<Asset> images,
  DateTime drinkDateTime,
  String drinkName,
  DrinkType drinkType,
  SubDrinkType subDrinkType,
  int score,
  String memo,
  int price,
  String place,
) async {
  final nowDatetime = DateTime.now();
  final imageDirectory = '$BASE_IMAGE_PATH/${user.userId}/${nowDatetime.millisecondsSinceEpoch}';

  // TODO: 識別子にタイムスタンプ以外も追加する
  final String thumbImagePath = '$imageDirectory/thumb';
  await uploadImage(images.first, thumbImagePath, THUMB_WIDTH_SIZE);

  final List<String> imagePaths = [];
  for (int index = 0 ; index < images.length ; index++) {
    final String originalImagePath = '$imageDirectory/original-$index';
    await uploadImage(images[index], originalImagePath, ORIGINAL_WIDTH_SIZE);
    imagePaths.add(originalImagePath);
  }

  final resizeRate = min(ORIGINAL_WIDTH_SIZE / images.first.originalWidth, 1);
  final firstImageWidth = (images.first.originalWidth * resizeRate).round();
  final firstImageHeight = (images.first.originalHeight * resizeRate).round();

  final drink = Drink(
    user.userId,
    user.userName,
    drinkDateTime,
    drinkName,
    drinkType,
    subDrinkType,
    score,
    memo,
    price,
    place,
    nowDatetime,
    thumbImagePath,
    imagePaths,
    firstImageWidth,
    firstImageHeight,
  );
  await drink.create();
}

Future<void> uploadImage(Asset image, String path, int expectWidthSize) async {
  double resizeRate = min(expectWidthSize / image.originalWidth, 1);
  ByteData byteData = await image.getThumbByteData(
    (image.originalWidth * resizeRate).round(),
    (image.originalHeight * resizeRate).round(),
  );
  List<int> imageData = byteData.buffer.asUint8List();
  final int error = await StorageRepository().uploadData(
    path,
    imageData,
    'image/jpeg',
  );

  if (error != null) {
    throw new Exception('アップロードに失敗しました: error: $error');
  }

  print('Upload Success: $path');
}

