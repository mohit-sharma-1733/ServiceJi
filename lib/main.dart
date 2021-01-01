import 'dart:convert';

import 'package:ServiceJi/screen/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:ServiceJi/Store/AppStore.dart';
import 'package:ServiceJi/app_localizations.dart';
import 'package:ServiceJi/app_theme.dart';
import 'package:ServiceJi/models/BuilderResponse.dart';
import 'package:ServiceJi/screen/AboutUsScreen.dart';
import 'package:ServiceJi/screen/CategoriesScreen.dart';
import 'package:ServiceJi/screen/ChangePasswordScreen.dart';
import 'package:ServiceJi/screen/DashboardScreen.dart';
import 'package:ServiceJi/screen/EditProfileScreen.dart';
import 'package:ServiceJi/screen/MyCartScreen.dart';
import 'package:ServiceJi/screen/OrderListScreen.dart';
import 'package:ServiceJi/screen/PaymentScreen.dart';
import 'package:ServiceJi/screen/PlaceOrderScreen.dart';
import 'package:ServiceJi/screen/SignInScreen.dart';
import 'package:ServiceJi/screen/SignUpScreen.dart';
import 'package:ServiceJi/screen/SplashScreen.dart';
import 'package:ServiceJi/screen/VendorListScreen.dart';
import 'package:ServiceJi/screen/WishListScreen.dart';
import 'package:ServiceJi/utils/constants.dart';

BuilderResponse builderResponse = BuilderResponse();
Color primaryColor;
Color colorAccent;
Color textPrimaryColour;
Color textSecondaryColour;
Color backgroundColor;
String BaseUrl;
String ConsumerKey;
String ConsumerSecret;
AppStore appStore = AppStore();
Future<String> loadBuilderData() async {
  return await rootBundle.loadString('assets/builder.json');
}

Future<BuilderResponse> loadContent() async {
  String jsonString = await loadBuilderData();
  final jsonResponse = json.decode(jsonString);
  return BuilderResponse.fromJson(jsonResponse);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  appStore.toggleDarkMode(value: await getBool(IS_DARK_THEME));
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  builderResponse = await loadContent();
  OneSignal.shared.init('69638a56-f66b-46f6-809a-91f113edce2f', iOSSettings: {OSiOSSettings.autoPrompt: false, OSiOSSettings.inAppLaunchUrl: false});
  OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
  await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);

  setString(PRIMARY_COLOR, builderResponse.appsetup.primaryColor);
  setString(SECONDARY_COLOR, builderResponse.appsetup.secondaryColor);
  setString(TEXT_PRIMARY_COLOR, builderResponse.appsetup.textPrimaryColor);
  setString(TEXT_SECONDARY_COLOR, builderResponse.appsetup.textSecondaryColor);
  setString(BACKGROUND_COLOR, builderResponse.appsetup.backgroundColor);
  setString(APP_URL, builderResponse.appsetup.appUrl);
  setString(CONSUMER_KEY, builderResponse.appsetup.consumerKey);
  setString(CONSUMER_SECRET, builderResponse.appsetup.consumerSecret);

  primaryColor = getColorFromHex(await getString(PRIMARY_COLOR), defaultColor: Color(0xFFff9762));
  colorAccent = getColorFromHex(await getString(SECONDARY_COLOR), defaultColor: Color(0xFF6b3b63));
  textPrimaryColour = getColorFromHex(await getString(TEXT_PRIMARY_COLOR), defaultColor: Color(0xFF212121));
  textSecondaryColour = getColorFromHex(await getString(TEXT_SECONDARY_COLOR), defaultColor: Color(0xFF757575));
  backgroundColor = getColorFromHex(await getString(BACKGROUND_COLOR), defaultColor: Color(0xFFf3f5f9));
  BaseUrl = await getString(APP_URL);
  ConsumerKey = await getString(CONSUMER_KEY);
  ConsumerSecret = await getString(CONSUMER_SECRET);

  appStore.setLanguage(await getString(LANGUAGE, defaultValue: 'en'));
  appStore.setCount(await getInt(CARTCOUNT));


  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  MyApp();

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log(appStore.selectedLanguage);
    return Observer(
      builder: (_) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: appStore.isDarkModeOn ? AppTheme.darkTheme : AppTheme.lightTheme,
          supportedLocales: [
            Locale('af', ''),
            Locale('de', ''),
            Locale('en', ''),
            Locale('es', ''),
            Locale('fr', ''),
            Locale('hi', ''),
            Locale('in', ''),
            Locale('tr', ''),
            Locale('vi', ''),
            Locale('ar', '')
          ],
          localizationsDelegates: [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
          localeResolutionCallback: (locale, supportedLocales) => Locale(appStore.selectedLanguage),
          locale: Locale(appStore.selectedLanguage),
          home: SplashScreen(),
          routes: <String, WidgetBuilder>{
            HomeScreen.tag: (BuildContext context) => HomeScreen(),
            SignInScreen.tag: (BuildContext context) => SignInScreen(),
            AboutUsScreen.tag: (BuildContext context) => AboutUsScreen(),
            ChangePasswordScreen.tag: (BuildContext context) => ChangePasswordScreen(),
            DashboardScreen.tag: (BuildContext context) => DashboardScreen(),
            EditProfileScreen.tag: (BuildContext context) => EditProfileScreen(),
            MyCartScreen.tag: (BuildContext context) => MyCartScreen(),
            OrderList.tag: (BuildContext context) => OrderList(),
            SignUpScreen.tag: (BuildContext context) => SignUpScreen(),
            WishListScreen.tag: (BuildContext context) => WishListScreen(),
            CategoriesScreen.tag: (BuildContext context) => CategoriesScreen(),
            PaymentScreen.tag: (BuildContext context) => PaymentScreen(),
            PlaceOrderScreen.tag: (BuildContext context) => PlaceOrderScreen(),
            VendorListScreen.tag: (BuildContext context) => VendorListScreen(),
          },
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: SBehavior(),
              child: child,
            );
          },
        );
      },
    );
  }
}

class SBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
