import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/view_model/category_db_helper.dart';
import 'package:household_expenses_project/provider/category_list_provider.dart';

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

enum SelectExpenses { outgo, income }

class SelectCategoryState {
  final Category? category;
  final Category? subCategory;
  final List<Category>? subCategoryList;
  final Category? nextInitCategory; /*registerPageでのカスタムキーボードからの遷移用パラメータ */
  final Category? nextInitSubCategory; /*同上*/
  final SelectExpenses selectExpenses;

  SelectCategoryState({
    required this.category,
    required this.subCategory,
    required this.subCategoryList,
    this.nextInitCategory,
    this.nextInitSubCategory,
    required this.selectExpenses,
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
      selectExpenses: selectExpenses,
    );
  }

  //収支切り替え（一部初期化）
  SelectCategoryState copyWithExpenses(
    Category? category,
    List<Category> subCategoryList,
    SelectExpenses selectExpenses,
  ) {
    return SelectCategoryState(
      category: (this.category == null) ? null : category,
      subCategory: null,
      subCategoryList: subCategoryList,
      nextInitCategory: null,
      nextInitSubCategory: null,
      selectExpenses: selectExpenses,
    );
  }
}

//Notifier
class SelectCategoryStateNotifier extends Notifier<SelectCategoryState> {
  @override
  SelectCategoryState build() {
    ref.read(categoryListNotifierProvider);
    return SelectCategoryState(
      category: null,
      subCategory: null,
      subCategoryList: [],
      selectExpenses: SelectExpenses.outgo,
    );
  }

  Future<List<Category>> getSubCategoryList(int? parentId) async {
    if (parentId == null) {
      return [];
    } else {
      return await CategoryDBHelper.getAllSubCategory(parentId);
    }
  }

  //現在のregisterListを元に更新
  Future<void> setInit() async {
    Category? initCategory = ref
        .read(categoryListNotifierProvider)
        .valueOrNull?[SelectExpenses.outgo]?[0];
    state = SelectCategoryState(
      category: initCategory,
      subCategory: null,
      subCategoryList: await getSubCategoryList(initCategory?.id),
      selectExpenses: SelectExpenses.outgo,
    );
  }

  //カテゴリーをセット＋selectCategoryのリストとExpensesをセットする
  Future<void> updateSelectBothCategory(
      Category? newParentCategory, Category? newSubCategory) async {
    state = SelectCategoryState(
      category: newParentCategory,
      subCategory: newSubCategory,
      subCategoryList: await getSubCategoryList(newParentCategory?.id),
      selectExpenses: newParentCategory?.expenses ?? SelectExpenses.outgo,
    );
  }

  //update select
  Future<void> updateSelectParentCategory(Category? newCategory) async {
    state = SelectCategoryState(
      category: newCategory,
      subCategory: null,
      subCategoryList: await getSubCategoryList(newCategory?.id),
      selectExpenses: state.selectExpenses,
    );
  }

  //update select sub
  Future<void> updateSelectSubCategory(Category? newSubCategory) async {
    state = SelectCategoryState(
      category: state.category,
      subCategory: newSubCategory,
      subCategoryList: state.subCategoryList,
      selectExpenses: state.selectExpenses,
    );
  }

  //
  //収支SegmentedButton用
  Future<void> changeIncome() async {
    final categoryListMap = await ref.read(categoryListNotifierProvider.future);
    final categoryList = categoryListMap[SelectExpenses.income];

    if (categoryList == null || categoryList.isEmpty) {
      state = state.copyWithExpenses(null, [], SelectExpenses.income);
    } else {
      state = state.copyWithExpenses(
        categoryList[0],
        await getSubCategoryList(categoryList[0].id),
        SelectExpenses.income,
      );
    }
  }

  Future<void> changeOutgo() async {
    final categoryListMap = await ref.read(categoryListNotifierProvider.future);
    final categoryList = categoryListMap[SelectExpenses.outgo];

    if (categoryList == null || categoryList.isEmpty) {
      state = state.copyWithExpenses(null, [], SelectExpenses.outgo);
    } else {
      state = state.copyWithExpenses(
        categoryList[0],
        await getSubCategoryList(categoryList[0].id),
        SelectExpenses.outgo,
      );
    }
  }

  //CategoryListの取得がかかるたびに呼び出される
  Future<void> resetSelectCategoryState(
      Map<SelectExpenses, List<Category>> map) async {
    final categoryList = map[state.selectExpenses];
    Category? selectCategory = state.nextInitCategory ?? categoryList?[0];
    state = SelectCategoryState(
      category: selectCategory,
      subCategory: state.nextInitSubCategory,
      subCategoryList: await getSubCategoryList(selectCategory?.id),
      selectExpenses: state.selectExpenses,
    );
  }

  //
  //registerPageの呼び出し時、nextInitの設定
  Future<void> setNextInitState(bool isResetSub) async {
    if (isResetSub) {
      state = SelectCategoryState(
        category: state.category,
        subCategory: null,
        subCategoryList: state.subCategoryList,
        nextInitCategory: state.category,
        nextInitSubCategory: state.subCategory,
        selectExpenses: state.selectExpenses,
      );
    } else {
      state = SelectCategoryState(
        category: null,
        subCategory: null,
        subCategoryList: [],
        nextInitCategory: state.category,
        nextInitSubCategory: state.subCategory,
        selectExpenses: state.selectExpenses,
      );
    }
  }

  //registerPageから新規登録した時
  Future<void> setNextInitStateAddCategory(bool isResetSub) async {
    final categoryListMap = await ref.read(categoryListNotifierProvider.future);
    final categoryList = categoryListMap[state.selectExpenses];
    if (isResetSub) {
      state = SelectCategoryState(
        category: state.category,
        subCategory: (state.subCategoryList?.isEmpty ?? false)
            ? state.subCategoryList?.last
            : null,
        subCategoryList: state.subCategoryList,
        selectExpenses: state.selectExpenses,
      );
    } else {
      state = SelectCategoryState(
        category: categoryList!.last,
        subCategory: null,
        subCategoryList: await getSubCategoryList(categoryList.last.id),
        selectExpenses: state.selectExpenses,
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
  //subCategory DB更新用
  Future<void> insertSubCategoryOfDB({
    required String name,
    required IconData icon,
    required Color color,
    required SelectExpenses expenses,
  }) async {
    final List<Category>? list = state.subCategoryList;

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
      expenses: expenses,
    );
    await CategoryDBHelper.insertCategory(category);
    List<Category> subCategoryList =
        await getSubCategoryList(state.category?.id);
    state = SelectCategoryState(
      category: state.category,
      subCategory: null,
      subCategoryList: subCategoryList,
      selectExpenses: state.selectExpenses,
    );
  }

  Future<void> updateCategoryOfDB(Category category) async {
    await CategoryDBHelper.updateCategory(category);
    List<Category> subCategoryList =
        await getSubCategoryList(state.category?.id);
    state = SelectCategoryState(
      category: state.category,
      subCategory: null,
      subCategoryList: subCategoryList,
      selectExpenses: state.selectExpenses,
    );
  }

  Future<void> deleteCategoryFromId(int id) async {
    await CategoryDBHelper.deleteCategoryFromId(id);
    List<Category> subCategoryList =
        await getSubCategoryList(state.category?.id);
    state = SelectCategoryState(
      category: state.category,
      subCategory: null,
      subCategoryList: subCategoryList,
      selectExpenses: state.selectExpenses,
    );
  }
}
