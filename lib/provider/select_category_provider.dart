import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/model/category.dart';

final selectCategoryNotifierProvider =
    NotifierProvider<SelectCategoryNotifier, Category?>(
        SelectCategoryNotifier.new);

final selectSubCategoryNotifierProvider =
    NotifierProvider<SelectCategoryNotifier, Category?>(
        SelectCategoryNotifier.new);

class SelectCategoryNotifier extends Notifier<Category?> {
  @override
  Category? build() {
    debugPrint("class build");
    return null;
  }

  void updateCategory(Category? newCategory) {
    debugPrint("setCategory");
    state = newCategory;
  }

  void initialize() {
    debugPrint("initialize");
    state = null;
  }
}
