import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/generalized_logic_component.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/model/register.dart';
import 'package:household_expense_project/provider/category_list_provider.dart';
import 'package:household_expense_project/provider/chart_page_provider/chart_page_provider.dart';
import 'package:household_expense_project/provider/register_db_provider.dart';
import 'package:household_expense_project/provider/register_edit_state.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';

//barChart用パラメータ
const double barChartItemWidth = 25;
const double barGroupSpace = medium;
const double barGroupWidth = barChartItemWidth + barGroupSpace;
const double barSpace = 2;
const double barChartFigurePadding = small;

enum TransitionSelectState {
  expense("収入と支出"),
  outgo("支出"),
  income("収入"),
  category("カテゴリー"),
  subCategory("サブカテゴリー");

  final String text;
  const TransitionSelectState(this.text);
}

enum TransitionChartDateRange {
  month("1ヶ月"),
  year("1年");

  final String text;
  const TransitionChartDateRange(this.text);
}

//推移チャート用
final transitionChartProvider =
    AsyncNotifierProvider<TransitionChartStateNotifier, TransitionChartState>(
        TransitionChartStateNotifier.new);

//rodGroupデータ
class TransitionChartGroupData {
  final List<List<Register>> transitionRegistersList;
  final List<double> transitionChartRodDataList; //同項目のrodList
  final Color? chartColor;
  final int maxAmount;
  TransitionChartGroupData({
    required this.transitionRegistersList,
    required this.transitionChartRodDataList,
    required this.chartColor,
    required this.maxAmount,
  });
}

//TransitionChartState
@immutable
class TransitionChartState implements RegisterEditState {
  final TransitionChartDateRange transitionChartDateRange;
  final TransitionSelectState transitionSelectState;
  final Category? selectCategory;
  final List<TransitionChartGroupData> transitionChartGroupDataList;
  final List<String> xTitleList;
  final List<DateTime> xDateList;
  final int selectBarGroupIndex; //x軸のインデックス
  final int selectRodDataIndex; //一メモリ内のrod数インデックス

  final DateTime baseDate;
  final int loadingState; //0：初期状態、1：画面遷移開始、２：画面遷移完了

  @override
  final bool isActiveDoneButton;

  const TransitionChartState({
    required this.transitionChartDateRange,
    required this.transitionSelectState,
    required this.selectCategory,
    required this.transitionChartGroupDataList,
    required this.xTitleList,
    required this.xDateList,
    required this.selectBarGroupIndex,
    required this.selectRodDataIndex,
    required this.isActiveDoneButton,
    required this.baseDate,
    required this.loadingState,
  });

  TransitionChartState.defaultState()
      : transitionChartDateRange = TransitionChartDateRange.month,
        transitionSelectState = TransitionSelectState.expense,
        selectCategory = null,
        transitionChartGroupDataList = [],
        xTitleList = [],
        xDateList = [],
        selectBarGroupIndex = 0,
        selectRodDataIndex = 0,
        isActiveDoneButton = false,
        baseDate = DateTime(DateTime.now().year, DateTime.now().month, 1),
        loadingState = 0;

  TransitionChartState copyWith({
    TransitionChartDateRange? transitionChartDateRange,
    TransitionSelectState? transitionSelectState,
    Category? selectCategory,
    List<TransitionChartGroupData>? transitionChartGroupDataList,
    List<String>? xTitleList,
    List<DateTime>? xDateList,
    int? selectBarGroupIndex,
    int? selectRodDataIndex,
    bool? isActiveDoneButton,
    DateTime? baseDate,
    int? loadingState,
  }) {
    return TransitionChartState(
      transitionChartDateRange:
          transitionChartDateRange ?? this.transitionChartDateRange,
      transitionSelectState:
          transitionSelectState ?? this.transitionSelectState,
      selectCategory: selectCategory ?? this.selectCategory,
      transitionChartGroupDataList:
          transitionChartGroupDataList ?? this.transitionChartGroupDataList,
      xTitleList: xTitleList ?? this.xTitleList,
      xDateList: xDateList ?? this.xDateList,
      selectBarGroupIndex: selectBarGroupIndex ?? this.selectBarGroupIndex,
      selectRodDataIndex: selectRodDataIndex ?? this.selectRodDataIndex,
      isActiveDoneButton: isActiveDoneButton ?? this.isActiveDoneButton,
      baseDate: baseDate ?? this.baseDate,
      loadingState: loadingState ?? this.loadingState,
    );
  }

