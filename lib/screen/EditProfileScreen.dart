import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/models/Countries.dart';
import 'package:ServiceJi/models/CustomerResponse.dart';
import 'package:ServiceJi/network/rest_apis.dart';
import 'package:ServiceJi/utils/app_Widget.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/constants.dart';
import 'package:ServiceJi/utils/extensions.dart';
import 'package:ServiceJi/utils/images.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  static String tag = '/EditProfileScreen';

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  var formKey = GlobalKey<FormState>();
  var txtFirstName = TextEditingController();
  var txtLastName = TextEditingController();
  var txtEmail = TextEditingController();

  var txtBillingFirstName = TextEditingController();
  var txtBillingLastName = TextEditingController();
  var txtBillingDate = TextEditingController();
  var txtBillingTime = TextEditingController();
  var txtBillingAddress2 = TextEditingController();
  var txtBillingCity = TextEditingController();
  var txtBillingPinCode = TextEditingController();
  var txtBillingMobile = TextEditingController();
  var txtBillingEmail = TextEditingController();

  var txtShippingFirstName = TextEditingController();
  var txtShippingLastName = TextEditingController();
  var txtShippingDate = TextEditingController();
  var txtShippingTime = TextEditingController();
  var txtShippingAddress2 = TextEditingController();
  var txtShippingCity = TextEditingController();
  var txtShippingPinCode = TextEditingController();

  bool mIsLoading = true;
  bool isCheckBoxSelected = false;
  var mCustomer;
  var billingCountryList = List<Country>();
  var billingStateList = List<CountryState>();
  var shippingStateList = List<CountryState>();
  File mSelectedImage;
  String avatar = '';
  SharedPreferences pref;
  int id;
  var userName = '';
  var userEmail = '';
  Country selectedBillingCountry;
  CountryState selectedBillingState;
  Country selectedShippingCountry;
  CountryState selectedShippingState;

  @override
  void initState() {
    super.initState();
    changeStatusColor(primaryColor);
    getCustomerData();
  }

  Future getCustomerData() async {
    id = await getInt(USER_ID);
    pref = await getSharedPref();

    setState(() {
      userName = pref.get(USERNAME) != null ? pref.getString(USERNAME) : '';
      userEmail = pref.get(USER_EMAIL) != null ? pref.getString(USER_EMAIL) : '';
    });

    await getCustomer(id).then((res) async {
      if (!mounted) return;
      txtFirstName.text = res['first_name'];
      txtLastName.text = res['last_name'];
      txtEmail.text = res['email'];
      avatar = pref.get(PROFILE_IMAGE) != null ? pref.getString(PROFILE_IMAGE) : pref.getString(AVATAR);
      txtBillingFirstName.text = res['billing']['first_name'];
      txtBillingLastName.text = res['billing']['last_name'];
      txtBillingDate.text = res['billing']['company'];
      txtBillingTime.text = res['billing']['address_1'];
      txtBillingAddress2.text = res['billing']['address_2'];
      txtBillingCity.text = res['billing']['city'];
      txtBillingPinCode.text = res['billing']['postcode'];

      txtBillingMobile.text = res['billing']['phone'];
      txtBillingEmail.text = res['billing']['email'];

      txtShippingFirstName.text = res['shipping']['first_name'];
      txtShippingLastName.text = res['shipping']['last_name'];
      txtShippingDate.text = res['shipping']['company'];
      txtShippingTime.text = res['shipping']['address_1'];
      txtShippingAddress2.text = res['shipping']['address_2'];
      txtShippingCity.text = res['shipping']['city'];
      txtShippingPinCode.text = res['shipping']['postcode'];

      isCheckBoxSelected = false;
      setString(FIRST_NAME, res['first_name']);
      setString(LAST_NAME, res['last_name']);
      String countries = pref.getString(COUNTRIES);
      if (countries == null) {
        await getCountries().then((value) async {
          log(value);
          setString(COUNTRIES, jsonEncode(value));
          setCountryStateData(value, res);
        }).catchError((error) {
          setState(() {
            mIsLoading = false;
          });
          toast(error);
        });
      } else {
        setCountryStateData(jsonDecode(countries), res);
      }
    }).catchError((error) {
      if (!mounted) return;
      mIsLoading = false;
    });
  }

  setCountryStateData(value, res) {
    var txtBillingCountry = res['billing']['country'];
    var txtBillingState = res['billing']['state'];
    var txtShippingCountry = res['shipping']['country'];
    var txtShippingState = res['shipping']['state'];
    Iterable list = value;
    var countris = list.map((model) => Country.fromJson(model)).toList();
    setState(() {
      billingCountryList.addAll(countris);
      if (billingCountryList.isNotEmpty) {
        selectedBillingCountry = billingCountryList[0];
        selectedShippingCountry = billingCountryList[0];
        if (txtBillingCountry != null || txtShippingCountry != null) {
          billingCountryList.forEach((element) {
            if (txtBillingCountry != null && txtBillingCountry.toString().isNotEmpty && element.name == txtBillingCountry) {
              selectedBillingCountry = element;
            }
            if (txtShippingCountry != null && txtShippingCountry.toString().isNotEmpty && element.name == txtShippingCountry) {
              selectedShippingCountry = element;
            }
          });
        }
        billingStateList.clear();
        shippingStateList.clear();
        billingStateList.addAll(selectedBillingCountry.states);
        shippingStateList.addAll(selectedShippingCountry.states);
        selectedBillingState = billingStateList.isNotEmpty ? billingStateList[0] : null;
        selectedShippingState = shippingStateList.isNotEmpty ? shippingStateList[0] : null;
        if (txtBillingState != null) {
          billingStateList.forEach((element) {
            if (txtBillingState != null && txtBillingState.toString().isNotEmpty && element.name == txtBillingState) {
              selectedBillingState = element;
            }
          });
        }
        if (txtShippingState != null) {
          shippingStateList.forEach((element) {
            if (txtShippingState != null && txtShippingState.toString().isNotEmpty && element.name == txtShippingState) {
              selectedShippingState = element;
            }
          });
        }
      }
      mIsLoading = false;
    });
  }

  void fillShipping() {
    if (isCheckBoxSelected) {
      txtShippingFirstName.text = txtBillingFirstName.text;
      txtShippingLastName.text = txtBillingLastName.text;
      txtShippingDate.text = txtBillingDate.text;
      txtShippingTime.text = txtBillingTime.text;
      txtShippingAddress2.text = txtBillingAddress2.text;
      txtShippingCity.text = txtBillingCity.text;
      txtShippingPinCode.text = txtBillingPinCode.text;
      selectedShippingCountry = selectedBillingCountry;
      shippingStateList.clear();
      shippingStateList.addAll(selectedShippingCountry.states);
      selectedShippingState = shippingStateList.isNotEmpty ? selectedBillingState : null;
    } else {
      txtShippingFirstName.text = '';
      txtShippingLastName.text = '';
      txtShippingDate.text = '';
      txtShippingTime.text = '';
      txtShippingAddress2.text = '';
      txtShippingCity.text = '';
      txtShippingPinCode.text = '';
    }
    log(txtShippingFirstName.text);

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    changeStatusColor(primaryColor);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
    saveUser() async {
      setState(() {
        mIsLoading = true;
      });
      hideKeyboard(context);

      var mBilling = Billing();
      mBilling.firstName = txtBillingFirstName.text;
      mBilling.lastName = txtBillingLastName.text;
      mBilling.company = txtBillingDate.text;
      mBilling.address1 = txtBillingTime.text;
      mBilling.address2 = txtBillingAddress2.text;
      mBilling.city = txtBillingCity.text;
      mBilling.postcode = txtBillingPinCode.text;
      mBilling.country = selectedBillingCountry.name.toString();
      mBilling.state = selectedBillingState != null ? selectedBillingState.name.toString() : "";
      mBilling.email = txtBillingEmail.text;
      mBilling.phone = txtBillingMobile.text;

      var mShipping = Shipping();
      mShipping.firstName = txtShippingFirstName.text;
      mShipping.lastName = txtShippingLastName.text;
      mShipping.company = txtShippingDate.text;
      mShipping.address1 = txtShippingTime.text;
      mShipping.address2 = txtShippingAddress2.text;
      mShipping.city = txtShippingCity.text;
      mShipping.postcode = txtShippingPinCode.text;
      mShipping.country = selectedShippingCountry.name.toString();
      mShipping.state = selectedShippingState != null ? selectedShippingState.name.toString() : "";

      var request = {
        'email': txtEmail.text,
        'first_name': txtFirstName.text,
        'last_name': txtLastName.text,
        'billing': mBilling,
        'shipping': mShipping,
      };
      updateCustomer(id, request).then((res) {
        if (!mounted) return;
        setState(() {
          mIsLoading = false;
        });
        pref.remove(BILLING);
        pref.remove(SHIPPING);
        setString(BILLING, jsonEncode(res['billing']));
        setString(SHIPPING, jsonEncode(res['shipping']));
        toast('Profile Saved');
        Navigator.pop(context, true);
      }).catchError((error) {
        toast(error.toString());
        mIsLoading = false;
      });
    }

    pickImage() async {
      File image = await ImagePicker.pickImage(source: ImageSource.gallery);
      log("Image: $image");

      setState(() {
        mSelectedImage = image;
      });

      if (mSelectedImage != null) {
        ConfirmAction res = await showConfirmDialogs(context, 'Are you sure want to upload image?', 'Yes', 'No');

        if (res == ConfirmAction.ACCEPT) {
          var base64Image = base64Encode(mSelectedImage.readAsBytesSync());
          var request = {'base64_img': base64Image};
          await saveProfileImage(request).then((res) async {
            if (!mounted) return;
            getCustomerData();
          }).catchError((error) {
            toast(error.toString());
          });
        }
      }
    }

    Widget profileImage = ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: mSelectedImage == null
          ? avatar.isEmpty
              ? Image.asset(
                  User_Profile,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  avatar,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return getLoadingProgress(loadingProgress);
                  },
                )
          : Image.file(
              mSelectedImage,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
    );

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
        title: Text(
          appLocalization.translate('lbl_edit_profile'),
          style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
        ),
      ),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: new EdgeInsets.only(top: 55.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: boxDecoration(context, radius: 10, showShadow: true),
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 50),
                              Text(
                                userName.toString(),
                                style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: 18),
                              ),
                              Text(userEmail.toString(), style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: 18)),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              profileImage,
                              15.height,
                              Container(
                                height: 35,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Theme.of(context).textTheme.subtitle2.color, width: 1),
                                    color: Theme.of(context).scaffoldBackgroundColor),
                                child: IconButton(
                                    icon: Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Theme.of(context).textTheme.subtitle2.color,
                                    ),
                                    onPressed: (() {
                                      pickImage();
                                    })),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    decoration: boxDecoration(context, radius: 10.0, showShadow: true),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appLocalization.translate('lbl_personal'),
                          style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeLargeMedium),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SimpleEditText(
                                mController: txtFirstName,
                                hintText: appLocalization.translate('hint_first_name'),
                                validator: (String v) {
                                  if (v.trim().isEmpty) return 'First Name is required';
                                },
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                                child: SimpleEditText(
                              mController: txtLastName,
                              hintText: appLocalization.translate('hint_last_name'),
                              validator: (String v) {
                                if (v.trim().isEmpty) return 'Last Name is required';
                              },
                            ))
                          ],
                        ),
                        SimpleEditText(
                          mController: txtEmail,
                          hintText: appLocalization.translate('lbl_email'),
                          validator: (String v) {
                            if (v.trim().isEmpty) return 'Email is required';
                            if (!v.trim().validateEmail()) return 'Email is not valid';
                          },
                        )
                      ],
                    ).paddingOnly(left: spacing_standard.toDouble(), top: spacing_standard_new.toDouble(), right: spacing_standard.toDouble(), bottom: spacing_standard_new.toDouble()),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    decoration: boxDecoration(context, radius: 10.0, showShadow: true),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appLocalization.translate('lbl_Billing'),
                          style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeLargeMedium),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: SimpleEditText(
                              mController: txtBillingFirstName,
                              hintText: appLocalization.translate('hint_first_name'),
                              validator: (String v) {
                                if (v.trim().isEmpty) return 'First name is required';
                                if (v.trim().isDigit()) return 'Digits are not allowed';
                              },
                            )),
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                                child: SimpleEditText(
                              mController: txtBillingLastName,
                              hintText: appLocalization.translate('hint_last_name'),
                              validator: (String v) {
                                if (v.trim().isEmpty) return 'Last Name is required';
                                if (v.trim().isDigit()) return 'Digits are not allowed';
                              },
                            )),
                          ],
                        ),
                        SimpleEditText(
                         mController: txtBillingDate,
                          hintText: appLocalization.translate('hint_company'),
                        //  hintText: Text('Date for Service'),
                       //   validator: (String v) {
                         //   if (v.trim().isEmpty) return 'Date is required';
                         // },
                        ),
                       SimpleEditText(
                         mController: txtBillingTime,
                         hintText: appLocalization.translate('hint_add1'),
                        // hintText: Text('Time should be between 9 AM to 6 PM'),
                     //   validator: (String v) {
                         //   if (v.trim().isEmpty) return 'Time  is required';
                        // },
                        ),
                        SimpleEditText(
                          mController: txtBillingAddress2,
                         hintText: appLocalization.translate('hint_add2'),
                          validator: (String v) {
                            if (v.trim().isEmpty) return 'Address  is required';
                          },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SimpleEditText(
                                mController: txtBillingCity,
                                hintText: appLocalization.translate('hint_city'),
                                validator: (String v) {
                                  if (v.trim().isEmpty) return 'City is required';
                                },
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: SimpleEditText(
                                mController: txtBillingPinCode,
                                keyboardType: TextInputType.number,
                                hintText: appLocalization.translate('hint_pin_code'),
                                validator: (String v) {
                                  if (v.trim().isEmpty) return 'Pincode is required';
                                  if (!v.trim().isDigit()) return 'Only Digits Allowed';
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Stack(
                              children: [
                                SimpleEditText(),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Theme.of(context).cardTheme.color,
                                  ),
                                  child: DropdownButton(
                                    value: selectedBillingCountry,
                                    isExpanded: true,
                                    underline: SizedBox(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedBillingCountry = value;
                                        billingStateList.clear();
                                        billingStateList.addAll(selectedBillingCountry.states);
                                        selectedBillingState = selectedBillingCountry.states.isNotEmpty ? billingStateList[0] : null;
                                        if (isCheckBoxSelected) {
                                          selectedShippingCountry = selectedBillingCountry;
                                          shippingStateList.clear();
                                          shippingStateList.addAll(selectedShippingCountry.states);
                                          selectedShippingState = selectedShippingCountry.states.isNotEmpty ? selectedBillingState : null;
                                        }
                                      });
                                    },
                                    items: billingCountryList.map((value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text(
                                            value.name != null && value.name.toString().isNotEmpty ? value.name : "NA",
                                            style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium),
                                          ).paddingAll(8.0),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            )),
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                                child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                SimpleEditText(),
                                selectedBillingState != null
                                    ? Theme(
                                        data: Theme.of(context).copyWith(
                                          canvasColor: Theme.of(context).cardTheme.color,
                                        ),
                                        child: DropdownButton(
                                          value: selectedBillingState,
                                          isExpanded: true,
                                          underline: SizedBox(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedBillingState = value;
                                              if (isCheckBoxSelected) {
                                                selectedShippingState = selectedBillingState;
                                              }
                                            });
                                          },
                                          items: billingStateList.map((value) {
                                            return DropdownMenuItem(
                                              value: value,
                                              child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(
                                                  value.name != null && value.name.toString().isNotEmpty ? value.name : "NA",
                                                  style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      )
                                    : Text(
                                        "NA",
                                        style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium),
                                      ),
                              ],
                            )),
                          ],
                        ).visible(billingCountryList.isNotEmpty),
                        SimpleEditText(
                          mController: txtBillingMobile,
                          keyboardType: TextInputType.number,
                          hintText: appLocalization.translate('hint_mobile_no'),
                          validator: (String v) {
                            if (v.trim().isEmpty) return 'Mobile Number  is required';
                          },
                        ),
                        SimpleEditText(
                          mController: txtBillingEmail,
                          hintText: appLocalization.translate('hint_email'),
                          validator: (String v) {
                            if (v.trim().isEmpty) return 'Email is required';
                            if (!v.trim().validateEmail()) return 'Email is not Valid';
                          },
                        ),
                      ],
                    ).paddingOnly(left: spacing_standard.toDouble(), top: spacing_standard_new.toDouble(), right: spacing_standard.toDouble(), bottom: spacing_standard_new.toDouble()),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    decoration: boxDecoration(context, radius: 10.0, showShadow: true),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              appLocalization.translate('lbl_Shipping'),
                              style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeLargeMedium),
                            ),
                            Row(
                              children: [
                                Text(appLocalization.translate('lbl_same'), style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium)),
                                Icon(isCheckBoxSelected == true ? Icons.check_box : Icons.check_box_outline_blank, color: isCheckBoxSelected == true ? darkGreyColor : greyColor, size: 30)
                                    .onTap(() {
                                  setState(() {
                                    isCheckBoxSelected = !isCheckBoxSelected;
                                    fillShipping();
                                  });
                                })
                              ],
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: SimpleEditText(
                              mController: txtShippingFirstName,
                              hintText: appLocalization.translate('hint_first_name'),
                              validator: (String v) {
                                if (v.trim().isEmpty) return 'First name is required';
                                if (v.trim().isDigit()) return 'Digits are not allowed';
                              },
                            )),
                            SizedBox(width: 16),
                            Expanded(
                                child: SimpleEditText(
                              mController: txtShippingLastName,
                              hintText: appLocalization.translate('hint_last_name'),
                              validator: (String v) {
                                if (v.trim().isEmpty) return 'Last Name is required';
                                if (v.trim().isDigit()) return 'Digits are not allowed';
                              },
                            ))
                          ],
                        ),
                       SimpleEditText(
                          mController: txtShippingDate,
                         hintText: appLocalization.translate('hint_company'),
                        validator: (String v) {
                          if (v.trim().isEmpty) return 'Booking date is required';
                         },
                      ),
                      SimpleEditText(
                          mController: txtShippingTime,
                        hintText: appLocalization.translate('hint_add1'),
                        validator: (String v) {
                          if (v.trim().isEmpty) return 'Time  is required';
                        },
                        ),
                      SimpleEditText(
                          mController: txtShippingAddress2,
                        hintText: appLocalization.translate('hint_add2'),
                          validator: (String v) {
                            if (v.trim().isEmpty) return 'Address  is required';
                         },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SimpleEditText(
                                mController: txtShippingCity,
                                hintText: appLocalization.translate('hint_city'),
                                validator: (String v) {
                                  if (v.trim().isEmpty) return 'City is required';
                                },
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: SimpleEditText(
                                mController: txtShippingPinCode,
                                hintText: appLocalization.translate('hint_pin_code'),
                                validator: (String v) {
                                  if (v.trim().isEmpty) return 'Pincode is required';
                                  if (!v.trim().isDigit()) return 'Only Digits Allowed';
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Stack(
                              children: [
                                SimpleEditText(),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Theme.of(context).cardTheme.color,
                                  ),
                                  child: DropdownButton(
                                    value: selectedShippingCountry,
                                    isExpanded: true,
                                    underline: SizedBox(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedShippingCountry = value;
                                        shippingStateList.clear();
                                        shippingStateList.addAll(selectedShippingCountry.states);
                                        selectedShippingState = selectedShippingCountry.states.isNotEmpty ? shippingStateList[0] : null;
                                      });
                                    },
                                    items: billingCountryList.map((value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text(
                                            value.name != null && value.name.toString().isNotEmpty ? value.name : "NA",
                                            style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium),
                                          ).paddingAll(8.0),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            )),
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                                child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                SimpleEditText(),
                                selectedShippingState != null
                                    ? Theme(
                                        data: Theme.of(context).copyWith(
                                          canvasColor: Theme.of(context).cardTheme.color,
                                        ),
                                        child: DropdownButton(
                                          value: selectedShippingState,
                                          isExpanded: true,
                                          underline: SizedBox(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedShippingState = value;
                                            });
                                          },
                                          items: shippingStateList.map((value) {
                                            return DropdownMenuItem(
                                              value: value,
                                              child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(
                                                  value.name != null && value.name.toString().isNotEmpty ? value.name : "NA",
                                                  style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      )
                                    : Text(
                                        "NA",
                                        style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium),
                                      ),
                              ],
                            )),
                          ],
                        ).visible(billingCountryList.isNotEmpty),
                      ],
                    ).paddingOnly(left: spacing_standard.toDouble(), top: spacing_standard_new.toDouble(), right: spacing_standard.toDouble(), bottom: spacing_standard_new.toDouble()),
                  ),
                  70.height,
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(spacing_standard_new.toDouble(), 8, spacing_standard_new.toDouble(), 8),
              alignment: Alignment.bottomCenter,
              height: 70,
              child: AppButton(
                  textContent: appLocalization.translate('lbl_save_profile'),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      formKey.currentState.save();
                      saveUser();
                    } else {
                      toast('Please Enter Valid Details');
                    }
                    /*if (!accessAllowed) {
                      toast("Sorry");
                      return;
                    }
                    if (txtFirstName.text.isEmpty)
                      toast(appLocalization.translate('hint_first_name') + " " + appLocalization.translate('error_field_required'));
                    else if (txtLastName.text.isEmpty)
                      toast(appLocalization.translate('hint_last_name') + " " + appLocalization.translate('error_field_required'));
                    else if (txtEmail.text.isEmpty)
                      toast(appLocalization.translate('lbl_email') + " " + appLocalization.translate('error_field_required'));
                    else if (txtBillingFirstName.text.isEmpty)
                      toast(appLocalization.translate('hint_first_name') + " " + appLocalization.translate('error_field_required'));
                    else if (txtBillingLastName.text.isEmpty)
                      toast(appLocalization.translate('hint_last_name') + " " + appLocalization.translate('error_field_required'));
                    else if (txtBillingCompanyName.text.isEmpty)
                      toast(appLocalization.translate('hint_company') + " " + appLocalization.translate('error_field_required'));
                    else if (txtBillingAddress1.text.isEmpty)
                      toast(appLocalization.translate('hint_add1') + " " + appLocalization.translate('error_field_required'));
                    else if (txtBillingAddress2.text.isEmpty)
                      toast(appLocalization.translate('hint_add2') + " " + appLocalization.translate('error_field_required'));
                    else if (txtBillingCity.text.isEmpty)
                      toast(appLocalization.translate('hint_city') + " " + appLocalization.translate('error_field_required'));
                    else if (txtBillingPinCode.text.isEmpty)
                      toast(appLocalization.translate('hint_pin_code') + " " + appLocalization.translate('error_field_required'));
                    else if (txtBillingMobile.text.isEmpty)
                      toast(appLocalization.translate('hint_mobile_no') + " " + appLocalization.translate('error_field_required'));
                    else if (txtBillingEmail.text.isEmpty)
                      toast(appLocalization.translate('lbl_email') + " " + appLocalization.translate('error_field_required'));
                    else if (txtShippingFirstName.text.isEmpty)
                      toast(appLocalization.translate('hint_first_name') + " " + appLocalization.translate('error_field_required'));
                    else if (txtShippingLastName.text.isEmpty)
                      toast(appLocalization.translate('hint_last_name') + " " + appLocalization.translate('error_field_required'));
                    else if (txtShippingCompanyName.text.isEmpty)
                      toast(appLocalization.translate('hint_company') + " " + appLocalization.translate('error_field_required'));
                    else if (txtShippingAddress1.text.isEmpty)
                      toast(appLocalization.translate('hint_add1') + " " + appLocalization.translate('error_field_required'));
                    else if (txtShippingAddress2.text.isEmpty)
                      toast(appLocalization.translate('hint_add2') + " " + appLocalization.translate('error_field_required'));
                    else if (txtShippingCity.text.isEmpty)
                      toast(appLocalization.translate('hint_city') + " " + appLocalization.translate('error_field_required'));
                    else if (txtShippingPinCode.text.isEmpty)
                      toast(appLocalization.translate('hint_pin_code') + " " + appLocalization.translate('error_field_required'));
                    else {
                      saveUser();
                    }*/
                  }),
            ),
            CircularProgressIndicator().center().visible(mIsLoading),
          ],
        ),
      ),
    );
  }
}
