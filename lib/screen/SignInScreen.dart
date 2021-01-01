import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/screen/DashboardScreen.dart';
import 'package:ServiceJi/screen/SignUpScreen.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import 'package:ServiceJi/utils/images.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_localizations.dart';
import 'EditProfileScreen.dart';

class SignInScreen extends StatefulWidget {
  static String tag = '/SignInScreen';

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  var formKey = GlobalKey<FormState>();
  var passwordVisible = false;
  var isLoading = false;
  bool isRemember = false;
  var usernameCont = TextEditingController();
  var passwordCont = TextEditingController();
  SharedPreferences pref;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    pref = await getSharedPref();
    setState(() {});
    var remember = await getBool(REMEMBER_PASSWORD) ?? false;
    if (remember) {
      var password = await getString(PASSWORD1, defaultValue: '12345678');
      var email = await getString(EMAIL, defaultValue: 'serviceji@gmail.com');
      setState(() {
        usernameCont.text = email;
        passwordCont.text = password;
        print(usernameCont.text);
        print(passwordCont.text);
      });
    }
    setState(() {
      isRemember = remember;
    });
  }

  save() async {}

  @override
  void dispose() {
    super.dispose();
    changeStatusColor(Colors.transparent);
  }

  @override
  Widget build(BuildContext context) {
    changeStatusColor(Colors.transparent);
    var appLocalization = AppLocalizations.of(context);

    void signInApi(req) async {
      setState(() {
        isLoading = true;
      });
      await login(req).then((res) async {
        if (!mounted) return;

        setInt(USER_ID, res['user_id']);
        setString(FIRST_NAME, res['first_name']);
        setString(LAST_NAME, res['last_name']);
        setString(USER_EMAIL, res['user_email']);
        setString(USERNAME, res['user_nicename']);
        setString(TOKEN, res['token']);
        setString(AVATAR, res['avatar']);
        if (res['profile_image'] != null) {
          setString(PROFILE_IMAGE, res['profile_image']);
        }
        setString(USER_DISPLAY_NAME, res['user_display_name']);
        setBool(REMEMBER_PASSWORD, isRemember);

        if (isRemember) {
          setString(EMAIL, usernameCont.text.toString());
          setString(PASSWORD1, passwordCont.text.toString());
        } else {
          setString(PASSWORD1, "");
          setString(EMAIL, '');
        }
        setString(BILLING, jsonEncode(res['billing']));
        setString(SHIPPING, jsonEncode(res['shipping']));
        setBool(IS_LOGGED_IN, true);
        setState(() {
          isLoading = false;
        });
        if (res['billing']['first_name'].toString().isNotEmpty) {
          DashboardScreen().launch(context);
        } else {
          //EditProfileScreen().launch(context);
          DashboardScreen().launch(context);
        }
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        toast(error.toString());
      });
    }

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: <Widget>[
            Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: (MediaQuery.of(context).size.height) / 3.5,
                        child: Stack(
                          children: <Widget>[
                            Image.asset(
                              'images/serviceji/applogo.png',
                             // SignIn_TopImg,
                              height: (MediaQuery.of(context).size.height) / 3.6,
                              fit: BoxFit.fill,
                              width: MediaQuery.of(context).size.width,
                              color: Theme.of(context).primaryColor,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: spacing_standard_new.toDouble()),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Welcome Back!' ,
                                   // appLocalization.translate('lbl_welcome'),
                                    style: boldTextStyle(color: Colors.white, size: 28),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                alignment: Alignment.bottomRight,
                                margin: EdgeInsets.only(right: 16),
                                child: Image.asset(
                                  'images/serviceji/applogo.png',
                                  height: 110,
                                  width: 130,
                                )),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: spacing_standard_new.toDouble()),
                        child: Column(
                          children: [
                            EditText(
                              hintText: appLocalization.translate('hint_Username'),
                              isPassword: false,
                              isSecure: false,
                              mController: usernameCont,
                              validator: (v) {
                                if (v.trim().isEmpty) return 'Username is required';

                                return null;
                              },
                            ),
                            spacing_standard_new.height,
                            EditText(
                              hintText: appLocalization.translate('hint_password'),
                              isPassword: true,
                              mController: passwordCont,
                              isSecure: true,
                              validator: (v) {
                                if (v.trim().isEmpty) return 'Password is required';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ).paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()),
                      SizedBox(height: 14),
                      Padding(
                        padding: EdgeInsets.fromLTRB(spacing_standard_new.toDouble(), 0, spacing_standard_new.toDouble(), 0),
                        child: AppButton(
                            textContent:
                             //   Text('Login'),
                            appLocalization.translate('lbl_sign_in_link'),
                            onPressed: () {
                              hideKeyboard(context);
                              if (formKey.currentState.validate()) {
                                formKey.currentState.save();
                                var request = {"username": "${usernameCont.text}", "password": "${passwordCont.text}"};
                                isLoading = true;
                                signInApi(request);
                              }
                            }),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        appLocalization.translate('lbl_forgot_password'),
                        style: secondaryTextStyle(size: 18, color: Theme.of(context).textTheme.subtitle2.color),
                      ).onTap(() {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => CustomDialog(),
                        );
                      }),
                      spacing_standard_new.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                        //  Text(appLocalization.translate('lbl_dont_have_account'), style: primaryTextStyle(size: 18, color: Theme.of(context).textTheme.subtitle1.color)),
                          Container(
                            margin: EdgeInsets.only(left: 4),
                            child: GestureDetector(
                                child: Text(
                                  'Don\'t have Account? Get one here!',
                                   // appLocalization.translate('lbl_sign_up_link'),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context).primaryColor,
                                    )),
                                onTap: () {
                                  SignUpScreen().launch(context);
                                }),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            isLoading
                ? Container(
                    child: CircularProgressIndicator(),
                    alignment: Alignment.center,
                  )
                : SizedBox(),
          ],
        ));
  }
}

// ignore: must_be_immutable
class CustomDialog extends StatelessWidget {
  var email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
    forgotPwdApi() async {
      hideKeyboard(context);
      var request = {
        'email': email.text,
      };

      forgetPassword(request).then((res) {
        toast('Email sent Successfully');
        finish(context);
      }).catchError((error) {
        toast(error.toString());
      });
    }

    return Dialog(
      //  insetPadding: EdgeInsets.fromLTRB(spacing_standard_new.toDouble(), 0, spacing_standard_new.toDouble(), 0),
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
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                Text(appLocalization.translate('lbl_forgot_password'), style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: 24))
                    .paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble(), top: spacing_standard_new.toDouble()),
                SizedBox(height: spacing_standard_new.toDouble()),
                Column(
                  children: [
                    EditTextBorder(
                      hint: appLocalization.translate('hint_enter_your_email_id'),
                      isPassword: false,
                      mController: email,
                    ),
                  ],
                ).paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble(), bottom: spacing_standard.toDouble()),
                Container(
                    width: MediaQuery.of(context).size.width,
                    child: RaisedButton(
                      color: colorAccent,
                      onPressed: () {
                        if (!accessAllowed) {
                          toast("Sorry");
                          return;
                        }
                        if (email.text.isEmpty)
                          toast(appLocalization.translate('hint_Email') + appLocalization.translate('error_field_required'));
                        else
                          forgotPwdApi();
                      },
                      child: Text(
                        appLocalization.translate('lbl_submit'),
                        style: primaryTextStyle(size: 16, color: white_color),
                      ),
                    )).paddingAll(spacing_standard_new.toDouble()),
              ],
            ),
          )),
    );
  }
}
