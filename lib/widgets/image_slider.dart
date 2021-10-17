import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({Key? key}) : super(key: key);

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {

  List <String> _carouselImages = [];
  var _dotPosition = 0;

  getImageSliderFromDb() async {
    var _firestoreIns = FirebaseFirestore.instance;
    QuerySnapshot qn = await _firestoreIns.collection("slider").get();
    setState(() {
      for(int i = 0; i<qn.docs.length; i++){
        _carouselImages.add(
          qn.docs[i]["image"],
        );
        print(qn.docs[i]["image"]);
      }
    });

    return qn.docs;
  }

  @override
  void initState() {
    getImageSliderFromDb();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: CarouselSlider(
            items: _carouselImages.map((item) => Padding(
              padding: const EdgeInsets.only(left: 3, right: 3),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: NetworkImage(item), fit: BoxFit.fitWidth),
                ),
              ),
            )).toList(),
            options: CarouselOptions(
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.8,
              initialPage: 0,
              height: 150,
              enlargeStrategy: CenterPageEnlargeStrategy.height,
              onPageChanged: (val, carouselPageChangeReason){
                setState(() {
                  _dotPosition = val;
                });
              }
            ),
          ),
        ),
        DotsIndicator(
          dotsCount: _carouselImages.length == 0?1 : _carouselImages.length,
          position: _dotPosition.toDouble(),
          decorator: DotsDecorator(
            activeColor: Colors.blue,
            color: Colors.blue.withOpacity(0.5),
            spacing: EdgeInsets.only(left: 2, right: 2),
            activeSize: const Size(18.0,7.0),
            activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
            size: const Size.square(7.0),
          ),
        ),
      ],
    );
  }
}
