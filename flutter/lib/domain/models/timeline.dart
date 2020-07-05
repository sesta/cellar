import 'dart:async';

import 'package:bacchus/domain/entities/drink.dart';
import 'package:bacchus/repository/provider/firestore.dart';

Future<List<Drink>> getTimelineImageUrls() async {
  final rawData = await getDocuments(
    'drinks',
    whereKey: 'userId',
    whereEqualValue: 'VQorGe4kfJRCbT79U0Nm0GEhw2Z2',
    orderKey: 'timestamp',
    isDeskOrder: true,
  );
  final drinks = rawData.map((data) => Drink(
    data['userId'],
    data['userName'],
    data['name'],
    DrinkType.values[data['drinkTypeIndex']],
    data['score'],
    data['memo'],
    data['price'],
    data['place'],
    data['thumbImagePath'],
    data['imagePaths'].cast<String>(),
    DateTime.fromMicrosecondsSinceEpoch(data['timestamp'] * 1000),
  )).toList();

  await Future.forEach(drinks, (drink) async {
    await drink.init();
  });

  return drinks;
}
