import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ServiceJi/utils/common.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../app_localizations.dart';

class WebViewExternalProductScreen extends StatefulWidget {
  var mExternal_URL;

  WebViewExternalProductScreen({
    Key key,
    this.mExternal_URL,
  }) : super(key: key);

  @override
  _WebViewExternalProductScreenState createState() =>
      _WebViewExternalProductScreenState();
}

class _WebViewExternalProductScreenState
    extends State<WebViewExternalProductScreen> {
  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
    return Scaffold(
      appBar:
          appBars(context, appLocalization.translate('lbl_external_product')),
      body: Builder(builder: (context) {
        var mIsError = false;
        return WebView(
          initialUrl: widget.mExternal_URL,
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true,
          onPageFinished: (String url) {
            if (mIsError) return;
          },
          onWebResourceError: (s) {
            mIsError = true;
          },
        );
      }),
    );
  }
}
