import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/models/CartModel.dart';
import 'package:ServiceJi/models/Coupon_lines.dart';
import 'package:ServiceJi/models/CreateOrderRequestModel.dart';
import 'package:ServiceJi/models/CustomerResponse.dart';
import 'package:ServiceJi/models/OrderModel.dart';
import 'package:ServiceJi/models/ShippingMethodResponse.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/screen/PlaceOrderScreen.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/common.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_localizations.dart';
import 'DashboardScreen.dart';
import 'WebViewPaymentScreen.dart';

class OrderSummaryScreen extends StatefulWidget {
  static String tag = '/OrderSummaryScreen';
  final List<CartModel> mCartProduct;
  final mCoupondata;
  final mPrice;
  final bool isNativePayment = false;
  ShippingLines shippingLines;
  Method method;
  double subtotal;
  double discount;

  OrderSummaryScreen(
      {Key key,
      this.mCartProduct,
      this.mCoupondata,
      this.mPrice,
      this.shippingLines,
      this.method,
      this.subtotal,
      this.discount})
      : super(key: key);

  @override
  OrderSummaryScreenState createState() => OrderSummaryScreenState();
}

class OrderSummaryScreenState extends State<OrderSummaryScreen> {
  bool selectedCashDelivery;
  SharedPreferences pref;
  var mUserId, mCurrency;
  var mBilling, mShipping;
  String mShippingFirstName,
      mShippingLastName,
      mShippingCompany,
      mShippingAddress,
      mShippingAddress2,
      mShippingCity,
      mShippingPostcode,
      mShippingCountry,
      mShippingState;
  String mBillingFirstName,
      mBillingLastName,
      mBillingAddress,
      mBillingAddress2,
      mBillingCompany,
      mBillingCity,
      mBillingPostcode,
      mBillingCountry,
      mBillingState,
      mBillingPhone,
      mBillingEmail;
  var isLoading = false;
  var isNativePayment = false;
  var mOrderModel = OrderResponse();
  Method method;
  NumberFormat nf = NumberFormat('##.00');

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    selectedCashDelivery = true;
    pref = await getSharedPref();
    changeStatusColor(primaryColor);
    if (await getString(PAYMENTMETHOD) == PAYMENT_METHOD_NATIVE) {
      isNativePayment = true;
    } else {
      isNativePayment = false;
    }
    mShipping = jsonDecode(pref.getString(SHIPPING)) ?? "";
    if (mShipping != null) {
      mShippingFirstName = mShipping['first_name'];
      mShippingLastName = mShipping['last_name'];
      mShippingCompany = mShipping['company'];
      mShippingAddress = mShipping['address_1'];
      mShippingAddress2 = mShipping['address_2'];
      mShippingCity = mShipping['city'];
      mShippingPostcode = mShipping['postcode'];
      mShippingCountry = mShipping['country'];
      mShippingState = mShipping['state'];
    }
    mBilling = jsonDecode(pref.getString(BILLING));

    if (mBilling != null) {
      mBillingFirstName = mBilling['first_name'];
      mBillingLastName = mBilling['last_name'];
      mBillingCompany = mBilling['company'];
      mBillingAddress = mBilling['address_1'];
      mBillingAddress2 = mBilling['address_2'];
      mBillingCity = mBilling['city'];
      mBillingPostcode = mBilling['postcode'];
      mBillingCountry = mBilling['country'];
      mBillingState = mBilling['state'];
      mBillingEmail = mBilling['email'];
      mBillingPhone = mBilling['phone'];
    }

