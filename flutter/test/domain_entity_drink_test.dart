import 'package:flutter_test/flutter_test.dart';

import 'package:cellar/domain/entity/entities.dart';

void main() {
  Drink drink1 = Drink(
    'user1',
    'userName1',
    false,
    DateTime(2020, 1, 2),
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
    DateTime(2020, 1, 10),
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

  test('Entity Drink init', () {
    expect(null, drink1.thumbImageUrl);

    // TODO: initをテストで実行できるようにする
    // expect('https://url', drink1.thumbImageUrl);
  });

  test('Entity Drink priceString', () {
    expect('¥1,234', drink1.priceString);
    expect('¥123', drink2.priceString);
  });

  test('Entity Drink drinkDateTimeString', () {
    expect('2020/01/02', drink1.drinkDatetimeString);
    expect('2020/01/10', drink2.drinkDatetimeString);
  });
}
