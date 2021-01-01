import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/models/ProductResponse.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';

import '../app_localizations.dart';
import '../main.dart';
import 'VendorProfileScreen.dart';

class VendorListScreen extends StatefulWidget {
  static String tag = '/VendorListScreen';

  @override
  _VendorListScreenState createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  var mVendorList = List<VendorResponse>();
  bool isLoading = false;
  var mErrorMsg = '';

  @override
  void initState() {
    super.initState();
    fetchVendorData();
    changeStatusColor(primaryColor);
  }

  Future fetchVendorData() async {
    setState(() {
      isLoading = true;
    });
    await getVendor().then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable list = res;
        mVendorList = list.map((model) => VendorResponse.fromJson(model)).toList();
        mErrorMsg = '';
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        mErrorMsg = error.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
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
          appLocalization.translate('lbl_vendors'),
          style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
        ),
      ),
      body: mErrorMsg.isEmpty
          ? mVendorList.isNotEmpty
              ? Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    ListView.builder(
                      itemCount: mVendorList.length,
                      padding: EdgeInsets.only(left: 4, right: 4),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, i) {
                        return GestureDetector(
                          onTap: () {
                            VendorProfileScreen(mVendorId: mVendorList[i].id).launch(context);
                          },
                          child: getVendorWidget(
                            mVendorList[i],
                            context,
                          ),
                        );
                      },
                    ),
                    CircularProgressIndicator().center().visible(isLoading),
                  ],
                )
              : Center(child: CircularProgressIndicator())
          : Center(
              child: Text(
                mErrorMsg,
                style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color),
              ),
            ),
    );
  }
}
