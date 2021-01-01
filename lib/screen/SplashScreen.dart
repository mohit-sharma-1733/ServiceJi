import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ServiceJi/screen/DashboardScreen.dart';
import 'package:ServiceJi/main.dart';
import 'WalkThroughScreen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with AfterLayoutMixin<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //  SetAppSetup();
    // log("Before ${jsonEncode(builderResponse.appSetup)}");
  }

  // void SetAppSetup() async {
  //   await setString(PRIMARY_COLOR, builderResponse.appSetup.primaryColor);
  //   await setString(SECONDARY_COLOR, builderResponse.appSetup.secondaryColor);
  //   await setString(TEXT_PRIMARY_COLOR, builderResponse.appSetup.textPrimaryColor);
  //   await setString(TEXT_SECONDARY_COLOR, builderResponse.appSetup.textSecondaryColor);
  //   await setString(BACKGROUND_COLOR, builderResponse.appSetup.backgroundColor);
  //   await setString(APP_URL, builderResponse.appSetup.appUrl);
  //   await setString(CONSUMER_KEY, builderResponse.appSetup.consumerKey);
  //   await setString(CONSUMER_SECRET, builderResponse.appSetup.consumerSecret);
  //   setState(() {});
  // }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);
    if (_seen) {
      await Future.delayed(Duration(seconds: 2));
      builderResponse.dashboard.layout == 'layout1' ? HomeScreen().launch(context, isNewTask: true) : HomeScreen().launch(context, isNewTask: true);
    } else {
      await prefs.setBool('seen', true);
      await Future.delayed(Duration(seconds: 2));
      WalkThroughScreen().launch(context, isNewTask: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Image.asset(
          'images/serviceji/logowhite.png',
          width: width * 0.5,
          height: width * 0.5,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
