import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:ServiceJi/models/ProductModel.dart';
import 'package:ServiceJi/models/ProductReviewModel.dart';
import 'package:ServiceJi/network/rest_apis.dart';

import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/common.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_localizations.dart';

class ReviewScreen extends StatefulWidget {
  static String tag = '/ReviewScreen';
  final mProductId;

  ReviewScreen({Key key, this.mProductId}) : super(key: key);

  @override
  ReviewScreenState createState() => ReviewScreenState();
}

class ReviewScreenState extends State<ReviewScreen> {
  List<ProductModel> product = List();
  var primaryColor;
  SharedPreferences pref;
  bool mIsLoggedIn = false;
  var mReviewModel = List<ProductReviewModel>();
  var mErrorMsg = '';
  var mUserEmail = '';
  var ratings = 0.0;
  var reviewCont = TextEditingController();
  var fiveStars = 0;
  var fourStars = 0;
  var threeStars = 0;
  var twoStars = 0;
  var oneStars = 0;
  double avgRating = 0.0;
  var fiveStarPercent = 0.0;
  var fourPercent = 0.0;
  var threePercent = 0.0;
  var twoPercent = 0.0;
  var onePercent = 0.0;
  bool mIsLoading = false;
  double isUpdate = 0.0;

  @override
  void initState() {
    super.initState();
    fetchData();
    getPrefs();
  }

  void getPrefs() async {
    pref = await getSharedPref();
    mIsLoggedIn = await isLoggedIn();
    primaryColor = await getThemeColor();
    setState(() {});
    if (await getBool(IS_LOGGED_IN)) {
      mUserEmail = await getString(USER_EMAIL);
    }
  }

  Future fetchData() async {
    setState(() {
      mIsLoading = true;
    });
    await getProductReviews(widget.mProductId).then((res) {
      if (!mounted) return;
      setState(() {
        mIsLoading = false;
        Iterable list = res;
        mReviewModel = list.map((model) => ProductReviewModel.fromJson(model)).toList();
        if (mReviewModel.isEmpty) {
          mErrorMsg = 'No Reviews';
          fiveStars = 0;
          fourStars = 0;
          threeStars = 0;
          twoStars = 0;
          oneStars = 0;
          avgRating = 0.0;
          fiveStarPercent = 0.0;
          fourPercent = 0.0;
          threePercent = 0.0;
          twoPercent = 0.0;
          onePercent = 0.0;
        } else {
          mErrorMsg = '';
          setReviews();
        }
      });
    }).catchError((error) {
      setState(() {
        mErrorMsg = error;
        mIsLoading = false;
      });
    });
  }

  Future postReviewApi(product_id, review, rating) async {
    var request = {'product_id': product_id, 'reviewer': pref.getString(USERNAME), 'reviewer_email': pref.getString(USER_EMAIL), 'review': review, 'rating': rating};
    setState(() {
      mIsLoading = true;
    });
    postReview(request).then((res) {
      if (!mounted) return;
      finish(context); // Dismiss Dialog
      setState(() {
        mIsLoading = false;
        mReviewModel.clear(); // T
      });
      fetchData();
    }).catchError((error) {
      setState(() {
        mIsLoading = false;
        toast(error);
      });
    });
  }

  Future updateReviewApi(product_id, review, rating, review_id) async {
    var request = {'product_id': product_id, 'reviewer': pref.getString(USERNAME), 'reviewer_email': pref.getString(USER_EMAIL), 'review': review, 'rating': rating};
    setState(() {
      mIsLoading = true;
    });
    updateReview(review_id, request).then((res) {
      if (!mounted) return;
      finish(context); // Dismiss Dialog

      setState(() {
        mIsLoading = false;
        mReviewModel.clear(); // T
        fetchData();
      });
    }).catchError((error) {
      setState(() {
        mIsLoading = false;
        toast(error);
      });
    });
  }

  Future deleteReviewApi(review_id) async {
    if (!accessAllowed) {
      toast(demoPurposeMsg);
      return;
    }
    setState(() {
      mIsLoading = true;
    });
    deleteReview(review_id).then((res) {
      if (!mounted) return;
      setState(() {
        mIsLoading = false;
        toast(res[msg]);
        fetchData();
      });
    }).catchError((error) {
      setState(() {
        mIsLoading = false;
        fetchData();
      });
    });
  }

