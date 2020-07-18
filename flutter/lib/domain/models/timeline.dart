import 'dart:async';

import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/repository/drink_repository.dart';

enum TimelineType {
  Mine,
  All,
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
