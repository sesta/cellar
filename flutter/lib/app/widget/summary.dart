import 'package:flutter/material.dart';

import 'package:cellar/domain/entity/entities.dart';

class Summary extends StatefulWidget {
  Summary({
    Key key,
    @required this.user,
  }) : super(key: key);

  final User user;

  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(widget.user.userId)
    );
  }
}