  TransitionChartState copyWithCategory({
    TransitionChartDateRange? transitionChartDateRange,
    TransitionSelectState? transitionSelectState,
    required Category? selectCategory,
    List<TransitionChartGroupData>? transitionChartGroupDataList,
    List<String>? xTitleList,
    List<DateTime>? xDateList,
    DateTime? baseDate,
    int? loadingState,
  }) {
    return TransitionChartState(
      transitionChartDateRange:
          transitionChartDateRange ?? this.transitionChartDateRange,
      transitionSelectState:
          transitionSelectState ?? this.transitionSelectState,
      selectCategory: selectCategory,
      transitionChartGroupDataList:
          transitionChartGroupDataList ?? this.transitionChartGroupDataList,
      xTitleList: xTitleList ?? this.xTitleList,
      xDateList: xDateList ?? this.xDateList,
      selectBarGroupIndex: selectBarGroupIndex,
      selectRodDataIndex: selectRodDataIndex,
      isActiveDoneButton: isActiveDoneButton,
      baseDate: baseDate ?? this.baseDate,
      loadingState: loadingState ?? this.loadingState,
    );
  }
}

//Notifier
class TransitionChartStateNotifier
    extends RegisterEditStateNotifier<TransitionChartState> {
  late final TransitionChartState _defaultState;
  @override
  Future<TransitionChartState> build() async {
    _defaultState = TransitionChartState.defaultState();
    reacquisitionRegisterListCallBack(isResetSelect: true);
    return _defaultState;
  }

  //RegisterDBが変更された際に実行
  Future<void> refreshRegisterList() async {
    await reacquisitionRegisterListCallBack(isResetSelect: false);
  }

  //セレクタのタイトル取得
  String selectListTitle() {
    if (state.valueOrNull == null) return '';
    TransitionChartState currentState = state.value!;
    switch (currentState.transitionSelectState) {
      case TransitionSelectState.subCategory:
        if (currentState.selectCategory != null) {}
        if (currentState.selectCategory?.parentId != null) {
          final Category? parentCategory = ref
              .read(categoryListNotifierProvider.notifier)
              .getMainCategoryFromId(currentState.selectCategory!.parentId!,
                  currentState.selectCategory!.expense);
          String selectorTitle = (parentCategory != null)
              ? "${currentState.selectCategory!.expense.text} / ${parentCategory.name} / ${currentState.selectCategory!.name}"
              : "";
          return selectorTitle;
        } else {
          //サブカテゴリーなしの場合
          return "${currentState.selectCategory!.expense.text} / ${currentState.selectCategory!.name} / サブカテゴリーなし";
        }
      case TransitionSelectState.category:
        return (currentState.selectCategory != null)
            ? ("${currentState.selectCategory!.expense.text} / ${currentState.selectCategory!.name}")
            : "";
      default:
        return currentState.transitionSelectState.text;
    }
  }

  //
  //-----セレクタ系-----
  //transitionChartStateセット（セレクタ初期化）
  Future<void> initSelectTransitionChartState() async {
    await setSelectTransitionChartState(TransitionSelectState.expense, null);
  }

  //transitionChartStateセット（セレクタ変更）
  Future<void> setSelectTransitionChartState(
      TransitionSelectState transitionSelectState, Category? category) async {
    state = AsyncData(state.valueOrNull?.copyWithCategory(
          transitionSelectState: transitionSelectState,
          selectCategory: category,
        ) ??
        _defaultState);
    await reacquisitionRegisterListCallBack(isResetSelect: true);
  }

  //transitionChartStateセット（期間変更）
  void setRangeTransitionChartState(
      TransitionChartDateRange transitionChartDateRange) async {
    state = AsyncData(state.valueOrNull
            ?.copyWith(transitionChartDateRange: transitionChartDateRange) ??
        _defaultState);
    await reacquisitionRegisterListCallBack(isResetSelect: true);
  }

  //
  //rate chartからの遷移
  Future<void> pageTransitionFromRate(
    TransitionSelectState transitionSelectState,
    Category? category,
    TransitionChartDateRange transitionChartDateRange,
    DateTime selectDate,
  ) async {
    state = AsyncData(state.valueOrNull?.copyWithCategory(
          transitionSelectState: transitionSelectState,
          selectCategory: category,
          transitionChartDateRange: transitionChartDateRange,
          baseDate: selectDate,
          loadingState: 1,
        ) ??
        _defaultState);
    ref.read(chartPageProvider.notifier).changeChartSegmentToTransition();
    await reacquisitionRegisterListCallBack(isResetSelect: true);
  }

  //棒グラフ選択（selectIndex設定）
  void selectBarRodFromIndex(int selectBarGroupIndex, int selectRodDataIndex) {
    state = AsyncData(state.valueOrNull?.copyWith(
          selectBarGroupIndex: selectBarGroupIndex,
          selectRodDataIndex: selectRodDataIndex,
        ) ??
        _defaultState);
  }

  //figure表示期間変更
  void setNextRangeFigure(int isNextRange) async {
    await reacquisitionRegisterListCallBack(
        isResetSelect: true, isNextRange: isNextRange);
  }

  //スクロールoffset計算
  double getChartTransitionScrollOffset() {
    var currentState = state.valueOrNull;
    if (currentState == null) {
      return 0;
    } else {
      double offset = small +
          barChartFigurePadding +
          barChartItemWidth + //ここから
          ssmall +
          sssmall + //ここまでボタン分
          ssmall +
          ((currentState.transitionSelectState == TransitionSelectState.expense)
                  ? (barGroupWidth + barChartItemWidth + barSpace)
                  : barGroupWidth) *
              (currentState.selectBarGroupIndex - 2);

      return offset;
    }
  }

  //maxAmount取得
  int getMaxAmount() {
    if (state.valueOrNull?.transitionChartGroupDataList.isNotEmpty == true) {
      return state.value!.transitionChartGroupDataList
          .map((item) => item.maxAmount)
          .reduce((a, b) => a > b ? a : b);
    } else {
      return 0;
    }
  }

  //リストの空判定
  bool isEmptyRegisterList() {
    return !(state.valueOrNull?.transitionChartGroupDataList.firstOrNull
            ?.transitionChartRodDataList.isNotEmpty ??
        false);
  }

  void setLoadingState(int loadingState) {
    state = AsyncData(state.valueOrNull?.copyWith(loadingState: loadingState) ??
        _defaultState);
  }

  //
  //-----バーチャート用データ-----
  //TransitionChartState 更新コールバック
  Future<void> reacquisitionRegisterListCallBack({
    required bool isResetSelect,
    int isNextRange = 0,
  }) async {
    state = const AsyncLoading<TransitionChartState>().copyWithPrevious(state);
    state = AsyncData(await getTransitionChartState(
      isResetSelect: isResetSelect,
      isNextRange: isNextRange,
    ));
  }

  //1 TransitionChartState更新
  Future<TransitionChartState> getTransitionChartState({
    required bool isResetSelect,
    required int isNextRange, //baseDate 0:変化なし、1:next、-1:pre
  }) async {
    final currentState = state.valueOrNull ?? _defaultState;
    DateTime baseDate = currentState.baseDate;
    late final int selectBarGroupIndex;
    final int selectRodDataIndex =
        isResetSelect ? 0 : currentState.selectRodDataIndex;

    List<List<Register>> registerGroupList = [];
    late final List<Color?> colorList;
    List<Register> registerList = [];

    //1 日付の範囲、xTitle作成
    late final int rangeOffset;
    late final DateTime startDate;
    late final DateTime endDate;
    List<DateTime> xDateList = [];
    List<String> xTitleList = [];
    switch (currentState.transitionChartDateRange) {
      case TransitionChartDateRange.month:
        rangeOffset = 2;
        selectBarGroupIndex =
            isResetSelect ? 24 : currentState.selectBarGroupIndex;

        baseDate = DateTime(
            baseDate.year + (rangeOffset * isNextRange), baseDate.month, 1);
        startDate = DateTime(baseDate.year - rangeOffset, baseDate.month, 1);
        endDate = DateTime(baseDate.year + rangeOffset, baseDate.month + 1, 0);
        DateTime calcDate = startDate;
        while (LogicComponent.compMonth(calcDate, endDate) != 2) {
          xDateList.add(calcDate);
          xTitleList.add('${calcDate.year}\n${calcDate.month}月');
          calcDate = DateTime(calcDate.year, calcDate.month + 1, 1);
        }
      case TransitionChartDateRange.year:
        rangeOffset = 10;
        selectBarGroupIndex =
            isResetSelect ? 10 : currentState.selectBarGroupIndex;
        baseDate = DateTime(
            baseDate.year + (rangeOffset * isNextRange), baseDate.month, 1);
        startDate = DateTime(baseDate.year - rangeOffset, 1, 1);
        endDate = DateTime(baseDate.year + rangeOffset + 1, 1, 0);
        DateTime calcDate = startDate;
        while (LogicComponent.compMonth(calcDate, endDate) != 2) {
          xDateList.add(calcDate);
          xTitleList.add('${calcDate.year}');
          calcDate = DateTime(calcDate.year + 1, calcDate.month, 1);
        }
    }

    //2 registerList取得、グラフの色取得
    switch (currentState.transitionSelectState) {
      case TransitionSelectState.expense:
        registerList =
            await RegisterDBProvider.getRegisterStateOfRangeAndSelectExpense(
                startDate, endDate, SelectExpense.outgo);

        registerGroupList.add(registerList);
        registerList =
            await RegisterDBProvider.getRegisterStateOfRangeAndSelectExpense(
                startDate, endDate, SelectExpense.income);
        registerGroupList.add(registerList);
        colorList = [Colors.red, Colors.blue];
        break;

      case TransitionSelectState.outgo:
        registerList =
            await RegisterDBProvider.getRegisterStateOfRangeAndSelectExpense(
                startDate, endDate, SelectExpense.outgo);
        registerGroupList.add(registerList);
        colorList = [Colors.red];
        break;

      case TransitionSelectState.income:
        registerList =
            await RegisterDBProvider.getRegisterStateOfRangeAndSelectExpense(
                startDate, endDate, SelectExpense.income);
        registerGroupList.add(registerList);
        colorList = [Colors.blue];
        break;

      case TransitionSelectState.category:
        if (currentState.selectCategory == null) {
          //ありえない想定
          registerList = [];
        } else {
          registerList =
              await RegisterDBProvider.getRegisterStateOfRangeAndCategory(
                  startDate, endDate, currentState.selectCategory!);
          registerGroupList.add(registerList);
          colorList = [
            registerList.isNotEmpty ? currentState.selectCategory!.color : null
          ];
        }
        break;
      case TransitionSelectState.subCategory:
        if (currentState.selectCategory == null) {
          //ありえない想定 *サブカテゴリーなしの場合は親カテゴリーが入る
          registerList = [];
        } else {
          registerList =
              await RegisterDBProvider.getRegisterStateOfRangeAndSubCategory(
                  startDate, endDate, currentState.selectCategory!);
          registerGroupList.add(registerList);
          colorList = [
            registerList.isNotEmpty ? currentState.selectCategory!.color : null
          ];
        }
        break;
    }

    //3 registerList→transitionChartGroupDataList取得（ロッド数分）
    List<TransitionChartGroupData> transitionChartGroupDataList = [];
    for (int i = 0; i < registerGroupList.length; i++) {
      final TransitionChartGroupData transitionChartGroupData =
          createTransitionChartGroupData(
        currentState.transitionChartDateRange,
        registerGroupList[i],
        colorList[i],
        xDateList,
      );
      transitionChartGroupDataList.add(transitionChartGroupData);
    }

    //4 データ更新
    return state.valueOrNull?.copyWith(
          transitionChartGroupDataList: transitionChartGroupDataList,
          xTitleList: xTitleList,
          xDateList: xDateList,
          selectBarGroupIndex: selectBarGroupIndex,
          selectRodDataIndex: selectRodDataIndex,
          baseDate: baseDate,
        ) ??
        _defaultState;
  }

  //3 registerList→TransitionChartGroupData取得
  TransitionChartGroupData createTransitionChartGroupData(
    TransitionChartDateRange dataRange,
    List<Register> registerList,
    Color? color,
    List<DateTime> xDateList,
  ) {
    //3.1 registerList→registerGroupList作成（選択期間ごとにグループ化）
    List<List<Register>> registerGroupList = [];

    late final int Function(DateTime, DateTime) compareDate;
    switch (dataRange) {
      case TransitionChartDateRange.month:
        compareDate = (date1, date2) => LogicComponent.compMonth(date1, date2);
      case TransitionChartDateRange.year:
        compareDate = (date1, date2) => LogicComponent.compYear(date1, date2);
    }

    int j = 0;
    for (int i = 0; i < xDateList.length; i++) {
      List<Register> registerGroup = [];
      while (j < registerList.length) {
        final int comp = compareDate(xDateList[i], registerList[j].date);
        // 一致
        if (comp == 0) {
          registerGroup.add(registerList[j]);

          j++;
        }
        // xDateList[i]<registerList[j]、次のxDateListへ
        else if (comp == 1) {
          break;
        }
        // xDateList[i]>registerList[j]、ありえない想定
        else {
          j++;
        }
      }
      registerGroupList.add(registerGroup);
    }

    //3.2 registerGroupMap→TransitionChartデータリスト作成、amountの最大値を更新
    List<double> transitionChartRodDataList = [];
    int maxAmount = 0;
    for (int i = 0; i < registerGroupList.length; i++) {
      final double sumAmount = registerGroupList[i]
          .fold(0, (total, register) => total + register.amount);
      transitionChartRodDataList.add(sumAmount);
      if (maxAmount < sumAmount) {
        maxAmount = sumAmount.toInt();
      }
    }

    return TransitionChartGroupData(
      transitionRegistersList: registerGroupList,
      transitionChartRodDataList: transitionChartRodDataList,
      chartColor: color,
      maxAmount: maxAmount,
    );
  }

  //register edit用
  //新規追加用（検索ページからは新規追加は不可のため、nullを返す）
  @override
  DateTime? currentSelectDate() {
    return null;
  }

  @override
  void formInputCheck(
      TextEditingController controller, ValueNotifier<Category?> notifier) {
    final bool isActive =
        controller.text.isNotEmpty && (notifier.value != null);
    state = AsyncData(
        state.valueOrNull?.copyWith(isActiveDoneButton: isActive) ??
            _defaultState);
  }

  @override
  void initDoneButton() {
    state = AsyncData(state.valueOrNull?.copyWith(isActiveDoneButton: false) ??
        _defaultState);
  }
}
