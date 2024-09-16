import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/view_model/category_db_provider.dart';

final selectCategoryNotifierProvider =
    NotifierProvider<SelectCategoryNotifier, Category?>(
        SelectCategoryNotifier.new);

final selectSubCategoryNotifierProvider =
    NotifierProvider<SelectCategoryNotifier, Category?>(
        SelectCategoryNotifier.new);

class SelectCategoryNotifier extends Notifier<Category?> {
  @override
  Category? build() {
    return null;
  }

  void updateCategory(Category? newCategory) {
    state = newCategory;
  }
}

final registerCategoryStateNotifierProvider =
    NotifierProvider<RegisterCategoryStateNotifier, RegisterCategoryState>(
        RegisterCategoryStateNotifier.new);

class RegisterCategoryStateNotifier extends Notifier<RegisterCategoryState> {
  @override
  RegisterCategoryState build() {
    return RegisterCategoryState();
  }

  void updateCategory(Category? newCategory, Category? newSubCategory) {
    state = state.copyWith(category: newCategory, subCategory: newSubCategory);
  }

  void updateOnlyCategory(Category? newCategory) {
    state =
        state.copyWith(category: newCategory, subCategory: state.subCategory);
  }

  void updateSubCategory(Category? newSubCategory) {
    state =
        state.copyWith(subCategory: newSubCategory, category: state.category);
  }

  void initCategory() {
    final categoryList = ref.read(categoryListNotifierProvider);
    Category? returnCategory;
    if (categoryList.value == null || categoryList.value!.isEmpty) {
      returnCategory = null;
    } else {
      if (state.fromRegisterView) {
        if (state.isAddCategory) {
          returnCategory = categoryList.value!.last;
        } else {
          returnCategory = state.saveCategory;
        }
      } else {
        returnCategory = categoryList.value![0];
      }
    }

    state = state.copyWith(
      category: returnCategory,
      subCategory: null,
    );
  }

  void initSubCategory(Category? lastCategory) {
    state = state.copyWith(
      category: state.category,
      subCategory: state.fromRegisterView
          ? (state.isAddCategory ? lastCategory : state.saveSubCategory)
          : null,
    );
  }

  //registerPageから遷移時に実行
  void saveCategory() {
    state = state.copyWithSave();
  }

  //registerPageにpopした時実行
  void resetIsRoute() {
    state = state.copyWithReset();
  }

  //新規登録した際に実行
  void setAddCategory() {
    state = state.copyWithAdd();
  }
}

class RegisterCategoryState {
  final Category? category;
  final Category? subCategory;
  final Category? saveCategory;
  final Category? saveSubCategory;
  final bool fromRegisterView;
  final bool isAddCategory;

  RegisterCategoryState({
    this.category,
    this.subCategory,
    this.saveCategory,
    this.saveSubCategory,
    this.fromRegisterView = false,
    this.isAddCategory = false,
  });

  RegisterCategoryState copyWith({
    required Category? category,
    required Category? subCategory,
  }) {
    return RegisterCategoryState(
      category: category,
      subCategory: subCategory,
      saveCategory: saveCategory,
      saveSubCategory: saveSubCategory,
      fromRegisterView: fromRegisterView,
      isAddCategory: isAddCategory,
    );
  }

  RegisterCategoryState copyWithReset() {
    return RegisterCategoryState(
      category: category,
      subCategory: subCategory,
      saveCategory: null,
      saveSubCategory: null,
      fromRegisterView: false,
      isAddCategory: false,
    );
  }

  RegisterCategoryState copyWithSave() {
    return RegisterCategoryState(
      category: category,
      subCategory: subCategory,
      saveCategory: category,
      saveSubCategory: subCategory,
      fromRegisterView: true,
    );
  }

  RegisterCategoryState copyWithAdd() {
    return RegisterCategoryState(
      category: category,
      subCategory: subCategory,
      saveCategory: category,
      saveSubCategory: subCategory,
      isAddCategory: true,
      fromRegisterView: fromRegisterView,
    );
  }
}
