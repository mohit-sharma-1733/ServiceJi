import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/models/CategoryData.dart';
import 'package:ServiceJi/models/ProductResponse.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/screen/MyCartScreen.dart';
import 'package:ServiceJi/screen/ProductDetailsBuilderScreen.dart';
import 'package:ServiceJi/utils/CountState.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/common.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import 'package:ServiceJi/utils/shared_pref.dart';
import 'package:provider/provider.dart';

import 'ProductDetailScreen.dart';

import 'SignInScreen.dart';

class SubCategory extends StatefulWidget {
  static String tag = '/SubCategory';
  int categoryId = 0;
  String headerName = "";

  SubCategory(this.headerName, {this.categoryId});

  @override
  _SubCategoryState createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  var sortType = -1;
  var mProductModel = List<ProductResponse>();
  var isListViewSelected = false;
  var errorMsg = '';
  var scrollController = new ScrollController();
  bool isLoading = false;
  bool isLoadingMoreData = false;
  int page = 1;
  bool isLastPage = false;
  var mCategoryModel = List<Category>();
  int crossAxisCount = 2;
  bool mIsLoggedIn = false;
  SharedPreferences pref;

  @override
  void initState() {
    super.initState();
    init();
    fetchCategoryData();
    fetchSubCategoryData();

  }

  init() async {
    crossAxisCount = await getInt(CROSS_AXIS_COUNT, defaultValue: 2);
    pref = await getSharedPref();
    mIsLoggedIn = pref.getBool(IS_LOGGED_IN) ?? false;
    setState(() {});
  }

