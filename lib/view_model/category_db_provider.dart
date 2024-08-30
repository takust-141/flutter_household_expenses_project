import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
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
    return await getAllCategory();
  }

  Future<List<Category>> getAllCategory() async {
    return await _categoryDBHelper.getAllCategory();
  }

  Future insertCategory(
      {required String name,
      required IconData icon,
      required Color color}) async {
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
      );
      await _categoryDBHelper.insertCategory(category);
      return await getAllCategory();
    });
  }

  Future deleteCategoryFromId(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _categoryDBHelper.deleteCategoryFromId(id);
      return await getAllCategory();
    });
  }

  Future updateCategory(Category category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _categoryDBHelper.updateCategory(category);
      return await getAllCategory();
    });
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
        updateSubCategory();
      },
    );
    return await getAllCategory();
  }

  @override
  Future<List<Category>> getAllCategory() async {
    final selectCategoryProvider = ref.watch(selectCategoryNotifierProvider);
    return await _categoryDBHelper
        .getAllSubCategory(selectCategoryProvider?.id);
  }

  Future<void> updateSubCategory() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await getAllCategory());
  }

  Future<void> insertSubCategory({
    required String name,
    required IconData icon,
    required Color color,
    required int parentId,
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
      );
      await _categoryDBHelper.insertCategory(category);
      return await getAllCategory();
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
        updateSubCategory();
      },
    );
    //サブカテゴリーリストのリスナー
    ref.listen(
      subCategoryListNotifierProvider,
      (previous, next) async {
        updateSubCategory();
      },
    );
    return await getAllCategory();
  }

  @override
  Future<List<Category>> getAllCategory() async {
    final selectCategoryProvider =
        ref.watch(registerCategoryStateNotifierProvider);
    return await _categoryDBHelper
        .getAllSubCategory(selectCategoryProvider.category?.id);
  }
}
