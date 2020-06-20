import 'dart:async';

import 'package:bacchus/domain/entities/sake.dart';
import 'package:bacchus/repository/provider/firestore.dart';

Future<List<String>> getTimelineImageUrls() async {
  final List<String> imageUrls = [];
  final rawData = await getAll('sakes');
  final sakes = rawData.map((data) => Sake(
    data['name'],
    data['thumbImagePath'],
    data['imagePaths'].cast<String>(),
    DateTime.fromMicrosecondsSinceEpoch(data['timestamp']),
  )).toList();

  await Future.forEach(sakes, (sake) async {
    final imageUrl = await sake.thumbImageUrl;
    imageUrls.add(imageUrl);
  });

  return imageUrls;
}