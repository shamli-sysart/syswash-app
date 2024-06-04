import 'package:flutter/cupertino.dart';

String logo = 'assets/logo/SYSWASH-LOGO 1.png';
String homeImageDelivery = 'assets/images/delivery2.jpg';
String homeImagePick = 'assets/images/pickuporder.jpg';
String logo1='assets/logo/AppIcon.png';



double screenWidth(context) {
  return MediaQuery.of(context).size.width;
}

double screenHeight(context) {
  return MediaQuery.of(context).size.height;
}

// padding size
EdgeInsets commonPaddingAll = const EdgeInsets.all(0.8);
EdgeInsets commonPaddingAll10 = const EdgeInsets.all(10);
EdgeInsets commonPaddingAll15 = const EdgeInsets.all(15);
EdgeInsets commonPaddingLr = const EdgeInsets.only(left: 20, right: 20);
EdgeInsets commonPaddingLrTb = const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10);


//divider (Sized box)

Widget dividerH() {
  return const SizedBox(height: 20);
}

Widget dividerLH() {
  return const SizedBox(height: 10);
}