import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/models/ProductDetailResponse.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/screen/MyCartScreen.dart';
import 'package:ServiceJi/screen/ProductDetailsBuilderScreen.dart';
import 'package:ServiceJi/screen/ZoomImageScreen.dart';
import 'package:ServiceJi/utils/CountState.dart';
import 'package:ServiceJi/utils/Countdown.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/common.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/shared_pref.dart';
import 'package:provider/provider.dart';
import '../app_localizations.dart';
import 'ReviewScreen.dart';
import 'SignInScreen.dart';
import 'VendorProfileScreen.dart';
import 'WebViewExternalProductScreen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int mProId;

  ProductDetailScreen({Key key, this.mProId}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<String> kgs = List();
  ProductDetailResponse productDetailNew;
  final mProductsList = List<ProductDetailResponse>();
  ProductDetailResponse mainProduct;
  List<ProductDetailResponse> product = List();
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

  @override
  void initState() {
    super.initState();
    productDetail();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future productDetail() async {
    pref = await getSharedPref();
    mIsLoggedIn = pref.getBool(IS_LOGGED_IN) ?? false;
    await getProductDetail(widget.mProId).then((res) {
      if (!mounted) return;
      setState(() {
        mIsLoading = false;
        Iterable mInfo = res;
        mProducts = mInfo.map((model) => ProductDetailResponse.fromJson(model)).toList();

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
            if (mProductOptions.isNotEmpty) mSelectedVariation = mProductOptions.first;

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
        decoration: boxDecoration(context, color: Theme.of(context).primaryColor, radius: 4.0, bgColor: Colors.transparent),
        child: Text(
          '${discount.toInt()} % ${AppLocalizations.of(context).translate('lbl_off1')}',
          style: primaryTextStyle(color: Theme.of(context).accentColor, size: textSizeSmall),
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
        var currentDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(DateTime.now().toString());
        var format = endDate.subtract(Duration(days: currentDate.day, hours: currentDate.hour, minutes: currentDate.minute, seconds: currentDate.second));
        log(format);

        return Countdown(
          duration: Duration(days: format.day, hours: format.hour, minutes: format.minute, seconds: format.second),
          onFinish: () {
            log('finished!');
          },
          builder: (BuildContext ctx, Duration remaining) {
            var seconds = ((remaining.inMilliseconds / 1000) % 60).toInt();
            var minutes = (((remaining.inMilliseconds / (1000 * 60)) % 60)).toInt();
            var hours = (((remaining.inMilliseconds / (1000 * 60 * 60)) % 24)).toInt();
            log(hours);
            return Container(
              decoration: boxDecoration(context, bgColor: colorAccent.withOpacity(0.3), radius: 4.0),
              child: Text(
                'Special price end in less then '
                '${remaining.inDays}d ${hours}h ${minutes}m ${seconds}s',
                style: primaryTextStyle(color: Theme.of(context).accentColor, size: textSizeSMedium),
              ).paddingAll(spacing_standard.toDouble()),
            ).paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble(), top: spacing_standard_new.toDouble());
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

      setState(() {

      });
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
      padding: EdgeInsets.only(left: 8, right: 8),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, i) {
        return Row(
          children: [
            Text(
              mainProduct.attributes[i].name + " : ",
              style: primaryTextStyle(size: textSizeMedium, color: Theme.of(context).textTheme.subtitle1.color),
            ).paddingOnly(left: spacing_standard.toDouble()),
            SizedBox(
              width: 4.0,
            ),
            Expanded(
                child: Text(
              getAllAttribute(mainProduct.attributes[i]),
              maxLines: 4,
              style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.subtitle1.color),
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

    Widget mUpcomingSale() {
      if (mainProduct != null) {
        if (mainProduct.dateOnSaleFrom != "") {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appLocalization.translate('lbl_upcoming_sale_on_this_item'),
                style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeMedium),
              ).paddingOnly(top: spacing_standard_new.toDouble(), left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()),
              Text(
                appLocalization.translate('lbl_sale_start_from') +
                    " " +
                    mainProduct.dateOnSaleFrom +
                    " " +
                    appLocalization.translate('lbl_to') +
                    " " +
                    mainProduct.dateOnSaleTo +
                    ". " +
                    appLocalization.translate('lbl_ge_amazing_discounts_on_the_products'),
                style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium),
              ).paddingOnly(left: spacing_standard_new.toDouble(), top: spacing_control.toDouble(), right: spacing_standard_new.toDouble()),
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
            style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeMedium),
          ).paddingLeft(spacing_standard_new.toDouble()),
          Container(
            margin: EdgeInsets.only(top: spacing_standard.toDouble(), bottom: spacing_standard_new.toDouble()),
            height: productWidth * 0.65,
            child: ListView.builder(
              itemCount: product.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                return Container(
                  height: 260,
                  width: 180,
                  margin: EdgeInsets.all(8),
                  decoration: boxDecoration(context, showShadow: true, radius: 8.0),
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
                      ).expand(),
                      spacing_control.height,
                      Text(
                        product[i].name,
                        style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeSMedium),
                        maxLines: 2,
                      ).paddingOnly(left: spacing_standard.toDouble(), right: spacing_standard.toDouble()),
                      spacing_standard.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              PriceWidget(price: product[i].regularPrice.toString(), size: 12, isLineThroughEnabled: true, color: Theme.of(context).textTheme.subtitle2.color)
                                  .visible(product[i].salePrice != null),
                              spacing_control_half.height,
                              PriceWidget(
                                  price: product[i].salePrice.toString().isNotEmpty ? product[i].salePrice.toString() : product[i].price.toString(),
                                  size: 14,
                                  color: Theme.of(context).textTheme.subtitle1.color),
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
                                style: boldTextStyle(size: 12, color: Theme.of(context).cardTheme.color),
                              ),
                            ).cornerRadiusWithClipRRect(5.0),
                          ),
                        ],
                      ).paddingOnly(left: spacing_standard.toDouble(), right: spacing_standard.toDouble()),
                      spacing_standard.height,
                    ],
                  ),
                ).onTap(() {
                  builderResponse.productdetailview.layout == "layout1"
                      ? ProductDetailScreen(mProId: product[i].id).launch(context)
                      : ProductDetailsBuilderScreen(mProId: product[i].id).launch(context);
                });
              },
            ),
          )
        ],
      );
    }

    Widget mGroupAttribute(List<ProductDetailResponse> product) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            appLocalization.translate('lbl_product_include'),
            style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeMedium),
          ).paddingOnly(left: spacing_standard.toDouble(), top: spacing_standard.toDouble()),
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
                                style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeSMedium),
                              ).paddingOnly(left: spacing_standard.toDouble(), right: spacing_standard.toDouble()),
                              spacing_large.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.17,
                                    height: 35,
                                    child: RaisedButton(
                                      color: colorAccent,
                                      onPressed: () {
                                        addToCartApi(product[i].id, 1);
                                      },
                                      textColor: Colors.white,
                                      child: Text(appLocalization.translate('lbl_add'), style: TextStyle(fontSize: 12)),
                                    ).cornerRadiusWithClipRRect(5.0),
                                  ),
                                  Column(
                                    children: [
                                      PriceWidget(
                                          price: product[i].sale_price.toString().validate().isNotEmpty ? product[i].sale_price.toString() : product[i].price.toString().validate(),
                                          size: 14,
                                          color: Theme.of(context).textTheme.subtitle2.color),
                                      spacing_control_half.height,
                                      PriceWidget(price: product[i].regular_price.toString(), size: 12, isLineThroughEnabled: true, color: Theme.of(context).textTheme.subtitle2.color)
                                          .visible(product[i].sale_price.toString().isNotEmpty),
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

    final carousel = mainProduct != null
        ? Container(
            padding: EdgeInsets.only(top: context.height() * 0.1),
            width: MediaQuery.of(context).size.width,
            color: white_color,
            child: Carousel(
              images: map<Widget>(
                mainProduct.images,
                (index, Images i) {
                  return InkWell(
                    onTap: () {
                      ZoomImageScreen(mProductImage: i.src).launch(context);
                    },
                    child: Image.network(i.src, fit: BoxFit.contain, width: double.infinity),
                  );
                },
              ).toList(),
              indicatorBgPadding: 8,
              dotBgColor: Colors.transparent,
              dotColor: Colors.grey.withOpacity(0.2),
              dotIncreasedColor: primaryColor,
              dotIncreaseSize: 1.5,
              borderRadius: true,
              dotSpacing: 16,
              autoplay: false,
            ),
          )
        : SizedBox();

    // Check Wish list
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
              color: mIsInWishList ? primaryColor : Theme.of(context).textTheme.subtitle2.color,
              size: 34,
            ),
          ).paddingOnly(bottom: spacing_control.toDouble()).visible(mainProduct.isAddedWishlist != null)
        : SizedBox();

    final mCartData = mainProduct != null
        ? Expanded(
            child: GestureDetector(
            onTap: () {
              if (mIsExternalProduct) {
                WebViewExternalProductScreen(mExternal_URL: mExternalUrl).launch(context);
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
              decoration: boxDecoration(context, radius: spacing_control.toDouble(), bgColor: Theme.of(context).primaryColor),
              child: Text(
                  mainProduct.type == 'external'
                      ? mainProduct.buttonText
                      : mainProduct.isAddedCart == false
                          ? appLocalization.translate('lbl_add_to_cart')

                          : appLocalization.translate('lbl_remove_cart'),
                  textAlign: TextAlign.center,
                  style: boldTextStyle(size: 16, color: white_color)),
            ),
          ))
        : SizedBox();


    final mPrice = mainProduct != null
        ? mainProduct.on_sale
            ? Row(
                children: [
                  PriceWidget(
                    price: productDetailNew.price.toString().toString(),
                    size: textSizeLargeMedium.toDouble(),
                    color: Theme.of(context).accentColor,
                  ),
                  PriceWidget(
                    price: productDetailNew.regular_price.toString(),
                    size: textSizeSMedium.toDouble(),
                    color: Theme.of(context).primaryColor,
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

    Widget mExternalAttribute() {
      setPriceDetail();
      mIsExternalProduct = true;
      mExternalUrl = mainProduct.externalUrl.toString();
      return SizedBox();
    }

    final body = mainProduct != null
        ? Stack(
            children: <Widget>[
              SingleChildScrollView(
                  child: Column(
                children: [
                  Container(
                    // decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        spacing_standard_new.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            mDiscount(),
                            // Sale label
                            if (mainProduct.on_sale == true)
                              Container(
                                padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.all(Radius.circular(4))),
                                child: Text(
                                  "Sale",
                                  style: boldTextStyle(color: Colors.white, size: 12),
                                ),
                              ).cornerRadiusWithClipRRectOnly(topLeft: 0, bottomLeft: 4),
                          ],
                        ).paddingAll(spacing_standard_new.toDouble()),
                        Text(
                          mainProduct.name,
                          style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium),
                        ).paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            mPrice,
                            Row(
                              children: [
                                RatingBar(
                                  initialRating: rating,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  unratedColor: Colors.grey.withOpacity(0.7),
                                  itemCount: 5,
                                  itemSize: 20.0,
                                  glow: false,
                                  ignoreGestures: true,
                                  itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: yellowColor,
                                  ),
                                  onRatingUpdate: (rating) {
                                    log(rating);
                                  },
                                ),
                              ],
                            ).onTap(() async {
                              final double result = await ReviewScreen(mProductId: mainProduct.id).launch(context);
                              if (result == 0.0) {
                                rating = rating;
                                setState(() {});
                              } else {
                                rating = result;
                                setState(() {});
                              }
                            }).visible(mainProduct.reviewsAllowed == true)
                          ],
                        ).paddingOnly(
                          top: spacing_middle.toDouble(),
                          left: spacing_standard_new.toDouble(),
                          right: spacing_standard.toDouble(),
                        ),
                        if (mainProduct.store != null)
                          Row(
                            children: [
                              Text(
                                appLocalization.translate('lbl_sold_by'),
                                style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium),
                              ),
                              8.width,
                              GestureDetector(
                                onTap: () {
                                  VendorProfileScreen(mVendorId: mainProduct.id).launch(context);
                                },
                                child: Text(
                                  mainProduct.store.shop_name != null ? mainProduct.store.shop_name : '',
                                  style: boldTextStyle(color: Theme.of(context).primaryColor, size: textSizeMedium),
                                ),
                              )
                            ],
                          ).paddingOnly(
                            top: spacing_middle.toDouble(),
                            left: spacing_standard_new.toDouble(),
                            right: spacing_standard.toDouble(),
                          ),
                        if (mainProduct.on_sale) mainProduct.dateOnSaleFrom.isNotEmpty ? mSpecialPrice() : SizedBox(),
                        if (mainProduct.type == "variable")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                appLocalization.translate('lbl_Available'),
                                style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium),
                              ).paddingAll(spacing_standard_new.toDouble()),
                              Container(
                                margin: EdgeInsets.only(left: 16.0, right: 16.0),
                                decoration: boxDecoration(context, radius: spacing_control.toDouble()),
                                padding: EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Theme.of(context).cardTheme.color,
                                  ),
                                  child: DropdownButton(
                                    value: mSelectedVariation,
                                    isExpanded: true,
                                    underline: SizedBox(),
                                    onChanged: (value) {
                                      setState(() {
                                        mSelectedVariation = value;
                                        int index = mProductOptions.indexOf(value);

                                        mProducts.forEach((product) {
                                          if (mProductVariationsIds[index] == product.id) {
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
                                          style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else if (mainProduct.type == "grouped")
                          mGroupAttribute(product)
                        else if (mainProduct.type == "simple")
                          Container()
                        else if (mainProduct.type == "external")
                          mExternalAttribute()
                        else
                          mOtherAttribute(),
                        Text(
                          appLocalization.translate('lbl_additional_information'),
                          style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium),
                        ).paddingAll(spacing_standard_new.toDouble()),
                        mSetAttribute(),
                        mUpcomingSale().visible(!mainProduct.on_sale),
                        Text(
                          appLocalization.translate('hint_description'),
                          style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium),
                        ).paddingOnly(top: spacing_standard_new.toDouble(), left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()),
                        Text(parseHtmlString(mainProduct.description),
                                textAlign: TextAlign.justify, style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium))
                            .paddingOnly(top: spacing_standard.toDouble(), left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()),
                        spacing_standard_new.height,
                        Text(
                          appLocalization.translate('lbl_category'),
                          style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium),
                        ).paddingOnly(top: spacing_standard_new.toDouble(), left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()),
                        Wrap(
                          children: mainProduct.categories.map((e) {
                            return Container(
                              width: context.width() * 0.5,
                              child: UL(
                                children: [
                                  Text(e.name, style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: 14)),
                                ],
                              ),
                            );
                          }).toList(),
                        ).paddingOnly(top: spacing_standard_new.toDouble(), left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()),
                        spacing_standard_new.height,
                        if (mainProduct.upsellIds != null) upSaleProductList(mainProduct.upsellId).visible(mainProduct.upsellId.isNotEmpty),
                        spacing_standard_new.height,
                        if (mainProduct.reviewsAllowed == true)
                          GestureDetector(
                            onTap: () async {
                              final result1 = await ReviewScreen(mProductId: mainProduct.id).launch(context);
                              toast(result1);
                              log("Result $result1");
                            },
                            child: (Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()),
                                decoration: boxDecoration(context, radius: spacing_control.toDouble(), color: view_color, bgColor: Theme.of(context).cardTheme.color),
                                padding: EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      appLocalization.translate('hint_review'),
                                      style: primaryTextStyle(size: 16, color: Theme.of(context).textTheme.headline6.color),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Theme.of(context).textTheme.headline6.color,
                                    )
                                  ],
                                ))),
                          ),
                        spacing_xxLarge.height,
                      ],
                    ),
                  )
                ],
              )),
            ],
          )
        : SizedBox();

    final collapsedBody = mainProduct != null
        ? NestedScrollView(
            body: SingleChildScrollView(
              child: (mainProduct != null) ? body : Container(),
            ),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Theme.of(context).cardTheme.color,
                  pinned: true,
                  floating: true,
                  expandedHeight: 330,
                  actionsIconTheme: IconThemeData(color: Theme.of(context).accentColor),
                  iconTheme: IconThemeData(color: Theme.of(context).accentColor),
                  leading: new IconButton(
                    icon: new Icon(
                      Icons.arrow_back,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: mainProduct.images.isNotEmpty ? carousel : SizedBox(),
                    title: innerBoxIsScrolled
                        ? Text(mainProduct != null ? mainProduct.name : ' ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.headline6.color,
                              fontSize: 16.0,
                            ))
                        : Text(
                            '',
                            style: TextStyle(color: Theme.of(context).textTheme.headline6.color),
                          ),
                  ),
                  actions:[
                    mCart(context,mIsLoggedIn,color: Theme.of(context).textTheme.headline6.color)
                  ],
                )
              ];
            },
          )
        : SizedBox();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body:
      Stack(
        alignment: Alignment.bottomLeft,
        children: <Widget>[
          mainProduct != null ? collapsedBody : SizedBox(),

          Center(child: CircularProgressIndicator()).visible(mIsLoading),
        ],
      ),
      bottomNavigationBar: Container(
        width: context.width(),
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Theme.of(context).hoverColor.withOpacity(0.2),
                blurRadius: 15.0,
                offset: Offset(0.0, 0.75)
            )
          ],
        ),
        child: Row(
          children: [
            mFavourite,
            SizedBox(
              width: spacing_standard_new.toDouble(),
            ),
            mCartData
          ],
        )
            .paddingOnly(top: spacing_standard.toDouble(), bottom: spacing_standard.toDouble(), right: spacing_standard_new.toDouble(), left: spacing_standard_new.toDouble())
            .visible(!mIsGroupedProduct),
      ).visible(mainProduct != null),


    );
  }
}
