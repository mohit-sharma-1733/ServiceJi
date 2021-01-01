import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/models/CouponResponse.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_localizations.dart';

class ApplyCouponScreen extends StatefulWidget {
  static String tag = '/ApplyCouponScreen';

  @override
  ApplyCouponScreenState createState() => ApplyCouponScreenState();
}

class ApplyCouponScreenState extends State<ApplyCouponScreen> {
  var mCouponModel = List<CouponResponse>();
  var mCouponModel1 = CouponResponse();
  var errorMsg = '';
  bool isLoading = false;
  SharedPreferences pref;

  @override
  void initState() {
    super.initState();
    init();
    fetchCouponData();
  }

  init() async {
    changeStatusColor(primaryColor);
  }

  Future fetchCouponData() async {
    setState(() {
      isLoading = true;
    });
    await getCouponList().then((res) {
      if (!mounted) return;
      isLoading = false;
      setState(() {
        Iterable mCoupon = res;
        mCouponModel = mCoupon.map((model) => CouponResponse.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    changeStatusColor(primaryColor);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
    Widget mCouponName(var text) {
      return Text(
        text,
        style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeMedium),
      );
    }

    Widget mCouponInfo(var text) {
      return Text(
        text,
        style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeSMedium),
      );
    }

    Widget mCoupon = ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: mCouponModel.length,
      itemBuilder: (context, i) {
        return Container(
            padding: EdgeInsets.only(bottom: spacing_standard.toDouble()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (mCouponModel[i].discountType == "percent")
                      mCouponName('Get ' + mCouponModel[i].amount.toString() + "% off")
                    else if (mCouponModel[i].discountType == "fixed_cart")
                      mCouponName('Get Flat ' + mCouponModel[i].amount.toString() + " off")
                    else if (mCouponModel[i].discountType == "fixed_product")
                      mCouponName('Get Flat ' + mCouponModel[i].amount + " off to all products")
                    else
                      mCouponName('Get ' + mCouponModel[i].amount + "off"),
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () {
                        Share.share('Apply Coupon Code: ' + mCouponModel[i].code + "\n\nDownload app from here: https://play.google.com/store/apps/details?id=");
                      },
                    ),
                  ],
                ),
                Text(
                  mCouponModel[i].description,
                  style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium),
                ),
                if (double.parse(mCouponModel[i].minimumAmount) > 0.0)
                  mCouponInfo("Valid only orders of " + mCouponModel[i].amount.toString() + " and above.")
                else if (double.parse(mCouponModel[i].maximumAmount) > 0.0)
                  mCouponInfo("\nMaximum bill amount is " + mCouponModel[i].maximumAmount)
                else
                  mCouponModel[i].usageLimit != null
                      ? mCouponModel[i].usageLimit > 0
                          ? mCouponInfo("Valid only for first " + mCouponModel[i].usageLimit.toString() + " users.")
                          : SizedBox()
                      : mCouponInfo("No Minimum order value needed."),
                spacing_control.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DottedBorder(
                      borderType: BorderType.RRect,
                      dashPattern: [6, 3, 6, 3],
                      color: colorAccent,
                      child: Container(
                        width: context.width() * 0.2,
                        height: 35,
                        color: colorAccent.withOpacity(0.15),
                        child: Center(child: Text(mCouponModel[i].code, style: secondaryTextStyle(color: Theme.of(context).accentColor, size: textSizeSMedium)))
                            .paddingAll(spacing_standard.toDouble()),
                      ),
                    ),
                    Text(appLocalization.translate('lbl_apply'), style: primaryTextStyle(color: Theme.of(context).accentColor, size: textSizeMedium)).onTap(() {
                      Navigator.pop(context, jsonEncode(mCouponModel[i].toJson()));
                    })
                  ],
                ).paddingOnly(right: spacing_standard.toDouble()),
                spacing_standard_new.height,
                Divider()
              ],
            ).paddingOnly(left: spacing_standard.toDouble()));
      },
    );

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
            "Available Coupon",
            style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
          ),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            mCoupon,
            CircularProgressIndicator().center().visible(isLoading),
          ],
        ));
  }
}
