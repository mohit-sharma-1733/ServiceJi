import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/models/CartModel.dart';
import 'package:ServiceJi/models/CategoryData.dart';
import 'package:ServiceJi/models/ProductResponse.dart';
import 'package:ServiceJi/models/SliderModel.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/screen/AboutUsScreen.dart';
import 'package:ServiceJi/screen/CategoriesScreen.dart';
import 'package:ServiceJi/screen/ChangePasswordScreen.dart';
import 'package:ServiceJi/screen/EditProfileScreen.dart';
import 'package:ServiceJi/screen/MyCartScreen.dart';
import 'package:ServiceJi/screen/OrderListScreen.dart';
import 'package:ServiceJi/screen/ProductDetailScreen.dart';
import 'package:ServiceJi/screen/ProductDetailsBuilderScreen.dart';
import 'package:ServiceJi/screen/ViewAllScreen.dart';
import 'package:ServiceJi/screen/WebViewExternalProductScreen.dart';
import 'package:ServiceJi/screen/WishListScreen.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/utils/common.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import 'package:ServiceJi/utils/images.dart';
import 'package:ServiceJi/utils/shared_pref.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ServiceJi/screen/home.dart';
import '../app_localizations.dart';
import '../app_state.dart';
import 'SearchScreen.dart';

import 'SignInScreen.dart';
import 'VendorListScreen.dart';

class DashboardScreen extends StatefulWidget {
  static String tag = '/DashboardScreen';

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  int cartCount = 0;
  int count = 0;
  var mSliderModel = List<SliderModel>();
  var mSliderImages = List<String>();
  var selectedIndex = 0;

  var mNewestProductModel = List<ProductResponse>();
  var mFeaturedProductModel = List<ProductResponse>();
  var mDealProductModel = List<ProductResponse>();
  var mSellingProductModel = List<ProductResponse>();
  var mSaleProductModel = List<ProductResponse>();
  var mOfferProductModel = List<ProductResponse>();
  var mSuggestedProductModel = List<ProductResponse>();
  var mYouMayLikeProductModel = List<ProductResponse>();
  var mVendorModel = List<VendorResponse>();
  var mCategoryModel = List<Category>();
  List<String> colorArray = ['#ffffff', '#ffffff', '#ffffff'];

  SharedPreferences pref;
  Color primaryColor;

  var mErrorMsg = '';
  bool mIsLoading = true;
  bool mIsLoggedIn = false;
  bool isSwitched;
  bool isDarkTheme = false;

