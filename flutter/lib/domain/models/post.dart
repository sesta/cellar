import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:bacchus/repository/provider/firestore.dart';
import 'package:bacchus/repository/provider/storage.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

const String BASE_IMAGE_PATH =  'post_images';
// スマホに表示する場合に安心できそうな横幅サイズ
const int ORIGINAL_WIDTH_SIZE = 1280;
// 2カラムを想定したサイズ
const int THUMB_WIDTH_SIZE = 640;

void post(List<Asset> images) async {
  final int timestamp = DateTime.now().millisecondsSinceEpoch;

  // TODO: 画像の内容をチェックする
  // TODO: 識別子にタイムスタンプ以外も追加する
  final String thumbImageName = 'image-$timestamp/thumb';
  await uploadImage(images.first, thumbImageName, THUMB_WIDTH_SIZE);

  final List<String> imagePaths = [];
  for (int index = 0 ; index < images.length ; index++) {
    final String originalImageName = 'image-$timestamp/original-$index';
    await uploadImage(images[index], originalImageName, ORIGINAL_WIDTH_SIZE);
    imagePaths.add('$BASE_IMAGE_PATH/$originalImageName');
  }

  addDate('posts', {
    'imagePaths': imagePaths,
    'timestamp': timestamp,
    'thumbImagePath': '$BASE_IMAGE_PATH/$thumbImageName',
  });
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

