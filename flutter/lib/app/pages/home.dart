import 'package:bacchus/app/widget/image_grid.dart';
import 'package:bacchus/domain/models/post.dart';
import 'package:bacchus/domain/models/timeline.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();

    getTimelineImageUrls().then((urls) {
      setState(() {
        imageUrls = urls;
      });
    });
  }

  void _getImageList() async {
    var resultList = await MultiImagePicker.pickImages(
      maxImages: 10,
    );

    uploadImages(resultList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: imageUrls.length == 0 ?
      Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Download中')
              ]
          )
      ) :
      ImageGrid(imageUrls: imageUrls),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageList,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