    mUserId = pref.getInt(USER_ID) != null ? pref.getInt(USER_ID) : '';
    mCurrency = pref.getString(DEFAULT_CURRENCY);
    setState(() {});
  }

  void createNativeOrder() async {
    hideKeyboard(context);

    var mBilling = Billing();
    mBilling.firstName = mBillingFirstName;
    mBilling.lastName = mBillingLastName;
    mBilling.company = mBillingCompany;
    mBilling.address1 = mBillingAddress;
    mBilling.address2 = mBillingAddress2;
    mBilling.city = mBillingCity;
    mBilling.postcode = mBillingPostcode;
    mBilling.country = mBillingCountry;
    mBilling.state = mBillingState;
    mBilling.email = mBillingEmail;
    mBilling.phone = mBillingPhone;

    var mShipping = Shipping();
    mShipping.firstName = mShippingFirstName;
    mShipping.lastName = mShippingLastName;
    mShipping.company = mShippingCompany;
    mShipping.address1 = mShippingAddress;
    mShipping.address2 = mShippingPostcode;
    mShipping.city = mShippingCity;
    mShipping.state = mShippingState;
    mShipping.postcode = mShippingPostcode;
    mShipping.country = mShippingCountry;

    var lineItems = List<LineItemsRequest>();
    widget.mCartProduct.forEach((item) {
      var lineItem = LineItemsRequest();
      lineItem.product_id = item.proId;
      lineItem.quantity = item.quantity;
      lineItem.variation_id = item.proId;
      lineItems.add(lineItem);
    });

    var couponCode = widget.mCoupondata;
    var mCouponItems = List<CouponLines>();
    if (couponCode.isNotEmpty) {
      var mCoupon = CouponLines();
      mCoupon.code = couponCode;
      mCouponItems.clear();
      mCouponItems.add(mCoupon);
    }

    var request = {
      'billing': mBilling,
      'shipping': mShipping,
      'line_items': lineItems,
      'payment_method': "cod",
      'transaction_id': "",
      'customer_id': mUserId.toString(),
      'coupon_lines': couponCode.isNotEmpty ? mCouponItems : '',
      'status': "pending",
      'set_paid': false,
    };
    setState(() {
      isLoading = true;
    });
    createOrderApi(request).then((response) async {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaceOrderScreen(
            mOrderID: response['id'],
            total: response['total'],
            transactionId: response['transaction_id'],
            orderKey: response['order_key'],
            paymentMethod: response['payment_method'],
            dateCreated: response['date_created'],
          ),
        ),
      );
      finish(context);
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      toast(error.toString());
    });
  }

  Future createWebViewOrder() async {
    if (!accessAllowed) {
      return;
    }

    var request = CreateOrderRequestModel();
    if (widget.shippingLines != null) {
      var shippingLines = List<ShippingLines>();
      shippingLines.add(widget.shippingLines);
      request.shippingLines = shippingLines;
    }
    var lineItems = List<LineItemsRequest>();
    widget.mCartProduct.forEach((item) {
      var lineItem = LineItemsRequest();
      lineItem.product_id = item.proId;
      lineItem.quantity = item.quantity;
      lineItem.variation_id = item.proId;
      lineItems.add(lineItem);
    });

    var pref = await getSharedPref();
    var shippingItem = Shipping();
    shippingItem.firstName = mShippingFirstName;
    shippingItem.lastName = mShippingLastName;
    shippingItem.address1 = mShippingAddress;
    shippingItem.company = mBillingCompany;
    shippingItem.address2 = mShippingAddress2;
    shippingItem.city = mShippingCity;
    shippingItem.state = mShippingState;
    shippingItem.postcode = mShippingPostcode;
    shippingItem.country = mShippingCountry;

    var mBilling = Billing();
    mBilling.firstName = mBillingFirstName;
    mBilling.lastName = mBillingLastName;
    mBilling.company = mBillingCompany;
    mBilling.address1 = mBillingAddress;
    mBilling.address2 = mBillingAddress2;
    mBilling.city = mBillingCity;
    mBilling.postcode = mBillingPostcode;
    mBilling.country = mBillingCountry;
    mBilling.state = mBillingState;
    mBilling.email = mBillingEmail;
    mBilling.phone = mBillingPhone;

    request.payment_method = "cod";
    request.transaction_id = "";
    request.customer_id = pref.getInt(USER_ID);
    request.status = "pending";
    request.set_paid = false;

    request.lineItems = lineItems;
    request.shipping = shippingItem;
    request.billing = mBilling;
    createOrder(request);

    /*Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentScreen(
                mCartModel: widget.mCartProduct,
                mCreateOrderRequestModel: request),
            maintainState: false));*/
  }

  void createOrder(CreateOrderRequestModel mCreateOrderRequestModel) async {
    setState(() {
      isLoading = true;
    });
    await createOrderApi(mCreateOrderRequestModel.toJson()).then((response) {
      if (!mounted) return;
      processPaymentApi(response['id']);
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      toast(error.toString());
    });
  }

  processPaymentApi(var mOrderId) async {
    log(mOrderId);
    var request = {"order_id": mOrderId};
    getCheckOutUrl(request).then((res) async {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      bool isPaymentDone = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewPaymentScreen(
                      checkoutUrl: res['checkout_url'],
                    )),
          ) ??
          false;
      if (isPaymentDone) {
        setState(() {
          isLoading = true;
        });
        clearCartItems().then((response) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
          });
          launchNewScreenWithNewTask(context, DashboardScreen.tag);
        }).catchError((error) {
          setState(() {
            isLoading = false;
          });
          toast(error.toString());
        });
      } else {
        deleteOrder(mOrderId)
            .then((value) => {log(value)})
            .catchError((error) {});
      }
    }).catchError((error) {});
  }

  void onOrderNowClick() async {
    createWebViewOrder();
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
          appLocalization.translate('order_summary'),
          style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: context.width(),
                  decoration:
                  boxDecoration(context, radius: 0, showShadow: true),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Text("Shipping Address", style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium)),

                      Text('Shipping Address',
                              style: boldTextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .color,
                                  size: textSizeMedium))
                          .visible(mShippingFirstName != null),
                      spacing_control.height,
                      Text('$mShippingFirstName $mShippingLastName\n$mShippingAddress\n$mShippingCity\n$mShippingCountry\n$mShippingPostcode\n$mShippingState',
                              style: secondaryTextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .color,
                                  size: textSizeMedium))
                          .visible(mShippingAddress != null),
                      spacing_standard.height,
                      Text('Method Applied',
                              style: boldTextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .color,
                                  size: textSizeMedium))
                          .visible(widget.method != null),
                      spacing_control.height,
                      widget.method != null
                          ? widget.method.id == "free_shipping"
                              ? Text(widget.method.method_title,
                                  style: secondaryTextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .color,
                                      size: textSizeMedium))
                              : Row(
                                  children: [
                                    Text(widget.method.method_title,
                                        style: secondaryTextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .subtitle1
                                                .color,
                                            size: textSizeMedium)),
                                    PriceWidget(
                                      price: widget.method.cost,
                                      color: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .color,
                                      size: textSizeMedium.toDouble(),
                                    ).paddingLeft(spacing_control.toDouble())
                                  ],
                                )
                          : SizedBox(),
                    ],
                  ).paddingAll(spacing_standard_new.toDouble()),
                ),
                spacing_standard.height,
                Container(
                  width: context.width(),
                  decoration:
                  boxDecoration(context, radius: 0, showShadow: true),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      spacing_standard.height,
                      Text(appLocalization.translate('lbl_Billing_address'),
                          style: boldTextStyle(
                              color:
                                  Theme.of(context).textTheme.subtitle2.color,
                              size: textSizeMedium)),
                      spacing_standard.height,
                      Text('$mBillingFirstName  $mBillingLastName',
                              style: secondaryTextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .color,
                                  size: textSizeSMedium))
                          .visible(mBillingFirstName != null),
                      spacing_standard.height,
                      Text(mBillingAddress,
                              style: secondaryTextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .color,
                                  size: textSizeSMedium))
                          .visible(mBillingAddress != null),
                      spacing_standard.height,
                      Text(mBillingCity,
                              style: secondaryTextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .color,
                                  size: textSizeSMedium))
                          .visible(mBillingCity != null),
                      spacing_standard.height,
                      Text(mBillingPostcode,
                              style: secondaryTextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .color,
                                  size: textSizeSMedium))
                          .visible(mBillingPostcode != null),
                      spacing_standard.height,
                      Text(mBillingCountry,
                              style: secondaryTextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .color,
                                  size: textSizeSMedium))
                          .visible(mBillingCountry != null),
                      spacing_standard.height,
                      Text(mBillingState,
                              style: secondaryTextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .color,
                                  size: textSizeSMedium))
                          .visible(mBillingState != null),
                    ],
                  ).paddingAll(spacing_standard_new.toDouble()),
                ),
                spacing_standard.height,
                Container(
                  width: context.width(),
                  decoration:
                  boxDecoration(context, radius: 0, showShadow: true),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      spacing_standard.height,
                      Text(appLocalization.translate('lbl_payment_methods'),
                          style: boldTextStyle(
                              color:
                                  Theme.of(context).textTheme.subtitle2.color,
                              size: textSizeMedium)),
                      spacing_standard.height,
                      Row(
                        children: [
                          Icon(
                            selectedCashDelivery
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: selectedCashDelivery
                                ? SelectionColor
                                : darkGreyColor,
                            size: 20,
                          ),
                          spacing_standard.width,
                          Text(
                              appLocalization.translate('lbl_cash_on_delivery'),
                              style: secondaryTextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .color,
                                  size: textSizeMedium)),
                        ],
                      ).onTap(() {
                        selectedCashDelivery = true;
                      }),
                      spacing_standard_new.height,
                    ],
                  ).paddingAll(spacing_standard_new.toDouble()),
                ).visible(isNativePayment == true),
              ],
            ),
          ),
          CircularProgressIndicator().center().visible(isLoading),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: boxDecoration(context,
            showShadow: true,
            bgColor: Theme.of(context).scaffoldBackgroundColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appLocalization.translate('lbl_total'),
                    style: secondaryTextStyle(
                        color: Theme.of(context).textTheme.subtitle1.color,
                        size: textSizeMedium)),
                PriceWidget(
                    price: nf.format(widget.subtotal),
                    color: Theme.of(context).textTheme.subtitle1.color,
                    size: 16)
              ],
            ),
            spacing_control.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appLocalization.translate('lbl_discount'),
                    style: secondaryTextStyle(
                        color: Theme.of(context).textTheme.subtitle1.color,
                        size: textSizeMedium)),
                PriceWidget(
                  price: widget.discount,
                  size: textSizeMedium.toDouble(),
                  color: Theme.of(context).textTheme.subtitle1.color,
                ),
              ],
            ),
            spacing_control.height,
            widget.method != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Shipping",
                          style: secondaryTextStyle(
                              color:
                                  Theme.of(context).textTheme.subtitle1.color,
                              size: textSizeMedium)),
                      widget.method != null &&
                              widget.method.cost != null &&
                              widget.method.cost.isNotEmpty
                          ? PriceWidget(
                              price: widget.method.cost,
                              color:
                                  Theme.of(context).textTheme.subtitle1.color,
                              size: 16)
                          : Text(
                              "Free",
                              style: boldFonts(color: Colors.green),
                            )
                    ],
                  )
                : SizedBox(),
            spacing_control.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appLocalization.translate('lbl_total_amount'),
                    style: boldTextStyle(
                        color: Theme.of(context).textTheme.subtitle2.color,
                        size: textSizeMedium)),
                PriceWidget(
                  price: widget.mPrice,
                  size: textSizeMedium.toDouble(),
                  color: Theme.of(context).textTheme.subtitle2.color,
                ),
              ],
            ),
            spacing_standard_new.height,
            GestureDetector(
              onTap: () {
                if (isLoading) {
                  return;
                }
                onOrderNowClick();
              },
              child: Container(
                width: context.width(),
                padding: EdgeInsets.fromLTRB(
                    spacing_middle.toDouble(),
                    spacing_standard.toDouble(),
                    spacing_middle.toDouble(),
                    spacing_standard.toDouble()),
                decoration: boxDecoration(context,
                    bgColor: Theme.of(context).primaryColor,
                    radius: spacing_control.toDouble()),
                child: Text(appLocalization.translate('lbl_continue'),
                    textAlign: TextAlign.center,
                    style: boldTextStyle(
                        size: textSizeMedium, color: white_color)),
              ),
            )
          ],
        ).paddingOnly(
            top: spacing_standard_new.toDouble(),
            left: spacing_standard_new.toDouble(),
            bottom: spacing_standard_new.toDouble(),
            right: spacing_standard_new.toDouble()),
      ),
    );
  }
}
