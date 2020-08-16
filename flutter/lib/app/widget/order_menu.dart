import 'package:cellar/domain/models/timeline.dart';
import 'package:flutter/material.dart';

class OrderMenu extends StatelessWidget {
  OrderMenu({
    @required this.selectedOrderType,
    @required this.updateOrderType,
  });

  final OrderType selectedOrderType;
  final updateOrderType;

  @override
  Widget build(BuildContext context) =>
    Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(padding: EdgeInsets.only(left: 12)),
          Text(
            selectedOrderType.label,
            style: Theme.of(context).textTheme.caption.copyWith(
              height: 1,
            ),
          ),

          PopupMenuButton(
            color: Theme.of(context).dialogBackgroundColor,
            onSelected: updateOrderType,
            icon: Icon(
              Icons.sort,
              size: 20,
            ),
            itemBuilder: (BuildContext context) =>
              OrderType.values.map((orderType) =>
                PopupMenuItem(
                  height: 40,
                  value: orderType,
                  child: Text(
                    orderType.label,
                    style: orderType == selectedOrderType
                      ? Theme.of(context).textTheme.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1,
                        )
                      : Theme.of(context).textTheme.caption,
                  ),
                )
              ).toList(),
          ),
        ],
      ),
    );
}