import 'package:flutter/material.dart';

//----状態管理-------------------
class MyAppState extends ChangeNotifier {
  //---fav機能---
  void getNext() {
    notifyListeners();
  }

  void toggleFavorite() {
    notifyListeners(); //状態遷移の通知
  }

  void unfavolite() {
    notifyListeners();
  }
}