  Future setReviews() async {
    if (mReviewModel.isEmpty) return;

    var fiveStar = 0;
    var fourStar = 0;
    var threeStar = 0;
    var twoStar = 0;
    var oneStar = 0;

    var totalRatings = 0;

    mReviewModel.forEach((item) {
      if (item.rating == 1) {
        oneStar++;
      } else if (item.rating == 2) {
        twoStar++;
      } else if (item.rating == 3) {
        threeStar++;
      } else if (item.rating == 4) {
        fourStar++;
      } else if (item.rating == 5) {
        fiveStar++;
      }
    });
    if (fiveStar == 0 && fourStar == 0 && threeStar == 0 && twoStar == 0 && oneStar == 0) {
      return;
    }
    setState(() {
      fiveStars = fiveStar;
      fourStars = fourStar;
      threeStars = threeStar;
      twoStars = twoStar;
      oneStars = oneStar;

      totalRatings = fiveStar + fourStar + threeStar + twoStar + oneStar;

      var mAvgRating = (5 * fiveStar + 4 * fourStar + 3 * threeStar + 2 * twoStar + 1 * oneStar) / (totalRatings);
      avgRating = double.parse(mAvgRating.toStringAsPrecision(2)).toDouble();

      fiveStarPercent = calculateRatings(totalRatings, fiveStar);
      fourPercent = calculateRatings(totalRatings, fourStar);
      threePercent = calculateRatings(totalRatings, threeStar);
      twoPercent = calculateRatings(totalRatings, twoStar);
      onePercent = calculateRatings(totalRatings, oneStar);
    });
  }

  double calculateRatings(total, starCount) {
    if (starCount < 1) return 0.0;
    var a = total / starCount;
    var b = a * 10;
    var c = b / 100;
    var d = 1.0 - c;
    return d;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);

    void onUpdateSubmit(review, rating, reviewId) async {
      if (accessAllowed) {
        updateReviewApi(widget.mProductId, review, rating, reviewId);
      } else {
        toast(demoPurposeMsg);
      }
    }

