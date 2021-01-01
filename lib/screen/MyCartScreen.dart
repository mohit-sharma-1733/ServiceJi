import 'dart:convert';

import 'package:ServiceJi/screen/DashboardScreen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/models/CartModel.dart';
import 'package:ServiceJi/models/Countries.dart';
import 'package:ServiceJi/models/CustomerResponse.dart';
import 'package:ServiceJi/models/Line_items.dart';
import 'package:ServiceJi/models/OrderModel.dart';
import 'package:ServiceJi/models/ShippingMethodResponse.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/screen/OrderSummaryScreen.dart';
import 'package:ServiceJi/screen/WishListScreen.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/utils/common.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_localizations.dart';
import 'ApplyCouponScreen.dart';
import 'EditProfileScreen.dart';
import 'home.dart';

class MyCartScreen extends StatefulWidget {
  static String tag = '/MyCartScreen';

  @override
  MyCartScreenState createState() => MyCartScreenState();
}

class MyCartScreenState extends State<MyCartScreen> {
  int itemCount;
  var mCartModel = List<CartModel>();
  var mLineItems = List<Line_items>();
  var mErrorMsg = '';
  bool mIsLoading = false;
  NumberFormat nf = NumberFormat('##.00');
  SharedPreferences pref;
  var mDiscountInfo;
  double mTotalDiscount = 0;
  var cartItemId = "";
  var isCoupons = false;
  var isEnableCoupon;
  var mCouponData;
  var mDiscountedAmount;
  var mTotalAmount = 0;
  double mTotalCount = 0.0;
  var countryList = List<Country>();
  ShippingMethodResponse shippingMethodResponse;
  var shippingMethods = List<Method>();
  Shipping shipping;
  var selectedShipment = 0;

  @override
  void initState() {
    super.initState();
    changeStatusColor(primaryColor);
    itemCount = 1;
    fetchCartData();
  }

  fetchShipmentData() async {
    if (countryList.isEmpty) {
      String countries = pref.getString(COUNTRIES);
      if (countries == null) {
        await getCountries().then((value) async {
          log(value);
          setString(COUNTRIES, jsonEncode(value));
          fetchShippingMethod(value);
        }).catchError((error) {
          setState(() {
            mIsLoading = false;
          });
          toast(error);
        });
      } else {
        fetchShippingMethod(jsonDecode(countries));
      }
    } else {
      setState(() {
        mIsLoading = false;
      });
      loadShippingMethod();
    }
  }

  fetchShippingMethod(var value) async {
    Iterable list = value;
    var countris = list.map((model) => Country.fromJson(model)).toList();
    setState(() {
      countryList.addAll(countris);
    });
    var mShipping = jsonDecode(pref.getString(SHIPPING)) ?? "";
    if (mShipping != null) {
      setState(() {
        shipping = Shipping.fromJson(mShipping);
      });
      var mShippingPostcode = shipping.postcode;
      var mShippingCountry = shipping.country;
      var mShippingState = shipping.state;
      var countryCode = "";
      var stateCode = "";
      if (mShippingCountry != null && mShippingCountry.isNotEmpty) {
        countryList.forEach((element) {
          if (element.name == mShippingCountry) {
            countryCode = element.code;
            if (mShippingState != null && mShippingState.isNotEmpty) {
              if (element.states != null && element.states.isNotEmpty) {
                element.states.forEach((state) {
                  if (state.name == mShippingState) {
                    stateCode = state.code;
                  }
                });
              }
            }
          }
        });
      }

      var request = {"country_code": countryCode, "state_code": stateCode, "postcode": mShippingPostcode};
      await getShippingMethod(request).then((value) {
        log(value);
        ShippingMethodResponse methodResponse = ShippingMethodResponse.fromJson(value);
        setState(() {
          mIsLoading = false;
          shippingMethodResponse = methodResponse;
          loadShippingMethod();
        });
      }).catchError((error) {
        setState(() {
          mIsLoading = false;
        });
        toast(error);
      });
    }
  }

  loadShippingMethod() {
    setState(() {
      shippingMethods.clear();
      if (shippingMethodResponse != null && shippingMethodResponse.methods != null) {
        shippingMethodResponse.methods.forEach((method) {
          if (shouldApply(method)) {
            shippingMethods.add(method);
          }
        });
        if (shippingMethods.isNotEmpty) {
          selectedShipment = 0;
        }
      }
    });
  }