  scrollHandler() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !isLastPage) {
      page++;
      loadMoreCategoryData(page);
    }
  }

  Future loadMoreCategoryData(page) async {
    setState(() {
      isLoadingMoreData = true;
    });
    await getAllCategories(widget.categoryId, page,TOTAL_ITEM_PER_PAGE).then((res) {
      if (!mounted) return;
      setState(() {
        isLoadingMoreData = false;
        Iterable list = res;
        mProductModel.addAll(list.map((model) => ProductResponse.fromJson(model)).toList());
        isLastPage = false;
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLastPage = true;
        isLoadingMoreData = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  Future fetchCategoryData() async {
    setState(() {
      isLoading = true;
    });
    await getAllCategories(widget.categoryId, 1,TOTAL_ITEM_PER_PAGE).then((res) {
      if (!mounted) return;
      setState(() {
        Iterable mCategory = res;
        mProductModel = mCategory.map((model) => ProductResponse.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future fetchSubCategoryData() async {
    setState(() {
      isLoading = true;
    });
    await getSubCategories(widget.categoryId, page).then((res) {
      if (!mounted) return;
      setState(() {
        Iterable mCategory = res;
        mCategoryModel = mCategory.map((model) => Category.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Widget mSubCategory(List<Category> category) {
    return Container(
        margin: EdgeInsets.only(top: spacing_standard_new.toDouble()),
        height: MediaQuery.of(context).size.width * 0.12,
        child: ListView.builder(
          itemCount: category.length,
          padding: EdgeInsets.only(left: 16, right: 8),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, i) {
            return GestureDetector(
              onTap: () {
                SubCategory(
                  mCategoryModel[i].name,
                  categoryId: mCategoryModel[i].id,
                ).launch(context);
              },
              child: Container(
                margin: EdgeInsets.only(right: spacing_standard_new.toDouble()),
                decoration: boxDecoration(context, color: colorAccent, radius: spacing_middle.toDouble()),
                padding: EdgeInsets.fromLTRB(spacing_standard.toDouble(), spacing_standard.toDouble(), spacing_standard.toDouble(), spacing_standard.toDouble()),
                child: Row(
                  children: <Widget>[
                    Image.network(
                      category[i].image.src,
                      width: MediaQuery.of(context).size.width * 0.1,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(
                      width: spacing_control.toDouble(),
                    ),
                    Text(parseHtmlString(category[i].name), style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeSMedium)),
                  ],
                ),
              ),
            );
          },
        ));
  }

  Future addToCartApi(pro_id, BuildContext context, {returnExpected = false}) async {
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

  Widget getProductWidget(ProductResponse product, BuildContext context, {double width = 180}) {
    String value = '';

    String img = product.images.isNotEmpty ? product.images.first.src.validate() : '';
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
                  width: width,
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
                    decoration: BoxDecoration(color: redColor, borderRadius: BorderRadius.all(Radius.circular(4))),
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
            margin: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: primaryTextStyle(color: Theme.of(context).accentColor, size: textSizeSmall),
                  maxLines: 2,
                ).paddingOnly(left: spacing_standard.toDouble(), right: spacing_standard.toDouble()),
                spacing_control.height,
                Text(
                  product.name,
                  style: primaryTextStyle(color: Theme.of(context).textTheme.headline5.color, size: textSizeSMedium),
                  maxLines: 2,
                ).paddingOnly(left: spacing_standard.toDouble(), right: spacing_standard.toDouble()),
                spacing_middle.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        PriceWidget(price: product.regular_price.validate().toString(), size: 12, isLineThroughEnabled: true, color: Theme.of(context).textTheme.subtitle1.color)
                            .visible(product.sale_price.validate().isNotEmpty),
                        spacing_control_half.height,
                        PriceWidget(
                            price: product.sale_price.validate().isNotEmpty ? product.sale_price.toString() : product.price.validate(),
                            size: 14,
                            color: Theme.of(context).textTheme.subtitle2.color),
                      ],
                    ),
                    product.purchasable
                        ? GestureDetector(
                            onTap: () {
                              setState(() {});
                              if (product.type.validate() == "variable" && product.variations != null && product.variations.isNotEmpty) {
                                addToCartApi(product.variations[0], context);
                              } else {
                                addToCartApi(product.id, context);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(spacing_middle.toDouble(), spacing_standard.toDouble(), spacing_middle.toDouble(), spacing_standard.toDouble()),
                              decoration: BoxDecoration(color: Theme.of(context).accentColor, borderRadius: BorderRadius.all(Radius.circular(5))),
                              child: Text('Add', style: TextStyle(fontSize: 14, color: Theme.of(context).cardTheme.color)),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.fromLTRB(spacing_middle.toDouble(), spacing_standard.toDouble(), spacing_middle.toDouble(), spacing_standard.toDouble()),
                            child: Text('', style: TextStyle(fontSize: 14, color: Theme.of(context).cardTheme.color)),
                          ),
                  ],
                ).paddingOnly(left: spacing_standard.toDouble(), right: spacing_standard.toDouble(), bottom: spacing_standard.toDouble()),
              ],
            ),
          )
        ],
      ),
      margin: EdgeInsets.all(8.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    setInt(CARTCOUNT, appStore.count);
    changeStatusColor(primaryColor);
    return SafeArea(
      child: Scaffold(
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
            widget.headerName,
            style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
          ),
          actions: [
            IconButton(
              onPressed: () {
                layoutSelectionBottomSheet(context);
              },
              icon: Image.asset('images/serviceji/dashboard.png', height: 24, width: 24, color: Colors.white),
            ),
            mCart(context,mIsLoggedIn)
          ],
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: <Widget>[
              errorMsg.isEmpty
                  ? mProductModel.isNotEmpty
                      ? Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.max, children: <Widget>[
                          mSubCategory(mCategoryModel).visible(mCategoryModel.isNotEmpty),
                          StaggeredGridView.countBuilder(
                            scrollDirection: Axis.vertical,
                            itemCount: mProductModel.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.all(8),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  builderResponse.productdetailview.layout == "layout1"
                                      ? ProductDetailScreen(mProId: mProductModel[index].id).launch(context)
                                      : ProductDetailsBuilderScreen(mProId: mProductModel[index].id).launch(context);
                                },
                                child: getProductWidget(mProductModel[index], context),
                              );
                            },
                            crossAxisCount: crossAxisCount,
                            staggeredTileBuilder: (index) {
                              return StaggeredTile.fit(1);
                            },
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                          CircularProgressIndicator().visible(isLoadingMoreData).center()
                        ])
                      : CircularProgressIndicator().paddingAll(8).center()
                  : Center(child: Text(errorMsg)),
            ],
          ),
        ),
      ),
    );
  }

  void layoutSelectionBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return layoutSelection(
          crossAxisCount: crossAxisCount,
          callBack: (crossValue) {
            crossAxisCount = crossValue;
            setState(() {});
          },
        );
      },
    );
  }
}
