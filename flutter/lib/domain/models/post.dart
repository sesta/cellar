import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:multi_image_picker/multi_image_picker.dart';

import 'package:bacchus/conf.dart';
import 'package:bacchus/domain/entities/sake.dart';
import 'package:bacchus/repository/provider/storage.dart';

void post(List<Asset> images) async {
  final nowDatetime = DateTime.now();

  // TODO: 識別子にタイムスタンプ以外も追加する
  final String thumbImageName = 'image-${nowDatetime.millisecondsSinceEpoch}/thumb';
  await uploadImage(images.first, thumbImageName, THUMB_WIDTH_SIZE);

  final List<String> imagePaths = [];
  for (int index = 0 ; index < images.length ; index++) {
    final String originalImageName = 'image-${nowDatetime.millisecondsSinceEpoch}/original-$index';
    await uploadImage(images[index], originalImageName, ORIGINAL_WIDTH_SIZE);
    imagePaths.add('$BASE_IMAGE_PATH/$originalImageName');
  }

  final sake = Sake(
    'tmpName',
    '$BASE_IMAGE_PATH/$thumbImageName',
    imagePaths,
    nowDatetime,
  );
  sake.addStore();
}

Future<void> uploadImage(Asset image, String imageName, int expectWidthSize) async {
  double resizeRate = min(expectWidthSize / image.originalWidth, 1);
  ByteData byteData = await image.getThumbByteData(
    (image.originalWidth * resizeRate).round(),
    (image.originalHeight * resizeRate).round(),
  );
  List<int> imageData = byteData.buffer.asUint8List();
  final int error = await uploadData(
    BASE_IMAGE_PATH,
    imageName,
    imageData,
    'image/jpeg',
  );

  if (error != null) {
    throw new Exception('アップロードに失敗しました: error: $error');
  }

  print('Upload Success: $imageName');
}

