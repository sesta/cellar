import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:cellar/domain/entities/drink.dart';
import 'package:cellar/app/widget/atoms/label_test.dart';
import 'package:cellar/app/widget/atoms/main_text.dart';
import 'package:cellar/app/widget/atoms/normal_text.dart';


class DrinkPage extends StatefulWidget {
  DrinkPage({Key key, this.drink}) : super(key: key);

  final Drink drink;

  @override
  _DrinkPageState createState() => _DrinkPageState();
}

class _DrinkPageState extends State<DrinkPage> {
  bool imageLoaded = false;
  int carouselPage = 0;

  @override
  void initState() {
    super.initState();

    setState(() {
      this.imageLoaded = widget.drink.imageUrls != null;
    });

    if (widget.drink.imageUrls == null) {
      _loadImage();
    }
  }

  void _loadImage() async {
    await widget.drink.getImageUrls();
    setState(() {
      this.imageLoaded = true;
    });
  }

  void _updatePage(int index, _) {
    setState(() {
      this.carouselPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageRatio = widget.drink.firstImageWidth/widget.drink.firstImageHeight;
    final imageLength = widget.drink.imagePaths.length;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  color: Theme.of(context).primaryColor,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      aspectRatio: imageRatio,
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                      onPageChanged: _updatePage,
                    ),
                    items: List.generate(imageLength, (index) {
                      Widget content = Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );

                      if (imageLoaded) {
                        content = Image(
                          image: NetworkImage(widget.drink.imageUrls[index]),
                          fit: BoxFit.contain,
                        );
                      }

                      if (index == 0) {
                        content = Hero(
                          tag: widget.drink.thumbImageUrl,
                          child: imageLoaded
                            ? content
                            : Image(
                              image: NetworkImage(widget.drink.thumbImageUrl),
                              fit: BoxFit.contain,
                            ),
                        );
                      }

                      return GestureDetector(
                        onVerticalDragEnd: (event) {
                          if (event.velocity.pixelsPerSecond.dy > 100) {
                            Navigator.of(context).pop(true);
                          }
                        },
                        child: AspectRatio(
                          aspectRatio: imageRatio,
                          child: content,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 16,
                  ),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.black87.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 24,
                        color: Colors.white
                      ),
                      padding: EdgeInsets.all(8),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: NormalText("${carouselPage + 1} / $imageLength"),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  Expanded(
                    child: NormalText(widget.drink.userName),
                  ),
                  NormalText(widget.drink.postDatetimeString),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 16,
                right: 16,
              ),
              child: MainText(
                widget.drink.drinkName,
                bold: true,
                multiLine: true,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 8,
                left: 16,
                right: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i)=> i).map<Widget>((index) =>
                  Padding(
                    padding: EdgeInsets.only(left: 4, right: 4),
                    child: Icon(
                      index < widget.drink.score ? Icons.star : Icons.star_border,
                      color: Colors.orangeAccent,
                    ),
                  )
                ).toList(),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(
                top: 32,
                left: 16,
                right: 16,
                bottom: 64,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      children: <Widget>[
                        LabelText(widget.drink.drinkTypeLabel),
                        widget.drink.price == 0 ? Container() : LabelText(widget.drink.priceString),
                        widget.drink.place == '' ? Container() : LabelText(widget.drink.place),
                      ],
                    ),
                  ),
                  NormalText(
                    widget.drink.memo,
                    multiLine: true,
                  ),
                ],
              )
            )
          ]
        ),
      )
    );
  }
}
