import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/models/CategoryData.dart';
import 'package:ServiceJi/models/ProductAttribute.dart';
import 'package:ServiceJi/models/ProductResponse.dart';
import 'package:ServiceJi/models/SearchRequest.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/screen/ProductDetailsBuilderScreen.dart';
import 'package:ServiceJi/screen/SubCategoryScreen.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import 'package:ServiceJi/utils/shared_pref.dart';

import 'ProductDetailScreen.dart';
import 'SignInScreen.dart';

class ViewAllScreen extends StatefulWidget {
  static String tag = '/ViewAllScreen';
  String headerName = "";
  bool isFeatured = false;
  bool isNewest = false;
  bool isSpecialProduct = false;
  bool isBestSelling = false;
  bool isSale = false;
  bool isCategory = false;
  int categoryId = 0;
  String specialProduct = "";

  ViewAllScreen(this.headerName, {this.isFeatured, this.isSale, this.isCategory, this.categoryId, this.isNewest, this.isSpecialProduct, this.isBestSelling, this.specialProduct});

  @override
  ViewAllScreenState createState() => ViewAllScreenState();
}

class ViewAllScreenState extends State<ViewAllScreen> {
  List<ProductResponse> mProductModel = List<ProductResponse>();
  var isListViewSelected = false;
  var errorMsg = '';

  var scrollController = ScrollController();
  bool isLoading = false;
  bool isLoadingMoreData = false;
  int page = 1;
  bool isLastPage = false;
  var mCategoryModel = List<Category>();
  var mAttributes = List<ProductAttribute>();
  var searchRequest = SearchRequest();
  int noPages;
  int crossAxisCount = 2;
  bool mIsLoggedIn = false;
  SharedPreferences pref;
  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  init() async {
    var crossAxisCount1 = await getInt(CROSS_AXIS_COUNT, defaultValue: 2);
    pref = await getSharedPref();
    mIsLoggedIn = pref.getBool(IS_LOGGED_IN) ?? false;
    setState(() {
      crossAxisCount = crossAxisCount1;
    });
  }

