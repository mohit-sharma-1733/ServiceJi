import 'package:ServiceJi/models/BuilderResponse.dart';
import 'package:ServiceJi/models/ProductDetailResponse.dart';
import 'package:ServiceJi/screen/DashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:ServiceJi/screen/MyCartScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ServiceJi/screen/SearchScreen.dart';
import 'package:url_launcher/url_launcher.dart';


import 'CategoriesScreen.dart';

class HomeScreen extends StatefulWidget {
  static String tag = '/HomeScreen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin{
  void _launchCaller(int number) async{
    var url = "tel:${number.toString()}";
    if(await canLaunch(url)){

      await launch(url);
    }else{
      throw 'Could not Place Call';
    }
  }
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animationIcon;
  Animation<double> _translateButton;
  Curve _curve =  Curves.easeOut;
  double _fabHeight = 56.0;

  List<Widget> _widgetList = [
    DashboardScreen(),
    CategoriesScreen(),
    SearchScreen(),
    MyCartScreen(),

  ];
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
         // tooltip: 'Call',

       icon :  Icon(Icons.phone),
        label : Text('Call Us'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,

        onPressed: () {
            _launchCaller(9622131653);
    },
        ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          // ignore: deprecated_member_use
          BottomNavigationBarItem(

            icon: Icon(
              //CartIcons.home,
                Icons.home_outlined
            ),
            // ignore: deprecated_member_use
            title: Text('Home'),
          ),

          BottomNavigationBarItem(
            icon: Icon(
              //CartIcons.favourites,
              Icons.widgets_sharp,
            ),
            // ignore: deprecated_member_use
            title: Text('Services'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              // CartIcons.cart,
                Icons.search
            ),
            // ignore: deprecated_member_use
            title: Text('Search'),
          ),
          BottomNavigationBarItem(

            icon: Icon(
              Icons.shopping_cart,

            ),


            // ignore: deprecated_member_use
            title: Text('My List'),
          ),
        ],
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.shifting,
        currentIndex: _index,
        onTap: (index) {
          setState(() {
            _index = index;
          });
        },
      ),
      body:
          _widgetList[_index],

    );
  }
}
