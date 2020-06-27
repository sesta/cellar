import 'dart:async';

import 'package:bacchus/domain/entities/sake.dart';
import 'package:bacchus/repository/provider/firestore.dart';

Future<List<Sake>> getTimelineImageUrls() async {
  final rawData = await getAll('sakes');
  final sakes = rawData.map((data) => Sake(
    data['userId'],
    data['name'],
    data['thumbImagePath'],
    data['imagePaths'].cast<String>(),
    DateTime.fromMicrosecondsSinceEpoch(data['timestamp']),
  )).toList();

  await Future.forEach(sakes, (sake) async {
    await sake.init();
  });

  return sakes;
}
