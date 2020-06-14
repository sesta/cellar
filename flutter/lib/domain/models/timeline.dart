import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> getTimelineImageUrls() async {
  final imagePaths = [];
  final posts = await Firestore.instance.collection('posts').getDocuments();
  posts.documents.forEach((doc) => imagePaths.add(doc['imagePath']));

  final List<String> imageUrls = [];
  await Future.forEach(imagePaths, (path) async {
    final StorageReference storageReference = FirebaseStorage().ref().child(path);
    final imageUrl = await storageReference.getDownloadURL();
    imageUrls.add(imageUrl);
  });

  return imageUrls;
}