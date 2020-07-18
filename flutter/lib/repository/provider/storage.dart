import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

Future<int> uploadData(
  String path,
  Uint8List data,
  String contentType,
) async {
  final StorageReference storageReference = FirebaseStorage()
    .ref()
    .child(path);
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
