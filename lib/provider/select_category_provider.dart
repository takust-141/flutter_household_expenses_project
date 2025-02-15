import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/register_snackbar.dart';
import 'package:household_expense_project/component/setting_component.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/provider/register_db_provider.dart';
import 'package:household_expense_project/provider/register_recurring_list_provider.dart';
import 'package:household_expense_project/provider/select_expense_state.dart';
import 'package:household_expense_project/view_model/category_db_helper.dart';
import 'package:household_expense_project/provider/category_list_provider.dart';
export 'package:household_expense_project/provider/select_expense_state.dart';

//選択しているカテゴリーのサブカテゴリー（状態ごとに異なる）
//Select Category Provider
final settingCategoryStateNotifierProvider =
    NotifierProvider<SelectCategoryStateNotifier, SelectCategoryState>(
        SelectCategoryStateNotifier.new);

final registerCategoryStateNotifierProvider =
    NotifierProvider<SelectCategoryStateNotifier, SelectCategoryState>(
        SelectCategoryStateNotifier.new);

final registerEditCategoryStateNotifierProvider =
    NotifierProvider<SelectCategoryStateNotifier, SelectCategoryState>(
        SelectCategoryStateNotifier.new);

//画面遷移時の共有用
final List<NotifierProvider<SelectCategoryStateNotifier, SelectCategoryState>>
    selectCategoryProviderList = [
  settingCategoryStateNotifierProvider, //index=0
  registerCategoryStateNotifierProvider, //index=1
  registerEditCategoryStateNotifierProvider, //index=2
];

@immutable
class SelectCategoryState extends SelectExpenseState {
  final Category? category;
  final Category? subCategory;
  final List<Category>? subCategoryList;
  final Category? nextInitCategory; /*registerPageでのカスタムキーボードからの遷移用パラメータ */
  final Category? nextInitSubCategory; /*同上*/
  @override
  final SelectExpense selectExpense;

  SelectCategoryState({
    required this.category,
    required this.subCategory,
    required this.subCategoryList,
    this.nextInitCategory,
    this.nextInitSubCategory,
    required this.selectExpense,
  });

  SelectCategoryState copyWith({
    required Category? category,
    required Category? subCategory,
  }) {
    return SelectCategoryState(
      category: category,
      subCategory: subCategory,
      subCategoryList: subCategoryList,
      nextInitCategory: nextInitCategory,
      nextInitSubCategory: nextInitSubCategory,
      selectExpense: selectExpense,
    );
  }

  //収支切り替え（一部初期化）
  SelectCategoryState copyWithExpense(
    Category? category,
    List<Category> subCategoryList,
    SelectExpense selectExpense,
  ) {
    return SelectCategoryState(
      category: category,
      subCategory: null,
      subCategoryList: subCategoryList,
      nextInitCategory: null,
      nextInitSubCategory: null,
      selectExpense: selectExpense,
    );
  }
}

