import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ServiceJi/models/ProductResponse.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/utils/shared_pref.dart';
import '../app_localizations.dart';
import '../main.dart';
import 'ProductDetailScreen.dart';
import 'ProductDetailsBuilderScreen.dart';
import 'SignInScreen.dart';

class VendorProfileScreen extends StatefulWidget {
  static String tag = '/VendorProfileScreen';
  final int mVendorId;

  VendorProfileScreen({Key key, this.mVendorId}) : super(key: key);

  @override
  _VendorProfileScreenState createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  VendorResponse mVendorModel;
  var mVendorProductList = List<ProductResponse>();
  bool isLoading = false;
  var mErrorMsg = '';

  @override
  void initState() {
    super.initState();
    fetchVendorProfile();
    fetchVendorProduct();
    changeStatusColor(primaryColor);
  }

  Future fetchVendorProfile() async {
    setState(() {
      isLoading = true;
    });
    await getVendorProfile(widget.mVendorId).then((res) {
      if (!mounted) return;
      VendorResponse methodResponse = VendorResponse.fromJson(res);
      setState(() {
        isLoading = false;
        mVendorModel = methodResponse;
        mErrorMsg = '';
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        mErrorMsg = 'No Products';
        print("VendorModels" + error.toString());
      });
    });
  }