  @override
  void initState() {
    super.initState();
    init();

    if (widget.isCategory == true) {
      fetchCategoryData();
      fetchSubCategoryData();
    } else {
      searchRequest.onSale = widget.isSale != null
          ? widget.isSale
              ? "_sale_price"
              : ""
          : "";
      searchRequest.featured = widget.isFeatured != null
          ? widget.isFeatured
              ? "product_visibility"
              : ""
          : "";
      searchRequest.bestSelling = widget.isBestSelling != null
          ? widget.isBestSelling
              ? "total_sales"
              : ""
          : "";
      searchRequest.newest = widget.isNewest != null
          ? widget.isNewest
              ? "newest"
              : ""
          : "";
      searchRequest.specialProduct = widget.isSpecialProduct != null
          ? widget.isSpecialProduct
              ? widget.specialProduct
              : ""
          : "";
      page = 1;
      getAllProducts();
      scrollController.addListener(() {
        scrollHandler();
      });
    }
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
    var productWidth = MediaQuery.of(context).size.width;
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
                        setState(() {
                          isLoading = true;
                        });
                        if (product.type.validate() == "variable" && product.variations != null && product.variations.isNotEmpty) {
                          appStore.increment();
                          addToCartApi(product.variations[0], context);
                        } else {
                          appStore.increment();
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
          ).paddingOnly(left: spacing_standard.toDouble(), right: spacing_standard.toDouble(), bottom: spacing_standard.toDouble())
        ],
      ),
      margin: EdgeInsets.all(8.0),
    );
  }

  scrollHandler() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && noPages > page && !isLoading) {
      page++;
      getAllProducts();
    }
  }

  Future loadMoreData(page) async {
    setState(() {
      isLoadingMoreData = true;
    });
    await getProducts(page).then((res) {
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

  Future loadMoreFeaturedData(page) async {
    setState(() {
      isLoadingMoreData = true;
    });
    await getFeaturedProducts(true, page).then((res) {
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

  Future loadMoreOnSaleData(page) async {
    setState(() {
      isLoadingMoreData = true;
    });
    await getOnSaleProducts(true, page).then((res) {
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

  Future loadMoreCategoryData(page) async {
    setState(() {
      isLoadingMoreData = true;
    });
    await getAllCategories(widget.categoryId, page,TOTAL_ITEM_PER_PAGE).then((res) {
      if (!mounted) return;
      setState(() {
        isLoadingMoreData = false;
        isLoading = false;

        Iterable list = res;
        mProductModel.addAll(list.map((model) => ProductResponse.fromJson(model)).toList());
        isLastPage = false;
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLastPage = true;
        isLoadingMoreData = false;
        isLoading = false;
      });
    });
  }

  Future fetchData() async {
    setState(() {
      isLoading = true;
    });
    await getProducts(1).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable list = res;
        mProductModel = list.map((model) => ProductResponse.fromJson(model)).toList();
      });
    }).catchError((error) {});
  }

  Future fetchOnSaleData() async {
    setState(() {
      isLoading = true;
    });
    await getOnSaleProducts(true, 1).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable list = res;
        mProductModel = list.map((model) => ProductResponse.fromJson(model)).toList();
      });
    }).catchError((error) {});
  }

  Future fetchFeaturedData() async {
    setState(() {
      isLoading = true;
    });
    await getFeaturedProducts(true, 1).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable list = res;
        mProductModel = list.map((model) => ProductResponse.fromJson(model)).toList();
      });
    }).catchError((error) {});
  }

  Future fetchCategoryData() async {
    setState(() {
      isLoading = true;
    });
    await getAllCategories(widget.categoryId, 1,TOTAL_ITEM_PER_PAGE).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;

        Iterable mCategory = res;
        mProductModel = mCategory.map((model) => ProductResponse.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }

  Future fetchSubCategoryData() async {
    setState(() {
      isLoading = true;
    });
    await getSubCategories(widget.categoryId, page).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable mCategory = res;
        mCategoryModel = mCategory.map((model) => Category.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }

  Widget mSubCategory(List<Category> category) {
    return Container(
        width: context.width(),
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
                decoration: boxDecoration(context, color: Theme.of(context).accentColor, radius: spacing_middle.toDouble()),
                padding: EdgeInsets.fromLTRB(spacing_standard.toDouble(), spacing_standard.toDouble(), spacing_standard.toDouble(), spacing_standard.toDouble()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    category[i].image != null
                        ? Image.network(
                            category[i].image.src.validate(),
                            width: MediaQuery.of(context).size.width * 0.1,
                          )
                        : Image.asset('images/serviceji/logowhite.png', width: MediaQuery.of(context).size.width * 0.1),
                    SizedBox(
                      width: spacing_control.toDouble(),
                    ),
                    Text(category[i].name, style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeSMedium)),
                  ],
                ),
              ),
            );
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    setInt(CARTCOUNT, appStore.count);
    changeStatusColor(primaryColor);
    Widget productsList = GridView.builder(
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, childAspectRatio: crossAxisCount == 1 ? 1.7 : 0.7, mainAxisSpacing: 4, crossAxisSpacing: 4),
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
          widget.headerName,
          style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
        ),
        actions: [
          IconButton(
            onPressed: () {
              layoutSelectionBottomSheet(context);
            },
            icon: Image.asset('images/serviceji/dashboard.png', height: 20, width: 20, color: Colors.white),
          ),
          mCart(context,mIsLoggedIn),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                mSubCategory(mCategoryModel).visible(widget.isCategory != null && widget.isCategory && mCategoryModel != null && mCategoryModel.isNotEmpty),
                productsList,
                CircularProgressIndicator().visible(isLoading && page > 1).center(),
              ],
            ),
          ),
          Center(child: CircularProgressIndicator().paddingAll(spacing_large.toDouble()).visible(isLoading && page == 1)),
          Center(child: Text(errorMsg)).visible(errorMsg.isEmpty && !isLoading),
        ],
      ),
    );
  }

  getAllProducts() async {
    setState(() {
      isLoading = true;
      searchRequest.page = page;
    });
    // log("searchRequest.toJson()");
    // log(searchRequest.toJson());
    await searchProduct(searchRequest.toJson()).then((res) {
      if (!mounted) return;
      log(res);
      setState(() {
        isLoading = false;
      });
      ProductListResponse listResponse = ProductListResponse.fromJson(res);
      setState(() {
        if (page == 1) {
          mProductModel.clear();
        }
        noPages = listResponse.num_of_pages;
        mProductModel.addAll(listResponse.data);
        isLoading = false;
        errorMsg = mProductModel.isEmpty ? 'No Data Found' : "";
      });
    }).catchError((error) {
      log(errorMsg);
      setState(() {
        isLoading = false;
        errorMsg = "No Data Found";
        if (page == 1) {
          mProductModel.clear();
        }
      });
    });
  }

  void layoutSelectionBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return layoutSelection(
          crossAxisCount: crossAxisCount,
          callBack: (crossvalue) {
            crossAxisCount = crossvalue;
            setState(() {});
          },
        );
      },
    );
  }
}
