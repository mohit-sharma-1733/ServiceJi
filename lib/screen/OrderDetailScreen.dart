import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/models/Coupon_lines.dart';
import 'package:ServiceJi/models/OrderModel.dart';
import 'package:ServiceJi/models/OrderTracking.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/screen/ProductDetailsBuilderScreen.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/common.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/dashed_ract.dart';
import '../app_localizations.dart';
import '../utils/app_Widget.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';
import 'ProductDetailScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailScreen extends StatefulWidget {
  static String tag = '/OrderDetailScreen';
  final OrderResponse mOrderModel;

  OrderDetailScreen({Key key, this.mOrderModel}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  var mOrderModel = List<OrderResponse>();
  var mOrderTrackingModel = List<OrderTracking>();
  bool isLoading = false;
  var mValue;
  final List<String> mCancelList = [
    'Product is being delivered to a wrong address',
    'Product is not required anymore',
    'Cheaper alternative available for lesser price',
    'The price of the product has fallen due to sales/discounts and customer wants to get it at a lesser price.',
    'Bad review from friends/relatives after ordering the product.',
    'Order placed by mistake',
  ].toList();
  String mValuee;
  SharedPreferences pref;

  @override
  void initState() {
    mValuee = mCancelList.first;
    super.initState();
    init();
    fetchTrackingData();
  }

  init() async {
    changeStatusColor(primaryColor);
    pref = await getSharedPref();
  }

  @override
  void dispose() {
    super.dispose();
    changeStatusColor(primaryColor);
  }

  Future fetchTrackingData() async {
    setState(() {
      isLoading = true;
    });
    await getOrdersTracking(widget.mOrderModel.id).then((res) {
      if (!mounted) return;
      isLoading = false;
      setState(() {
        Iterable mCategory = res;
        mOrderTrackingModel = mCategory.map((model) => OrderTracking.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        toast(error.toString());
      });
    });
  }

  void cancelOrderData(String mValue) async {
    setState(() {
      isLoading = true;
    });
    var request = {
      "status": "cancelled",
      "customer_note": mValue,
    };
    await cancelOrder(widget.mOrderModel.id, request).then((res) {
      if (!mounted) return;
      isLoading = false;
      setState(() {
        var request = {
          'customer_note': true,
          'note': "{\n" + "\"status\":\"Cancelled\",\n" + "\"message\":\"Order Cancelled by you due to " + mValue + ".\"\n" + "} ",
        };
        CreateOrderNotes(widget.mOrderModel.id, request).then((res) {
          if (!mounted) return;
          isLoading = false;
          setState(() {
            finish(context);
          });
        }).catchError((error) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
            toast(error.toString());
          });
        });
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        toast(error.toString());
      });
    });
  }

  Widget mData(OrderTracking orderTracking) {
    Tracking tracking;
    try {
      var x = jsonDecode(orderTracking.note) as Map<String, dynamic>;
      tracking = Tracking.fromJson(x);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            tracking.status,
            style: boldTextStyle(size: 16, color: Theme.of(context).textTheme.subtitle2.color),
          ),
          Text(
            tracking.message,
            style: secondaryTextStyle(size: 14, color: Theme.of(context).textTheme.subtitle1.color),
          )
        ],
      );
    } on FormatException catch (e) {
      log(e);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "By ServiceJi",
            style: boldTextStyle(size: 16, color: Theme.of(context).textTheme.subtitle2.color),
          ),
          Text(
            orderTracking.note,
            style: secondaryTextStyle(size: 16, color: Theme.of(context).textTheme.subtitle1.color),
          ),
        ],
      );
    }
  }

  Widget mTracking() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: mOrderTrackingModel.length,
      itemBuilder: (context, i) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(margin: EdgeInsets.fromLTRB(0, 4, 0, 0), height: 10, width: 10, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16))),
                SizedBox(
                  height: 100,
                  child: DashedRect(
                    gap: 2,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: spacing_standard.toDouble(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  mData(mOrderTrackingModel[i]),
                  SizedBox(height: 8),
                  Text(convertDate(mOrderTrackingModel[i].dateCreated), style: secondaryTextStyle(size: 14, color: Theme.of(context).textTheme.subtitle1.color))
                ],
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
    changeStatusColor(primaryColor);

    var currentDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(DateTime.now().toString());
    final mOrderDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(widget.mOrderModel.dateCreated.date);
    final difference = currentDate.difference(mOrderDate).inHours;

    Widget mCancelOrder() {
      if (widget.mOrderModel.status == COMPLETED || widget.mOrderModel.status == REFUNDED || widget.mOrderModel.status == CANCELED) {
        return SizedBox();
      } else {
        if (difference <= 1) {
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Text(appLocalization.translate('title_cancel_order')),
                        content: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: boxDecoration(context, color: white_color, radius: 8.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: mValuee,
                                      isExpanded: true,
                                      onChanged: (String newValue) {
                                        setState(() {
                                          mValuee = newValue;
                                        });
                                      },
                                      items: mCancelList.map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(top: spacing_standard.toDouble()),
                                      width: MediaQuery.of(context).size.width,
                                      child: RaisedButton(
                                        color: colorAccent,
                                        onPressed: () {
                                          cancelOrderData(mValuee);
                                        },
                                        child: Text(
                                          appLocalization.translate('lbl_cancel_order'),
                                          style: primaryTextStyle(size: 16, color: white_color),
                                        ),
                                      ))
                                ],
                              ),
                            )),
                      );
                    },
                  );
                },
              );
            },
            child: Container(
              padding: EdgeInsets.only(top: spacing_middle.toDouble(), bottom: spacing_middle.toDouble()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appLocalization.translate('lbl_cancel_order'),
                    style: primaryTextStyle(color: primaryColor, size: 16),
                  ),
                  Icon(Icons.chevron_right)
                ],
              ),
            ),
          );
        } else {
          return SizedBox();
        }
      }
    }

    Widget mBody(BuildContext context) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
                width: context.width(),
                margin: EdgeInsets.only(
                  top: spacing_standard.toDouble(),
                  bottom: spacing_standard_new.toDouble(),
                ),
                decoration: boxDecoration(context, radius: 0, showShadow: true),
                padding: EdgeInsets.fromLTRB(spacing_standard_new.toDouble(), spacing_standard_new.toDouble(), spacing_standard_new.toDouble(), spacing_standard_new.toDouble()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.mOrderModel.datePaid != null)
                      Text(
                        "Order Via " + widget.mOrderModel.paymentMethod + " (" + widget.mOrderModel.transactionId + ").paid on " + widget.mOrderModel.datePaid,
                        style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium),
                      )
                    else
                      Text(
                        "Order Via " + widget.mOrderModel.paymentMethod,
                        style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium),
                      ),
                  ],
                )),
            Container(
              decoration: boxDecoration(context, radius: 0, showShadow: true),
              margin: EdgeInsets.only(
                bottom: spacing_standard.toDouble(),
              ),
              padding: EdgeInsets.fromLTRB(spacing_standard_new.toDouble(), spacing_standard.toDouble(), spacing_standard_new.toDouble(), spacing_standard.toDouble()),
              child: Column(
                children: [mTracking(), mCancelOrder()],
              ),
            ).visible(mOrderTrackingModel.isNotEmpty),
            Container(
              width: context.width(),
              decoration: boxDecoration(context, radius: 0, showShadow: true),
              margin: EdgeInsets.only(
                bottom: spacing_standard.toDouble(),
              ),
              padding: EdgeInsets.fromLTRB(spacing_standard_new.toDouble(), spacing_standard.toDouble(), spacing_standard_new.toDouble(), spacing_standard.toDouble()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  spacing_standard.height,
                  Text(
                    appLocalization.translate('lbl_shipping_details'),
                    style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium),
                  ),
                  Divider(),
                  Text(
                    widget.mOrderModel.shipping.firstName + " " + widget.mOrderModel.shipping.lastName,
                    style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium),
                  ),
                  SizedBox(
                    height: spacing_standard.toDouble(),
                  ),
                  Text(widget.mOrderModel.shipping.address1, style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeSMedium)),
                  spacing_control.height,
                  Text(widget.mOrderModel.shipping.city, style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeSMedium)),
                  spacing_control.height,
                  Text(widget.mOrderModel.shipping.country, style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeSMedium)),
                  spacing_control.height,
                  Text(widget.mOrderModel.shipping.state, style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeSMedium)),
                  spacing_large.height,
                ],
              ),
            ),
            Container(
              width: context.width(),
              decoration: boxDecoration(context, radius: 0, showShadow: true),
              margin: EdgeInsets.only(
                bottom: spacing_standard.toDouble(),
              ),
              padding: EdgeInsets.fromLTRB(spacing_standard_new.toDouble(), spacing_standard.toDouble(), spacing_standard_new.toDouble(), spacing_standard.toDouble()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  spacing_standard.height,
                  Text(
                    appLocalization.translate('lbl_other_item_in_cart'),
                    style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeSMedium),
                  ),
                  Divider(),
                  ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.mOrderModel.lineItems.length,
                      itemBuilder: (context, i) {
                        return GestureDetector(
                          onTap: () {
                            builderResponse.productdetailview.layout == "layout1"
                                ? ProductDetailScreen(mProId: widget.mOrderModel.lineItems[0].productId).launch(context)
                                : ProductDetailsBuilderScreen(mProId: widget.mOrderModel.lineItems[0].productId).launch(context);
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: spacing_middle.toDouble()),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: boxDecoration(context, showShadow: true, radius: spacing_middle.toDouble()),
                                  child: Image.network(
                                    widget.mOrderModel.lineItems[i].productImages[0].src,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.mOrderModel.lineItems[i].name,
                                        style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium),
                                        maxLines: 2,
                                      ),
                                      spacing_standard_new.height,
                                      Row(
                                        children: [
                                          PriceWidget(
                                            price: widget.mOrderModel.lineItems[i].total.toString(),
                                            size: textSizeLargeMedium.toDouble(),
                                            color: Theme.of(context).textTheme.subtitle1.color,
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            "Qty: " + widget.mOrderModel.lineItems[i].quantity.toString(),
                                            style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium),
                                          ),
                                        ],
                                      )
                                    ],
                                  ).paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble(), top: spacing_control.toDouble()),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                ],
              ),
            ),
            Container(
              width: context.width(),
              decoration: boxDecoration(context, radius: 0, showShadow: true),
              margin: EdgeInsets.only(
                bottom: spacing_standard.toDouble(),
              ),
              padding: EdgeInsets.fromLTRB(spacing_standard_new.toDouble(), spacing_standard.toDouble(), spacing_standard_new.toDouble(), spacing_standard.toDouble()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  spacing_standard.height,
                  Text(
                    appLocalization.translate('lbl_price_detail'),
                    style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium),
                  ),
                  Divider(),
                  spacing_standard_new.height,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appLocalization.translate('lbl_extra_discount'),
                        style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeSMedium),
                      ),
                      PriceWidget(
                        price: widget.mOrderModel.discountTotal,
                        size: textSizeSMedium.toDouble(),
                        color: Theme.of(context).textTheme.subtitle2.color,
                      )
                    ],
                  ),
                  spacing_standard.height,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appLocalization.translate('lbl_total_amount'),
                        style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeSMedium),
                      ),
                      PriceWidget(
                        price: widget.mOrderModel.total,
                        size: textSizeSMedium.toDouble(),
                        color: Theme.of(context).textTheme.subtitle2.color,
                      ),
                    ],
                  ),
                  Divider(
                    color: darkGreyColor,
                  ),
                  spacing_standard.height,
                ],
              ),
            )
          ],
        ),
      );
    }

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
            "Order #" + widget.mOrderModel.id.toString() + " Details",
            style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
          ),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            mBody(context),
            CircularProgressIndicator().center().visible(isLoading),
          ],
        ));
  }
}
