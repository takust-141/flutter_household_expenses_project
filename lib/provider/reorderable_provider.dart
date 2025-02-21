import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/model/register_recurring.dart';
import 'package:household_expense_project/provider/category_list_provider.dart';
import 'package:household_expense_project/provider/register_recurring_list_provider.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';

//Provider
final reorderableProvider =
    NotifierProvider<ReorderableNotifier, ReorderableState>(
        ReorderableNotifier.new);

@immutable
class ReorderableState {
  final bool isCategoryReorder;
  final List<Category> reorderCategoryList;

  final bool isSubCategoryReorder;
  final List<Category> reorderSubCategoryList;

  final bool isRecurringReorder;
  final List<RegisterRecurring> reorderRecurringList;

  const ReorderableState({
    required this.isCategoryReorder,
    required this.reorderCategoryList,
    required this.isSubCategoryReorder,
    required this.reorderSubCategoryList,
    required this.isRecurringReorder,
    required this.reorderRecurringList,
  });

  ReorderableState copyWith({
    bool? isCategoryReorder,
    List<Category>? reorderCategoryList,
    bool? isSubCategoryReorder,
    List<Category>? reorderSubCategoryList,
    bool? isRecurringReorder,
    List<RegisterRecurring>? reorderRecurringList,
  }) {
    return ReorderableState(
      isCategoryReorder: isCategoryReorder ?? this.isCategoryReorder,
      reorderCategoryList: reorderCategoryList ?? this.reorderCategoryList,
      isSubCategoryReorder: isSubCategoryReorder ?? this.isSubCategoryReorder,
      reorderSubCategoryList:
          reorderSubCategoryList ?? this.reorderSubCategoryList,
      isRecurringReorder: isRecurringReorder ?? this.isRecurringReorder,
      reorderRecurringList: reorderRecurringList ?? this.reorderRecurringList,
    );
  }
}

//Notifier
class ReorderableNotifier extends Notifier<ReorderableState> {
  @override
  ReorderableState build() {
    return ReorderableState(
      isCategoryReorder: false,
      reorderCategoryList: [],
      isSubCategoryReorder: false,
      reorderSubCategoryList: [],
      isRecurringReorder: false,
      reorderRecurringList: [],
    );
  }

  //init
  void initReorderState() {
    state = state.copyWith(
      isCategoryReorder: false,
      reorderCategoryList: [],
      isSubCategoryReorder: false,
      reorderSubCategoryList: [],
      isRecurringReorder: false,
      reorderRecurringList: [],
    );
  }

  //
  //カテゴリーリスト用
  //change
  void changeCategoryReorder(BuildContext context) {
    List<Category> categorylist = state.reorderCategoryList;
    //並び替え完了時に更新
    if (state.isCategoryReorder == true &&
        state.reorderCategoryList.isNotEmpty) {
      //カテゴリーリスト更新
      ref
          .read(categoryListNotifierProvider.notifier)
          .updateCategoryOrder(categorylist, context);
      categorylist = [];
    }
    state = state.copyWith(
      isCategoryReorder: !state.isCategoryReorder,
      reorderCategoryList: categorylist,
    );
  }

  //リオーダー
  void setReorderCategoryList(List<Category> categoryList) {
    state = state.copyWith(reorderCategoryList: categoryList);
  }

  //
  //サブカテゴリーリスト用
  //change
  void changeSubCategoryReorder(BuildContext context) {
    List<Category> subCategorylist = state.reorderSubCategoryList;
    //並び替え完了時に更新
    if (state.isSubCategoryReorder == true &&
        state.reorderSubCategoryList.isNotEmpty) {
      //サブカテゴリーリスト更新
      ref
          .read(settingCategoryStateNotifierProvider.notifier)
          .updateSubCategoryOrderOfDB(subCategorylist, context);
      subCategorylist = [];
    }
    state = state.copyWith(
      isSubCategoryReorder: !state.isSubCategoryReorder,
      reorderSubCategoryList: subCategorylist,
    );
  }

  //リオーダー
  void setReorderSubCategoryList(List<Category> subCategoryList) {
    state = state.copyWith(reorderSubCategoryList: subCategoryList);
  }

  //リカーリングリスト用
  //change
  void changeRecurringReorder(BuildContext context) {
    List<RegisterRecurring> recurringlist = state.reorderRecurringList;
    //並び替え完了時に更新
    if (state.isRecurringReorder == true &&
        state.reorderRecurringList.isNotEmpty) {
      //リカーリングリスト更新
      ref
          .read(registerRecurringListNotifierProvider.notifier)
          .updateRecurringListOrder(recurringlist, context);
      recurringlist = [];
    }
    state = state.copyWith(
      isRecurringReorder: !state.isRecurringReorder,
      reorderRecurringList: recurringlist,
    );
  }

  //リオーダー
  void setReorderRecurringList(List<RegisterRecurring> recurringList) {
    state = state.copyWith(reorderRecurringList: recurringList);
  }
}
