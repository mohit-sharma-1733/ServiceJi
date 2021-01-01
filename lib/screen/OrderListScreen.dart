import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/models/OrderModel.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/screen/OrderDetailScreen.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/constants.dart';
import '../utils/app_Widget.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';
import '../app_localizations.dart';

class OrderList extends StatefulWidget {
  static String tag = '/OrderList';

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  var mOrderModel = List<OrderResponse>();
  var mProductModel = List<OrderResponse>();
  var mErrorMsg = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
    fetchOrderData();
  }

  Future fetchOrderData() async {
    setState(() {
      isLoading = true;
    });
    await getOrders().then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable mOrderDetails = res;
        mOrderModel = mOrderDetails.map((model) => OrderResponse.fromJson(model)).toList();
        //   mOrderModel.addAll(mOrderDetails.map((model) => OrderResponse.fromJson(model)).toList());
        if (mOrderModel.isEmpty) {
          mErrorMsg = ('No Data Found');
        } else {
          mErrorMsg = '';
        }
      });
    }).catchError((error) {
      if (!mounted) return;
      log(error);
      setState(() {
        isLoading = false;
        mOrderModel.clear();
        mErrorMsg = error.toString();
      });
    });
  }

  init() async {
    changeStatusColor(primaryColor);
  }

  @override
  void dispose() {
    super.dispose();
    changeStatusColor(primaryColor);
  }

  @override
  Widget build(BuildContext context) {
    changeStatusColor(primaryColor);
    var appLocalization = AppLocalizations.of(context);
    Widget mBody = ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: mOrderModel.length,
        itemBuilder: (context, i) {
          return Container(
              decoration: boxDecoration(context, radius: 0, showShadow: true),
              margin: EdgeInsets.only(top: spacing_standard.toDouble()),
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      if (mOrderModel[i].lineItems.isNotEmpty)
                        if (mOrderModel[i].lineItems[0].productImages[0].src.isNotEmpty)
                          Image.network(
                            mOrderModel[i].lineItems[0].productImages[0].src,
                            height: 100,
                            width: 100,
                            fit: BoxFit.contain,
                          ).paddingOnly(top: spacing_middle.toDouble()),
                      10.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            if (mOrderModel[i].lineItems.isNotEmpty)
                              if (mOrderModel[i].lineItems.length > 1)
                                Text(mOrderModel[i].lineItems[0].name + " + " + " more items".toString(),
                                    style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium))
                              else
                                Text(
                                  mOrderModel[i].lineItems[0].name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium),
                                )
                            else
                              Text(
                                mOrderModel[i].id.toString(),
                                style: primaryTextStyle(size: textSizeLargeMedium),
                              ),
                            spacing_standard.height,
                            Text(
                              "Order Via " + mOrderModel[i].paymentMethod,
                              style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color),
                            ),
                            spacing_standard.height,
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: boxDecorationWithRoundedCorners(backgroundColor: Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                mOrderModel[i].status.toUpperCase(),
                                style: secondaryTextStyle(size: 12, color: Theme.of(context).textTheme.subtitle2.color),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )).onTap(() {
            OrderDetailScreen(mOrderModel: mOrderModel[i]).launch(context);
          });
        });
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
          appLocalization.translate('lbl_my_orders'),
          style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
        ),
      ),
      body: mErrorMsg.isEmpty
          ? mOrderModel.isNotEmpty
              ? mBody
              : Center(child: CircularProgressIndicator())
          : Center(
              child: Text(
              mErrorMsg,
              style: boldTextStyle(color: Colors.black),
            )),
    );
  }
}
