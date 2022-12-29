import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageRepository {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<int> uploadData(
    String path,
    Uint8List data,
    String contentType,
  ) async {
    final storageReference = _firebaseStorage
      .ref()
      .child(path);

    // TODO: エラー内容を見て調整する
    try {
      await storageReference
          .putData(
          data,
          SettableMetadata(
            contentType: contentType,
          )
      );
    } catch (e) {
      return e;
    }
  }

  Future<String> getUrl(String path) async {
    return await _firebaseStorage
      .ref()
      .child(path)
      .getDownloadURL();
  }
}
