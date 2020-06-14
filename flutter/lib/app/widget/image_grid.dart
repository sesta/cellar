import 'package:flutter/material.dart';

class ImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  ImageGrid({this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: imageUrls.map<Widget>((url) {
        return Image(
          image: NetworkImage(url),
        );
      }).toList(),
    );
  }
}