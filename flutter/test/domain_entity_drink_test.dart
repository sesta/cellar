import 'package:flutter_test/flutter_test.dart';

import 'package:cellar/domain/entity/entities.dart';

void main() {
  Drink drink1 = Drink(
    'user1',
    'userName1',
    false,
    DateTime.now(),
    'drinkName1',
    DrinkType.Sake,
    SubDrinkType.SakeDaiginjo,
    1,
    'memo1',
    1234,
    '',
    '',
    DateTime.now(),
    '',
    [''],
    123,
    234,
    drinkId: 'drink1',
  );

  Drink drink2 = Drink(
    'user1',
    'userName1',
    false,
    DateTime.now(),
    'drinkName1',
    DrinkType.Sake,
    SubDrinkType.SakeDaiginjo,
    1,
    'memo1',
    123,
    '',
    '',
    DateTime.now(),
    '',
    [''],
    123,
    234,
    drinkId: 'drink1',
  );

  test('Entity priceString', () {
    expect('¥1,234', drink1.priceString);
    expect('¥123', drink2.priceString);
  });
}