  Future fetchVendorProduct() async {
    setState(() {
      isLoading = true;
    });
    await getVendorProduct(widget.mVendorId).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        mErrorMsg = '';
        Iterable list = res;
        mVendorProductList =
            list.map((model) => ProductResponse.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        mErrorMsg = 'No Products';
      });
    });
  }

  Widget getProductWidget(ProductResponse product, BuildContext context,
      {double width = 180}) {
    var productWidth = MediaQuery.of(context).size.width;
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
                  height: 135,
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
          Text(
            value.toString(),
            style: primaryTextStyle(
                color: Theme.of(context).accentColor, size: textSizeSmall),
            maxLines: 2,
          ).paddingOnly(
              left: spacing_standard.toDouble(),
              right: spacing_standard.toDouble()),
          spacing_control.height,
          Text(
            product.name,
            style: primaryTextStyle(
                color: Theme.of(context).textTheme.headline5.color,
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
                          price: product.regular_price.validate().toString(),
                          size: 12,
                          isLineThroughEnabled: true,
                          color: Theme.of(context).textTheme.subtitle1.color)
                      .visible(product.sale_price.validate().isNotEmpty),
                  spacing_control_half.height,
                  PriceWidget(
                      price: product.sale_price.validate().isNotEmpty
                          ? product.sale_price.toString()
                          : product.price.validate(),
                      size: 14,
                      color: Theme.of(context).textTheme.subtitle2.color),
                ],
              ),
              product.purchasable
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          isLoading = true;
                        });
                        if (product.type.validate() == "variable" &&
                            product.variations != null &&
                            product.variations.isNotEmpty) {
                          appStore.increment();
                          addToCartApi(product.variations[0], context);
                        } else {
                          appStore.increment();
                          addToCartApi(product.id, context);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                            spacing_middle.toDouble(),
                            spacing_standard.toDouble(),
                            spacing_middle.toDouble(),
                            spacing_standard.toDouble()),
                        decoration: BoxDecoration(
                            color: Theme.of(context).accentColor,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text('Add',
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).cardTheme.color)),
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
                              fontSize: 14,
                              color: Theme.of(context).cardTheme.color)),
                    ),
            ],
          ).paddingOnly(
              left: spacing_standard.toDouble(),
              right: spacing_standard.toDouble(),
              bottom: spacing_standard.toDouble())
        ],
      ),
      margin: EdgeInsets.all(8.0),
    );
  }

  Future addToCartApi(pro_id, BuildContext context,
      {returnExpected = false}) async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    setState(() {
      isLoading = true;
    });
    var request = {
      "pro_id": pro_id,
      "quantity": 1,
    };
    await addToCart(request).then((res) {
      setState(() {
        toast(res[msg]);
        isLoading = false;
        return returnExpected;
      });
    }).catchError((error) {
      setState(() {
        appStore.decrement();
        toast(error.toString());
        isLoading = false;
        return returnExpected;
      });
    });
  }

  Widget mOption(var value, var icon, var color, {maxLine = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Theme.of(context).accentColor,
          size: 20,
        ),
        8.width,
        Text(
          value,
          style: primaryTextStyle(
            color: color,
            size: textSizeMedium,
          ),
          maxLines: maxLine,
        ).expand()
      ],
    ).paddingOnly(left: 10, right: 16);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
    var addressText = "";
    if (mVendorModel != null) {
      if (mVendorModel.address != null) {
        if (mVendorModel.address.street_1.isNotEmpty && addressText.isEmpty) {
          addressText = mVendorModel.address.street_1;
        }
        if (mVendorModel.address.street_2.isNotEmpty) {
          if (addressText.isEmpty) {
            addressText = mVendorModel.address.street_2;
          } else {
            addressText += ", " + mVendorModel.address.street_2;
          }
        }

        if (mVendorModel.address.city.isNotEmpty) {
          if (addressText.isEmpty) {
            addressText = mVendorModel.address.city;
          } else {
            addressText += ", " + mVendorModel.address.city;
          }
        }
        if (mVendorModel.address.zip.isNotEmpty) {
          if (addressText.isEmpty) {
            addressText = mVendorModel.address.zip;
          } else {
            addressText += " - " + mVendorModel.address.zip;
          }
        }
        if (mVendorModel.address.state.isNotEmpty) {
          if (addressText.isEmpty) {
            addressText = mVendorModel.address.state;
          } else {
            addressText += ", " + mVendorModel.address.state;
          }
        }
        if (mVendorModel.address.country.isNotEmpty) {
          if (addressText.isEmpty) {
            addressText = mVendorModel.address.country;
          } else {
            addressText += ", " + mVendorModel.address.country;
          }
        }
      }
    }

    final body = mVendorModel != null
        ? Stack(
            children: <Widget>[
              SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  spacing_standard_new.height,
                  mOption(
                          mVendorModel.store_name != null
                              ? mVendorModel.store_name
                              : '',
                          Icons.store,
                          Theme.of(context).textTheme.subtitle2.color)
                      .visible(!mVendorModel.store_name.isEmptyOrNull),
                  spacing_middle.height,
                  mOption(
                          mVendorModel.phone != null ? mVendorModel.phone : '',
                          Icons.phone_android_rounded,
                          Theme.of(context).textTheme.subtitle1.color)
                      .visible(!mVendorModel.phone.isEmptyOrNull),
                  spacing_middle.height,
                  mOption(addressText, Icons.house_sharp,
                      Theme.of(context).textTheme.subtitle1.color,
                      maxLine: 3),
                  spacing_middle.height,
                  Divider(
                    color: view_color,
                    thickness: 4,
                  ).paddingOnly(left: 16, right: 16),
                  spacing_middle.height,
                  Text(
                    appLocalization.translate('lbl_product_list'),
                    style: boldTextStyle(
                        color: Theme.of(context).textTheme.subtitle2.color,
                        size: textSizeMedium),
                  ).paddingLeft(16).visible(mVendorProductList.isNotEmpty),
                  mVendorProductList.isNotEmpty
                      ? GridView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: mVendorProductList.length,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                builderResponse.productdetailview.layout ==
                                        "layout1"
                                    ? ProductDetailScreen(
                                            mProId:
                                                mVendorProductList[index].id)
                                        .launch(context)
                                    : ProductDetailsBuilderScreen(
                                            mProId:
                                                mVendorProductList[index].id)
                                        .launch(context);
                              },
                              child: getProductWidget(
                                  mVendorProductList[index], context),
                            );
                          },
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 2 == 1 ? 1.7 : 0.7,
                                  mainAxisSpacing: 4,
                                  crossAxisSpacing: 4),
                        )
                      : Text(
                          "No Product Found",
                          style: boldTextStyle(
                              color:
                                  Theme.of(context).textTheme.subtitle2.color,
                              size: textSizeMedium),
                        )
                ],
              )),
            ],
          )
        : SizedBox();

    final collapsedBody = NestedScrollView(
      body: SingleChildScrollView(
        child: (mVendorModel != null) ? body : Container(),
      ),
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).cardTheme.color,
            pinned: true,
            floating: true,
            expandedHeight: 250,
            actionsIconTheme:
                IconThemeData(color: Theme.of(context).accentColor),
            iconTheme: IconThemeData(color: Theme.of(context).accentColor),
            leading: new IconButton(
              icon: new Icon(
                Icons.arrow_back,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: mVendorModel.banner.isNotEmpty
                  ? Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        fit: BoxFit.fill,
                        image: CachedNetworkImageProvider(mVendorModel.banner),
                      )),
                    )
                  : SizedBox(),
              title: innerBoxIsScrolled
                  ? Text(mVendorModel != null ? mVendorModel.store_name : ' ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.headline6.color,
                        fontSize: 16.0,
                      ))
                  : Text(
                      '',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.headline6.color),
                    ),
            ),
          )
        ];
      },
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        alignment: Alignment.bottomLeft,
        children: <Widget>[
          collapsedBody.visible(mVendorModel != null),
          Center(child: CircularProgressIndicator()).visible(isLoading),
        ],
      ),
    );
  }
}
