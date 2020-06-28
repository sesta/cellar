import 'dart:async';

import 'package:bacchus/domain/entities/drink.dart';
import 'package:bacchus/repository/provider/firestore.dart';

Future<List<Drink>> getTimelineImageUrls() async {
  final rawData = await getAll('sakes');
  final drinks = rawData.map((data) => Drink(
    data['userId'],
    data['name'],
    data['thumbImagePath'],
    data['imagePaths'].cast<String>(),
    DateTime.fromMicrosecondsSinceEpoch(data['timestamp']),
  )).toList();

  await Future.forEach(drinks, (drink) async {
    await drink.init();
  });

  return drinks;
}
