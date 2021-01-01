import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info/package_info.dart';
import 'package:ServiceJi/models/CartModel.dart';
import 'package:ServiceJi/models/CreateOrderRequestModel.dart';
import 'package:ServiceJi/models/PaymentGatewayModel.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/screen/DashboardScreen.dart';
import 'package:ServiceJi/screen/WebViewPaymentScreen.dart';
import 'package:ServiceJi/utils/app_Widget.dart';

import 'package:ServiceJi/utils/common.dart';
import 'package:ServiceJi/utils/constants.dart';

import '../app_localizations.dart';
import '../main.dart';

// ignore: must_be_immutable
class PaymentScreen extends StatefulWidget {
  static String tag = '/PaymentScreen';
  var mCartModel = List<CartModel>();
  CreateOrderRequestModel mCreateOrderRequestModel;

  PaymentScreen({Key key, this.mCartModel, this.mCreateOrderRequestModel}) : super(key: key);

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  var mOrderId;
  var appName = '';
  var amount = '';
  var email = '';
  List<PaymentGatewayModel> mPaymentGatewayList = List<PaymentGatewayModel>();
  var mErrorMsg = '';
  var mIsLoading = false;

  @override
  void initState() {
    super.initState();
    init();
    processPaymentApi();
  }

/*
  getActivePaymentGateways() async {
    getActivePaymentGatewaysApi().then((res) {
      if (!mounted) return;
      setState(() {
        Iterable list = res;
        mPaymentGatewayList =
            list.map((model) => PaymentGatewayModel.fromJson(model)).toList();
        mErrorMsg = '';
      });
    }).catchError((error) {
      setState(() {
        mErrorMsg = error.toString();
      });
    });
  }
*/

  init() async {
    setState(() {
      amount = getTotalAmount(widget.mCartModel);
    });
    await getString(USER_EMAIL).then((s) {
      setState(() {
        email = s;
      });
    });
    await PackageInfo.fromPlatform().then((p) {
      setState(() {
        appName = p.appName;
      });
    });
  }

  void createOrder({String paymentMethod, String txnId = ''}) async {
    setState(() {
      mIsLoading = true;
    });
    await createOrderApi(widget.mCreateOrderRequestModel.toJson()).then((response) {
      if (!mounted) return;
      setState(() {
        mIsLoading = false;
        mOrderId = response['id'];
        processPaymentApi(txnId: txnId);
      });
    }).catchError((error) {
      setState(() {
        mIsLoading = false;
      });
      toast(error.toString());
    });
  }

  processPaymentApi({String paymentMethod, String txnId = ''}) async {
    log(mOrderId);
    if (mOrderId == null) {
      createOrder(txnId: txnId);
      return;
    }
    var request = {"order_id": mOrderId};
    getCheckOutUrl(request).then((res) async {
      if (!mounted) return;
      bool isPaymentDone = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewPaymentScreen(
                  checkoutUrl: res['checkout_url'],
                )),
      );
      if (isPaymentDone) {
        clearCartItems().then((response) {
          if (!mounted) return;
          setState(() {
            mIsLoading = false;
          });
          appStore.setCount(0);
          launchNewScreenWithNewTask(context, DashboardScreen.tag);
        }).catchError((error) {
          setState(() {
            mIsLoading = false;
          });
          toast(error.toString());
        });
      }
    }).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
    Widget paymentDetailView = Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.all(16),
        decoration: boxDecoration(context),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                appLocalization.translate('lbl_payment_details'),
                style: boldFonts(size: 18, color: Theme.of(context).textTheme.headline6.color),
              ),
              SizedBox(height: 10),
              Divider(height: 1),
              SizedBox(height: 10),
              Row(children: <Widget>[
                Text(
                  appLocalization.translate('lbl_total_amount'),
                  style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.headline6.color),
                ),
                PriceWidget(price: amount)
              ])
            ],
          ),
        ));

    Widget listView = ListView.separated(
        separatorBuilder: (context, index) {
          return Divider();
        },
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (_, i) {
          return InkWell(
              child: Container(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(mPaymentGatewayList[i].method_title, style: TextStyle(color: Theme.of(context).textTheme.headline6.color, fontSize: 18)),
                    ],
                  )),
              onTap: () {});
        },
        itemCount: 3);

    Widget body = Column(children: <Widget>[
      SizedBox(height: 16),
      mErrorMsg.isEmpty
          ? mPaymentGatewayList.isNotEmpty
              ? listView
              : Container(height: 100, child: Center(child: CircularProgressIndicator()))
          : Container(height: 100, child: Center(child: Text(mErrorMsg))),
      paymentDetailView
    ]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          onPressed: () {
            finish(context);
          },
          icon: Icon(Icons.arrow_back, size: 30, color: Colors.white),
        ),
        title: Text(
          appLocalization.translate('title_payment'),
          style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
        ),
      ),
      body: !mIsLoading ? SingleChildScrollView(child: body, physics: BouncingScrollPhysics()) : Center(child: CircularProgressIndicator()),
    );
  }
}

String getTotalAmount(List<CartModel> products) {
  var amount = 0.0;
  for (var i = 0; i < products.length; i++) {
    amount += (double.parse(products[i].price) * double.parse(products[i].quantity));
  }
  return amount.toString();
}
