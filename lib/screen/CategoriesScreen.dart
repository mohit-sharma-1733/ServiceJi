import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/models/CategoryData.dart';
import 'package:ServiceJi/models/LayoutTypeSelectModel.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/common.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import '../app_localizations.dart';
import 'ViewAllScreen.dart';

class CategoriesScreen extends StatefulWidget {
  static String tag = '/CategoriesScreen';

  @override
  CategoriesScreenState createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
  var mCategoryModel = List<Category>();
  var errorMsg = '';
  bool isLoading = false, isLastPage = false;
  int crossAxisCount = 2;
  int page = 1, noPages;
  var scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    init();
    fetchCategoryData();
    changeStatusColor(primaryColor);
  }

  init() async {
    crossAxisCount = await getInt(CATEGORY_CROSS_AXIS_COUNT, defaultValue: 2);
    setState(() {});
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  scrollHandler() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !isLoading) {
      page++;
      loadMoreData(page);
    }
  }

  Future fetchCategoryData() async {
    setState(() {
      isLoading = true;
    });
    await getCategories(1,TOTAL_CATEGORY_PER_PAGE).then((res) {
      if (!mounted) return;
      isLoading = false;
      setState(() {
        Iterable mCategory = res;
        mCategoryModel = mCategory.map((model) => Category.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        toast(error.toString());
      });
    });
  }

  Future loadMoreData(page) async {
    isLoading = true;
    setState(() {});
    await getCategories(page,TOTAL_CATEGORY_PER_PAGE).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable list = res;
        mCategoryModel.addAll(list.map((model) => Category.fromJson(model)).toList());
        isLastPage = false;
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLastPage = true;
        isLoading = false;
      });
    });
  }

  void layoutSelectionBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return LayoutSelectionCategory(
          crossAxisCount: crossAxisCount,
          callBack: (crossValue) {
            crossAxisCount = crossValue;
            setState(() {});
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    changeStatusColor(primaryColor);
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var h = context.height();
    var w = context.width();
    var appLocalization = AppLocalizations.of(context);
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
        actions: [
          IconButton(
            onPressed: () {
              layoutSelectionBottomSheet(context);
            },
            icon: Image.asset('images/serviceji/dashboard.png', height: 20, width: 20, color: Colors.white),
          ),
        ],
        title: Text(
          appLocalization.translate('lbl_categories'),
          style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: mCategoryModel.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        ViewAllScreen(
                          mCategoryModel[index].name,
                          isCategory: true,
                          categoryId: mCategoryModel[index].id,
                        ).launch(context);
                      },
                      child: Container(
                        decoration: boxDecoration(context, showShadow: true, radius: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: mCategoryModel[index].image != null
                                  ? Image.network(mCategoryModel[index].image.src, height: h * 0.1, width: w, fit: BoxFit.contain)
                                      .paddingOnly(top: spacing_middle.toDouble(), left: spacing_middle.toDouble(), right: spacing_middle.toDouble())
                                  : Image.asset('images/serviceji/logowhite.png', height: 100, width: w, fit: BoxFit.contain),
                            ),
                            Text(parseHtmlString(mCategoryModel[index].name),
                                    textAlign: TextAlign.center, style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium), maxLines: 2)
                                .paddingOnly(top: spacing_middle.toDouble(), bottom: spacing_middle.toDouble(), left: spacing_standard.toDouble(), right: spacing_standard.toDouble()),
                          ],
                        ),
                      ),
                    );
                  },
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, childAspectRatio: crossAxisCount != 1 ? 0.9 : 1.9, mainAxisSpacing: 16, crossAxisSpacing: 16),
                ),
                CircularProgressIndicator().center().visible(isLoading && page > 1),
                50.height,
              ],
            ),
          ),
          Center(child: CircularProgressIndicator().visible(isLoading && page == 1)),
        ],
      ),
    );
  }
}

class LayoutSelectionCategory extends StatefulWidget {
  final int crossAxisCount;
  final Function callBack;

  LayoutSelectionCategory({this.crossAxisCount, this.callBack});
  @override
  _LayoutSelectionCategoryState createState() => _LayoutSelectionCategoryState();
}

class _LayoutSelectionCategoryState extends State<LayoutSelectionCategory> {
  List<LayoutTypesSelection> select = [];
  int crossvalue;

  @override
  void initState() {
    super.initState();
    init();
    crossvalue = widget.crossAxisCount;
  }

  init() async {
    select.clear();
    select.add(LayoutTypesSelection(image: 'images/serviceji/list.png', isSelected: false));
    select.add(LayoutTypesSelection(image: 'images/serviceji/twoGrid.png', isSelected: false));
    select.add(LayoutTypesSelection(image: 'images/serviceji/threegrid.png', isSelected: false));
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LAYOUTS',
            style: boldTextStyle(size: 18,color: Colors.white),
          ),
          10.height,
          Container(
            height: 45,
            child: ListView.builder(
              itemCount: select == null ? 0 : select.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: boxDecorationWithRoundedCorners(
                        borderRadius: BorderRadius.circular(10), backgroundColor: select[index].isSelected ? Colors.black54.withOpacity(0.2) : Colors.white.withOpacity(0.2)),
                    child: IconButton(
                      icon: Image.asset(
                        select[index].image,
                        height: 24,
                        width: 24,
                        color: select[index].isSelected ? Colors.black : Colors.white,
                      ),
                      onPressed: () async {
                        init();
                        select[index].isSelected = !select[index].isSelected;
                        setState(() {});
                        if (index == 0)
                          crossvalue = 1;
                        else if (index == 1)
                          crossvalue = 2;
                        else if (index == 2)
                          crossvalue = 3;
                        else if (index == 3)
                          crossvalue = 4;
                        else
                          crossvalue = 2;

                        setInt(CATEGORY_CROSS_AXIS_COUNT, crossvalue);

                        widget.callBack(crossvalue);
                        finish(context);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
