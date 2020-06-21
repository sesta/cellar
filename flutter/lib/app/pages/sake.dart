import 'package:flutter/material.dart';

class SakePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String url = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(
          title: Text('酒の詳細'),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: url,
                    child: Image(
                      image: NetworkImage(url),
                    ),
                  )
                ]
            )
        )
    );
  }
}
