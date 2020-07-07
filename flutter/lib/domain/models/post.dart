import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:multi_image_picker/multi_image_picker.dart';

import 'package:cellar/conf.dart';
import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/repository/provider/storage.dart';

Future<void> post(
  String userId,
  String userName,
  List<Asset> images,
  String name,
  DrinkType drinkType,
  int score,
  String memo,
  int price,
  String place,
) async {
  final nowDatetime = DateTime.now();
  final imageDirectory = '$BASE_IMAGE_PATH/$userId/${nowDatetime.millisecondsSinceEpoch}';

  // TODO: 識別子にタイムスタンプ以外も追加する
  final String thumbImagePath = '$imageDirectory/thumb';
  await uploadImage(images.first, thumbImagePath, THUMB_WIDTH_SIZE);

  final List<String> imagePaths = [];
  for (int index = 0 ; index < images.length ; index++) {
    final String originalImagePath = '$imageDirectory/original-$index';
    await uploadImage(images[index], originalImagePath, ORIGINAL_WIDTH_SIZE);
    imagePaths.add(originalImagePath);
  }

  final drink = Drink(
    userId,
    userName,
    name,
    drinkType,
    score,
    memo,
    price,
    place,
    thumbImagePath,
    imagePaths,
    nowDatetime,
  );
  drink.addStore();
}

Future<void> uploadImage(Asset image, String path, int expectWidthSize) async {
  double resizeRate = min(expectWidthSize / image.originalWidth, 1);
  ByteData byteData = await image.getThumbByteData(
    (image.originalWidth * resizeRate).round(),
    (image.originalHeight * resizeRate).round(),
  );
  List<int> imageData = byteData.buffer.asUint8List();
  final int error = await uploadData(
    path,
    imageData,
    'image/jpeg',
  );

  if (error != null) {
    throw new Exception('アップロードに失敗しました: error: $error');
  }

  print('Upload Success: $path');
}

