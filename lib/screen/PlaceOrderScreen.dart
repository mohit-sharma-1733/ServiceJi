import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/images.dart';
import '../app_localizations.dart';
import 'DashboardScreen.dart';

class PlaceOrderScreen extends StatefulWidget {
  static String tag = '/PlaceOrderScreen';
  var mOrderID, total, transactionId, orderKey, paymentMethod, dateCreated;

  PlaceOrderScreen({
    Key key,
    this.mOrderID,
    this.total,
    this.transactionId,
    this.orderKey,
    this.paymentMethod,
    this.dateCreated,
  }) : super(key: key);

  @override
  PlaceOrderScreenState createState() => PlaceOrderScreenState();
}

class PlaceOrderScreenState extends State<PlaceOrderScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    createOrderTracking();
  }

  init() async {}

  Future createOrderTracking() async {
    setState(() {
      isLoading = true;
    });
    var request = {
      'customer_note': true,
      'note': "{\n" + "\"status\":\"Ordered\",\n" + "\"message\":\"Your order has been placed.\"\n" + "} ",
    };
    await CreateOrderNotes(widget.mOrderID, request).then((res) {
      if (!mounted) return;
      isLoading = false;
      setState(() {});
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        toast(error.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: () {
            finish(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 30, color: BlackColor),
        ),
        bottomOpacity: 0.0,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Image.asset(
              Selected_icon,
              height: 60,
              width: 60,
              color: Color(0xFF66953A),
              fit: BoxFit.contain,
            )),
            spacing_standard_new.height,
            Center(
                child: Text(
              appLocalization.translate('lbl_oder_placed_successfully'),
              style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeLargeMedium),
            )),
            spacing_standard_new.height,
            Text(appLocalization.translate('lbl_total_amount_'), style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeSMedium)),
            spacing_control.height,
            Text(widget.total, style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeLargeMedium)),
            spacing_standard_new.height,
            Text(appLocalization.translate('lbl_transaction_id'), style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeSMedium)),
            spacing_control.height,
            Text(widget.transactionId, style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeLargeMedium)),
            spacing_standard_new.height,
            Text(appLocalization.translate('lbl_order_id'), style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeSMedium)),
            Text(widget.orderKey, style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeLargeMedium)),
            spacing_standard_new.height,
            Text(appLocalization.translate('lbl_payment_through'), style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeSMedium)),
            Text(widget.paymentMethod, style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeLargeMedium)),
            spacing_standard_new.height,
            Text(appLocalization.translate('lbl_transaction_date'), style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeSMedium)),
            Text(widget.dateCreated.toString(), style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeLargeMedium)),
            spacing_large.height,
            AppButton(
                textContent: appLocalization.translate('lbl_done'),
                color: colorAccent,
                onPressed: () {
                  clearCartItems().then((response) {
                    if (!mounted) return;
                    setState(() {});
                    launchNewScreenWithNewTask(context, DashboardScreen.tag);
                  }).catchError((error) {
                    setState(() {});
                    toast(error.toString());
                  });
                }),
          ],
        ).paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()),
      ),
    );
  }
}
