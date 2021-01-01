import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_localizations.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePasswordScreen';

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  var formKey = GlobalKey<FormState>();
  var passwordCont = TextEditingController();
  var oldPasswordCont = TextEditingController();
  var newPasswordCont = TextEditingController();
  var isLoading = false;
  var userName = '';
  SharedPreferences pref;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    changeStatusColor(primaryColor);
    pref = await getSharedPref();
    setState(() {
      userName = pref.getBool(IS_LOGGED_IN) != null ? pref.getString(USERNAME) : '';
    });
  }

  @override
  void dispose() {
    super.dispose();
    changeStatusColor(primaryColor);
  }

  @override
  Widget build(BuildContext context) {
    changeStatusColor(primaryColor);
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
          appLocalization.translate('lbl_change_pwd'),
          style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
        ),
      ),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: [
                  spacing_standard_new.height,
                  EditText(
                    hintText: appLocalization.translate('hint_enter_old_password'),
                    isPassword: true,
                    isSecure: true,
                    mController: oldPasswordCont,
                    validator: (String v) {
                      if (v.trim().isEmpty) return "Old password required";
                      return null;
                    },
                  ),
                  spacing_standard_new.height,
                  EditText(
                    hintText: appLocalization.translate('lbl_new_pwd'),
                    isPassword: true,
                    isSecure: true,
                    mController: newPasswordCont,
                    validator: (String v) {
                      if (v.trim().isEmpty) return "New password required";
                      return null;
                    },
                  ),
                  spacing_standard_new.height,
                  EditText(
                    hintText: appLocalization.translate('hint_confirm_password'),
                    isPassword: true,
                    mController: passwordCont,
                    isSecure: true,
                    validator: (String v) {
                      if (v.trim().isEmpty) return "Confirm password required";
                      return null;
                    },
                  ),
                  spacing_standard_new.height,
                  AppButton(
                      textContent: appLocalization.translate('lbl_change_now'),
                      onPressed: () {
                        if (formKey.currentState.validate()) {
                          formKey.currentState.save();
                          isLoading = true;
                          var request = {'password': oldPasswordCont.text, 'new_password': passwordCont.text, 'username': userName};
                          setState(() {
                            isLoading = true;
                          });
                          changePassword(request).then((res) {
                            setState(() {
                              isLoading = false;
                            });
                            toast(res["message"]);
                            finish(context);
                          }).catchError((error) {
                            setState(() {
                              isLoading = false;
                            });
                            toast(error.toString());
                          });
                        } else {
                          toast('Enter Valid Password');
                        }
                      }),
                ],
              ).paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()),
            ),
            Center(
              child: Container(child: CircularProgressIndicator()),
            ).visible(isLoading)
          ],
        ),
      ),
    );
  }
}
