import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';

import 'package:cellar/domain/entity/entities.dart';
import 'package:cellar/repository/repositories.dart';

import 'package:cellar/app/widget/atoms/label.dart';
import 'package:cellar/app/widget/atoms/toast.dart';

class DrinkPage extends StatefulWidget {
  DrinkPage({
    Key key,
    @required this.user,
    @required this.drink,
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
    try {
      await widget.drink.getImageUrls();
    } catch (e, stackTrace) {
      showToast(context, '画像の読み込みに失敗しました。');
      AlertRepository().send(
        '詳細ページで画像の読み込みに失敗しました。',
        stackTrace.toString().substring(0, 1000),
      );
    }

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
      backgroundColor: Theme.of(context).backgroundColor,
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
                        child: Text(
                          "${_carouselPage + 1} / $imageLength",
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
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
                          color: Theme.of(context).primaryColor,
                        ),
                        Padding(padding: EdgeInsets.only(right: 4)),
                        Text(
                          widget.drink.userName,
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                        Expanded(child: Container()),

                        Text(
                          widget.drink.drinkDatetimeString,
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 24)),

                    Text(
                      widget.drink.drinkName,
                      style: Theme.of(context).textTheme.headline2,
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
                          widget.drink.isPrivate ? Label('非公開') : Container(width: 0),
                          Label(widget.drink.drinkType.label),
                          widget.drink.subDrinkType == SubDrinkType.Empty ? Container(width: 0) : Label(widget.drink.subDrinkType.label),
                          widget.drink.origin == '' ? Container(width: 0) : Label(widget.drink.origin),
                          widget.drink.price == 0 ? Container(width: 0) : Label(widget.drink.priceString),
                          widget.drink.place == '' ? Container(width: 0) : Label(widget.drink.place),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 8)),

                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.drink.memo,
                        style: Theme.of(context).textTheme.bodyText2,
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
      color: Theme.of(context).scaffoldBackgroundColor,
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

          if (index == 0 && widget.drink.thumbImageUrl != null) {
            content = _imageLoaded
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