//Notifier
class SelectCategoryStateNotifier
    extends SelectExpenseStateNotifier<SelectCategoryState> {
  @override
  SelectCategoryState build() {
    ref.read(categoryListNotifierProvider);
    return SelectCategoryState(
      category: null,
      subCategory: null,
      subCategoryList: const [],
      selectExpense: SelectExpense.outgo,
    );
  }

  //サブカテゴリー更新
  Future<List<Category>> getSubCategoryList(int? parentId) async {
    if (parentId == null) {
      return [];
    } else {
      return await CategoryDBHelper.getAllSubCategory(parentId);
    }
  }

  //現在のregisterListを元に更新（新規追加時）
  Future<void> setInit({bool isCurrentExpense = false}) async {
    late final SelectExpense defaultSelectExpense;
    if (isCurrentExpense) {
      defaultSelectExpense = state.selectExpense;
    } else {
      defaultSelectExpense = SelectExpense.outgo;
    }

    Category? initCategory = (ref
                .read(categoryListNotifierProvider)
                .valueOrNull?[defaultSelectExpense]
                ?.isNotEmpty !=
            true)
        ? null
        : ref
            .read(categoryListNotifierProvider)
            .valueOrNull?[defaultSelectExpense]?[0];
    state = SelectCategoryState(
      category: initCategory,
      subCategory: null,
      subCategoryList: await getSubCategoryList(initCategory?.id),
      selectExpense: defaultSelectExpense,
    );
  }

  //カテゴリーをセット＋selectCategoryのリストとExpenseをセットする
  Future<void> updateSelectBothCategory(
      Category? newParentCategory, Category? newSubCategory) async {
    state = SelectCategoryState(
      category: newParentCategory,
      subCategory: newSubCategory,
      subCategoryList: await getSubCategoryList(newParentCategory?.id),
      selectExpense: newParentCategory?.expense ?? SelectExpense.outgo,
    );
  }

  //update select
  Future<void> updateSelectParentCategory(Category? newCategory) async {
    state = SelectCategoryState(
      category: newCategory,
      subCategory: null,
      subCategoryList: await getSubCategoryList(newCategory?.id),
      selectExpense: state.selectExpense,
    );
  }

  //update select sub
  Future<void> updateSelectSubCategory(Category? newSubCategory) async {
    state = SelectCategoryState(
      category: state.category,
      subCategory: newSubCategory,
      subCategoryList: state.subCategoryList,
      selectExpense: state.selectExpense,
    );
  }

  //
  //収支SegmentedButton用
  @override
  Future<void> changeIncome() async {
    final categoryListMap = await ref.read(categoryListNotifierProvider.future);
    final categoryList = categoryListMap[SelectExpense.income];

    if (categoryList == null || categoryList.isEmpty) {
      state = state.copyWithExpense(null, [], SelectExpense.income);
    } else {
      state = state.copyWithExpense(
        categoryList[0],
        await getSubCategoryList(categoryList[0].id),
        SelectExpense.income,
      );
    }
  }

  @override
  Future<void> changeOutgo() async {
    final categoryListMap = await ref.read(categoryListNotifierProvider.future);
    final categoryList = categoryListMap[SelectExpense.outgo];

    if (categoryList == null || categoryList.isEmpty) {
      state = state.copyWithExpense(null, [], SelectExpense.outgo);
    } else {
      state = state.copyWithExpense(
        categoryList[0],
        await getSubCategoryList(categoryList[0].id),
        SelectExpense.outgo,
      );
    }
  }

  //CategoryListの取得がかかるたびに呼び出される
  Future<void> resetSelectCategoryState(
      Map<SelectExpense, List<Category>> map) async {
    final List<Category>? categoryList = map[state.selectExpense];
    Category? selectCategory = state.nextInitCategory ??
        (categoryList != null && categoryList.isNotEmpty
            ? categoryList[0]
            : null);
    state = SelectCategoryState(
      category: selectCategory,
      subCategory: state.nextInitSubCategory,
      subCategoryList: await getSubCategoryList(selectCategory?.id),
      selectExpense: state.selectExpense,
    );
  }

  //
  //registerPageからカテゴリー新規登録時、nextInitの設定
  Future<void> setNextInitState(bool isSub) async {
    if (isSub) {
      state = SelectCategoryState(
        category: state.category,
        subCategory: null,
        subCategoryList: state.subCategoryList,
        nextInitCategory: state.category,
        nextInitSubCategory: state.subCategory,
        selectExpense: state.selectExpense,
      );
    } else {
      state = SelectCategoryState(
        category: null,
        subCategory: null,
        subCategoryList: const [],
        nextInitCategory: state.category,
        nextInitSubCategory: state.subCategory,
        selectExpense: state.selectExpense,
      );
    }
  }

  //registerPageから新規登録した時
  Future<void> setNextInitStateAddCategory(bool isSub) async {
    final categoryListMap = await ref.read(categoryListNotifierProvider.future);
    final categoryList = categoryListMap[state.selectExpense];
    if (isSub) {
      state = SelectCategoryState(
        category: state.category,
        subCategory: (state.subCategoryList?.isNotEmpty ?? false)
            ? state.subCategoryList?.last
            : null,
        subCategoryList: state.subCategoryList,
        selectExpense: state.selectExpense,
      );
    } else {
      state = SelectCategoryState(
        category: categoryList!.last,
        subCategory: null,
        subCategoryList: await getSubCategoryList(categoryList.last.id),
        selectExpense: state.selectExpense,
      );
    }
  }

  //Registerからのpop用 state更新
  Future<void> resetSelectCategoryStateFromRegister() async {
    if (state.nextInitCategory != null || state.nextInitSubCategory != null) {
      final categoryListMap =
          await ref.read(categoryListNotifierProvider.future);
      await resetSelectCategoryState(categoryListMap);
    }
  }

  //
  //subCategory insert 追加
  Future<void> insertSubCategoryOfDB({
    required String name,
    required IconData icon,
    required Color color,
    required SelectExpense expense,
    required BuildContext context,
  }) async {
    final List<Category>? list = state.subCategoryList;

    final IndicatorOverlay indicatorOverlay = IndicatorOverlay();
    indicatorOverlay.insertOverlay(context);

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
      parentId: state.category?.id,
      expense: expense,
    );

    bool isError = false;
    try {
      await CategoryDBHelper.insertCategory(category);
    } catch (e) {
      isError = true;
      rethrow;
    } finally {
      //サブカテゴリーリスト更新用
      List<Category> subCategoryList =
          await getSubCategoryList(state.category?.id);
      //DB更新時レジスターリスト更新
      await _refreshRegister();

      state = SelectCategoryState(
        category: state.category,
        subCategory: null,
        subCategoryList: subCategoryList,
        selectExpense: state.selectExpense,
      );
      indicatorOverlay.removeOverlay();
      //スナックバー表示
      if (context.mounted) {
        updateSnackBarCallBack(
          text: isError ? 'カテゴリーの削除に失敗しました' : 'カテゴリーを削除しました',
          context: context,
          isError: isError,
          ref: ref,
          isNotNeedBottomHeight: true,
        );
      }
    }
  }

  Future<void> updateCategoryOfDB(
      Category category, BuildContext context) async {
    bool isError = false;
    final IndicatorOverlay indicatorOverlay = IndicatorOverlay();
    indicatorOverlay.insertOverlay(context);
    try {
      await CategoryDBHelper.updateCategory(category);
    } catch (e) {
      isError = true;
      rethrow;
    } finally {
      //DB更新時レジスターリスト更新
      await _refreshRegister();
      List<Category> subCategoryList =
          await getSubCategoryList(state.category?.id);
      state = SelectCategoryState(
        category: state.category,
        subCategory: null,
        subCategoryList: subCategoryList,
        selectExpense: state.selectExpense,
      );

      indicatorOverlay.removeOverlay();
      //スナックバー表示
      if (context.mounted) {
        updateSnackBarCallBack(
          text: isError ? 'カテゴリーの更新に失敗しました' : 'カテゴリーを更新しました',
          context: context,
          isError: isError,
          ref: ref,
          isNotNeedBottomHeight: true,
        );
      }
    }
  }

  //サブカテゴリー削除処理：register削除 → サブカテゴリー削除 → リスト更新
  Future<void> deleteCategoryFromId(int id, BuildContext context) async {
    bool isError = false;
    final IndicatorOverlay indicatorOverlay = IndicatorOverlay();
    indicatorOverlay.insertOverlay(context);
    try {
      //register削除→カテゴリー、サブカテゴリー削除
      await CategoryDBHelper.deleteCategoryFromId(id);
    } catch (e) {
      isError = true;
      rethrow;
    } finally {
      //register更新
      await Future.wait([
        _refreshRegister(),
        //recurring register更新
        ref
            .read(registerRecurringListNotifierProvider.notifier)
            .refreshFromCategory(ref),
      ]);

      //サブカテゴリーリスト更新
      List<Category> subCategoryList =
          await getSubCategoryList(state.category?.id);
      state = SelectCategoryState(
        category: state.category,
        subCategory: null,
        subCategoryList: subCategoryList,
        selectExpense: state.selectExpense,
      );
      indicatorOverlay.removeOverlay();
      //スナックバー表示
      if (context.mounted) {
        updateSnackBarCallBack(
          text: isError ? 'カテゴリーの削除に失敗しました' : 'サブカテゴリーを削除しました',
          context: context,
          isError: isError,
          ref: ref,
          isNotNeedBottomHeight: true,
        );
      }
    }
  }

  //register更新
  Future<void> _refreshRegister() async {
    //registerリスト＋セレクタ更新
    await RegisterDBProvider.refreshFromCategory(ref);
  }
}
