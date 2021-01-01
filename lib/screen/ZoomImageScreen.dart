import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ZoomImageScreen extends StatefulWidget {
  final mProductImage;

  ZoomImageScreen({Key key, this.mProductImage}) : super(key: key);

  @override
  _ZoomImageScreenState createState() => _ZoomImageScreenState();
}

class _ZoomImageScreenState extends State<ZoomImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoView(
      imageProvider: NetworkImage(widget.mProductImage),
    ));
  }
}
