import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/models/LayoutTypeSelectModel.dart';
import 'package:ServiceJi/models/ProductAttribute.dart';
import 'package:ServiceJi/models/ProductResponse.dart';
import 'package:ServiceJi/screen/MyCartScreen.dart';
import 'package:ServiceJi/screen/SearchScreen.dart';
import 'package:ServiceJi/screen/VendorListScreen.dart';
import 'package:ServiceJi/screen/VendorProfileScreen.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';
import 'package:ServiceJi/utils/constants.dart';

import 'colors.dart';
import 'common.dart';

class AppButton extends StatefulWidget {
  var textContent;
  Color color;
  VoidCallback onPressed;

  AppButton({@required this.textContent, @required this.color, @required this.onPressed});

  @override
  State<StatefulWidget> createState() {
    return AppButtonState();
  }
}

class AppButtonState extends State<AppButton> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        onPressed: widget.onPressed,
        textColor: Theme.of(context).cardTheme.color,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        padding: const EdgeInsets.all(0.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSecondary,
            borderRadius: BorderRadius.all(Radius.circular(80.0)),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
              child: Text(
                widget.textContent,
                style: boldTextStyle(size: 18, color: Theme.of(context).cardTheme.color),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ));
  }
}

BoxDecoration boxDecoration(BuildContext context, {double radius = 2, Color color = Colors.transparent, Color bgColor, var showShadow = false}) {
  return BoxDecoration(
      //gradient: LinearGradient(colors: [bgColor, whiteColor]),
      color: bgColor ?? Theme.of(context).cardTheme.color,
      boxShadow:
          showShadow ? [BoxShadow(color: Theme.of(context).hoverColor.withOpacity(0.2), blurRadius: 3, spreadRadius: 1, offset: Offset(1, 3))] : [BoxShadow(color: Colors.transparent)],
      border: Border.all(color: color),
      borderRadius: BorderRadius.all(Radius.circular(radius)));
}

class EditText extends StatefulWidget {
  var isPassword;
  var hintText;
  var isSecure;
  int fontSize;
  var textColor;
  var fontFamily;
  var text;
  var maxLine;
  Function validator;
  Function onChanged;
  TextEditingController mController;
  VoidCallback onPressed;

  EditText({
    var this.fontSize = textSizeNormal,
    var this.textColor = textColorSecondary,
    var this.hintText = '',
    var this.isPassword = true,
    var this.isSecure = false,
    var this.text = "",
    this.onChanged,
    this.validator,
    var this.mController,
    var this.maxLine = 1,
  });

  @override
  State<StatefulWidget> createState() {
    return EditTextState();
  }
}

class EditTextState extends State<EditText> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isSecure) {
      return TextFormField(
        controller: widget.mController,
        obscureText: widget.isPassword,
        cursorColor: primaryColor,
        maxLines: widget.maxLine,
        style: TextStyle(fontSize: widget.fontSize.toDouble(), color: Theme.of(context).textTheme.subtitle2.color, fontFamily: widget.fontFamily),
        onChanged: widget.onChanged,
        validator: widget.validator,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(26, 18, 4, 18),
          labelText: widget.hintText,
          labelStyle: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color),
          filled: true,
          fillColor: Theme.of(context).textTheme.headline4.color,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: Theme.of(context).cardTheme.color, width: 0.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          errorMaxLines: 2,
          errorStyle: primaryTextStyle(color: Colors.red, size: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: Theme.of(context).cardTheme.color, width: 0.0),
          ),
        ),
      );
    } else {
      return TextFormField(
        controller: widget.mController,
        obscureText: widget.isPassword,
        cursorColor: primaryColor,
        validator: widget.validator,
        style: TextStyle(fontSize: widget.fontSize.toDouble(), color: Theme.of(context).textTheme.subtitle2.color, fontFamily: widget.fontFamily),
        decoration: InputDecoration(
          suffixIcon: new GestureDetector(
            onTap: () {
              setState(() {
                widget.isPassword = !widget.isPassword;
              });
            },
            child: new Icon(
              widget.isPassword ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).accentColor,
            ),
          ),
          contentPadding: EdgeInsets.fromLTRB(26, 18, 4, 18),
          labelText: widget.hintText,
          labelStyle: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color),
          filled: true,
          fillColor: Theme.of(context).textTheme.headline4.color,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: Theme.of(context).cardTheme.color, width: 0.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          errorMaxLines: 2,
          errorStyle: primaryTextStyle(color: Colors.red, size: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: Theme.of(context).cardTheme.color, width: 0.0),
          ),
        ),
      );
    }
  }
}