  fetchCartData() async {
    pref = await getSharedPref();
    setState(() {
      mIsLoading = true;
      isEnableCoupon = pref.getBool(ENABLECOUPON);
    });
    await getCartList().then((res) {
      if (!mounted) return;
      setState(() {
        Iterable list = res;
        mCartModel = list.map((model) => CartModel.fromJson(model)).toList();
        mErrorMsg = '';

        mTotalCount = 0.0;
        mLineItems.clear();
        if (mCartModel.isEmpty) {
          mErrorMsg = ('No Items in your cart');
          mIsLoading = false;
        } else {
          mErrorMsg = '';
          for (var i = 0; i < mCartModel.length; i++) {
            var mItem = Line_items();
            mItem.proId = mCartModel[i].proId;
            mItem.quantity = mCartModel[i].quantity;
            mLineItems.add(mItem);
            if (mCartModel[i].onSale) {
              mTotalCount += double.parse(mCartModel[i].salePrice) * int.parse(mCartModel[i].quantity);
            } else {
              mTotalCount += double.parse(mCartModel[i].regularPrice.toString().isNotEmpty ? mCartModel[i].regularPrice : mCartModel[i].price) * int.parse(mCartModel[i].quantity);
            }
          }
          fetchShipmentData();
        }
      });
    }).catchError((error) {
      log(error);
      setState(() {
        mIsLoading = false;
        mCartModel.clear();
        mErrorMsg = 'No Items in your cart';
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    changeStatusColor(primaryColor);
  }

  Future updateCartItemApi(request) async {
    updateCartItem(request).then((res) {
      setState(() {
        mIsLoading = false;
      });
      fetchCartData();
    }).catchError((error) {
      toast(error.toString());
      mIsLoading = false;
    });
  }

  Future removeCartItemApi(proId, index) async {
    var request = {
      'pro_id': proId,
    };
    mCartModel.removeAt(index);
    setState(() {
      mIsLoading = true;
    });
    removeCartItem(request).then((res) {
      fetchCartData();
    }).catchError((error) {
      appStore.increment();
      fetchCartData();
    });
  }

  @override
  Widget build(BuildContext context) {
    setInt(CARTCOUNT, appStore.count);
    var appLocalization = AppLocalizations.of(context);
    var w = context.width();
    var h = context.height();
    void onValueChanged(int value, proId, cartId) {
      setState(() {
        var request = {
          'pro_id': proId,
          'cart_id': cartId,
          'quantity': value,
        };
        updateCartItemApi(request);
      });
    }

    Widget slideLeftBackground() {
      return Container(
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
      );
    }

    Widget mCartInfo = ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: mCartModel.length,
      itemBuilder: (context, i) {
        return Dismissible(
          background: slideLeftBackground(),
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) async {
            final bool res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text("Are you sure you want to remove the item?"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        appStore.increment();
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        // TODO: Delete the item from DB etc..
                        setState(() {
                          appStore.decrement();
                          removeCartItemApi(mCartModel[i].proId, i);
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
            return res;
          },
          child: InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.fromLTRB(spacing_standard_new.toDouble(), spacing_standard_new.toDouble(), spacing_standard_new.toDouble(), 0),
                child: Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: boxDecoration(
                            context,
                            radius: 10.0,
                          ),
                          width: w * 0.25,
                          height: h * 0.14,
                          padding: EdgeInsets.all(spacing_control.toDouble()),
                          child: Image.network(
                            mCartModel[i].full,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mCartModel[i].name,
                                maxLines: 2,
                                style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeSMedium),
                              ).paddingOnly(
                                left: spacing_standard_new.toDouble(),
                              ),
                              spacing_standard_new.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            var qty = int.parse(mCartModel[i].quantity);
                                            if (qty == 1 || qty < 1) {
                                              qty = 1;
                                            } else {
                                              qty = qty - 1;
                                              mIsLoading = true;
                                              onValueChanged(qty, mCartModel[i].proId, mCartModel[i].cartId);
                                              appStore.decrement();
                                            }
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(left: spacing_standard.toDouble(), right: spacing_middle.toDouble()),
                                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(2))),
                                          child: Icon(
                                            Icons.remove,
                                            color: Theme.of(context).cardTheme.color,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        mCartModel[i].quantity,
                                        style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: 16),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            var qty = int.parse(mCartModel[i].quantity);
                                            var value = qty + 1;
                                            mIsLoading = true;
                                            onValueChanged(value, mCartModel[i].proId, mCartModel[i].cartId);
                                            appStore.increment();
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(left: spacing_middle.toDouble(), right: spacing_middle.toDouble()),
                                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(2))),
                                          child: Icon(
                                            Icons.add,
                                            size: 20,
                                            color: Theme.of(context).cardTheme.color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  PriceWidget(
                                    price: nf.format(double.parse(mCartModel[i].price) * double.parse(mCartModel[i].quantity)),
                                    size: 16,
                                    color: Theme.of(context).textTheme.subtitle2.color,
                                  ).paddingTop(4),
                                ],
                              ).paddingOnly(
                                left: 8,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 0.5,
                      color: view_color,
                      margin: EdgeInsets.only(
                        top: spacing_standard_new.toDouble(),
                      ),
                    )
                  ],
                ),
              )),
        );
      },
    );

    _navigateAndDisplaySelection(BuildContext context) async {
      var result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ApplyCouponScreen()),
      );
      setState(() {
        mDiscountInfo = jsonDecode(result);
        if (mDiscountInfo != null) {
          isCoupons = true;
          loadShippingMethod();
        }
      });
    }

    String getTotalAmount() {
      if (shippingMethodResponse != null && shippingMethods.isNotEmpty && shippingMethods[selectedShipment].cost != null && shippingMethods[selectedShipment].cost.isNotEmpty) {
        return ((mDiscountInfo != null
                    ? isCoupons
                        ? mDiscountedAmount
                        : mTotalCount
                    : mTotalCount) +
                double.parse(shippingMethods[selectedShipment].cost))
            .toString();
      } else {

        return mDiscountInfo != null
            ? isCoupons
                ? mDiscountedAmount.toString()
                : mTotalCount.toString()
            : mTotalCount.toString();
      }
    }

    Widget mCouponInfo(var text, var status) {
      return DottedBorder(
        borderType: BorderType.RRect,
        dashPattern: [6, 3, 6, 3],
        color: Theme.of(context).accentColor,
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(isCoupons ? text : 'Coupon Code', maxLines: 2, style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeSMedium)),
              ),
              Text(isCoupons ? status : appLocalization.translate('lbl_apply'), style: secondaryTextStyle(color: Theme.of(context).primaryColor, size: textSizeSMedium)).onTap(() {
                setState(() {
                  if (isCoupons) {
                    isCoupons = !isCoupons;
                    mDiscountInfo = null;
                    loadShippingMethod();
                  } else {
                    _navigateAndDisplaySelection(context);
                  }
                });
              }),
            ],
          ).paddingOnly(left: spacing_standard.toDouble(), right: spacing_standard.toDouble()),
        ),
      ).paddingAll(spacing_standard_new.toDouble());
    }

    Widget mCouponInformation() {
      if (mDiscountInfo != null) {
        return mCouponInfo("Applied Coupon:" + mDiscountInfo['code'], appLocalization.translate('lbl_remove'));
      } else {
        return mCouponInfo(appLocalization.translate('lbl_coupon_code'), appLocalization.translate('lbl_apply'));
      }
    }

    Widget mDiscount(var text, var value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isCoupons ? text : appLocalization.translate('lbl_discount'), style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium)),
          PriceWidget(
            price: isCoupons ? value : '0',
            size: textSizeMedium.toDouble(),
            color: Theme.of(context).textTheme.subtitle1.color,
          ),
        ],
      );
    }

    Widget mDiscountLabelCondition() {
      if (mDiscountInfo != null) {
        log('discount' + mDiscountInfo.toString());
        var type = mDiscountInfo['discount_type'];
        log(type);
        switch (type) {
          case "percent":
            {
              mTotalDiscount = ((mTotalCount * double.parse(mDiscountInfo['amount'])) / 100);
              mDiscountedAmount = mTotalCount - mTotalDiscount;
              return mDiscount('Discount' + ' (' + mDiscountInfo['amount'] + '% off)', mTotalDiscount);
            }
            break;

          case "fixed_cart":
            {
             // mTotalDiscount = mDiscountInfo['amount'];
              mTotalDiscount = double.parse(mDiscountInfo['amount']);
              mDiscountedAmount = mTotalCount - mTotalDiscount;
              log(mTotalCount);
              return mDiscount('Discount (Flat ' + mDiscountInfo['amount'].toString() + '% off)', mTotalDiscount);
            }
            break;

          case "fixed_product":
            {
              var finalAmount = mDiscountInfo['amount'].split(".");
              mTotalDiscount = (int.parse(finalAmount[0]) * (mCartModel.length)).toDouble();
              mDiscountedAmount = mTotalCount - mTotalDiscount;
              return mDiscount('Discount', mTotalDiscount);
            }
            break;

          default:
            {
              mTotalDiscount = mDiscountInfo['amount'];
              mDiscountedAmount = mTotalCount - mTotalDiscount;
              return mDiscount('Discount (Flat ' + mDiscountInfo['amount'] + ' off)', mTotalDiscount);
            }
            break;
        }
      } else {
        mTotalDiscount = 0;
        return mDiscount('Discount ', "0");
      }
    }

    Widget mPaymentInfo() {
      return Container(
        decoration: boxDecoration(
          context,
          showShadow: true,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appLocalization.translate('lbl_total'), style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium)),
                PriceWidget(price: nf.format(mTotalCount), color: Theme.of(context).textTheme.subtitle1.color, size: 16)
              ],
            ),
            spacing_control.height,
            mDiscountLabelCondition().visible(isEnableCoupon == true),
            spacing_control.height,
            shippingMethodResponse != null && shippingMethods != null && shippingMethods.isNotEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Shipping", style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium)),
                      shippingMethods[selectedShipment].cost != null && shippingMethods[selectedShipment].cost.isNotEmpty
                          ? PriceWidget(price: shippingMethods[selectedShipment].cost, color: Theme.of(context).textTheme.subtitle1.color, size: 16)
                          : Text(
                              "Free",
                              style: boldFonts(color: Colors.green),
                            )
                    ],
                  )
                : SizedBox(),
            Divider(),
            spacing_control.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appLocalization.translate('lbl_total_amount_'), style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium)),
                PriceWidget(
                  price: getTotalAmount(),
                  size: textSizeMedium.toDouble(),
                  color: Theme.of(context).textTheme.subtitle2.color,
                ),
              ],
            ),
            spacing_standard_new.height,
            GestureDetector(
              onTap: () {
                ShippingLines shippingLine;
                Method method;
                if (shippingMethodResponse != null && !mIsLoading) {
                  if (shippingMethodResponse != null && shippingMethods.isNotEmpty) {
                    method = shippingMethods[selectedShipment];
                    shippingLine = ShippingLines(method_id: shippingMethods[selectedShipment].id, method_title: shippingMethods[selectedShipment].method_title, total: shippingMethods[selectedShipment].cost);
                  }
                  OrderSummaryScreen(
                    mCartProduct: mCartModel,
                    mCoupondata: mDiscountInfo != null && isCoupons ? mDiscountInfo['code'] : '',
                    mPrice: getTotalAmount().toString(),
                    shippingLines: shippingLine,
                    method: method,
                    subtotal: mTotalCount,
                    discount: isCoupons ? mTotalDiscount : 0,
                  ).launch(context);
                }
              },
              child: Container(
                width: context.width(),
                padding: EdgeInsets.fromLTRB(spacing_middle.toDouble(), spacing_standard.toDouble(), spacing_middle.toDouble(), spacing_standard.toDouble()),
                decoration: boxDecoration(context, bgColor: Theme.of(context).primaryColor, radius: spacing_control.toDouble()),
                child: Text(appLocalization.translate('lbl_continue'), textAlign: TextAlign.center, style: boldTextStyle(size: textSizeMedium, color: white_color)),
              ),
            )
          ],
        ).paddingAll(spacing_middle.toDouble()),
      );
    }

    var shiping;
    if (shipping != null && shippingMethodResponse != null) {
      shiping = Container(
            decoration: boxDecoration(context, showShadow: true),
            margin: EdgeInsets.only(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble(), bottom: spacing_standard_new.toDouble()),
            padding: EdgeInsets.all(spacing_standard.toDouble()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Shipping", style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium)),
                    Text("Change", style: secondaryTextStyle(color: primaryColor, size: textSizeSMedium)).onTap(() async {
                      bool isChanged = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfileScreen()),
                      );
                      if (isChanged) {
                        setState(() {
                          countryList.clear();
                          mIsLoading = true;
                          shippingMethodResponse = null;
                        });
                        fetchShipmentData();
                      }
                    }),
                  ],
                ),
                Text(
                  "(" + shipping.getAddress() + ")",
                  style: primaryTextStyle(size: 14, color: Theme.of(context).textTheme.subtitle1.color),
                ),
                shippingMethods != null && shippingMethods.isNotEmpty
                    ? ListView.builder(
                        itemCount: shippingMethods.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          Method method = shippingMethods[index];
                          return Container(
                            padding: EdgeInsets.only(top: spacing_control.toDouble(), bottom: spacing_control.toDouble()),
                            child: Row(
                              children: [
                                Container(
                                  decoration: boxDecoration(
                                    context,
                                    bgColor: selectedShipment == index ? primaryColor : Colors.grey.withOpacity(0.3),
                                    radius: spacing_control.toDouble(),
                                  ),
                                  width: 16,
                                  height: 16,
                                  child: Icon(
                                    Icons.done,
                                    size: 12,
                                    color: Colors.white,
                                  ).visible(selectedShipment == index),
                                ),
                                Text(
                                  method.id != "free_shipping" ? method.method_title + ":" : method.method_title,
                                  style: primaryTextStyle(size: textSizeMedium, color: Theme.of(context).textTheme.subtitle2.color),
                                ).paddingLeft(spacing_standard.toDouble()),
                                PriceWidget(
                                  price: method.cost,
                                  color: Theme.of(context).textTheme.subtitle2.color,
                                ).paddingLeft(spacing_standard.toDouble()).visible(method.id != "free_shipping")
                              ],
                            ),
                          ).onTap(() {
                            setState(() {
                              selectedShipment = index;
                            });
                          });
                        })
                    : Text(
                        "Free Shipping",
                        style: boldFonts(size: textSizeMedium, color: textColorSecondary),
                      ).paddingTop(spacing_standard.toDouble())
              ],
            ),
          );
    } else {
      shiping = Container(
        child: RaisedButton( child: Text('Set address' , style: TextStyle(color: Colors.white),) , color: Colors.black, onPressed: () { EditProfileScreen().launch(context); },),

      );
      reassemble();
    }



    Widget mBody = Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 200),
          child: Column(
            children: [mCartInfo, mCouponInformation().visible(isEnableCoupon == true), shiping],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: mPaymentInfo(),
        )
      ],
    ).visible(mCartModel.isNotEmpty);

    changeStatusColor(primaryColor);

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
          appLocalization.translate('menu_my_cart'),
          style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
        ),
        actions: [
          Text(
            appLocalization.translate('lbl_wish_list'),
            style: primaryTextStyle(color: Colors.white, size: spacing_standard_new),
          ).center().paddingOnly(right: spacing_standard.toDouble()).onTap(() async {
            bool isAddedToCart = await WishListScreen().launch(context);
            if (isAddedToCart) {
              fetchCartData();
            }
          })
        ],
      ),
      body: mErrorMsg.isEmpty
          ? mCartModel.isNotEmpty
              ? Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    mBody,
                    CircularProgressIndicator().center().visible(mIsLoading),
                  ],
                )
              : Center(child: CircularProgressIndicator())
          : Container(
              width: context.width(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.asset(
                    'images/serviceji/ic_no_data.png',
                    height: 100,
                    width: 200,
                  ),
                  20.height,
                  Text(
                    mErrorMsg,
                    style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: 18),
                  ),
                  20.height,
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    onPressed: () { HomeScreen().launch(context);},
                    child: Text('Shop Now', style: primaryTextStyle(color: white)).paddingLeft(10).paddingRight(10),
                  ),
                ],
              ),
            ),
    );
  }

  bool shouldApply(Method method) {
    if (method.enabled == "yes") {
      if (method.id == "free_shipping") {
        if (method.requires.isEmpty) {
          return true;
        } else {
          if (method.requires == "min_amount") {
            return freeShippingOnMinAmount(method);
          } else if (method.requires == "coupon") {
            return freeShippingOnCoupan(method);
          } else if (method.requires == "either") {
            return freeShippingOnMinAmount(method) == true || freeShippingOnCoupan(method) == true;
          } else if (method.requires == "both") {
            return freeShippingOnMinAmount(method) == true && freeShippingOnCoupan(method) == true;
          }
        }
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  bool freeShippingOnMinAmount(Method method) {
    return isCoupons
        ? method.instanceSettings.ignore_discounts == "yes"
            ? mTotalCount >= double.parse(method.min_amount)
            : mDiscountedAmount >= double.parse(method.min_amount)
        : mTotalCount >= double.parse(method.min_amount);
  }

  bool freeShippingOnCoupan(Method method) {
    if (isCoupons && mDiscountInfo != null) {
      log("freeshippinmhcoupan" + mDiscountInfo['free_shipping'].toString());
      return mDiscountInfo['free_shipping'];
    } else {
      return false;
    }
  }
}
