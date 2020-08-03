import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';

import 'package:cellar/domain/entities/user.dart';
import 'package:cellar/domain/entities/drink.dart';

import 'package:cellar/app/widget/atoms/label_test.dart';
import 'package:cellar/app/widget/atoms/main_text.dart';
import 'package:cellar/app/widget/atoms/normal_text.dart';


class DrinkPage extends StatefulWidget {
  DrinkPage({
    Key key,
    this.user,
    this.drink,
  }) : super(key: key);

  final User user;
  final Drink drink;

  @override
  _DrinkPageState createState() => _DrinkPageState();
}

class _DrinkPageState extends State<DrinkPage> {
  bool _imageLoaded = false;
  int _carouselPage = 0;
  ScrollController _scrollController = ScrollController();
  // 連続でpopが発生しないように、状態を持っておく
  bool _isPop = false;

  @override
  initState() {
    super.initState();

    _scrollController.addListener(_popPage);

    setState(() {
      _imageLoaded = widget.drink.imageUrls != null;
    });

    if (widget.drink.imageUrls == null) {
      _loadImage();
    }
  }

  _updatePage(int index, _) {
    setState(() {
      _carouselPage = index;
    });
  }

  Future<void> _loadImage() async {
    await widget.drink.getImageUrls();
    setState(() {
      _imageLoaded = true;
    });
  }

  Future<void> _editDrink() async{
    final isDelete = await Navigator.of(context).pushNamed('/edit', arguments: widget.drink);

    if (isDelete == true) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {});
  }

  Future<void> _popPage() async {
    if (_scrollController.position.pixels > -80 || _isPop) {
      return;
    }

    setState(() {
      _isPop = true;
    });
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final imageLength = widget.drink.imagePaths.length;

    return Scaffold(
      body:  SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  _drinkImageContainer(),
                  Positioned(
                    top: MediaQuery.of(context).padding.top,
                    left: 16,
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
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                  ),
                  widget.user == null || widget.user.userId != widget.drink.userId ? Container()
                    : Positioned(
                      top: MediaQuery.of(context).padding.top,
                      right: 16,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.black87.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.white
                          ),
                          padding: EdgeInsets.all(8),
                          onPressed: _editDrink,
                        ),
                      ),
                    ),
                  imageLength == 1 ? Container()
                    :Positioned(
                      bottom: 0,
                      right: 0,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: NormalText("${_carouselPage + 1} / $imageLength"),
                      ),
                    ),
                ],
              ),
              Padding(padding: EdgeInsets.only(bottom: 16)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          color: Theme.of(context).accentColor,
                        ),
                        Padding(padding: EdgeInsets.only(right: 4)),
                        NormalText(widget.drink.userName),
                        Expanded(child: Container()),

                        NormalText(widget.drink.drinkDatetimeString),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 24)),

                    MainText(
                      widget.drink.drinkName,
                      bold: true,
                      multiLine: true,
                      textAlign: TextAlign.center,
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 8)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i)=> i).map((index) =>
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < widget.drink.score ? Icons.star : Icons.star_border,
                            color: Colors.orangeAccent,
                          ),
                        )
                      ).toList(),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 32)),

                    Container(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        children: <Widget>[
                          LabelText(widget.drink.drinkType.label),
                          widget.drink.subDrinkType == SubDrinkType.Empty ? Container(width: 0) : LabelText(widget.drink.subDrinkType.label),
                          widget.drink.price == 0 ? Container(width: 0) : LabelText(widget.drink.priceString),
                          widget.drink.place == '' ? Container(width: 0) : LabelText(widget.drink.place),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 8)),

                    Container(
                      alignment: Alignment.centerLeft,
                      child: NormalText(
                        widget.drink.memo,
                        multiLine: true,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: 80)),
            ]
          ),
        ),
      )
    );
  }

  Widget _drinkImageContainer() {
    final imageRatio = widget.drink.firstImageWidth/widget.drink.firstImageHeight;
    final imageLength = widget.drink.imagePaths.length;

    return Container(
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
            child: Lottie.asset(
              'assets/lottie/loading.json',
              width: 80,
              height: 80,
            ),
          );

          if (_imageLoaded) {
            content = CachedNetworkImage(
              placeholder: (context, url) => Center(
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  width: 80,
                  height: 80,
                ),
              ),
              imageUrl: widget.drink.imageUrls[index],
              fit: BoxFit.contain,
            );
          }

          if (index == 0) {
            content = Hero(
              tag: widget.drink.thumbImagePath,
              child: _imageLoaded
                  ? CachedNetworkImage(
                placeholder: (context, url) => Image(
                  image: NetworkImage(
                    widget.drink.thumbImageUrl,
                  ),
                  fit: BoxFit.contain,
                ),
                imageUrl: widget.drink.imageUrls.first,
                fit: BoxFit.contain,
              )
                  : Image(
                image: NetworkImage(
                  widget.drink.thumbImageUrl,
                ),
                fit: BoxFit.contain,
              ),
            );
          }

          return AspectRatio(
            aspectRatio: imageRatio,
            child: content,
          );
        }).toList(),
      ),
    );
  }
}