class PinEntryTextField extends StatefulWidget {
  final String lastPin;
  final int fields;
  final onSubmit;
  final fieldWidth;
  final fontSize;
  final isTextObscure;
  final showFieldAsBox;

  PinEntryTextField({this.lastPin, this.fields: 4, this.onSubmit, this.fieldWidth: 40.0, this.fontSize: 16.0, this.isTextObscure: false, this.showFieldAsBox: false}) : assert(fields > 0);

  @override
  State createState() {
    return PinEntryTextFieldState();
  }
}

class PinEntryTextFieldState extends State<PinEntryTextField> {
  List<String> _pin;
  List<FocusNode> _focusNodes;
  List<TextEditingController> _textControllers;

  Widget textfields = Container();

  @override
  void initState() {
    super.initState();
    _pin = List<String>(widget.fields);
    _focusNodes = List<FocusNode>(widget.fields);
    _textControllers = List<TextEditingController>(widget.fields);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (widget.lastPin != null) {
          for (var i = 0; i < widget.lastPin.length; i++) {
            _pin[i] = widget.lastPin[i];
          }
        }
        textfields = generateTextFields(context);
      });
    });
  }

  @override
  void dispose() {
    _textControllers.forEach((TextEditingController t) => t.dispose());
    super.dispose();
  }

  Widget generateTextFields(BuildContext context) {
    List<Widget> textFields = List.generate(widget.fields, (int i) {
      return buildTextField(i, context);
    });

    if (_pin.first != null) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, verticalDirection: VerticalDirection.down, children: textFields);
  }

  void clearTextFields() {
    _textControllers.forEach((TextEditingController tEditController) => tEditController.clear());
    _pin.clear();
  }

  Widget buildTextField(int i, BuildContext context) {
    if (_focusNodes[i] == null) {
      _focusNodes[i] = FocusNode();
    }
    if (_textControllers[i] == null) {
      _textControllers[i] = TextEditingController();
      if (widget.lastPin != null) {
        _textControllers[i].text = widget.lastPin[i];
      }
    }

    _focusNodes[i].addListener(() {
      if (_focusNodes[i].hasFocus) {}
    });

    final String lastDigit = _textControllers[i].text;

    return Container(
      width: widget.fieldWidth,
      margin: EdgeInsets.only(right: 10.0),
      child: TextField(
        controller: _textControllers[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(color: primaryColor, fontSize: widget.fontSize),
        focusNode: _focusNodes[i],
        obscureText: widget.isTextObscure,
        decoration: InputDecoration(focusColor: primaryColor, counterText: "", border: widget.showFieldAsBox ? OutlineInputBorder(borderSide: BorderSide(width: 2.0)) : null),
        onChanged: (String str) {
          setState(() {
            _pin[i] = str;
          });
          if (i + 1 != widget.fields) {
            _focusNodes[i].unfocus();
            if (lastDigit != null && _pin[i] == '') {
              FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
            } else {
              FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
            }
          } else {
            _focusNodes[i].unfocus();
            if (lastDigit != null && _pin[i] == '') {
              FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
            }
          }
          if (_pin.every((String digit) => digit != null && digit != '')) {
            widget.onSubmit(_pin.join());
          }
        },
        onSubmitted: (String str) {
          if (_pin.every((String digit) => digit != null && digit != '')) {
            widget.onSubmit(_pin.join());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return textfields;
  }
}

class EditTextBorder extends StatefulWidget {
  var isPassword;
  var isSecure;
  int fontSize;
  var textColor;
  var fontFamily;
  var text;
  var hint;
  var maxLine;
  TextEditingController mController;

  VoidCallback onPressed;

  EditTextBorder(
      {var this.fontSize = textSizeLargeMedium,
      var this.textColor = textColorSecondary,
      var this.isPassword = true,
      var this.hint = "",
      var this.isSecure = false,
      var this.text = "",
      var this.mController,
      var this.maxLine = 1});

  @override
  State<StatefulWidget> createState() {
    return EditTextBorderState();
  }
}

class EditTextBorderState extends State<EditTextBorder> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.mController,
      obscureText: widget.isPassword,
      cursorColor: primaryColor,
      style: TextStyle(fontSize: widget.fontSize.toDouble(), color: Theme.of(context).textTheme.headline6.color, fontFamily: widget.fontFamily),
      decoration: InputDecoration(
        suffixIcon: widget.isSecure
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    widget.isPassword = !widget.isPassword;
                  });
                },
                child: new Icon(widget.isPassword ? Icons.visibility : Icons.visibility_off),
              )
            : null,
        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        hintText: widget.hint,
        hintStyle: TextStyle(color: textColorThird, fontSize: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: view_color, width: 0.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: view_color, width: 0.0),
        ),
      ),
    );
  }
}

