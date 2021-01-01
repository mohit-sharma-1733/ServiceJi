import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info/package_info.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/common.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import 'package:ServiceJi/utils/images.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_localizations.dart';

class AboutUsScreen extends StatefulWidget {
  static String tag = '/AboutUsScreen';

  @override
  AboutUsScreenState createState() => AboutUsScreenState();
}

class AboutUsScreenState extends State<AboutUsScreen> {
  SharedPreferences pref;
  var primaryColor;
  var darkMode = false;
  PackageInfo package;
  var copyrightText = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    pref = await getSharedPref();
    primaryColor = await getThemeColor();
    package = await PackageInfo.fromPlatform();
    setState(() {
      if (pref.getString(COPYRIGHT_TEXT) != null) {
        copyrightText = pref.getString(COPYRIGHT_TEXT);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    changeStatusColor(Theme.of(context).primaryColor);
    var appLocalization = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          onPressed: () {
            finish(context);
          },
          icon: Icon(Icons.arrow_back, size: 30, color: Colors.white),
        ),
        title: Text(
          appLocalization.translate('lbl_about'),
          style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: pref != null
              ? Column(
                  children: [
                    spacing_standard_new.height,
                    Container(
                      width: 120,
                      height: 120,
                      padding: EdgeInsets.all(spacing_standard.toDouble()),
                      decoration: boxDecoration(
                        context,
                        radius: 10.0,
                        showShadow: true,
                        bgColor: Colors.white,
                      ),
                      child: Image.asset(
                        app_logo,
                      ),
                    ),
                    spacing_standard_new.height,
                    (package.appName != null)
                        ? Text(
                            package.appName.validate(),
                            style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeNormal),
                          )
                        : SizedBox(),
                    spacing_standard.height,
                    Text(
                      appLocalization.translate('lbl_version'),
                      style: secondaryTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeSMedium),
                    ),
                    spacing_standard.height,
                    Text(
                      copyrightText,
                      style: secondaryTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeLargeMedium),
                    ),
                    spacing_standard_new.height,
                    GestureDetector(
                      onTap: () => redirectUrl(pref.getString(TERMS_AND_CONDITIONS)),
                      child: Text(parseHtmlString(appLocalization.translate('lbl_terms_conditions')), style: boldFonts(size: 20, color: primaryColor)),
                    ),
                    spacing_standard_new.height,
                    GestureDetector(
                      onTap: () => redirectUrl(pref.getString(PRIVACY_POLICY)),
                      child: Text(appLocalization.translate('llb_privacy_policy'), style: boldFonts(size: 20, color: primaryColor)),
                    ),
                  ],
                ).center()
              : SizedBox(),
        ),
      ),
      bottomNavigationBar: pref != null
          ? Container(
              width: context.width(),
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    appLocalization.translate('llb_follow_us'),
                    style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium),
                  ).visible(pref.getString(WHATSAPP).isNotEmpty),
                  spacing_standard_new.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          redirectUrl('https://wa.me/${pref.getString(WHATSAPP)}');
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: spacing_standard_new.toDouble()),
                          padding: EdgeInsets.all(10),
                          child: Image.asset(ic_WhatsUp, height: 35, width: 35),
                        ),
                      ).visible(pref.getString(WHATSAPP).isNotEmpty),
                      InkWell(
                        onTap: () => redirectUrl(pref.getString(INSTAGRAM)),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Image.asset(ic_Inst, height: 35, width: 35),
                        ),
                      ).visible(pref.getString(INSTAGRAM).isNotEmpty),
                      InkWell(
                        onTap: () => redirectUrl(pref.getString(TWITTER)),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Image.asset(ic_Twitter, height: 35, width: 35),
                        ),
                      ).visible(pref.getString(TWITTER).isNotEmpty),
                      InkWell(
                        onTap: () => redirectUrl(pref.getString(FACEBOOK)),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Image.asset(ic_Fb, height: 35, width: 35),
                        ),
                      ).visible(pref.getString(FACEBOOK).isNotEmpty),
                      InkWell(
                        onTap: () => redirectUrl('tel:${pref.getString(CONTACT)}'),
                        child: Container(
                          margin: EdgeInsets.only(right: spacing_standard_new.toDouble()),
                          padding: EdgeInsets.all(10),
                          child: Image.asset(ic_CallRing, height: 35, width: 35, color: primaryColor),
                        ),
                      ).visible(pref.getString(CONTACT).isNotEmpty)
                    ],
                  )
                ],
              ),
            )
          : SizedBox(),
    );
  }
}
