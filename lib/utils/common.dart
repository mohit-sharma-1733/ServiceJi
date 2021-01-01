import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/main.dart';

import 'package:ServiceJi/screen/DashboardScreen.dart';
import 'package:ServiceJi/screen/SignInScreen.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/shared_pref.dart';
import 'package:url_launcher/url_launcher.dart';

import 'colors.dart';
import 'constants.dart';

Widget appBars(context, String title, {List<Widget> actions}) {
  return AppBar(
    backgroundColor: Theme.of(context).primaryColor,
    leading: IconButton(
      onPressed: () {
        finish(context);
      },
      icon: Icon(Icons.arrow_back, size: 30, color: Colors.white),
    ),
    title: Text(title, style: boldTextStyle(color: Colors.white)),
    actions: actions,
    automaticallyImplyLeading: true,
  );
}

//String parseHtmlString(String htmlString) {
//  return parse(parse(htmlString).body.text).documentElement.text;
//}
TextStyle boldFonts({color = blackColor, size = 16.0}) {
  return GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: size is int ? double.parse(size.toString()).toDouble() : size, textStyle: boldTextStyle(color: color));
}

String convertDate(date) {
  try {
    return date != null ? DateFormat(orderDateFormat).format(DateTime.parse(date)) : '';
  } catch (e) {
    log(e);
    return '';
  }
}

String reviewConvertDate(date) {
  try {
    return date != null ? DateFormat(reviewDateFormat).format(DateTime.parse(date)) : '';
  } catch (e) {
    log(e);
    return '';
  }
}

Future getThemeColor() async {
  String color = await getString(THEME_COLOR);
  if (color.isEmpty) {
    return primaryColor;
  } else {
    return getColorFromHex(color);
  }
}

void redirectUrl(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    toast('Please check URL');
    throw 'Could not launch $url';
  }
}

Future openRateProductDialog(context, onSubmit) async {
  var reviewCont = TextEditingController();
  var ratings = 0.0;

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Text('Rate this product', style: boldFonts()),
                  SizedBox(height: 20),
                  RatingBar(
                    initialRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      ratings = rating;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: reviewCont,
                    maxLines: 5,
                    minLines: 2,
                    decoration: InputDecoration(hintText: 'Review'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          elevation: 10,
                          color: primaryColor,
                          onPressed: () {
                            if (ratings < 1) {
                              toast('Please Rate');
                            } else if (reviewCont.text.isEmpty) {
                              toast('Please Review');
                            } else {
                              onSubmit(reviewCont.text, ratings);
                            }
                          },
                          child: Text('Rate Now', style: TextStyle(color: whiteColor)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      );
    },
  );
}

Future<bool> checkLogin(context) async {
  if (!await isLoggedIn()) {
    SignInScreen().launch(context);
    return false;
  } else {
    return true;
  }
}

Future logout(BuildContext context) async {
  ConfirmAction res = await showConfirmDialogs(context, 'Are you sure want to logout?', 'Yes', 'Cancel');
  if (res == ConfirmAction.ACCEPT) {
    var pref = await getSharedPref();
    var primaryColor = pref.getString(THEME_COLOR);
    if (pref.getBool(IS_LOGGED_IN) != null) {
      pref.clear();
    }
    pref.remove(PROFILE_IMAGE);
    pref.remove(BILLING);
    pref.remove(SHIPPING);
    pref.remove(USERNAME);
    pref.setString(THEME_COLOR, primaryColor);
    DashboardScreen().launch(context, isNewTask: true);
  }
}

checkLoggedIn(context, tag) async {
  var pref = await getSharedPref();
  if (pref.getBool(IS_LOGGED_IN) != null && pref.getBool(IS_LOGGED_IN)) {
    launchNewScreen(context, tag);
  } else {
    SignInScreen().launch(context);
    //launchNewScreen(context, LoginScreen.tag);
  }
}

String parseHtmlString(String htmlString) {
  return parse(parse(htmlString).body.text).documentElement.text;
}