class SimpleEditText extends StatefulWidget {
  bool isPassword;
  bool isSecure;
  int fontSize;
  var textColor;
  var fontFamily;
  var text;
  var maxLine;
  Function validator;
  TextInputType keyboardType;
  var hintText;

  TextEditingController mController;

  VoidCallback onPressed;

  SimpleEditText(
      {this.fontSize = textSizeNormal,
      this.textColor = textColorPrimary,
      this.isPassword = false,
      this.isSecure = true,
      this.text = '',
      this.mController,
      this.maxLine = 1,
      this.hintText = '',
      this.keyboardType,
      this.validator});

  @override
  State<StatefulWidget> createState() {
    return SimpleEditTextState();
  }
}

class SimpleEditTextState extends State<SimpleEditText> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: widget.mController,
        obscureText: widget.isPassword,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        style: TextStyle(color: Theme.of(context).textTheme.subtitle1.color, fontSize: 16),
        decoration: InputDecoration(
          hintText: widget.hintText,
          contentPadding: EdgeInsets.fromLTRB(8, 8, 4, 4),
          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          errorMaxLines: 2,
          errorStyle: primaryTextStyle(color: Colors.red, size: 12),
        ));
  }
}

Widget text(String text,
    {var fontSize = textSizeMedium,
    textColor = textColorPrimary,
//      var fontFamily = fontRegular,
    var isCentered = false,
    var maxLine = 1,
    var latterSpacing = 0.25,
    var textAllCaps = false,
    var isLongText = false}) {
  return Text(textAllCaps ? text.toUpperCase() : text,
      textAlign: isCentered ? TextAlign.center : TextAlign.start,
      maxLines: isLongText ? null : maxLine,
      style: TextStyle(
//          fontFamily: fontFamily,
          fontSize: fontSize,
          color: textColor,
          height: 1.5,
          letterSpacing: latterSpacing));
}

FadeInImage networkImage(String image, {String aPlaceholder = 'assets/placeholder.JPG', double aWidth, double aHeight, var fit = BoxFit.fill}) {
  return image != null && image.isNotEmpty
      ? FadeInImage(
          placeholder: AssetImage(aPlaceholder),
          image: NetworkImage(image),
          width: aWidth != null ? aWidth : null,
          height: aHeight != null ? aHeight : null,
          fit: fit,
        )
      : Image.asset(
          aPlaceholder,
          width: aWidth,
          height: aHeight,
          fit: BoxFit.fill,
        );
}

enum ConfirmAction { CANCEL, ACCEPT }

Future<ConfirmAction> showConfirmDialogs(context, msg, positiveText, negativeText) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text(msg, style: TextStyle(fontSize: 16)),
        actions: <Widget>[
          FlatButton(
            child: Text(
              negativeText,
              style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color),
            ),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.CANCEL);
            },
          ),
          FlatButton(
            child: Text(
              positiveText,
              style: primaryTextStyle(color: Theme.of(context).textTheme.headline6.color),
            ),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.ACCEPT);
            },
          )
        ],
      );
    },
  );
}

Widget getLoadingProgress(loadingProgress) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
      ),
    ),
  );
}

class PriceWidget extends StatefulWidget {
  static String tag = '/PriceWidget';
  var price;
  var size = 22.0;
  Color color;
  var isLineThroughEnabled = false;

  PriceWidget({Key key, this.price, this.color, this.size, this.isLineThroughEnabled = false}) : super(key: key);

