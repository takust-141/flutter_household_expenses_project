import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/provider/select_expenses_provider.dart';
import 'package:household_expenses_project/view_model/category_db_helper.dart';
import 'package:household_expenses_project/model/category.dart';

//Provider
final categoryListNotifierProvider =
    AsyncNotifierProvider<CategoryNotifier, List<Category>>(
        CategoryNotifier.new);

final subCategoryListNotifierProvider =
    AsyncNotifierProvider<SubCategoryNotifier, List<Category>>(
        SubCategoryNotifier.new);

//registerView用
final subCategoryRegisterListNotifierProvider =
    AsyncNotifierProvider<SubCategoryRegisterNotifier, List<Category>>(
        SubCategoryRegisterNotifier.new);

//CategoryNotifier
class CategoryNotifier extends AsyncNotifier<List<Category>> {
  final CategoryDBHelper _categoryDBHelper = CategoryDBHelper();

  //初期作業・初期値
  @override
  Future<List<Category>> build() async {
    debugPrint("CategoryNotifier build");
    return await getAllCategory(SelectExpenses.income);
  }

  Future<List<Category>> getAllCategory(SelectExpenses expenses) async {
    return await _categoryDBHelper.getAllCategory(expenses);
  }

  Future insertCategory({
    required String name,
    required IconData icon,
    required Color color,
    required SelectExpenses expenses,
  }) async {
    final List<Category>? list = state.value;

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
      await _categoryDBHelper.insertCategory(category);
      return await getAllCategory(expenses);
    });
  }

  Future deleteCategoryFromId(int id, SelectExpenses expenses) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _categoryDBHelper.deleteCategoryFromId(id);
      return await getAllCategory(expenses);
    });
  }

  Future updateCategory(Category category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _categoryDBHelper.updateCategory(category);
      return await getAllCategory(category.expenses);
    });
  }

  void reacquisitionCategoryList(SelectExpenses expenses) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await getAllCategory(expenses));
  }

  //idは一意のため一件のみ返す
  Future<Category?> getCategoryFromId(int id) async {
    return await _categoryDBHelper.getCategoryFromId(id);
  }
}

//サブカテゴリー
class SubCategoryNotifier extends CategoryNotifier {
  //初期作業・初期値
  @override
  Future<List<Category>> build() async {
    ref.listen(
      selectCategoryNotifierProvider,
      (previous, next) async {
        updateSubCategory(ref.watch(selectExpenses));
      },
    );
    return await getAllCategory(SelectExpenses.income);
  }

  @override
  Future<List<Category>> getAllCategory(SelectExpenses expenses) async {
    final selectCategoryProvider = ref.watch(selectCategoryNotifierProvider);
    return await _categoryDBHelper.getAllSubCategory(
        expenses, selectCategoryProvider?.id);
  }

  Future<void> updateSubCategory(SelectExpenses expenses) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await getAllCategory(expenses));
  }

  Future<void> insertSubCategory({
    required String name,
    required IconData icon,
    required Color color,
    required int parentId,
    required SelectExpenses expenses,
  }) async {
    final List<Category>? list = state.value;

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
        parentId: parentId,
        expenses: expenses,
      );
      await _categoryDBHelper.insertCategory(category);
      return await getAllCategory(expenses);
    });
  }
}

//register用サブカテゴリー
class SubCategoryRegisterNotifier extends SubCategoryNotifier {
  //初期作業・初期値
  @override
  Future<List<Category>> build() async {
    //registerカテゴリーリストのリスナー
    ref.listen(
      registerCategoryStateNotifierProvider
          .select((categoryState) => categoryState.category),
      (previous, next) async {
        updateSubCategory(ref.watch(selectExpenses));
      },
    );
    //サブカテゴリーリストのリスナー
    ref.listen(
      subCategoryListNotifierProvider,
      (previous, next) async {
        updateSubCategory(ref.watch(selectExpenses));
      },
    );
    return await getAllCategory(SelectExpenses.income);
  }

  @override
  Future<List<Category>> getAllCategory(SelectExpenses expenses) async {
    final selectCategoryProvider =
        ref.watch(registerCategoryStateNotifierProvider);
    return await _categoryDBHelper.getAllSubCategory(
        expenses, selectCategoryProvider.category?.id);
  }
}
