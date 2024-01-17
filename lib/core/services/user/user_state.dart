import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  bool shouldFetchUserData = true;

  void setShouldFetchUserData(bool value) {
    shouldFetchUserData = value;
    notifyListeners();
  }
}
