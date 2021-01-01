import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/main.dart';

import 'colors.dart';
import 'common.dart';

class SearchBar extends StatefulWidget {
  static String tag = '/SearchBar';

  final void Function(String) onTextChange;
  final String hintText;

  SearchBar({this.onTextChange, this.hintText});

  @override
  SearchBarState createState() => SearchBarState();
}

class SearchBarState extends State<SearchBar> {
  var primaryColor;
  var controller = TextEditingController();
  var searchText = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    primaryColor = await getThemeColor();
    setState(() {});
    controller.addListener(() {
      setState(() {
        searchText = controller.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onFieldSubmitted: widget.onTextChange,
        style: secondaryTextStyle(color: colorAccent, size: 18),
        decoration: InputDecoration(
            suffixIcon: searchText.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: textPrimaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        controller.clear();
                      });
                    },
                  )
                : SizedBox(),
            hintText: widget.hintText,
            hintStyle: secondaryTextStyle(color: colorAccent, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.only(left: 0, right: 0)));
  }
}
