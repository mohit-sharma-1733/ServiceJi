import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:ServiceJi/models/ProductAttribute.dart';
import 'package:ServiceJi/models/ProductResponse.dart';
import 'package:ServiceJi/models/SearchRequest.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/screen/ProductDetailsBuilderScreen.dart';
import 'package:ServiceJi/utils/CountState.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import 'package:ServiceJi/utils/shared_pref.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import 'ProductDetailScreen.dart';
import 'SignInScreen.dart';

class SearchScreen extends StatefulWidget {
  static String tag = '/SearchScreen';

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  var mProductModel = List<ProductResponse>();
  var mAttributes = List<ProductAttribute>();
  var mTerms = List<Terms>();
  var mTermsModel = List<Terms>();
  bool isLoading = false;
  bool addingToCart = false;
  int page = 1;
  var mErrorMsg = '';
  var searchText = "";
  var isSearchDone = false;
  var controller = TextEditingController();
  var focusNode = FocusNode();
  var isAttributesLoaded = false;
  var searchRequest = SearchRequest();
  var scrollController = new ScrollController();
  int noPages;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      //here you have the changes of your textfield

      setState(() {
        searchText = controller.text;
      });
    });
    init();
  }

  @override
  void dispose() {
    super.dispose();
    changeStatusColor(primaryColor);
    scrollController.dispose();
  }

  init() async {
    changeStatusColor(primaryColor);
    // getAttributes();
    getAttributes();
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  void onTextChange(String value) async {
    log(value);
    setState(() {
      searchText = value;
      searchRequest.text = value;
      page = 1;
    });
    searchProducts();
  }

  scrollHandler() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && noPages > page && !isLoading) {
      page++;
      searchProducts();
    }
  }

  searchProducts() async {
    setState(() {
      isLoading = true;
    });
    var req = {"text": searchText, "attribute": searchRequest.attribute ?? [], "price": searchRequest.price ?? [], "page": page};
    log(searchRequest.toJson());
    await searchProduct(req).then((res) {
      if (!mounted) return;
      log(res);
      setState(() {
        isLoading = false;
      });
      ProductListResponse listResponse = ProductListResponse.fromJson(res);
      setState(() {
        isSearchDone = true;
        if (page == 1) {
          mProductModel.clear();
        }
        noPages = listResponse.num_of_pages;
        mProductModel.addAll(listResponse.data);
        isLoading = false;
        mErrorMsg = mProductModel.isEmpty ? 'No Data Found' : "";
      });
    }).catchError((error) {
      log(errorMsg);
      setState(() {
        isLoading = false;
        mErrorMsg = "No Data Found";
        isSearchDone = true;
        if (page == 1) {
          mProductModel.clear();
        }
      });
    });
  }

  Future addToCartApi(pro_id, BuildContext context, {returnExpected = false}) async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    setState(() {
      addingToCart = true;
    });
    var request = {
      "pro_id": pro_id,
      "quantity": 1,
    };
    await addToCart(request).then((res) {
      setState(() {
        toast(res[msg]);
        addingToCart = false;
        return returnExpected;
      });
    }).catchError((error) {
      setState(() {
        appStore.decrement();
        toast(error.toString());
        addingToCart = false;
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
          Stack(
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
          ).expand(),
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

  @override
  Widget build(BuildContext context) {
    setInt(CARTCOUNT, appStore.count);
    changeStatusColor(primaryColor);
    var appLocalization = AppLocalizations.of(context);
    Widget body = GridView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
      ),
      padding: EdgeInsets.all(8),
      physics: NeverScrollableScrollPhysics(),
      itemCount: mProductModel.length,
      itemBuilder: (_, index) {
        return GestureDetector(
          onTap: () {
            builderResponse.productdetailview.layout == "layout1"
                ? ProductDetailScreen(mProId: mProductModel[index].id).launch(context)
                : ProductDetailsBuilderScreen(mProId: mProductModel[index].id).launch(context);
          },
          child: getProductWidget(
            mProductModel[index],
            context,
          ),
        );
      },
    );

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: /*!isSearchDone
              ? */
              TextFormField(
                  autofocus: true,
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: onTextChange,
                  cursorColor: Colors.white,
                  style: secondaryTextStyle(color: Colors.white, size: 18),
                  decoration: InputDecoration(
                      hintText: appLocalization.translate('lbl_search'),
                      hintStyle: secondaryTextStyle(color: Colors.white, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.only(left: 0, right: 0)))
          /*: Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Text(
                    searchText,
                    style: secondaryTextStyle(color: colorAccent, size: 18),
                  )).onTap(() {
                  setState(() {
                    isSearchDone = false;
                  });
                })*/
          ,
          actions: <Widget>[
            /*IconButton(
              onPressed: () {
                setState(() {
                  isSearchDone = false;
                });
                FocusScope.of(context).requestFocus(focusNode);
              },
              icon: Icon(Icons.search,
                  size: 30, color: Theme.of(context).accentColor),
            ).visible(isSearchDone),*/
            IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  controller.clear();
                });
              },
            ).visible(searchText.isNotEmpty),
            IconButton(
              onPressed: () {
                if (!isAttributesLoaded) {
                  toast("Please Wait");
                  return;
                }
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  builder: (context) => FilterWidget(mTerms, (List<Map<String, Object>> attribute, List<int> price) {
                    setState(() {
                      searchRequest.attribute = attribute;
                      searchRequest.price = price;
                      page = 1;
                    });
                    searchProducts();
                  }),
                );
              },
              icon: Icon(Icons.filter_list, size: 24, color: Colors.white,),
            ),
          ],
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SafeArea(
            child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  body,
                  CircularProgressIndicator().paddingAll(spacing_standard_new.toDouble()).visible(isLoading && page > 1),
                ],
              ),
            ).visible(mProductModel.isNotEmpty),
            Center(child: CircularProgressIndicator()).visible(isLoading && page == 1 || addingToCart),
            Center(
                child: Text(
              mErrorMsg,
              style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: 20),
            )).visible(mErrorMsg.isNotEmpty && !isLoading && mProductModel.isEmpty),
          ],
        )));
  }

  void getAttributes() async {
    await getProductAttribute().then((res) {
      if (!mounted) return;
      ProductAttribute mAttributess = ProductAttribute.fromJson(res);
      var list = List<Terms>();
      mAttributess.attribute.forEach((element) {
        list.add(Terms(name: element.name, isParent: true, isSelected: false));
        element.terms.forEach((term) {
          list.add(term);
        });
      });
      setState(() {
        isAttributesLoaded = true;
        mTerms.addAll(list);
      });
    }).catchError((error) {
      log(error);
      setState(() {
        isAttributesLoaded = false;
      });
    });
  }
}