    Widget body = Container(
      padding: EdgeInsets.all(5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(appLocalization.translate('lbl_ratings'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.headline6.color)),
            GestureDetector(
              onTap: () async {
                await checkLogin(context).then((value) {
                  if (value)
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                        /*insetPadding: EdgeInsets.fromLTRB(
                            spacing_standard_new.toDouble(),
                            0,
                            spacing_standard_new.toDouble(),
                            0),*/
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(spacing_middle.toDouble()),
                        ),
                        elevation: 0.0,
                        backgroundColor: Colors.transparent,
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: boxDecoration(context, color: white_color, radius: 10.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                // To make the card compact
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(appLocalization.translate('hint_review').toUpperCase(), style: boldTextStyle(color: blackColor, size: 16)),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          color: black,
                                          size: 22,
                                        ),
                                      )
                                    ],
                                  ).paddingOnly(
                                    left: spacing_standard_new.toDouble(),
                                  ),
                                  Divider(),
                                  TextFormField(
                                    controller: reviewCont,
                                    maxLines: 8,
                                    minLines: 1,
                                    keyboardType: TextInputType.multiline,
                                    style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color),
                                    decoration: InputDecoration(hintText: 'Review'),
                                  ).paddingOnly(
                                    left: spacing_standard_new.toDouble(),
                                    right: spacing_standard_new.toDouble(),
                                  ),
                                  20.height,
                                  RatingBar(
                                    initialRating: 0,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      ratings = rating;
                                    },
                                  )
                                      .paddingOnly(
                                        left: spacing_standard_new.toDouble(),
                                        right: spacing_standard_new.toDouble(),
                                      )
                                      .center(),
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: RaisedButton(
                                        color: colorAccent,
                                        onPressed: () {
                                          if (!accessAllowed) {
                                            toast("Sorry");
                                            return;
                                          }
                                          setState(() {
                                            if (ratings < 1) {
                                              toast('Please Rate');
                                            } else if (reviewCont.text.isEmpty) {
                                              toast('Please Review');
                                            } else {
                                              mIsLoading = true;
                                              if (accessAllowed) {
                                                postReviewApi(widget.mProductId, reviewCont.text, ratings);
                                              } else {
                                                toast(demoPurposeMsg);
                                              }
                                            }
                                          });
                                        },
                                        child: Text(
                                          appLocalization.translate('lbl_submit'),
                                          style: primaryTextStyle(size: 16, color: white_color),
                                        ),
                                      )).paddingAll(spacing_standard_new.toDouble()),
                                ],
                              ),
                            )),
                      ),
                    );
                });
              },
              child: Container(
                decoration: boxDecoration(context, color: colorAccent, radius: spacing_control.toDouble()),
                padding: EdgeInsets.fromLTRB(spacing_standard_new.toDouble(), 6.0, spacing_standard_new.toDouble(), 6.0),
                child: Text(appLocalization.translate('lbl_rate_now'), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
        SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardTheme.color),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    Text(avgRating.toString(), style: boldFonts(color: Theme.of(context).textTheme.headline6.color, size: 20)),
                    Icon(Icons.star, color: primaryColor, size: 22)
                  ]),
                ],
              ),
            ),
          ),
          SizedBox(width: spacing_standard.toDouble()),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '5',
                    style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color),
                  ),
                  SizedBox(
                    width: spacing_control_half.toDouble(),
                  ),
                  Icon(Icons.star, color: primaryColor, size: 14),
                  SizedBox(
                    width: spacing_standard.toDouble(),
                  ),
                  LinearPercentIndicator(
                    backgroundColor: viewLineColor,
                    width: 150.0,
                    animateFromLastPercent: true,
                    animation: true,
                    lineHeight: 8.0,
                    percent: fiveStarPercent,
                    progressColor: Color(0xFF66953A),
                  ),
                  SizedBox(
                    width: spacing_standard.toDouble(),
                  ),
                  Text(
                    fiveStars.toString(),
                    style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color),
                  ),
                ],
              ),
              spacing_control.height,
              Row(
                children: [
                  Text(
                    '4',
                    style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color),
                  ),
                  SizedBox(
                    width: spacing_control_half.toDouble(),
                  ),
                  Icon(Icons.star, color: primaryColor, size: 14),
                  SizedBox(
                    width: spacing_standard.toDouble(),
                  ),
                  LinearPercentIndicator(
                    backgroundColor: viewLineColor,
                    width: 150.0,
                    animation: true,
                    animateFromLastPercent: true,
                    lineHeight: 8.0,
                    percent: fourPercent,
                    progressColor: Color(0xFF66953A),
                  ),
                  SizedBox(
                    width: spacing_standard.toDouble(),
                  ),
                  Text(
                    fourStars.toString(),
                    style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color),
                  ),
                ],
              ),
              spacing_control.height,
              Row(
                children: [
                  Text(
                    '3',
                    style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color),
                  ),
                  SizedBox(
                    width: spacing_control_half.toDouble(),
                  ),
                  Icon(Icons.star, color: primaryColor, size: 14),
                  SizedBox(
                    width: spacing_standard.toDouble(),
                  ),
                  LinearPercentIndicator(
                    width: 150.0,
                    lineHeight: 8.0,
                    animation: true,
                    animateFromLastPercent: true,
                    backgroundColor: viewLineColor,
                    percent: threePercent,
                    progressColor: yellowColor,
                  ),
                  SizedBox(
                    width: spacing_standard.toDouble(),
                  ),
                  Text(
                    threeStars.toString(),
                    style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color),
                  ),
                ],
              ),
              spacing_control.height,
              Row(
                children: [
                  Text(
                    '2',
                    style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color),
                  ),
                  SizedBox(
                    width: spacing_control_half.toDouble(),
                  ),
                  Icon(Icons.star, color: primaryColor, size: 14),
                  SizedBox(
                    width: spacing_standard.toDouble(),
                  ),
                  LinearPercentIndicator(
                    width: 150.0,
                    lineHeight: 8.0,
                    animation: true,
                    percent: twoPercent,
                    animateFromLastPercent: true,
                    backgroundColor: viewLineColor,
                    progressColor: yellowColor,
                  ),
                  SizedBox(
                    width: spacing_standard.toDouble(),
                  ),
                  Text(
                    twoStars.toString(),
                    style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color),
                  ),
                ],
              ),
              spacing_control.height,
              Row(
                children: [
                  Text(
                    '1',
                    style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color),
                  ),
                  SizedBox(
                    width: spacing_control_half.toDouble(),
                  ),
                  Icon(Icons.star, color: primaryColor, size: 14),
                  SizedBox(
                    width: spacing_standard.toDouble(),
                  ),
                  LinearPercentIndicator(
                    width: 150.0,
                    animateFromLastPercent: true,
                    lineHeight: 8.0,
                    animation: true,
                    percent: onePercent,
                    backgroundColor: viewLineColor,
                    progressColor: redColor,
                  ),
                  SizedBox(
                    width: spacing_standard.toDouble(),
                  ),
                  Text(
                    oneStars.toString(),
                    style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color),
                  ),
                ],
              )
            ],
          ),
        ]),
        SizedBox(height: 20),
        Divider(height: 1),
        SizedBox(height: 10),
        Text(appLocalization.translate('lbl_reviews'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Theme.of(context).textTheme.headline6.color)),
        SizedBox(height: 10)
      ]),
    );

    Widget listView = ListView.separated(
        separatorBuilder: (context, index) {
          return Divider();
        },
        shrinkWrap: true,
        reverse: true,
        itemCount: mReviewModel.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                      decoration: BoxDecoration(
                          color: mReviewModel[index].rating == 1
                              ? redColor
                              : mReviewModel[index].rating == 2
                                  ? yellowColor
                                  : mReviewModel[index].rating == 3
                                      ? yellowColor
                                      : Color(0xFF66953A),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            mReviewModel[index].rating.toString(),
                            style: TextStyle(color: whiteColor),
                          ),
                          SizedBox(
                            width: spacing_control.toDouble(),
                          ),
                          Icon(Icons.star_border, size: 16, color: whiteColor)
                        ],
                      ),
                    ),
                    SizedBox(
                      width: spacing_standard.toDouble(),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mReviewModel[index].reviewer, style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color, size: 16)),
                        Text(reviewConvertDate(mReviewModel[index].dateCreated), style: TextStyle(color: Theme.of(context).textTheme.subtitle2.color, fontSize: 16)),
                        5.height,
                        Text(parseHtmlString(mReviewModel[index].review), style: TextStyle(color: Theme.of(context).textTheme.subtitle2.color, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                mUserEmail == mReviewModel[index].reviewerEmail
                    ? PopupMenuButton<int>(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 1,
                            child: Text("Update"),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: Text("Delete"),
                          ),
                        ],
                        initialValue: 2,
                        onSelected: (value) async {
                          if (value == 1) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => Dialog(
                                /*insetPadding: EdgeInsets.fromLTRB(
                                    spacing_standard_new.toDouble(),
                                    0,
                                    spacing_standard_new.toDouble(),
                                    0),*/
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(spacing_middle.toDouble()),
                                ),
                                elevation: 0.0,
                                backgroundColor: Theme.of(context).cardTheme.color,
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: boxDecoration(context, color: white_color, radius: 10.0),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        // To make the card compact
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(appLocalization.translate('hint_review'), style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: 16)),
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.pop(context, true);
                                                },
                                                icon: Icon(
                                                  Icons.close,
                                                  color: Theme.of(context).textTheme.headline6.color,
                                                  size: 18,
                                                ),
                                              )
                                            ],
                                          ).paddingOnly(
                                            left: spacing_standard_new.toDouble(),
                                          ),
                                          Divider(),
                                          TextFormField(
                                            controller: reviewCont,
                                            maxLines: 5,
                                            minLines: 2,
                                            decoration: InputDecoration(hintText: 'Review'),
                                          ).paddingOnly(
                                            left: spacing_standard_new.toDouble(),
                                            right: spacing_standard_new.toDouble(),
                                          ),
                                          SizedBox(height: 20),
                                          RatingBar(
                                            initialRating: 0,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (rating) {
                                              ratings = rating;
                                            },
                                          ).paddingOnly(
                                            left: spacing_standard_new.toDouble(),
                                            right: spacing_standard_new.toDouble(),
                                          ),
                                          Container(
                                              width: MediaQuery.of(context).size.width,
                                              child: RaisedButton(
                                                color: colorAccent,
                                                onPressed: () {
                                                  if (!accessAllowed) {
                                                    toast("Sorry");
                                                    return;
                                                  }
                                                  if (ratings < 1) {
                                                    toast('Please Rate');
                                                  } else if (reviewCont.text.isEmpty) {
                                                    toast('Please Review');
                                                  } else {
                                                    onUpdateSubmit(reviewCont.text, ratings, mReviewModel[index].id);
                                                  }
                                                },
                                                child: Text(
                                                  appLocalization.translate('lbl_submit'),
                                                  style: primaryTextStyle(size: 16, color: white_color),
                                                ),
                                              )).paddingAll(spacing_standard_new.toDouble()),
                                        ],
                                      ),
                                    )),
                              ),
                            );
                          } else {
                            ConfirmAction res = await showConfirmDialogs(context, 'Are you sure want to remove?', 'Yes', 'Cancel');
                            if (res == ConfirmAction.ACCEPT) {
                              setState(() {
                                mIsLoading = true;
                              });
                              deleteReviewApi(mReviewModel[index].id);
                            }
                          }
                        },
                      )
                    : Container(),
              ],
            ),
          );
        });

    return WillPopScope(
      onWillPop: () async {
        isUpdate = avgRating;

        finish(context, isUpdate);
        return false;
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            leading: IconButton(
              color: Colors.white,
              onPressed: () {
                finish(context);
              },
              icon: Icon(Icons.arrow_back, size: 25),
            ),
            title: Text(
              appLocalization.translate('lbl_reviews'),
              style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                body,
                mErrorMsg.isEmpty
                    ? mReviewModel.isNotEmpty
                        ? SingleChildScrollView(physics: BouncingScrollPhysics(), child: listView)
                        : CircularProgressIndicator().center().visible(mIsLoading)
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            mErrorMsg,
                            style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color),
                          ),
                        ),
                      ),
                25.height
              ],
            ),
          )),
    );
  }
}
