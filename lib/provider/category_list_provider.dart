import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/view_model/category_db_helper.dart';
import 'package:household_expenses_project/model/category.dart';

//Provider
final categoryListNotifierProvider = AsyncNotifierProvider<CategoryNotifier,
    Map<SelectExpenses, List<Category>>>(CategoryNotifier.new);

//CategoryNotifier
class CategoryNotifier
    extends AsyncNotifier<Map<SelectExpenses, List<Category>>> {
  //初期作業・初期値
  @override
  Future<Map<SelectExpenses, List<Category>>> build() async {
    debugPrint("CategoryNotifier build");
    return await getAllCategory();
  }

  Future<Map<SelectExpenses, List<Category>>> getAllCategory() async {
    final categoryListMap = {
      SelectExpenses.outgo:
          await CategoryDBHelper.getAllCategory(SelectExpenses.outgo),
      SelectExpenses.income:
          await CategoryDBHelper.getAllCategory(SelectExpenses.income),
    };

    //各SelectCategoryStateの更新
    ref
        .read(settingCategoryStateNotifierProvider.notifier)
        .resetSelectCategoryState(categoryListMap);
    ref
        .read(registerCategoryStateNotifierProvider.notifier)
        .resetSelectCategoryState(categoryListMap);
    ref
        .read(registerEditCategoryStateNotifierProvider.notifier)
        .resetSelectCategoryState(categoryListMap);
    return categoryListMap;
  }

  Future insertCategory({
    required String name,
    required IconData icon,
    required Color color,
    required SelectExpenses expenses,
  }) async {
    final List<Category>? list = state.value?[expenses];

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      int maxOrder = 0;
      if (list != null) {
        for (int i = 0; i < list.length; i++) {
          if (maxOrder < list[i].order) {
            maxOrder = list[i].order;
          }
        }
      }
      Category category = Category(
        name: name,
        icon: icon,
        color: color,
        order: maxOrder + 1,
        expenses: expenses,
      );
      await CategoryDBHelper.insertCategory(category);
      return await getAllCategory();
    });
  }

  Future deleteCategoryFromId(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await CategoryDBHelper.deleteCategoryFromId(id);
      return await getAllCategory();
    });
  }

  Future updateCategory(Category category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await CategoryDBHelper.updateCategory(category);
      return await getAllCategory();
    });
  }

  void reacquisitionCategoryList() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await getAllCategory());
  }

  //idは一意のため一件のみ返す
  Future<Category?> getCategoryFromId(int id) async {
    return await CategoryDBHelper.getCategoryFromId(id);
  }
}
