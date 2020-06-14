import 'dart:typed_data';

import 'package:bacchus/repository/provider/firestore.dart';
import 'package:bacchus/repository/provider/storage.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

const String BASE_IMAGE_PATH =  'post_images';

void post(List<Asset> images) async {
  // TODO: 複数画像の対応する
  // TODO: 画像の容量をどうにかする
  // TODO: 画像の内容をチェックする
  ByteData byteData = await images[0].getByteData();
  List<int> imageData = byteData.buffer.asUint8List();
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  final String imageName = 'image_$timestamp';
  final int error = await uploadData(
    BASE_IMAGE_PATH,
    imageName,
    imageData,
    'image/jpeg',
  );

  if (error != null) {
    print('error: $error');
    return ;
  }

  print('upload success');
  addDate('posts', {
    'timestamp': timestamp,
    'imagePath': '$BASE_IMAGE_PATH/$imageName',
  });
}
