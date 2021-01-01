import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/common.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPaymentScreen extends StatefulWidget {
  static String tag = '/WebViewPaymentScreen';
  String checkoutUrl;

  WebViewPaymentScreen({this.checkoutUrl});

  @override
  WebViewPaymentScreenState createState() => WebViewPaymentScreenState();
}

class WebViewPaymentScreenState extends State<WebViewPaymentScreen> {
  var mIsError = false;
  var mIsLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: appBars(context, 'Payment'),
      body: Stack(
        children: [
          WebView(
            initialUrl: widget.checkoutUrl,
            javascriptMode: JavascriptMode.unrestricted,
            gestureNavigationEnabled: true,
            onPageFinished: (String url) {
              if (mIsError) return;
              if (url.contains('checkout/order-received')) {
                mIsLoading = true;
                toast('Order placed successfully');
                appStore.setCount(0);
                Navigator.pop(context, true);
              } else {
                mIsLoading = false;
              }
            },
            onWebResourceError: (s) {
              mIsError = true;
            },
          ),
          Center(child: CircularProgressIndicator()).visible(mIsLoading)
        ],
      ),
    );
  }
}
