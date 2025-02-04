import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/register_snackbar.dart';
import 'package:household_expense_project/component/setting_component.dart';
import 'package:household_expense_project/provider/register_db_provider.dart';
import 'package:household_expense_project/provider/register_recurring_list_provider.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/view_model/category_db_helper.dart';
import 'package:household_expense_project/model/category.dart';

//メインカテゴリーのリスト（全てのページで共通）
//Provider
final categoryListNotifierProvider =
    AsyncNotifierProvider<CategoryNotifier, Map<SelectExpense, List<Category>>>(
        CategoryNotifier.new);

//CategoryNotifier
class CategoryNotifier
    extends AsyncNotifier<Map<SelectExpense, List<Category>>> {
  //初期作業・初期値
  @override
  Future<Map<SelectExpense, List<Category>>> build() async {
    return await getAllCategory();
  }

  //カテゴリーリスト更新（registerリスト、セレクタ更新）
  Future<Map<SelectExpense, List<Category>>> getAllCategory() async {
    final categoryLists = await CategoryDBHelper.getAllCategory();
    final categoryListMap = {
      SelectExpense.outgo: categoryLists.$1,
      SelectExpense.income: categoryLists.$2,
    };

    //各SelectCategoryStateの更新
    await Future.wait([
      ref
          .read(registerCategoryStateNotifierProvider.notifier)
          .resetSelectCategoryState(categoryListMap),
      ref
          .read(registerEditCategoryStateNotifierProvider.notifier)
          .resetSelectCategoryState(categoryListMap),
      ref
          .read(settingCategoryStateNotifierProvider.notifier)
          .resetSelectCategoryState(categoryListMap),
    ]);

    return categoryListMap;
  }

  //カテゴリー登録
  Future insertCategory({
    required String name,
    required IconData icon,
    required Color color,
    required SelectExpense expense,
    required BuildContext context,
  }) async {
    final List<Category>? list = state.valueOrNull?[expense];

    bool isError = false;
    state = const AsyncValue.loading();
    final IndicatorOverlay indicatorOverlay = IndicatorOverlay();
    indicatorOverlay.insertOverlay(context);
    try {
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
        expense: expense,
      );
      await CategoryDBHelper.insertCategory(category);
    } catch (e, stackTrace) {
      isError = true;
      state = AsyncValue.error(e, stackTrace);
    } finally {
      //カテゴリー更新
      await updateCategoryListState();
      indicatorOverlay.removeOverlay();
      //スナックバー表示
      if (context.mounted) {
        updateSnackBarCallBack(
          text: isError ? 'カテゴリーの登録に失敗しました' : 'カテゴリーを登録しました',
          context: context,
          isError: isError,
        );
      }
    }
  }

  //メインカテゴリー削除処理
  //register削除 → サブカテゴリーとメインカテゴリー削除 → リスト、各state更新
  Future deleteCategoryFromId(int id, BuildContext context) async {
    bool isError = false;
    state = const AsyncValue.loading();
    final IndicatorOverlay indicatorOverlay = IndicatorOverlay();
    indicatorOverlay.insertOverlay(context);
    try {
      //register削除→カテゴリーとサブカテゴリー削除
      await CategoryDBHelper.deleteCategoryFromId(id);
    } catch (e, stackTrace) {
      isError = true;
      state = AsyncValue.error(e, stackTrace);
    } finally {
      await Future.wait([
        //カテゴリー更新
        updateCategoryListState(),
        //register更新
        _refreshRegister(),
        //recurring register更新
        ref
            .read(registerRecurringListNotifierProvider.notifier)
            .refreshFromCategory(ref),
      ]);

      indicatorOverlay.removeOverlay();
      //スナックバー表示
      if (context.mounted) {
        updateSnackBarCallBack(
          text: isError ? 'カテゴリーの削除に失敗しました' : 'カテゴリーを削除しました',
          context: context,
          isError: isError,
        );
      }
    }
  }

  //カテゴリー更新
  Future updateCategory(Category category, BuildContext context) async {
    bool isError = false;
    state = const AsyncValue.loading();
    final IndicatorOverlay indicatorOverlay = IndicatorOverlay();
    indicatorOverlay.insertOverlay(context);
    try {
      await CategoryDBHelper.updateCategory(category);
    } catch (e, stackTrace) {
      isError = true;
      state = AsyncValue.error(e, stackTrace);
    } finally {
      await Future.wait([
        //カテゴリー更新
        updateCategoryListState(),
        //register更新
        _refreshRegister(),
      ]);

      indicatorOverlay.removeOverlay();
      //スナックバー表示
      if (context.mounted) {
        updateSnackBarCallBack(
          text: isError ? 'カテゴリーの更新に失敗しました' : 'カテゴリーを更新しました',
          context: context,
          isError: isError,
        );
      }
    }
  }

  Future<void> updateCategoryListState() async {
    state = AsyncValue.data(await getAllCategory());
  }

  //idからメインカテゴリを返す（現在のstateから）
  Category? getMainCategoryFromId(int id, SelectExpense selectExpense) {
    if (state.valueOrNull?[selectExpense] == null) {
      return null;
    }
    Category? targetCategory;
    for (Category categoryItem in state.value![selectExpense]!) {
      if (categoryItem.id == id) {
        targetCategory = categoryItem;
        break;
      }
    }
    return targetCategory;
  }

  //idは一意のため一件のみ返す
  Future<Category?> getCategoryFromId(int id) async {
    return await CategoryDBHelper.getCategoryFromId(id);
  }

  //register更新
  Future<void> _refreshRegister() async {
    //registerリスト＋セレクタ更新
    await RegisterDBProvider.refreshFromCategory(ref);
  }
}