  var userName = '';
  var userEmail = '';
  var mProfileImage = '';
  var mCartModel = List<CartModel>();
  bool isWasConnectionLoss = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    fetchDashboardData();
    fetchCategoryData();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        isWasConnectionLoss = true;
        Scaffold(body: noInternet(context.height(), context.width()))
            .launch(context);
      } else {
        if (isWasConnectionLoss) finish(context);
      }
    });
  }

  Future fetchCategoryData() async {
    setState(() {
      mIsLoading = true;
    });
    await getCategories(1, TOTAL_CATEGORY_PER_PAGE).then((res) {
      if (!mounted) return;
      mIsLoading = false;
      setState(() {
        Iterable mCategory = res;
        mCategoryModel =
            mCategory.map((model) => Category.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        mIsLoading = false;
        toast(error.toString());
      });
    });
  }

  Future fetchDashboardData() async {
    primaryColor = await getThemeColor();
    changeStatusColor(primaryColor);

    pref = await getSharedPref();
    isSwitched = pref.getBool(IS_DARK_THEME) ?? false;
    mIsLoggedIn = pref.getBool(IS_LOGGED_IN) ?? false;
    userName = mIsLoggedIn ? pref.getString(USERNAME) : '';
    userEmail = mIsLoggedIn ? pref.getString(USER_EMAIL) : '';

    mProfileImage = pref.getString(PROFILE_IMAGE) != null
        ? pref.getString(PROFILE_IMAGE) ?? ""
        : pref.getString(AVATAR) ?? "";
    setState(() {});
    if (pref.getString(DASHBOARD_DATA) != null) {
      setProductData(jsonDecode(pref.getString(DASHBOARD_DATA)));
    }
    changeStatusColor(Colors.redAccent);
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        await getCartList().then((res) {
          if (!mounted) return;
          setState(() {
            Iterable list = res;
            mCartModel =
                list.map((model) => CartModel.fromJson(model)).toList();
            appStore.setCount(mCartModel.length);
          });
        }).catchError((error) {
          log(error);
          setState(() {});
        });
        await getDashboardApi().then((res) async {
          if (!mounted) return;
          mIsLoading = false;
          setString(DASHBOARD_DATA, jsonEncode(res));
          setString(SLIDER_DATA, jsonEncode(res));
          setProductData(res);
          if (res['social_link'] != null) {
            getSharedPref().then((pref) {
              pref.setString(WHATSAPP, res['social_link']['whatsapp']);
              pref.setString(FACEBOOK, res['social_link']['facebook']);
              pref.setString(TWITTER, res['social_link']['twitter']);
              pref.setString(INSTAGRAM, res['social_link']['instagram']);
              pref.setString(CONTACT, res['social_link']['contact']);
              pref.setString(
                  PRIVACY_POLICY, res['social_link']['privacy_policy']);
              pref.setString(
                  TERMS_AND_CONDITIONS, res['social_link']['term_condition']);
              pref.setString(
                  COPYRIGHT_TEXT, res['social_link']['copyright_text']);
            });
          }
          pref.setString(DEFAULT_CURRENCY,
              parseHtmlString(res['currency_symbol']['currency_symbol']));
          pref.setString(THEME_COLOR, res['theme_color']);
          pref.setString(LANGUAGE, res['app_lang']);
          pref.setString(PAYMENTMETHOD, res['payment_method']);
          pref.setBool(ENABLECOUPON, res['enable_coupons']);
          Provider.of<AppState>(context, listen: false)
              .changeLocale(Locale(res['app_lang'], ''));
          Provider.of<AppState>(context, listen: false)
              .changeLanguageCode(res['app_lang']);
        }).catchError((error) {
          if (!mounted) return;
          mIsLoading = false;
          mErrorMsg = errorMsg;
        });

        String list = await getString(SLIDER_DATA);
        setString(SLIDER_DATA, jsonEncode(list));
      } else {
        toast('You are not connected to Internet');
        if (!mounted) return;
        mIsLoading = false;
      }
      setState(() {});
    });
  }

  void setProductData(res) async {
    Iterable newest = res['newest'];
    mNewestProductModel =
        newest.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable featured = res['featured'];
    mFeaturedProductModel =
        featured.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable deal = res['deal_of_the_day'];
    mDealProductModel =
        deal.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable selling = res['best_selling_product'];
    mSellingProductModel =
        selling.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable sale = res['sale_product'];
    mSaleProductModel =
        sale.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable offer = res['offer'];
    mOfferProductModel =
        offer.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable suggested = res['suggested_for_you'];
    mSuggestedProductModel =
        suggested.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable youMayLike = res['you_may_like'];
    mYouMayLikeProductModel =
        youMayLike.map((model) => ProductResponse.fromJson(model)).toList();

    if (res['vendors'] != null) {
      Iterable vendorList = res['vendors'];
      mVendorModel =
          vendorList.map((model) => VendorResponse.fromJson(model)).toList();
    }

    mSliderImages.clear();
    Iterable list = res['banner'];
    mSliderModel = list.map((model) => SliderModel.fromJson(model)).toList();
    log("$mSliderModel");
    mSliderModel.forEach((s) => mSliderImages.add(s.image));

    setState(() {});
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  void dispose() {
    super.dispose();
    changeStatusColor(primaryColor);
  }

  Future addToCartApi(pro_id, BuildContext context,
      {returnExpected = false}) async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    setState(() {
      mIsLoading = true;
    });
    var request = {
      "pro_id": pro_id,
      "quantity": 1,
    };
    await addToCart(request).then((res) {
      setState(() {
        toast(res[msg]);
        mIsLoading = false;
        return returnExpected;
      });
    }).catchError((error) {
      setState(() {
        toast(error.toString());
        appStore.decrement();
        mIsLoading = false;
        return returnExpected;
      });
    });
  }

  Widget getProductWidget(ProductResponse product, BuildContext context,
      {double width = 160}) {
    var productWidth = MediaQuery
        .of(context)
        .size
        .width;
    String value = '';

    String img =
    product.images.isNotEmpty ? product.images.first.src.validate() : '';
    if (product.attributes.isNotEmpty) {
      List<Attributes> attributes = product.attributes;
      List<String> options = attributes.first.options;
      value = options.first;
    }
    return Container(
      width: width,
      height: 250,
      decoration: boxDecoration(context, showShadow: true, radius: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Stack(
              children: [
                Image.network(
                  img,
                  height: 100,
                  width: productWidth,
                  fit: BoxFit.contain,
                ).paddingOnly(
                  top: spacing_middle.toDouble(),
                  left: spacing_standard.toDouble(),
                  right: spacing_standard.toDouble(),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: redColor,
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                    child: Text(
                      "Sale",
                      style: primaryTextStyle(color: white_color, size: 12),
                      maxLines: 1,
                    ),
                  ).cornerRadiusWithClipRRectOnly(topLeft: 0, bottomLeft: 4),
                ).visible(product.on_sale == true)
              ],
            ),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value.toString(),
                  style: primaryTextStyle(
                      color: Theme
                          .of(context)
                          .accentColor,
                      size: textSizeSmall),
                  maxLines: 2,
                ).paddingOnly(
                    left: spacing_standard.toDouble(),
                    right: spacing_standard.toDouble()),
                spacing_control.height,
                Text(
                  product.name + "\n",
                  style: primaryTextStyle(
                      color: Theme
                          .of(context)
                          .textTheme
                          .headline5
                          .color,
                      size: textSizeSMedium),
                  maxLines: 2,
                ).paddingOnly(
                    left: spacing_standard.toDouble(),
                    right: spacing_standard.toDouble()),
                spacing_middle.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        PriceWidget(
                            price:
                            product.regular_price.validate().toString(),
                            size: 12,
                            isLineThroughEnabled: true,
                            color:
                            Theme
                                .of(context)
                                .textTheme
                                .subtitle1
                                .color)
                            .visible(product.sale_price
                            .validate()
                            .isNotEmpty),
                        spacing_control_half.height,
                        PriceWidget(
                            price: product.sale_price
                                .validate()
                                .isNotEmpty
                                ? product.sale_price.toString()
                                : product.price.validate(),
                            size: 14,
                            color: Theme
                                .of(context)
                                .textTheme
                                .subtitle2
                                .color),
                      ],
                    ),
                    product.purchasable
                        ? GestureDetector(
                      onTap: () {
                        setState(() {
                          mIsLoading = true;
                          if (product.type.validate() == "variable" &&
                              product.variations != null &&
                              product.variations.isNotEmpty) {
                            appStore.increment();
                            addToCartApi(product.variations[0], context);
                          } else {
                            appStore.increment();
                            addToCartApi(product.id, context);
                            //setInt(key, value)

                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                            spacing_middle.toDouble(),
                            spacing_standard.toDouble(),
                            spacing_middle.toDouble(),
                            spacing_standard.toDouble()),
                        decoration: BoxDecoration(
                            color: Theme
                                .of(context)
                                .accentColor,
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))),
                        child: Text('Add',
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                Theme
                                    .of(context)
                                    .cardTheme
                                    .color)),
                      ),
                    )
                        : Container(
                      padding: EdgeInsets.fromLTRB(
                          spacing_middle.toDouble(),
                          spacing_standard.toDouble(),
                          spacing_middle.toDouble(),
                          spacing_standard.toDouble()),
                      child: Text('',
                          style: TextStyle(
                              fontSize: 14, color: white_color)),
                    ),
                  ],
                ).paddingOnly(
                    left: spacing_standard.toDouble(),
                    right: spacing_standard.toDouble(),
                    bottom: spacing_standard.toDouble())
              ],
            ),
          ),
        ],
      ),
      margin: EdgeInsets.all(8.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    //log('Counts ${appStore.count}');
    setInt(CARTCOUNT, appStore.count);

    var appLocalization = AppLocalizations.of(context);
    changeStatusColor(Theme
        .of(context)
        .primaryColor);

    Widget productList(List<ProductResponse> product) {
      return Container(
        height: 260,
        alignment: Alignment.centerLeft,
        child: ListView.builder(
          itemCount: product.length,
          padding: EdgeInsets.only(left: 8, right: 8),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, i) {
            return GestureDetector(
              onTap: () {
                builderResponse.productdetailview.layout == "layout1"
                    ? ProductDetailScreen(mProId: product[i].id).launch(context)
                    : ProductDetailsBuilderScreen(mProId: product[i].id)
                    .launch(context);
              },
              child: getProductWidget(
                product[i],
                context,
              ),
            );
          },
        ),
      );
    }

    Widget category =
    // Container(
    // height: 500,
    // child: GridView.builder(
    // padding: EdgeInsets.all(2),
    // scrollDirection: Axis.vertical,
    // shrinkWrap: true,
    // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //     crossAxisCount: 3, crossAxisSpacing: 3.0, mainAxisSpacing: 3.0),
    //  itemCount: mCategoryModel.length,
    // itemBuilder: (BuildContext context, int index) {
    //   return GestureDetector(
    //   onTap: () {
    //    ViewAllScreen(
    //     mCategoryModel[index].name,
    //    isCategory: true,
    //   categoryId: mCategoryModel[index].id,
    // ).launch(context);
    // },
    // child: Card(
    //   width: 150,
    //   elevation: BoxDecoration(
    //   borderRadius: BorderRadius.circular(4),
    //  ),

    //   child: Stack(
    //    children: [
    //     Container(
    //     decoration: BoxDecoration(
    //      borderRadius: BorderRadius.circular(4),
    //      image: DecorationImage(
    //       fit: BoxFit.fill,
    //      image: CachedNetworkImageProvider(mCategoryModel[
    //                    index]
    //                  .image !=
    //       null
    //         ? mCategoryModel[index].image.src
    //        : 'http://www.serviceji.com/wp-content/uploads/2020/08/Service-Ji-5-min.jpg'),
    //  )),
    //   ),
    //   Container(
    //    decoration: BoxDecoration(
    //      borderRadius: BorderRadius.circular(4),

    //     color: getColorFromHex(
    //       colorArray[index % colorArray.length],
    //  ).withOpacity(0.3),
    //        ),
    //     ),
    //    Text(
    //     mCategoryModel[index].name,
    //    maxLines: 2,
    //   textAlign: TextAlign.center,
    //   style: TextStyle(
    //     fontSize: 12,
    //     color: Colors.black,
    //   ),
    //  ),
    // ],
    //   ),
    // ),
    //.paddingRight(8),
    // );
    Container(
      height: 400,
      padding: EdgeInsets.all(18.0),
      child:
      Column(
        children: [
          Container(
            height: 50,
            alignment: Alignment.topLeft,
            child: Text(
              'What ServiceJi Offers?',
              textAlign: TextAlign.left,
              style: TextStyle(

                  fontSize: 16,
                  fontWeight: FontWeight.w700
              ),
            ),
          ),
          GridView.builder(

            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemCount: mCategoryModel.length,
            itemBuilder: (context, index) {
              var data = mCategoryModel[index];
              return GestureDetector(
                onTap: () {
                  ViewAllScreen(
                    mCategoryModel[index].name,
                    isCategory: true,
                    categoryId: mCategoryModel[index].id,
                  ).launch(context);
                },
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(0.0),
                        width: 80,
                        height: 80,
                        alignment: Alignment.center,
                        child: Image.network(
                          mCategoryModel[index].image.src,
                          height: 80,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 5),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text(mCategoryModel[index].name,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          //  Icon(
                          // Icons.keyboard_arrow_right,
                          // color: Colors.black,
                          //  size: 15,
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );

    Widget availableOfferAndDeal(String title, List<ProductResponse> product) {
      return Stack(
        children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0)),
                  color: Theme
                      .of(context)
                      .primaryColor),
              width: context.width(),
              height: context.height() * 0.62),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: boldTextStyle(
                          color: Colors.white, size: textSizeLargeMedium))
                      .paddingOnly(left: spacing_standard.toDouble()),
                  Container(
                      decoration: boxDecoration(context,
                          bgColor: Theme
                              .of(context)
                              .accentColor, radius: 5.0),
                      margin: EdgeInsets.only(right: spacing_middle.toDouble()),
                      child: Text(
                        builderResponse.dashboard.youMayLikeProduct.viewAll,
                        style: boldTextStyle(
                            color: Theme
                                .of(context)
                                .cardTheme
                                .color,
                            size: textSizeMedium),
                      ).paddingAll(spacing_standard.toDouble()).onTap(() {
                        if (title ==
                            builderResponse.dashboard.dealOfTheDay.title) {
                          ViewAllScreen(
                            title,
                            isSpecialProduct: true,
                            specialProduct: "deal_of_the_day",
                          ).launch(context);
                        } else if (title ==
                            appLocalization.translate('lbl_offer')) {
                          ViewAllScreen(
                            appLocalization.translate('lbl_offer'),
                            isSpecialProduct: true,
                            specialProduct: "offer",
                          ).launch(context);
                        } else {
                          ViewAllScreen(title);
                        }
                      })),
                ],
              ).paddingOnly(left: spacing_standard.toDouble()),
              Container(
                decoration: boxDecoration(
                  context,
                  radius: 5.0,
                ),
                margin: EdgeInsets.all(20.0),
                child: Container(
                  margin: EdgeInsets.all(8.0),
                  child: StaggeredGridView.countBuilder(
                    scrollDirection: Axis.vertical,
                    itemCount: product.length > 4 ? 4 : product.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () {
                          builderResponse.productdetailview.layout == "layout1"
                              ? ProductDetailScreen(mProId: product[i].id)
                              .launch(context)
                              : ProductDetailsBuilderScreen(
                              mProId: product[i].id)
                              .launch(context);
                        },
                        child: getProductWidget(product[i], context),
                      );
                    },
                    crossAxisCount: 2,
                    staggeredTileBuilder: (index) {
                      return StaggeredTile.fit(1);
                    },
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    /*gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                    ),*/
                  ),
                ),
              )
            ],
          ).paddingOnly(
            top: spacing_standard_new.toDouble(),
          ),
        ],
      );
    }

    Widget _slider({String title}) {
      return Container(
        height: 180,
        child: ListView.builder(
          padding: EdgeInsets.only(left: 16),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: mSliderModel.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  WebViewExternalProductScreen(
                      mExternal_URL: mSliderModel[index].url)
                      .launch(context);
                });
              },
              child: Container(
                  width: context.width() * 0.8,
                  margin: EdgeInsets.only(right: 16),
                  child: Image.network(
                    mSliderModel[index].image,
                    fit: BoxFit.fill,
                  ).cornerRadiusWithClipRRect(10.0)),
            );
          },
        ),
      );
    }

    Widget _newProduct({String title}) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Latest Services',
                  //builderResponse.dashboard.newProduct.title,
                  style: boldTextStyle(
                      color: Theme
                          .of(context)
                          .accentColor,
                      size: textSizeMedium)),
              Text(builderResponse.dashboard.newProduct.viewAll,
                  style: boldTextStyle(
                      color: Theme
                          .of(context)
                          .accentColor,
                      size: textSizeMedium))
                  .onTap(() {
                ViewAllScreen(
                  builderResponse.dashboard.newProduct.title,
                  isNewest: true,
                ).launch(context);
              }),
            ],
          )
              .paddingOnly(
              left: spacing_standard_new.toDouble(),
              right: spacing_standard_new.toDouble())
              .visible(mNewestProductModel.isNotEmpty),
          spacing_standard.height,
          productList(mNewestProductModel)
              .visible(mNewestProductModel.isNotEmpty),
        ],
      );
    }

    Widget _featureProduct({String title}) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Rated Services',
                  // builderResponse.dashboard.featureProduct.title,
                  style: boldTextStyle(
                      color: Theme
                          .of(context)
                          .textTheme
                          .headline6
                          .color,
                      size: textSizeMedium)),
              Text(builderResponse.dashboard.featureProduct.viewAll,
                  style: boldTextStyle(
                      color: Theme
                          .of(context)
                          .textTheme
                          .headline6
                          .color,
                      size: textSizeMedium))
                  .onTap(() {
                ViewAllScreen(
                  builderResponse.dashboard.featureProduct.title,
                  isFeatured: true,
                ).launch(context);
              }),
            ],
          )
              .paddingOnly(
              left: spacing_standard_new.toDouble(),
              right: spacing_standard_new.toDouble())
              .visible(mFeaturedProductModel.isNotEmpty),
          spacing_standard.height,
          productList(mFeaturedProductModel)
              .visible(mFeaturedProductModel.isNotEmpty),
        ],
      );
    }

    Widget _dealoftheday({String title}) {
      return Column(
        children: [
          availableOfferAndDeal(
              appLocalization.translate('lbl_deals_of_the_day'),
              mDealProductModel)
              .visible(mDealProductModel.isNotEmpty),
        ],
      );
    }

    Widget _bestSelling({String title}) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(builderResponse.dashboard.bestSaleProduct.title,
                  style: boldTextStyle(
                      color: Theme
                          .of(context)
                          .textTheme
                          .headline6
                          .color,
                      size: textSizeMedium)),
              Text(builderResponse.dashboard.bestSaleProduct.viewAll,
                  style: boldTextStyle(
                      color: Theme
                          .of(context)
                          .textTheme
                          .headline6
                          .color,
                      size: textSizeMedium))
                  .onTap(() {
                ViewAllScreen(
                  builderResponse.dashboard.bestSaleProduct.title,
                  isBestSelling: true,
                ).launch(context);
              }),
            ],
          )
              .paddingOnly(
              left: spacing_standard_new.toDouble(),
              right: spacing_standard_new.toDouble())
              .visible(mSellingProductModel.isNotEmpty),
          spacing_standard.height,
          productList(mSellingProductModel)
              .visible(mSellingProductModel.isNotEmpty),
        ],
      );
    }

    Widget _saleProduct({String title}) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(builderResponse.dashboard.saleProduct.title,
                  style: boldTextStyle(
                      color: Theme
                          .of(context)
                          .textTheme
                          .headline6
                          .color,
                      size: textSizeMedium)),
              Text(builderResponse.dashboard.saleProduct.viewAll,
                  style: boldTextStyle(
                      color: Theme
                          .of(context)
                          .textTheme
                          .headline6
                          .color,
                      size: textSizeMedium))
                  .onTap(() {
                ViewAllScreen(
                  builderResponse.dashboard.saleProduct.title,
                  isSale: true,
                ).launch(context);
              }),
            ],
          )
              .paddingOnly(
              left: spacing_standard_new.toDouble(),
              right: spacing_standard_new.toDouble())
              .visible(mSaleProductModel.isNotEmpty),
          spacing_standard.height,
          productList(mSaleProductModel).visible(mSaleProductModel.isNotEmpty),
        ],
      );
    }

    Widget _offer({String title}) {
      return Column(
        children: [
          availableOfferAndDeal(
              appLocalization.translate('lbl_offer'), mOfferProductModel)
              .visible(mOfferProductModel.isNotEmpty),
        ],
      );
    }

    Widget _suggested({String title}) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(builderResponse.dashboard.suggestionProduct.title,
                  style: boldTextStyle(
                      color: Theme
                          .of(context)
                          .textTheme
                          .headline6
                          .color,
                      size: textSizeMedium)),
              Text(builderResponse.dashboard.suggestionProduct.viewAll,
                  style: boldTextStyle(
                      color: Theme
                          .of(context)
                          .textTheme
                          .headline6
                          .color,
                      size: textSizeMedium))
                  .onTap(() {
                ViewAllScreen(
                  builderResponse.dashboard.suggestionProduct.title,
                  isSpecialProduct: true,
                  specialProduct: "suggested_for_you",
                ).launch(context);
              }),
            ],
          )
              .paddingOnly(
              left: spacing_standard_new.toDouble(),
              right: spacing_standard_new.toDouble())
              .visible(mSuggestedProductModel.isNotEmpty),
          spacing_standard.height,
          productList(mSuggestedProductModel)
              .visible(mSuggestedProductModel.isNotEmpty),
        ],
      );
    }

    Widget _youmaylike({String title}) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(builderResponse.dashboard.youMayLikeProduct.title,
                  style: boldTextStyle(
                      color: Theme
                          .of(context)
                          .textTheme
                          .headline6
                          .color,
                      size: textSizeMedium)),
              Text(builderResponse.dashboard.youMayLikeProduct.viewAll,
                  style: boldTextStyle(
                      color: Theme
                          .of(context)
                          .textTheme
                          .headline6
                          .color,
                      size: textSizeMedium))
                  .onTap(() {
                ViewAllScreen(
                  builderResponse.dashboard.youMayLikeProduct.title,
                  isSpecialProduct: true,
                  specialProduct: "you_may_like",
                ).launch(context);
              }),
            ],
          )
              .paddingOnly(
              left: spacing_standard_new.toDouble(),
              right: spacing_standard_new.toDouble())
              .visible(mYouMayLikeProductModel.isNotEmpty),
          spacing_standard.height,
          productList(mYouMayLikeProductModel)
              .visible(mYouMayLikeProductModel.isNotEmpty),
        ],
      );
    }

    Widget mSideMenu(var text, var icon, var tag) {
      return Container(
          padding: EdgeInsets.only(
              left: spacing_standard_new.toDouble(),
              right: spacing_standard_new.toDouble(),
              top: 12.0,
              bottom: 12.0),
          child: Row(
            children: [
              Image.asset(
                icon,
                height: 20,
                width: 20,
                color: Theme
                    .of(context)
                    .textTheme
                    .subtitle2
                    .color,
              ),
              SizedBox(
                width: 12.0,
              ),
              Text(
                text,
                style: primaryTextStyle(
                    color: Theme
                        .of(context)
                        .textTheme
                        .subtitle2
                        .color,
                    size: textSizeMedium),
              )
            ],
          )).onTap(() {
        launchNewScreen(context, tag);
      });
    }

    Widget body = SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
         // category,
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: builderResponse.dashboard == null
                ? 0
                : builderResponse.dashboard.sorting.length,
            itemBuilder: (_, index) {
              if (builderResponse.dashboard.sorting[index] == 'slider') {
                return _slider()
                    .visible(builderResponse.dashboard.sliderView.enable)
                    .paddingTop(16);
              }
              else if (builderResponse.dashboard.sorting[index] ==
                  'categories') {
                return category
                    .visible(builderResponse.dashboard.category.enable)
                    .paddingTop(8);
              }
              else if (builderResponse.dashboard.sorting[index] ==
                  'newest_product') {
                return _newProduct()
                    .visible(builderResponse.dashboard.newProduct.enable)
                    .paddingTop(8);
              } else if (builderResponse.dashboard.sorting[index] == 'vendor') {
                return mVendorWidget(context, mVendorModel)
                    .visible(builderResponse.dashboard.vendor.enable)
                    .paddingTop(8);
              } else if (builderResponse.dashboard.sorting[index] ==
                  'feature_products') {
                return _featureProduct()
                    .visible(builderResponse.dashboard.featureProduct.enable)
                    .paddingTop(8);
              } else if (builderResponse.dashboard.sorting[index] ==
                  'deal_of_the_day') {
                return _dealoftheday()
                    .visible(builderResponse.dashboard.dealOfTheDay.enable)
                    .paddingTop(8);
              } else if (builderResponse.dashboard.sorting[index] ==
                  'best_selling_product') {
                return _bestSelling()
                    .visible(builderResponse.dashboard.bestSaleProduct.enable)
                    .paddingTop(8);
              } else if (builderResponse.dashboard.sorting[index] ==
                  'sale_product') {
                return _saleProduct()
                    .visible(builderResponse.dashboard.saleProduct.enable)
                    .paddingTop(8);
              } else if (builderResponse.dashboard.sorting[index] == 'offer') {
                return _offer()
                    .visible(builderResponse.dashboard.offerProduct.enable)
                    .paddingTop(8);
              } else if (builderResponse.dashboard.sorting[index] ==
                  'suggested_for_you') {
                return _suggested()
                    .visible(builderResponse.dashboard.suggestionProduct.enable)
                    .paddingTop(8);
              } else if (builderResponse.dashboard.sorting[index] ==
                  'you_may_like') {
                return _youmaylike()
                    .visible(builderResponse.dashboard.youMayLikeProduct.enable)
                    .paddingTop(8);
              } else {
                return 0.height;
              }
            },
          ),
        ],
      ),
    );

    return SafeArea(
      child: Scaffold(
          backgroundColor: Theme
              .of(context)
              .scaffoldBackgroundColor,
          key: scaffoldKey,
          appBar: AppBar(
            backgroundColor: Theme
                .of(context)
                .primaryColor,
            leading: IconButton(
              onPressed: () {
                scaffoldKey.currentState.openDrawer();
              },
              icon: Icon(Icons.menu, size: 30, color: Colors.white),
            ),
            title: Text(
              appLocalization.translate('home'),

              style:
              boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  SearchScreen().launch(context);
                },
                icon: Icon(Icons.search_sharp, size: 30, color: Colors.white),
              ),
              mCart(context, mIsLoggedIn),
            ],
          ),

          drawer: Drawer(
            child: Container(
              color: Theme
                  .of(context)
                  .cardTheme
                  .color,
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        spacing_standard_new.height,
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              mProfileImage.isNotEmpty
                                  ? CircleAvatar(
                                  backgroundImage:
                                  NetworkImage(mProfileImage),
                                  radius: context.width() * 0.09)
                                  : CircleAvatar(
                                  backgroundImage:
                                  Image
                                      .asset(User_Profile)
                                      .image,
                                  radius: context.width() * 0.09),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(userName,
                                        style: boldTextStyle(
                                            color: Theme
                                                .of(context)
                                                .textTheme
                                                .headline6
                                                .color,
                                            size: textSizeMedium))
                                        .paddingOnly(
                                        top:
                                        spacing_control_half.toDouble())
                                        .visible(mIsLoggedIn),
                                    Text(userEmail,
                                        style: boldTextStyle(
                                            color: Theme
                                                .of(context)
                                                .textTheme
                                                .headline6
                                                .color,
                                            size: textSizeSMedium))
                                        .paddingOnly(
                                        top:
                                        spacing_control_half.toDouble())
                                        .visible(mIsLoggedIn),
                                  ],
                                ).paddingOnly(
                                    left: spacing_control.toDouble(),
                                    right: spacing_control.toDouble(),
                                    bottom: spacing_standard.toDouble()),
                              )
                            ],
                          ).paddingOnly(left: spacing_control.toDouble()),
                        )
                            .paddingOnly(
                            left: spacing_standard.toDouble(),
                            bottom: spacing_standard.toDouble(),
                            right: spacing_standard.toDouble())
                            .visible(mIsLoggedIn)
                            .onTap(() {
                          EditProfileScreen().launch(context);
                        }),
                        mSideMenu(appLocalization.translate('home'), ic_home,
                            HomeScreen.tag),
                        mSideMenu(appLocalization.translate('cart'),
                            ic_shopping_cart, MyCartScreen.tag)
                            .visible(mIsLoggedIn),
                        mSideMenu(appLocalization.translate('lbl_wish_list'),
                            ic_heart, WishListScreen.tag)
                            .visible(mIsLoggedIn),
                        mSideMenu(appLocalization.translate('lbl_vendors'),
                            ic_group_fill, VendorListScreen.tag)
                            .visible(mVendorModel.isNotEmpty),
                        mSideMenu(appLocalization.translate('lbl_categories'),
                            ic_category, CategoriesScreen.tag),
                        mSideMenu(appLocalization.translate('lbl_my_order'),
                            ic_order, OrderList.tag)
                            .visible(mIsLoggedIn),
                        mSideMenu(appLocalization.translate('lbl_change_pwd'),
                            ic_lock, ChangePasswordScreen.tag)
                            .visible(mIsLoggedIn),
                        Container(
                            padding: EdgeInsets.only(
                                left: spacing_standard_new.toDouble(),
                                right: spacing_standard_new.toDouble(),
                                top: 12.toDouble(),
                                bottom: 12.toDouble()),
                            child: Row(
                              children: [
                                Image.asset(ic_login,
                                    height: 20,
                                    width: 20,
                                    color: Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle2
                                        .color),
                                SizedBox(
                                  width: 12.0,
                                ),
                                Text(
                                  appLocalization.translate('btn_sign_out'),
                                  style: primaryTextStyle(
                                      color: Theme
                                          .of(context)
                                          .textTheme
                                          .subtitle2
                                          .color,
                                      size: textSizeMedium),
                                )
                              ],
                            )).onTap(() {
                          logout(context);
                        }).visible(mIsLoggedIn),
                        Container(
                            padding: EdgeInsets.only(
                                left: spacing_standard_new.toDouble(),
                                right: spacing_standard_new.toDouble(),
                                top: 12.toDouble(),
                                bottom: 12.toDouble()),
                            child: Row(
                              children: [
                                Image.asset(ic_mode,
                                    height: 20,
                                    width: 20,
                                    color: Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle2
                                        .color),
                                SizedBox(
                                  width: 12.0,
                                ),
                                Text(
                                  isSwitched == false
                                      ? appLocalization
                                      .translate('lbl_night_mode')
                                      : appLocalization
                                      .translate('lbl_light_mode'),
                                  style: primaryTextStyle(
                                      color: Theme
                                          .of(context)
                                          .textTheme
                                          .subtitle2
                                          .color,
                                      size: textSizeMedium),
                                )
                              ],
                            )).onTap(() {
                          setState(() {
                            if (appStore.isDarkModeOn == false) {
                              pref.setBool(IS_DARK_THEME, true);
                              appStore.toggleDarkMode(value: true);
                            } else {
                              pref.setBool(IS_DARK_THEME, false);
                              appStore.toggleDarkMode(value: false);
                            }
                            isSwitched = !isSwitched;
                          });
                        }),
                        mSideMenu(appLocalization.translate('lbl_sign_in_link'),
                            ic_login, SignInScreen.tag)
                            .visible(!mIsLoggedIn),
                        mSideMenu(appLocalization.translate('lbl_about'),
                            ic_information, AboutUsScreen.tag),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          body:
              RefreshIndicator(
                onRefresh: () {
                  return fetchDashboardData();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    body,
                    CircularProgressIndicator().center().visible(mIsLoading),
                  ],
                ),
              ),
          ),
    );
  }
}

