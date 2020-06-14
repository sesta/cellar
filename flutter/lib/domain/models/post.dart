import 'dart:typed_data';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String BASE_IMAGE_PATH =  'post_images';

void uploadImages(List<Asset> images) async {
  // TODO: 画像の容量をどうにかする
  // TODO: 画像の内容をチェックする
  ByteData byteData = await images[0].getByteData();
  List<int> imageData = byteData.buffer.asUint8List();
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  final String imageName = 'image_$timestamp';
  final StorageReference storageReference = FirebaseStorage().ref().child('$BASE_IMAGE_PATH/$imageName');
  final StorageUploadTask uploadTask = storageReference.putData(
      imageData,
      StorageMetadata(
        contentType: "image/jpeg",
      )
  );
  StorageTaskSnapshot snapshot = await uploadTask.onComplete;

  if (snapshot.error == null) {
    print('upload success');
    Firestore.instance.collection('posts').document()
        .setData({
      'timestamp': timestamp,
      'imagePath': '$BASE_IMAGE_PATH/$imageName',
    });
  } else {
    print('error: $snapshot.error');
  }
}
