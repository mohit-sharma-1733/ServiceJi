import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/screen/DashboardScreen.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import 'package:ServiceJi/utils/images.dart';
import '../app_localizations.dart';
import 'package:ServiceJi/screen/home.dart';

class WalkThroughScreen extends StatefulWidget {
  static String tag = '/WalkThroughScreen';

  @override
  WalkThroughScreenState createState() => WalkThroughScreenState();
}

class WalkThroughScreenState extends State<WalkThroughScreen> {
  int currentIndexPage = 0;
  int pageLength;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    currentIndexPage = 0;
    pageLength = 3;
    changeStatusColor(white_color);
  }

  @override
  void dispose() {
    super.dispose();
    changeStatusColor(white_color);
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.width;
    var w = MediaQuery.of(context).size.height;
    var appLocalization = AppLocalizations.of(context);
    var titles = [appLocalization.translate('lbl_signin_up'), appLocalization.translate('lbl_service_quality'), appLocalization.translate('lbl_cost_effective')];
    var subTitles = [appLocalization.translate('lbl_dummy_text'), appLocalization.translate('lbl_dummy_text'), appLocalization.translate('lbl_dummy_text')];

    changeStatusColor(white_color);
    return Scaffold(
      backgroundColor: white_color,
      body: Stack(
        fit: StackFit.expand,
        children: [
          spacing_large.height,
          Image.asset(
            splash_Background_Img,
            width: w,
            height: h,
            fit: BoxFit.fill,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: PageView(
              children: [
                WalkThrough(textContent: walk_Img1),
                WalkThrough(textContent: walk_Img2),
                WalkThrough(textContent: walk_Img3),
              ],
              onPageChanged: (value) {
                setState(() => currentIndexPage = value);
              },
            ),
          ),
          Positioned(
            width: MediaQuery.of(context).size.width,
            height: 50,
            top: MediaQuery.of(context).size.height * 0.51,
            child: Align(
              alignment: Alignment.center,
              child: DotsIndicator(
                  dotsCount: 3,
                  position: currentIndexPage,
                  decorator: DotsDecorator(
                    color: view_color,
                    activeColor: colorAccent,
                  )),
            ),
          ),
          Positioned(
            width: MediaQuery.of(context).size.width,
            top: MediaQuery.of(context).size.height * 0.55,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    titles[currentIndexPage],
                    style: boldTextStyle(size: 20, color: colorAccent),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Center(
                      child: Text(
                    subTitles[currentIndexPage],
                    style: primaryTextStyle(size: 16, color: Theme.of(context).textTheme.subtitle2.color),
                    textAlign: TextAlign.center,
                  )),
                  SizedBox(height: 50),
                  AppButton(
                    textContent: appLocalization.translate('lbl_get_started'),
                    color: colorAccent,
                    onPressed: () {
                      HomeScreen().launch(context);
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WalkThrough extends StatelessWidget {
  final String textContent;

  WalkThrough({Key key, @required this.textContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: white_color,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SizedBox(
          child: Stack(
        children: <Widget>[
          SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: (MediaQuery.of(context).size.height) / 2.15,
              alignment: Alignment.center,
              child: Image.asset(
                textContent,
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width,
                height: (MediaQuery.of(context).size.height),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
