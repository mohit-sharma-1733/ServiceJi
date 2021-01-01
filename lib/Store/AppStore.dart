import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:ServiceJi/app_theme.dart';
part 'AppStore.g.dart';

class AppStore = AppStoreBase with _$AppStore;

abstract class AppStoreBase with Store {
  @observable
  bool isDarkModeOn = false;

  @observable
  String selectedLanguage = 'en';

  @observable
  int count = 0;

  @action
  Future<void> toggleDarkMode({bool value}) async {
    isDarkModeOn = value ?? !isDarkModeOn;
  }

  @action
  void increment() {
    count++;
  }

  @action
  void decrement() {
    count--;
  }

  @action
  void setLanguage(String aLanguage) => selectedLanguage = aLanguage;

  @action
  void setCount(int aCount) => count = aCount;
}