  @override
  PriceWidgetState createState() => PriceWidgetState();
}

class PriceWidgetState extends State<PriceWidget> {
  var currency = '₹';
  Color primaryColor;

  @override
  void initState() {
    super.initState();
    get();
  }

  get() async {
    await getSharedPref().then((pref) {
      if (pref.get(DEFAULT_CURRENCY) != null) {
        setState(() {
          currency = pref.getString(DEFAULT_CURRENCY);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLineThroughEnabled) {
      return Text('$currency${widget.price.toString().replaceAll(".00", "")}', style: boldFonts(size: widget.size, color: widget.color != null ? widget.color : primaryColor));
    } else {
      return widget.price.toString().isNotEmpty
          ? Text('$currency${widget.price.toString().replaceAll(".00", "")}',
              style: TextStyle(fontSize: widget.size, color: widget.color ?? textPrimaryColor, decoration: TextDecoration.lineThrough))
          : Text('');
    }
  }
}

class FilterWidget extends StatefulWidget {
  static String tag = '/FilterWidget';
  var mTerms = List<Terms>();
  final void Function(List<Map<String, Object>>, List<int> price) onDataChange;

  FilterWidget(this.mTerms, this.onDataChange);

  @override
  FilterWidgetState createState() => FilterWidgetState();
}

class FilterWidgetState extends State<FilterWidget> {
  RangeValues _values = RangeValues(min_price, max_price);

  @override
  Widget build(BuildContext context) {
    var filterList = ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.mTerms.length,
        itemBuilder: (context, i) {
          return Container(
            decoration: widget.mTerms[i].isParent
                ? boxDecoration(context, bgColor: Theme.of(context).accentColor, radius: 0)
                : boxDecoration(context, bgColor: widget.mTerms[i].isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent),
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: widget.mTerms[i].isParent
                ? Text(
                    widget.mTerms[i].name,
                    style: secondaryTextStyle(color: Colors.white, size: 18),
                  )
                : Row(
                    children: <Widget>[
                      Expanded(
                          child: Text(
                        widget.mTerms[i].name,
                        style: secondaryTextStyle(size: 16, color: widget.mTerms[i].isSelected ? Theme.of(context).accentColor : Theme.of(context).textTheme.subtitle2.color),
                      )),
                      Container(
                        width: 18,
                        height: 18,
                        padding: EdgeInsets.all(2),
                        decoration: boxDecoration(context,
                            bgColor: widget.mTerms[i].isSelected ? Colors.transparent : Theme.of(context).textTheme.subtitle2.color.withOpacity(0.1),
                            color: widget.mTerms[i].isSelected ? Theme.of(context).accentColor : Colors.transparent),
                        child: Icon(
                          Icons.done,
                          color: Theme.of(context).accentColor,
                          size: 12,
                        ).visible(widget.mTerms[i].isSelected),
                      )
                    ],
                  ).onTap(() {
                    setState(() {
                      widget.mTerms[i].isSelected = !widget.mTerms[i].isSelected;
                    });
                  }),
          );
        });

    return SafeArea(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        margin: EdgeInsets.only(top: 24),
        child: Column(
          children: <Widget>[
            Container(
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Text("Filter", style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeMedium)),
                  ),
                  IconButton(
                    onPressed: () {
                      finish(context);
                    },
                    icon: Icon(Icons.clear),
                  )
                ],
                alignment: Alignment.centerRight,
              ),
              height: 50,
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    decoration: boxDecoration(context, bgColor: Theme.of(context).accentColor, radius: 0),
                    padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                    child: Text(
                      "Price",
                      style: secondaryTextStyle(color: Colors.white, size: 18),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        _values.start.toStringAsFixed(0).toString(),
                        style: boldTextStyle(size: 16, color: Theme.of(context).textTheme.subtitle2.color),
                      ),
                      Text(
                        _values.end.toStringAsFixed(0).toString(),
                        style: boldTextStyle(size: 16, color: Theme.of(context).textTheme.subtitle2.color),
                      )
                    ],
                  ).paddingOnly(left: 16, right: 16, top: 16),
                  RangeSlider(
                    values: _values,
                    min: min_price,
                    max: max_price,
                    divisions: 10,
                    inactiveColor: Theme.of(context).textTheme.subtitle2.color,
                    activeColor: Theme.of(context).accentColor,
                    onChanged: (RangeValues values) {
                      setState(() {
                        _values = values;
                      });
                    },
                  ),
                  filterList,
                ],
              ),
            )),
            Container(
              width: double.infinity,
              height: 50,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Container(
                        height: double.infinity,
                        alignment: Alignment.center,
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          "Reset",
                          style: secondaryTextStyle(size: 18, color: Colors.white),
                        )).onTap(() {
                      setState(() {
                        widget.mTerms.forEach((term) {
                          term.isSelected = false;
                        });
                        _values = RangeValues(1, 10000);
                      });
                      widget.onDataChange(List(), [_values.start.toInt(), _values.end.toInt()]);
                    }),
                  ),
                  Expanded(
                      child: Container(
                          height: double.infinity,
                          alignment: Alignment.center,
                          color: Theme.of(context).accentColor,
                          child: Text(
                            "Apply",
                            style: secondaryTextStyle(size: 18, color: Theme.of(context).scaffoldBackgroundColor),
                          )).onTap(
                    () {
                      var map = Map<String, List<int>>();
                      widget.mTerms.forEach((storeProductAttribute) {
                        if (storeProductAttribute.isSelected) {
                          if (map.containsKey(storeProductAttribute.taxonomy)) {
                            map[storeProductAttribute.taxonomy]?.add(storeProductAttribute.termId);
                          } else {
                            var list = List<int>();
                            list.add(storeProductAttribute.termId);
                            map[storeProductAttribute.taxonomy] = list;
                          }
                        }
                      });
                      var list = List<Map<String, Object>>();
                      map.keys.forEach((key) {
                        Map<String, Object> attribute = Map<String, Object>();
                        attribute[key] = map[key];
                        list.add(attribute);
                      });
                      widget.onDataChange(list, [_values.start.toInt(), _values.end.toInt()]);
                      finish(context);
                    },
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class layoutSelection extends StatefulWidget {
  final int crossAxisCount;
  final Function callBack;

  layoutSelection({this.crossAxisCount, this.callBack});

  @override
  _layoutSelectionState createState() => _layoutSelectionState();
}

class _layoutSelectionState extends State<layoutSelection> {
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
  //  select.add(LayoutTypesSelection(image: 'images/serviceji/twoGrid.png', isSelected: false));
    //select.add(LayoutTypesSelection(image: 'images/serviceji/threegrid.png', isSelected: false));
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
                          borderRadius: BorderRadius.circular(10), backgroundColor: select[index].isSelected ? Colors.white.withOpacity(0.2) : Colors.black54.withOpacity(0.2)),
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
                          else
                            crossvalue = 2;

                          setInt(CROSS_AXIS_COUNT, crossvalue);

                          widget.callBack(crossvalue);
                          finish(context);
                        },
                      )
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

