import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'colors.dart';

RoundedRectangleBorder roundedRectangleBorder(double radius, {Color color = viewLineColor}) {
  return RoundedRectangleBorder(side: BorderSide(color: color), borderRadius: BorderRadius.all(Radius.circular(radius)));
}
BoxDecoration boxDecorationSoftUI({darkMode = false, radius = 40.0}) {
  return BoxDecoration(
    color: darkMode ? darkBgColor : lightBgColor,
    borderRadius: BorderRadius.all(Radius.circular(radius)),
    boxShadow: [
      BoxShadow(color: darkMode ? Colors.black54 : Colors.grey[500], offset: Offset(4.0, 4.0), blurRadius: 15.0, spreadRadius: 1.0),
      BoxShadow(color: darkMode ? Colors.grey[800] : Colors.white, offset: Offset(-4.0, -4.0), blurRadius: 15.0, spreadRadius: 1.0),
    ],
  );
}