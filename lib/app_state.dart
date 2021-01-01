import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  Locale locale = Locale('en');
  var selectedLanguageCode = 'en';
  Color color;
  var wishListCount = 0;
  bool isDarkTheme = false;
  int count = 0;

  set setThemeData(bool val) {
    if (val) {
      isDarkTheme = true;
    } else {
      isDarkTheme = false;
    }
    notifyListeners();
  }

  AppState(lang, {isDarkMode = false}) {
    selectedLanguageCode = lang;
    if (lang == "en" || lang == "fr" || lang == "af" || lang == "de" || lang == "es" || lang == "in" || lang == "vi" || lang == "tr" || lang == "hi" || lang == "ar") {
      selectedLanguageCode = lang;
    } else {
      selectedLanguageCode = 'en';
    }
    isDarkTheme = isDarkMode;
  }

  Locale get getLocale => locale;

  get getSelectedLanguageCode => selectedLanguageCode;

  get getWishListCount => wishListCount;

  setLocale(locale) => this.locale = locale;

  setSelectedLanguageCode(code) => this.selectedLanguageCode = code;

  changeLocale(Locale l) {
    var lang = l.languageCode;
    if (lang == "en" || lang == "fr" || lang == "af" || lang == "de" || lang == "es" || lang == "in" || lang == "vi" || lang == "tr" || lang == "hi" || lang == "ar") {
      locale = l;
      notifyListeners();
    } else {
      locale = 'en' as Locale;
      notifyListeners();
    }
  }

  changeMode(isDarkMode) {
    isDarkTheme = isDarkMode;
    notifyListeners();
  }

  changeLanguageCode(code) {
    if (code == "en" || code == "fr" || code == "af" || code == "de" || code == "es" || code == "in" || code == "vi" || code == "tr" || code == "hi" || code == "ar") {
      selectedLanguageCode = code;
      notifyListeners();
    } else {
      selectedLanguageCode = 'en';
      notifyListeners();
    }
  }

  changeWishListCount(count) {
    wishListCount = count;
    notifyListeners();
  }

  void increment() {
    count++;
    notifyListeners();
  }

  void decrement() {
    count--;
    notifyListeners();
  }
}
