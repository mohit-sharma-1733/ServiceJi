import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/models/WishListResponse.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import '../app_localizations.dart';
import 'ProductDetailScreen.dart';
import 'ProductDetailsBuilderScreen.dart';
import 'SearchScreen.dart';

class WishListScreen extends StatefulWidget {
  static String tag = '/WishListScreen';

  @override
  WishListScreenState createState() => WishListScreenState();
}

class WishListScreenState extends State<WishListScreen> {
  var mWishListModel = List<WishListResponse>();
  bool isLoading = false;
  var mErrorMsg = '';
  bool mIsLoggedIn = false;
  SharedPreferences pref;

  @override
  void initState() {
    super.initState();
    fetchWishListData();
    changeStatusColor(primaryColor);
  }

  init() async {
    pref = await getSharedPref();
    mIsLoggedIn = pref.getBool(IS_LOGGED_IN) ?? false;
  }

  Future fetchWishListData() async {
    setState(() {
      isLoading = true;
    });
    await getWishList().then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable list = res;
        mWishListModel =
            list.map((model) => WishListResponse.fromJson(model)).toList();
        mErrorMsg = '';
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        mErrorMsg = 'No Products';
      });
    });
  }

  Future addToCartApi(mProId) async {
    var removeWishListRequest = {
      'pro_id': mProId,
    };

    removeWishList(removeWishListRequest).then((res) {
      if (!mounted) return;
      var request = {
        'pro_id': mProId,
        'quantity': 1,
      };
      addToCart(request).then((res) {
        toast(res[msg]);
        fetchWishListData();
      }).catchError((error) {
        toast(error.toString());
        fetchWishListData();
      });
    }).catchError((error) {});
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
    Widget mWishList = GridView.builder(
      scrollDirection: Axis.vertical,
      itemCount: mWishListModel.length,
      shrinkWrap: true,
      padding: EdgeInsets.all(8),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            builderResponse.productdetailview.layout == "layout1"
                ? ProductDetailScreen(mProId: mWishListModel[index].proId)
                    .launch(context)
                : ProductDetailsBuilderScreen(
                        mProId: mWishListModel[index].proId)
                    .launch(context);
          },
          child: Container(
            height: 260,
            width: 180,
            margin: EdgeInsets.only(
                left: spacing_standard.toDouble(),
                right: spacing_standard.toDouble()),
            decoration: boxDecoration(context, showShadow: true, radius: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.network(
                    mWishListModel[index].full,
                    height: 100,
                    width: context.width(),
                    fit: BoxFit.contain,
                  )
                      .paddingOnly(top: spacing_middle.toDouble())
                      .visible(mWishListModel[index].full.isNotEmpty),
                ),
                spacing_standard_new.height,
                Column(
                  children: [
                    Text(
                      mWishListModel[index].name,
                      style: boldTextStyle(
                          color: Theme.of(context).textTheme.subtitle2.color,
                          size: textSizeMedium),
                      maxLines: 2,
                    ).paddingOnly(
                        left: spacing_standard.toDouble(),
                        right: spacing_standard.toDouble()),
                    spacing_standard.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: <Widget>[
                            PriceWidget(
                              price: mWishListModel[index].salePrice.isNotEmpty
                                  ? mWishListModel[index].salePrice.toString()
                                  : mWishListModel[index].price.toString(),
                              size: textSizeLargeMedium.toDouble(),
                              color:
                                  Theme.of(context).textTheme.subtitle2.color,
                            ),
                            PriceWidget(
                              price: mWishListModel[index].salePrice.isEmpty
                                  ? mWishListModel[index]
                                      .regularPrice
                                      .toString()
                                  : ''.toString(),
                              size: textSizeSMedium.toDouble(),
                              color:
                                  Theme.of(context).textTheme.subtitle1.color,
                              isLineThroughEnabled: true,
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.shopping_cart,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: () {
                            addToCartApi(mWishListModel[index].proId);
                          },
                        )
                      ],
                    ).paddingOnly(
                        left: spacing_control.toDouble(),
                        right: spacing_control.toDouble()),
                  ],
                )
              ],
            ),
          ),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 8,
      ),
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
          appLocalization.translate('lbl_wish_list'),
          style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
        ),
        actions: [
          IconButton(
            onPressed: () {
              SearchScreen().launch(context);
            },
            icon: Icon(Icons.search, size: 30, color: Colors.white),
          ),
          mCart(context, true)
        ],
      ),
      body: mErrorMsg.isEmpty
          ? mWishListModel.isNotEmpty
              ? Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    mWishList,
                    CircularProgressIndicator().center().visible(isLoading),
                  ],
                )
              : Center(child: CircularProgressIndicator())
          : Center(
              child: Text(
                mErrorMsg,
                style: primaryTextStyle(
                    color: Theme.of(context).textTheme.headline6.color),
              ),
            ),
    );
  }
}
