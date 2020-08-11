import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageRepository {
  final FirebaseStorage _firebaseStorage = FirebaseStorage();

  Future<int> uploadData(
    String path,
    Uint8List data,
    String contentType,
  ) async {
    final StorageReference storageReference = _firebaseStorage
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

  Future<String> getUrl(String path) async {
    return await _firebaseStorage
      .ref()
      .child(path)
      .getDownloadURL();
  }
}
