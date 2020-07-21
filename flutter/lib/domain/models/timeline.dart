import 'dart:async';

import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/repository/drink_repository.dart';

enum TimelineType {
  Mine,
  All,
}

enum OrderType {
  Newer,
  Older,
  Score,
}

extension OrderTypeExtension on OrderType {
  String get label {
    switch(this) {
      case OrderType.Newer: return '新しい順';
      case OrderType.Older: return '古い順';
      case OrderType.Score: return 'スコア順';
    }

    throw '不明なTypeです。: $this';
  }
}

Future<List<Drink>> getTimelineImageUrls(TimelineType timelineType, {
  DrinkType drinkType,
  String userId,
}) async {
  List<Drink> drinks;

  switch (timelineType) {
    case TimelineType.Mine:
      drinks = await DrinkRepository().getUserDrinks(userId, drinkType);
      break;
    case TimelineType.All:
      drinks = await DrinkRepository().getPublicDrinks(drinkType);
      break;
  }

  return drinks;
}
