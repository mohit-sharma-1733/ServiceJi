// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AppStore on AppStoreBase, Store {
  final _$isDarkModeOnAtom = Atom(name: 'AppStoreBase.isDarkModeOn');

  @override
  bool get isDarkModeOn {
    _$isDarkModeOnAtom.reportRead();
    return super.isDarkModeOn;
  }

  @override
  set isDarkModeOn(bool value) {
    _$isDarkModeOnAtom.reportWrite(value, super.isDarkModeOn, () {
      super.isDarkModeOn = value;
    });
  }

  final _$selectedLanguageAtom = Atom(name: 'AppStoreBase.selectedLanguage');

  @override
  String get selectedLanguage {
    _$selectedLanguageAtom.reportRead();
    return super.selectedLanguage;
  }

  @override
  set selectedLanguage(String value) {
    _$selectedLanguageAtom.reportWrite(value, super.selectedLanguage, () {
      super.selectedLanguage = value;
    });
  }

  final _$countAtom = Atom(name: 'AppStoreBase.count');

  @override
  int get count {
    _$countAtom.reportRead();
    return super.count;
  }

  @override
  set count(int value) {
    _$countAtom.reportWrite(value, super.count, () {
      super.count = value;
    });
  }

  final _$toggleDarkModeAsyncAction =
      AsyncAction('AppStoreBase.toggleDarkMode');

  @override
  Future<void> toggleDarkMode({bool value}) {
    return _$toggleDarkModeAsyncAction
        .run(() => super.toggleDarkMode(value: value));
  }

  final _$AppStoreBaseActionController = ActionController(name: 'AppStoreBase');

  @override
  void increment() {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.increment');
    try {
      return super.increment();
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void decrement() {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.decrement');
    try {
      return super.decrement();
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLanguage(String aLanguage) {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.setLanguage');
    try {
      return super.setLanguage(aLanguage);
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCount(int aCount) {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.count');
    try {
      return super.setCount(aCount);
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }



  @override
  String toString() {
    return '''
isDarkModeOn: ${isDarkModeOn},
selectedLanguage: ${selectedLanguage},
count: ${count}
    ''';
  }
}
