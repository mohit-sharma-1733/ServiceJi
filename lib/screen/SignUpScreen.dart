import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import 'package:ServiceJi/utils/images.dart';
import '../app_localizations.dart';
import 'SignInScreen.dart';

class SignUpScreen extends StatefulWidget {
  static String tag = '/SignUpScreen';

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  var formKey = GlobalKey<FormState>();
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  var isLoading = false;
  var fNameCont = TextEditingController();
  var lNameCont = TextEditingController();
  var emailCont = TextEditingController();
  var usernameCont = TextEditingController();
  var passwordCont = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  signUpApi() async {
    hideKeyboard(context);
    var request = {
      'email': emailCont.text,
      'first_name': fNameCont.text,
      'last_name': lNameCont.text,
      'username': usernameCont.text,
      'password': passwordCont.text,
    };
    setState(() {
      isLoading = true;
    });
    createCustomer(request).then((res) {
      if (!mounted) return;
      toast('Register Successfully');
      setState(() {
        isLoading = false;
      });
      finish(context);
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      toast(error.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
    changeStatusColor(Colors.transparent);
  }

  @override
  Widget build(BuildContext context) {
    changeStatusColor(Colors.transparent);
    var appLocalization = AppLocalizations.of(context);
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    height: (MediaQuery.of(context).size.height) / 3.5,
                    child: Stack(
                      children: <Widget>[
                        Image.asset(
                          SignIn_TopImg,
                          fit: BoxFit.fill,
                          height: (MediaQuery.of(context).size.height) / 3.6,
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
                                'Registration ',
                                style: boldTextStyle(color: Colors.white, size: 28),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            alignment: Alignment.bottomRight,
                            margin: EdgeInsets.all(20.0),
                            child: Image.asset(
                              'images/serviceji/applogo.png',
                              height: 70,
                              width: 140,
                            )),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: EditText(
                                hintText: appLocalization.translate('hint_first_name'),
                                isPassword: false,
                                mController: fNameCont,
                                validator: (String v) {
                                  if (v.trim().isEmpty) return 'First Name is required';
                                  if (v.trim().isDigit()) return 'Only Alphabets allowed';
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: EditText(
                                hintText: appLocalization.translate('hint_last_name'),
                                isPassword: false,
                                mController: lNameCont,
                                validator: (String v) {
                                  if (v.trim().isEmpty) return 'Last Name is required';
                                  if (v.trim().isDigit()) return 'Only Alphabets allowed';
                                  return null;
                                },
                              ),
                            )
                          ],
                        ),
                        spacing_standard_new.height,
                        EditText(
                          hintText: appLocalization.translate('lbl_email'),
                          isPassword: false,
                          mController: emailCont,
                          validator: (String v) {
                            if (v.trim().isEmpty) return 'Email is required';
                            if (!v.trim().validateEmail()) return 'Email you entered is wrong';
                            return null;
                          },
                        ),
                        spacing_standard_new.height,
                        EditText(
                          hintText: appLocalization.translate('hint_Username'),
                          isPassword: false,
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
                          isSecure: true,
                          mController: passwordCont,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Password is required';
                            return null;
                          },
                        ),
                        spacing_standard_new.height,
                        EditText(
                          hintText: appLocalization.translate('hint_confirm_password'),
                          isPassword: true,
                          isSecure: true,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'ConfirmPassword is required';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  spacing_standard_new.height,
                  Padding(
                    padding: EdgeInsets.fromLTRB(spacing_standard_new.toDouble(), 0, spacing_standard_new.toDouble(), 0),
                    child: AppButton(
                        textContent:
                       appLocalization.translate('lbl_sign_up_link'),
                        color: colorAccent,
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            formKey.currentState.save();
                            isLoading = true;
                            signUpApi();
                          }
                        }),
                  ),
                  spacing_standard_new.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(appLocalization.translate('lbl_already_have_account'), style: primaryTextStyle(size: 18, color: Theme.of(context).textTheme.subtitle1.color)),
                      Container(
                        margin: EdgeInsets.only(left: 4),
                        child: GestureDetector(
                            child: Text(appLocalization.translate('lbl_sign_in'),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColor,
                                )),
                            onTap: () {
                              SignInScreen().launch(context);
                            }),
                      )
                    ],
                  ),
                  spacing_standard_new.height,
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
