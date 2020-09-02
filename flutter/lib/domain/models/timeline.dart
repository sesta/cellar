import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/repositories.dart';

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

Future<List<Drink>> getTimelineDrinks(
  TimelineType timelineType,
  OrderType orderType,
  {
    DrinkType drinkType,
    String userId,
    Drink lastDrink,
  }
) async {
  List<Drink> drinks;

  switch (timelineType) {
    case TimelineType.Mine:
      drinks = await DrinkRepository().getUserDrinks(
        userId,
        drinkType,
        orderType != OrderType.Older,
        orderType == OrderType.Score,
        lastDrink,
      );
      break;
    case TimelineType.All:
      drinks = await DrinkRepository().getPublicDrinks(
        drinkType,
        orderType != OrderType.Older,
        orderType == OrderType.Score,
        lastDrink,
      );
      break;
  }

  return drinks;
}
