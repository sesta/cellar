import 'package:flutter/material.dart';

import 'package:cellar/domain/entity/entities.dart';

import 'package:cellar/app/widget/atoms/badge.dart';

class DrinkTypeTab {
  DrinkTypeTab({
    @required this.drinkType,
    @required this.count,
  });

  final DrinkType drinkType;
  final int count;
}

class DrinkTypeTabBar extends StatelessWidget {
  DrinkTypeTabBar({
    @required this.tabController,
    @required this.drinkTypeTabs,
  });

  final TabController tabController;
  final List<DrinkTypeTab> drinkTypeTabs;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top
      ),
      child: TabBar(
        controller: tabController,
        indicatorColor: Theme.of(context).primaryColor,
        isScrollable: true,
        tabs: drinkTypeTabs.map((drinkTypeTab) =>
          Tab(
            child: Row(
              children: <Widget>[
                Text(
                  drinkTypeTab.drinkType == null
                    ? '全て'
                    : drinkTypeTab.drinkType.label,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                Padding(padding: EdgeInsets.only(right: 4)),
                Badge(drinkTypeTab.count.toString()),
              ],
            ),
          )
        ).toList(),
      ),
    );
  }
}