Widget noInternet(height, width) {
  return Stack(
    children: [
      Image.asset(
        'images/serviceji/noInternet.jpg',
        height: height,
        width: width,
        fit: BoxFit.cover,
      ),
      Positioned(
        bottom: 50,
        left: 0,
        right: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No Internet.', style: boldTextStyle(size: 24, color: textPrimaryColor)),
            4.height,
            Text(
              'There is something wrong with the proxy server :( Meanwhile You check your Internet Connection too',
              style: secondaryTextStyle(size: 14, color: textSecondaryColor),
              textAlign: TextAlign.center,
            ).paddingOnly(left: 20, right: 20),
          ],
        ).paddingOnly(top: 30),
      )
    ],
  );
}

Widget appBar(BuildContext context, {Widget leading, Widget title, bool showSearch = true, int cartCount = 0}) {
  return AppBar(
    backgroundColor: Theme.of(context).primaryColor,
    leading: leading,
    title: title,
    actions: [
      showSearch == true
          ? IconButton(
              onPressed: () {
                SearchScreen().launch(context);
              },
              icon: Icon(Icons.search, size: 30, color: Colors.white),
            )
          : 0.height,
      Stack(
        overflow: Overflow.visible,
        alignment: Alignment.topRight,
        children: [
          IconButton(
            onPressed: () {
              checkLoggedIn(context, MyCartScreen.tag);
            },
            icon: Icon(Icons.shopping_cart, size: 30, color: Colors.white),
          ),
          Positioned(
            top: 5,
            right: 10,
            child: CircleAvatar(
              maxRadius: 7,
              minRadius: 5,
              child: FittedBox(child: Text(cartCount.toString())),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget getVendorWidget(VendorResponse vendor, BuildContext context, {double width = 300}) {
  var productWidth = MediaQuery.of(context).size.width;

  String img = vendor.banner.isNotEmpty ? vendor.banner.validate() : '';

  var addressText = "";
  if (vendor.address.street_1.isNotEmpty && addressText.isEmpty) {
    addressText = vendor.address.street_1;
  }
  if (vendor.address.street_2.isNotEmpty) {
    if (addressText.isEmpty) {
      addressText = vendor.address.street_2;
    } else {
      addressText += ", " + vendor.address.street_2;
    }
  }

  if (vendor.address.city.isNotEmpty) {
    if (addressText.isEmpty) {
      addressText = vendor.address.city;
    } else {
      addressText += ", " + vendor.address.city;
    }
  }
  if (vendor.address.zip.isNotEmpty) {
    if (addressText.isEmpty) {
      addressText = vendor.address.zip;
    } else {
      addressText += " - " + vendor.address.zip;
    }
  }
  if (vendor.address.state.isNotEmpty) {
    if (addressText.isEmpty) {
      addressText = vendor.address.state;
    } else {
      addressText += ", " + vendor.address.state;
    }
  }
  if (!vendor.address.country.isNotEmpty) {
    if (addressText.isEmpty) {
      addressText = vendor.address.country;
    } else {
      addressText += ", " + vendor.address.country;
    }
  }

  return Container(
    width: width,
    decoration: boxDecoration(context, showShadow: true, radius: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          child: Image.network(
            img,
            height: 140,
            width: productWidth,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(vendor.gravatar),
                radius: 35,
              ),
              spacing_middle.width,
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  spacing_control.height,
                  Text(
                    vendor.store_name,
                    style: boldTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: textSizeMedium),
                  ),
                  spacing_control.height,
                  Text(
                    addressText,
                    maxLines: 3,
                    style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium),
                  ),
                ],
              ).expand(),
            ],
          ),
        ).paddingAll(8),
      ],
    ),
    margin: EdgeInsets.all(8.0),
  );
}

