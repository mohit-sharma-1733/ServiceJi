import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/models/ProductDetailResponse.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/screen/ProductDetailScreen.dart';
import 'package:ServiceJi/screen/ReviewScreen.dart';
import 'package:ServiceJi/screen/WebViewExternalProductScreen.dart';
import 'package:ServiceJi/utils/Countdown.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/utils/common.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/shared_pref.dart';

import '../app_localizations.dart';
import 'SignInScreen.dart';
import 'VendorProfileScreen.dart';

class ProductDetailsBuilderScreen extends StatefulWidget {
  final int mProId;

  ProductDetailsBuilderScreen({this.mProId});

  @override
  _ProductDetailsBuilderScreenState createState() =>
      _ProductDetailsBuilderScreenState();
}

class _ProductDetailsBuilderScreenState
    extends State<ProductDetailsBuilderScreen> {
  List<String> kgs = List();
  var selectedIndex = 0;
  ProductDetailResponse productDetailNew;
  final mProductsList = List<ProductDetailResponse>();
  ProductDetailResponse mainProduct;
  List<ProductDetailResponse> product = List();
  final PageController _controller =
      PageController(viewportFraction: 0.7, keepPage: true, initialPage: 0);
  var discount = 0.0;
  var mProducts = List<ProductDetailResponse>();
  var isAddedToCart = false;
  bool mIsLoading = true;
  var mIsInWishList = false;
  List<String> mProductOptions = List();
  List<int> mProductVariationsIds = List();
  String mSelectedVariation = '';
  String mExternalUrl = '';
  bool mIsGroupedProduct = false;
  bool mIsExternalProduct = false;
  double rating = 0.0;
  bool mIsLoggedIn = false;
  SharedPreferences pref;

  Future productDetail() async {
    pref = await getSharedPref();
    mIsLoggedIn = pref.getBool(IS_LOGGED_IN) ?? false;
    await getProductDetail(widget.mProId).then((res) {
      if (!mounted) return;
      setState(() {
        mIsLoading = false;
        Iterable mInfo = res;
        mProducts = mInfo
            .map((model) => ProductDetailResponse.fromJson(model))
            .toList();

        if (mProducts != null && mProducts.isNotEmpty) {
          productDetailNew = mProducts[0];
          mainProduct = mProducts[0];

          rating = double.parse(mainProduct.average_rating);
          productDetailNew.variations.forEach((element) {
            mProductVariationsIds.add(element);
          });

          if (mainProduct.isAddedCart) {
            isAddedToCart = true;
          } else {
            isAddedToCart = false;
          }

          if (mainProduct.isAddedWishlist) {
            mIsInWishList = true;
          } else {
            mIsInWishList = false;
          }
          mProductsList.clear();
          for (var i = 0; i < mProducts.length; i++) {
            if (i != 0) {
              mProductsList.add(mProducts[i]);
            }
          }
          if (mainProduct.type == "variable") {
            mProductOptions.clear();
            mProductsList.forEach((product) {
              var option = '';

              product.attributes.forEach((attribute) {
                if (option.isNotEmpty) {
                  option = '$option - ${attribute.option.validate()}';
                } else {
                  option = attribute.option.validate();
                }
              });

              if (product.on_sale) {
                option = '$option [Sale]';
              }

              mProductOptions.add(option);
            });
            if (mProductOptions.isNotEmpty)
              mSelectedVariation = mProductOptions.first;

            log(mProductOptions);
            log(mSelectedVariation);

            if (mainProduct.type == "variable" && mProductsList.isNotEmpty) {
              productDetailNew = mProductsList[0];
              mProducts = mProducts;
            }
            log('mProductOptions');
          } else if (mainProduct.type == 'grouped') {
            mIsGroupedProduct = true;
            product.clear();
            product.addAll(mProductsList);
          }
          setPriceDetail();
        }
      });
    }).catchError((error) {
      log(error);
      mIsLoading = false;
      toast(error.toString());
      setState(() {});
    });
  }

  // Set Price Detail
  Widget setPriceDetail() {
    setState(() {
      if (productDetailNew.on_sale) {
        double mrp = double.parse(productDetailNew.regular_price).toDouble();
        double discountPrice = double.parse(productDetailNew.price).toDouble();
        discount = ((mrp - discountPrice) / mrp) * 100;
      }
    });
  }

  Widget mDiscount() {
    if (mainProduct.on_sale)
      return Container(
        decoration: boxDecoration(context,
            color: Theme.of(context).accentColor,
            radius: 4.0,
            bgColor: Colors.transparent),
        child: Text(
          '${discount.toInt()} % ${AppLocalizations.of(context).translate('lbl_off1')}',
          style: primaryTextStyle(
              color: Theme.of(context).textTheme.subtitle1.color,
              size: textSizeSmall),
        ).center().paddingAll(spacing_control.toDouble()),
      );
    else
      return SizedBox();
  }

  Widget mSpecialPrice() {
    if (mainProduct != null) {
      if (mainProduct.dateOnSaleFrom != "") {
        var endTime = mainProduct.dateOnSaleTo.toString() + " 23:59:59.000";
        var endDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(endTime);
        var currentDate =
            DateFormat('yyyy-MM-dd HH:mm:ss').parse(DateTime.now().toString());
        var format = endDate.subtract(Duration(
            days: currentDate.day,
            hours: currentDate.hour,
            minutes: currentDate.minute,
            seconds: currentDate.second));
        log(format);

        return Countdown(
          duration: Duration(
              days: format.day,
              hours: format.hour,
              minutes: format.minute,
              seconds: format.second),
          onFinish: () {
            log('finished!');
          },
          builder: (BuildContext ctx, Duration remaining) {
            var seconds = ((remaining.inMilliseconds / 1000) % 60).toInt();
            var minutes =
                (((remaining.inMilliseconds / (1000 * 60)) % 60)).toInt();
            var hours =
                (((remaining.inMilliseconds / (1000 * 60 * 60)) % 24)).toInt();
            log(hours);
            return Container(
              decoration: boxDecoration(context,
                  bgColor: colorAccent.withOpacity(0.3), radius: 4.0),
              child: Text(
                'Special price end in less then '
                '${remaining.inDays}d ${hours}h ${minutes}m ${seconds}s',
                style: primaryTextStyle(
                    color: Theme.of(context).accentColor,
                    size: textSizeSMedium),
              ).paddingAll(spacing_standard.toDouble()),
            ).paddingOnly(left: 16, right: 16, top: 16);
          },
        );
      } else {
        return SizedBox();
      }
    } else {
      return SizedBox();
    }
  }

  void removeWishListItem() async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    await removeWishList({
      'pro_id': mainProduct.id,
    }).then((res) {
      if (!mounted) return;
      mIsInWishList = false;
      setState(() {
        toast(res[msg]);
      });
    }).catchError((error) {
      setState(() {
        toast(error.toString());
      });
    });
  }

  void addToWishList() async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    var request = {'pro_id': mainProduct.id};
    await addWishList(request).then((res) {
      if (!mounted) return;
      mIsInWishList = true;
      setState(() {
        toast(res[msg]);
      });
    }).catchError((error) {
      setState(() {
        toast(error.toString());
      });
    });
  }

  // API calling for add to cart
  Future addToCartApi(pro_id, int quantity, {returnExpected = false}) async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }

    setState(() {
      mIsLoading = true;
    });
    var request = {
      "pro_id": pro_id,
      "quantity": quantity,
    };
    setState(() {
      mIsLoading = true;
    });
    await addToCart(request).then((res) {
      toast(res[msg]);
      mIsLoading = false;
      isAddedToCart = true;
      mIsLoading = false;
      productDetail();
      setState(() {});
      return returnExpected;
    }).catchError((error) {
      toast(error.toString());
      setState(() {
        mIsLoading = false;
      });
      return returnExpected;
    });
  }

  // API calling for remove cart
  Future removeToCartApi(pro_id, {returnExpected = false}) async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }

    var request = {
      "pro_id": pro_id,
    };

    await removeCartItem(request).then((res) {
      toast(res[msg]);
      isAddedToCart = false;
      productDetail();

      return returnExpected;
    }).catchError((error) {
      toast(error.toString());
      setState(() {});
      return returnExpected;
    });
  }

  // get Additional Information
  String getAllAttribute(Attributes attribute) {
    String attributes = "";
    for (var i = 0; i < attribute.options.length; i++) {
      attributes = attributes + attribute.options[i];
      if (i < attribute.options.length - 1) {
        attributes = attributes + ", ";
      }
    }
    return attributes;
  }

  // Set additional information
  Widget mSetAttribute() {
    return ListView.builder(
      itemCount: mainProduct.attributes.length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, i) {
        return Row(
          children: [
            Text(
              mainProduct.attributes[i].name + " : ",
              style: primaryTextStyle(
                  size: textSizeMedium,
                  color: Theme.of(context).textTheme.subtitle1.color),
            ),
            SizedBox(
              width: 4.0,
            ),
            Expanded(
                child: Text(
              getAllAttribute(mainProduct.attributes[i]),
              maxLines: 4,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.subtitle1.color,
                  fontWeight: FontWeight.bold),
            ))
          ],
        );
      },
    );
  }

  // Attribute Information

  Widget mOtherAttribute() {
    toast('Product type not supported');
    finish(context);
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    productDetail();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    setInt(CARTCOUNT, appStore.count);
    var appLocalization = AppLocalizations.of(context);
    List<T> map<T>(List list, Function handler) {
      List<T> result = [];
      for (var i = 0; i < list.length; i++) {
        result.add(handler(i, list[i]));
      }
      return result;
    }

    final mPrice = mainProduct != null
        ? mainProduct.on_sale
            ? Row(
                children: [
                  PriceWidget(
                    price: productDetailNew.price.toString().toString(),
                    size: textSizeLargeMedium.toDouble(),
                    color: Theme.of(context).textTheme.subtitle2.color,
                  ),
                  PriceWidget(
                    price: productDetailNew.regular_price.toString(),
                    size: textSizeSMedium.toDouble(),
                    color: Theme.of(context).textTheme.subtitle1.color,
                    isLineThroughEnabled: true,
                  ).paddingOnly(left: spacing_standard.toDouble())
                ],
              )
            : Row(
                children: [
                  PriceWidget(
                    price: productDetailNew.price.toString(),
                    size: textSizeLargeMedium.toDouble(),
                    color: Theme.of(context).accentColor,
                  ),
                ],
              )
        : SizedBox();

    final mFavourite = mainProduct != null
        ? InkWell(
            onTap: () {
              if (mIsInWishList)
                removeWishListItem();
              else
                addToWishList();
            },
            child: Icon(
              mIsInWishList ? Icons.favorite : Icons.favorite_border,
              color:
                  mIsInWishList ? primaryColor : Theme.of(context).primaryColor,
              size: 25,
            ),
          )
            .paddingOnly(bottom: spacing_control.toDouble())
            .visible(mainProduct.isAddedWishlist != null)
        : SizedBox();
    Widget mExternalAttribute() {
      setPriceDetail();
      mIsExternalProduct = true;
      mExternalUrl = mainProduct.externalUrl.toString();
      return SizedBox();
    }

    Widget mGroupAttribute(List<ProductDetailResponse> product) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            appLocalization.translate('lbl_product_include'),
            style: boldTextStyle(
                color: Theme.of(context).textTheme.headline6.color,
                size: textSizeMedium),
          ).paddingOnly(
              left: spacing_standard.toDouble(),
              top: spacing_standard.toDouble()),
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: product.length,
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(spacing_standard.toDouble()),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: boxDecoration(
                            context,
                            radius: 10.0,
                          ),
                          width: context.width() * 0.22,
                          height: context.height() * 0.12,
                          child: Image.network(
                            product[i].images[0].src,
                            height: context.height() * 0.1,
                            width: 0.1,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product[i].name,
                                style: boldTextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .color,
                                    size: textSizeSMedium),
                              ).paddingOnly(
                                  left: spacing_standard.toDouble(),
                                  right: spacing_standard.toDouble()),
                              spacing_large.height,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.17,
                                    height: 35,
                                    child: RaisedButton(
                                      color: colorAccent,
                                      onPressed: () {
                                        addToCartApi(product[i].id, 1);
                                      },
                                      textColor: Colors.white,
                                      child: Text(
                                          appLocalization.translate('lbl_add'),
                                          style: TextStyle(fontSize: 12)),
                                    ).cornerRadiusWithClipRRect(5.0),
                                  ),
                                  Column(
                                    children: [
                                      PriceWidget(
                                          price: product[i]
                                                  .sale_price
                                                  .toString()
                                                  .validate()
                                                  .isNotEmpty
                                              ? product[i].sale_price.toString()
                                              : product[i]
                                                  .price
                                                  .toString()
                                                  .validate(),
                                          size: 14,
                                          color: Theme.of(context)
                                              .textTheme
                                              .subtitle2
                                              .color),
                                      spacing_control_half.height,
                                      PriceWidget(
                                              price: product[i]
                                                  .regular_price
                                                  .toString(),
                                              size: 12,
                                              isLineThroughEnabled: true,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2
                                                  .color)
                                          .visible(product[i]
                                              .sale_price
                                              .toString()
                                              .isNotEmpty),
                                    ],
                                  )
                                ],
                              ).paddingOnly(
                                left: 8,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              })
        ],
      );
    }

    Widget mUpcomingSale() {
      if (mainProduct != null) {
        if (mainProduct.dateOnSaleFrom != "") {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appLocalization.translate('lbl_upcoming_sale_on_this_item'),
                style: boldTextStyle(
                    color: Theme.of(context).textTheme.headline6.color,
                    size: textSizeMedium),
              ).paddingOnly(top: 16, left: 16, right: 16),
              Text(
                appLocalization.translate('lbl_sale_start_from') +
                    " " +
                    mainProduct.dateOnSaleFrom +
                    " " +
                    appLocalization.translate('lbl_to') +
                    " " +
                    mainProduct.dateOnSaleTo +
                    ". " +
                    appLocalization
                        .translate('lbl_ge_amazing_discounts_on_the_products'),
                style: secondaryTextStyle(
                    color: Theme.of(context).textTheme.subtitle2.color,
                    size: textSizeMedium),
              ).paddingOnly(
                  left: 16, top: spacing_control.toDouble(), right: 16),
            ],
          );
        } else {
          return SizedBox();
        }
      } else {
        return SizedBox();
      }
    }

    Widget upSaleProductList(List<UpsellId> product) {
      var productWidth = MediaQuery.of(context).size.width;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            builderResponse.dashboard.youMayLikeProduct.title,
            style: boldTextStyle(
                color: Theme.of(context).textTheme.headline6.color,
                size: textSizeMedium),
          ).paddingLeft(spacing_standard_new.toDouble()),
          Container(
            margin: EdgeInsets.only(
                top: spacing_standard.toDouble(),
                bottom: spacing_standard_new.toDouble()),
            height: 280,
            child: ListView.builder(
              itemCount: product.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                return Container(
                  height: 250,
                  width: 160,
                  margin: EdgeInsets.fromLTRB(spacing_standard_new.toDouble(),
                      spacing_middle.toDouble(), 0, spacing_middle.toDouble()),
                  decoration:
                      boxDecoration(context, showShadow: true, radius: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Image.network(
                            product[i].images.first.src,
                            height: 150,
                            width: productWidth,
                            fit: BoxFit.contain,
                          ).paddingOnly(top: spacing_middle.toDouble()),
                        ],
                      ),
                      spacing_control.height,
                      Text(
                        product[i].name,
                        style: boldTextStyle(
                            color: Theme.of(context).textTheme.headline6.color,
                            size: textSizeSMedium),
                        maxLines: 2,
                      ).paddingOnly(
                          left: spacing_standard.toDouble(),
                          right: spacing_standard.toDouble()),
                      spacing_standard.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              PriceWidget(
                                      price: product[i].regularPrice.toString(),
                                      size: 12,
                                      isLineThroughEnabled: true,
                                      color: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .color)
                                  .visible(product[i].salePrice != null),
                              spacing_control_half.height,
                              PriceWidget(
                                  price:
                                      product[i].salePrice.toString().isNotEmpty
                                          ? product[i].salePrice.toString()
                                          : product[i].price.toString(),
                                  size: 14,
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .color),
                            ],
                          ),
                          Container(
                            width: productWidth * 0.17,
                            height: 35,
                            child: RaisedButton(
                              color: Theme.of(context).accentColor,
                              onPressed: () {
                                appStore.increment();
                                setState(() {
                                  mIsLoading = true;
                                });
                                var request = {
                                  "pro_id": product[i].id,
                                  "quantity": "1",
                                };
                                addToCart(request).then((res) {
                                  toast(res[msg]);
                                  mIsLoading = false;
                                  productDetail();
                                  setState(() {});
                                }).catchError((error) {
                                  appStore.decrement();
                                  toast(error.toString());
                                  setState(() {
                                    mIsLoading = false;
                                  });
                                });
                              },
                              textColor: Colors.white,
                              child: Text(
                                'Add',
                                style: boldTextStyle(
                                    size: 12,
                                    color: Theme.of(context).cardTheme.color),
                              ),
                            ).cornerRadiusWithClipRRect(5.0),
                          ),
                        ],
                      ).paddingOnly(
                          left: spacing_standard.toDouble(),
                          right: spacing_standard.toDouble()),
                      spacing_standard.height,
                    ],
                  ),
                ).onTap(() {
                  builderResponse.productdetailview.layout == "layout1"
                      ? ProductDetailScreen(mProId: product[i].id)
                          .launch(context)
                      : ProductDetailsBuilderScreen(mProId: product[i].id)
                          .launch(context);
                });
              },
            ),
          )
        ],
      );
    }

    final mCartData = mainProduct != null
        ? GestureDetector(
            onTap: () {
              if (mIsExternalProduct) {
                WebViewExternalProductScreen(mExternal_URL: mExternalUrl)
                    .launch(context);
              } else {
                if (isAddedToCart) {
                  appStore.decrement();
                  removeToCartApi(productDetailNew.id);
                } else {
                  appStore.increment();
                  addToCartApi(productDetailNew.id, 1);
                }
              }
            },
            child: Container(
              padding: EdgeInsets.all(spacing_middle.toDouble()),
              decoration: boxDecoration(context,
                  radius: spacing_control.toDouble(),
                  bgColor: Theme.of(context).primaryColor),
              child: Text(
                  mainProduct.type == 'external'
                      ? mainProduct.buttonText
                      : mainProduct.isAddedCart == false
                          ? appLocalization.translate('lbl_add_to_cart')
                          : appLocalization.translate('lbl_remove_cart'),
                  textAlign: TextAlign.center,
                  style: boldTextStyle(size: 16, color: Colors.white)),
            ),
          )
        : SizedBox();

    final mBuyNow = mainProduct != null
        ? GestureDetector(
            onTap: () {
              if (mIsExternalProduct) {
                WebViewExternalProductScreen(mExternal_URL: mExternalUrl)
                    .launch(context);
              } else {
                if (isAddedToCart) {
                  appStore.decrement();
                  removeToCartApi(productDetailNew.id);
                } else {
                  appStore.increment();
                  addToCartApi(productDetailNew.id, 1);
                }
              }
            },
            child: Container(
              padding: EdgeInsets.all(spacing_middle.toDouble()),
              decoration: boxDecoration(context,
                  radius: spacing_control.toDouble(),
                  bgColor: Theme.of(context).colorScheme.onPrimary),
              child: Text(
                  mainProduct.type == 'external'
                      ? mainProduct.buttonText
                      : mainProduct.isAddedCart == false
                          ? appLocalization.translate('lbl_add_to_cart')
                          : appLocalization.translate('lbl_remove_cart'),
                  textAlign: TextAlign.center,
                  style: boldTextStyle(size: 16, color: Colors.white)),
            ),
          )
        : SizedBox();
    return SafeArea(
        child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  finish(context);
                },
                icon: Icon(Icons.arrow_back,
                    size: 30, color: Theme.of(context).accentColor),
              ),
            ),
            body: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                (mainProduct != null)
                    ? ListView(
                        shrinkWrap: true,
                        children: [
                          30.height,
                          Container(
                            height: 240,
                            child: PageView(
                              pageSnapping: true,
                              physics: ClampingScrollPhysics(),
                              controller: _controller,
                              onPageChanged: (index) {
                                selectedIndex = index;
                                setState(() {});
                              },
                              children: mainProduct.images.map((i) {
                                return Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      )),
                                      alignment: Alignment.bottomCenter,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 4.0, vertical: 2),
                                      child: Image.network(
                                        i.src,
                                        fit: BoxFit.cover,
                                      ).cornerRadiusWithClipRRect(10.0),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          20.height,
                          Container(
                            child: Text(
                              mainProduct.name,
                              style: boldTextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .color,
                                  size: textSizeMedium),
                            ),
                          ).paddingOnly(left: 16, right: 16),
                          Container(
                            margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                            padding: EdgeInsets.all(8),
                            decoration: boxDecorationRoundedWithShadow(5,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    mDiscount(),
                                    5.width,
                                    if (mainProduct.on_sale == true)
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(6, 2, 6, 2),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: redColor,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4))),
                                        child: Text(
                                          "Sale",
                                          style: boldTextStyle(
                                              color: Colors.white, size: 12),
                                        ),
                                      ).cornerRadiusWithClipRRectOnly(
                                          topLeft: 0, bottomLeft: 4),
                                  ],
                                ),
                                10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        RatingBar(
                                          initialRating: rating,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          unratedColor: Colors.grey,
                                          itemCount: 5,
                                          itemSize: 20.0,
                                          glow: false,
                                          ignoreGestures: true,
                                          itemPadding: EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: yellowColor,
                                          ),
                                          onRatingUpdate: (rating) {
                                            log(rating);
                                          },
                                        ).onTap(() async {
                                          final double result =
                                              await ReviewScreen(
                                                      mProductId:
                                                          mainProduct.id)
                                                  .launch(context);
                                          if (result == 0.0) {
                                            rating = rating;
                                            setState(() {});
                                          } else {
                                            rating = result;
                                            setState(() {});
                                          }
                                        }).visible(
                                            mainProduct.reviewsAllowed == true),
                                        2.width,
                                        Text(
                                          "(${rating.toString()})",
                                          style: primaryTextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2
                                                  .color),
                                        )
                                      ],
                                    ).expand(),
                                    if (mainProduct.reviewsAllowed == true)
                                      GestureDetector(
                                        onTap: () async {
                                          final result1 = await ReviewScreen(
                                                  mProductId: mainProduct.id)
                                              .launch(context);
                                          toast(result1);
                                        },
                                        child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: boxDecoration(context,
                                                color: Theme.of(context)
                                                    .accentColor,
                                                radius: 4.0,
                                                bgColor: Colors.transparent),
                                            child: Text(
                                              appLocalization
                                                  .translate('hint_review'),
                                              style: primaryTextStyle(
                                                  size: 16,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .headline6
                                                      .color),
                                            ).center()),
                                      ),
                                  ],
                                ),
                                10.height,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    mPrice,
                                    mFavourite,
                                  ],
                                ),
                                10.height,
                                if (mainProduct.store != null)
                                  Row(
                                    children: [
                                      Text(
                                        appLocalization
                                            .translate('lbl_sold_by'),
                                        style: primaryTextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .subtitle1
                                                .color,
                                            size: textSizeMedium),
                                      ),
                                      8.width,
                                      GestureDetector(
                                        onTap: () {
                                          VendorProfileScreen(
                                                  mVendorId: mainProduct.id)
                                              .launch(context);
                                        },
                                        child: Text(
                                          mainProduct.store.shop_name != null
                                              ? mainProduct.store.shop_name
                                              : '',
                                          style: boldTextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: textSizeMedium),
                                        ),
                                      )
                                    ],
                                  )
                              ],
                            ),
                          ),
                          if (mainProduct.on_sale)
                            mainProduct.dateOnSaleFrom.isNotEmpty
                                ? mSpecialPrice()
                                : SizedBox(),
                          if (mainProduct.type == "variable")
                            Container(
                              margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                              padding: EdgeInsets.all(8),
                              decoration: boxDecorationRoundedWithShadow(5,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    appLocalization.translate('lbl_Available'),
                                    style: boldTextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            .color,
                                        size: textSizeMedium),
                                  ),
                                  16.height,
                                  Container(
                                    padding: EdgeInsets.only(left: 8, right: 8),
                                    decoration: boxDecoration(context,
                                        radius: spacing_control.toDouble(),
                                        color: Colors.grey.withOpacity(0.5)),
                                    child: DropdownButton(
                                      dropdownColor:
                                          Theme.of(context).cardTheme.color,
                                      value: mSelectedVariation,
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      onChanged: (value) {
                                        setState(() {
                                          mSelectedVariation = value;
                                          int index =
                                              mProductOptions.indexOf(value);
                                          mProducts.forEach((product) {
                                            if (mProductVariationsIds[index] ==
                                                product.id) {
                                              this.productDetailNew = product;
                                            }
                                          });
                                          setPriceDetail();
                                        });
                                      },
                                      items: mProductOptions.map((value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: primaryTextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1
                                                    .color,
                                                size: textSizeMedium),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (mainProduct.type == "grouped")
                            mGroupAttribute(product)
                          else if (mainProduct.type == "simple")
                            Container()
                          else if (mainProduct.type == "external")
                            mExternalAttribute()
                          else
                            mOtherAttribute(),
                          Container(
                            margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                            padding: EdgeInsets.all(16),
                            decoration: boxDecorationRoundedWithShadow(5,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appLocalization
                                      .translate('lbl_additional_information'),
                                  style: boldTextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          .color,
                                      size: textSizeMedium),
                                ),
                                16.height,
                                mSetAttribute(),
                              ],
                            ),
                          ),
                          mUpcomingSale().visible(!mainProduct.on_sale),
                          Container(
                            margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                            padding: EdgeInsets.all(16),
                            decoration: boxDecorationRoundedWithShadow(5,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appLocalization.translate('hint_description'),
                                  style: boldTextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          .color,
                                      size: textSizeMedium),
                                ),
                                16.height,
                                Text(parseHtmlString(mainProduct.description),
                                    textAlign: TextAlign.justify,
                                    style: secondaryTextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            .color,
                                        size: textSizeMedium))
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                            padding: EdgeInsets.all(16),
                            decoration: boxDecorationRoundedWithShadow(5,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appLocalization.translate('lbl_category'),
                                  style: boldTextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          .color,
                                      size: textSizeMedium),
                                ),
                                16.height,
                                Wrap(
                                  children: mainProduct.categories.map((e) {
                                    return Container(
                                      width: context.width() * 0.4,
                                      child: UL(
                                        children: [
                                          Text(
                                            e.name,
                                            style: secondaryTextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1
                                                    .color,
                                                size: textSizeMedium),
                                          )
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                )
                              ],
                            ),
                          ),
                          20.height,
                          if (mainProduct.upsellIds != null)
                            upSaleProductList(mainProduct.upsellId)
                                .visible(mainProduct.upsellId.isNotEmpty),
                          16.height,
                        ],
                      )
                    : Container(),
                Center(child: CircularProgressIndicator()).visible(mIsLoading),
              ],
            ),
            bottomNavigationBar: mainProduct != null
                ? Container(
                    width: MediaQuery.of(context).copyWith().size.width,
                    decoration: BoxDecoration(boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Theme.of(context).hoverColor.withOpacity(0.2),
                          blurRadius: 15.0,
                          offset: Offset(0.0, 0.75))
                    ], color: Theme.of(context).scaffoldBackgroundColor),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        mCart(context, mIsLoggedIn,
                            color: Theme.of(context).accentColor),
                        mCartData.expand(),
                        8.width,
                      ],
                    ).paddingOnly(
                        top: spacing_standard.toDouble(),
                        bottom: spacing_standard.toDouble(),
                        right: spacing_standard_new.toDouble(),
                        left: spacing_standard_new.toDouble()),
                  )
                : SizedBox()));
  }
}
