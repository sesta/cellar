import 'dart:async';

import 'package:bacchus/repository/provider/firestore.dart';
import 'package:bacchus/repository/provider/storage.dart';

Future<List<String>> getTimelineImageUrls() async {
  final List<String> imageUrls = [];
  final posts = await getAll('posts');
  await Future.forEach(posts, (post) async {
    final path = post['imagePath'];
    print(path);
    final imageUrl = await getDataUrl(path);
    imageUrls.add(imageUrl);
  });

  return imageUrls;
}