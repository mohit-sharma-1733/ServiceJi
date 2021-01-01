import 'package:flutter/material.dart';

const colorPrimaryDark = Color(0xFF559b52);
const splashBackground = Color(0xFFFFFFFF);
const textColorPrimary = Color(0xFF212121);
const textColorSecondary = Color(0xFF757575);
const textColorThird = Color(0xFFBABFB6);
const textColorGreen = Color(0xFFff9762);
const colorPrimaryLight = Color(0xFF6B9C69);
const view_color = Color(0xFFDADADA);
const white_color = Color(0xFFFFFFFF);
const edit_backgroundColor = Color(0xFFF5F4F4);
const shadow_color = Color(0xFFECECEC);
const redColors = Color(0xFFF61929);
const yellowColor = Color(0xFFFEBA39);
const greyColor = Color(0xFFccd5e1);
const darkGreyColor = Color(0xFF333333);
const app_Background = Color(0xFFf3f5f9);
const BlackColor = Color(0xFF000000);
const SelectionColor = Color(0xFF3CCDCD);

var darkBgColor = Colors.grey[850];
var lightBgColor = Colors.grey[300];

Map<int, Color> color = {
  50: Color.fromRGBO(136, 14, 79, .1),
  100: Color.fromRGBO(136, 14, 79, .2),
  200: Color.fromRGBO(136, 14, 79, .3),
  300: Color.fromRGBO(136, 14, 79, .4),
  400: Color.fromRGBO(136, 14, 79, .5),
  500: Color.fromRGBO(136, 14, 79, .6),
  600: Color.fromRGBO(136, 14, 79, .7),
  700: Color.fromRGBO(136, 14, 79, .8),
  800: Color.fromRGBO(136, 14, 79, .9),
  900: Color.fromRGBO(136, 14, 79, 1),
};

MaterialColor materialColor(colorHax) {
  return MaterialColor(colorHax, color);
}

MaterialColor colorCustom = MaterialColor(0xFF5959fc, color);
