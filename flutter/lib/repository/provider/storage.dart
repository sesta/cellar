import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

Future<int> uploadData(
  String path,
  String dataName,
  Uint8List data,
  String contentType,
) async {
  final StorageReference storageReference = FirebaseStorage()
    .ref()
    .child('$path/$dataName');
  final StorageUploadTask uploadTask = storageReference
    .putData(
      data,
      StorageMetadata(
        contentType: contentType,
      )
    );

  final StorageTaskSnapshot snapshot = await uploadTask.onComplete;
  return snapshot.error;
}

Future<String> getDataUrl(String path) async {
  return await FirebaseStorage()
    .ref()
    .child(path)
    .getDownloadURL();
}