Widget vendorList(List<VendorResponse> product) {
  return Container(
    height: 270,
    alignment: Alignment.centerLeft,
    child: ListView.builder(
      itemCount: product.length,
      padding: EdgeInsets.only(left: 8, right: 8),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, i) {
        return GestureDetector(
          onTap: () {
            VendorProfileScreen(mVendorId: product[i].id).launch(context);
          },
          child: getVendorWidget(
            product[i],
            context,
          ),
        );
      },
    ),
  );
}

Widget mVendorWidget(BuildContext context, List<VendorResponse> mVendorModel, {size: textSizeMedium}) {
  return mVendorModel.isNotEmpty?Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Vendors", style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: size)),
          Text("View All", style: boldTextStyle(color: Theme.of(context).textTheme.headline6.color, size: textSizeMedium)).onTap(() {
            VendorListScreen().launch(context);
          }),
        ],
      ).paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()).visible(mVendorModel.isNotEmpty),
      spacing_standard.height,
      vendorList(mVendorModel),
      spacing_standard.height,
    ],
  ):SizedBox();
}

Widget mCart(BuildContext context,bool mIsLoggedIn,{Color color=Colors.white,}){
  return Stack(
    overflow: Overflow.visible,
    alignment: Alignment.center,
    children: [
      IconButton(
        onPressed: () {
          checkLoggedIn(context, MyCartScreen.tag);
        },
        icon: Icon(Icons.shopping_cart, size: 30, color: color),
      ),
      if(appStore.count.toString()!="0")
        Positioned(
          top: 5,
          right: 10,
          child: Observer(
            builder: (_) => CircleAvatar(
              maxRadius: 7,
              minRadius: 5,
              backgroundColor: color,
              child: FittedBox(child: Text('${appStore.count}', style: Theme.of(context).textTheme.headline3)),
            ),
          ),
        ).visible(mIsLoggedIn),
    ],
  );
}