import 'package:flutter/material.dart';
import 'package:ServiceJi/main.dart';

class CountState with ChangeNotifier {
  int count = 0;

  CountState({this.count});

  void increment() {
    count++;
    notifyListeners();
  }

  void decrement() {
    count--;
    notifyListeners();
  }
}
