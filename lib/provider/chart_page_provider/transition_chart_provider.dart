import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/model/register.dart';
import 'package:household_expenses_project/provider/register_db_provider.dart';
import 'package:household_expenses_project/provider/register_edit_state.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';

//barChart用パラメータ
const double barChartItemWidth = 25;
const double barGroupSpace = medium;
const double barGroupWidth = barChartItemWidth + barGroupSpace;
const double barSpace = 2;
const double barChartFigurePadding = medium;

enum TransitionSelectState {
  expenses("収入と支出"),
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

//rodデータ
class TransitionChartRodData {
  final String key; //YYYYMM（MM：期間が年の時は00）
  final int value;
  const TransitionChartRodData({
    required this.key,
    required this.value,
  });
}

//rodGroupデータ
class TransitionChartGroupData {
  final Map<String, List<Register>> transitionRegistersMap;
  final List<TransitionChartRodData> transitionChartRodDataList; //同項目のrodList
  final Color? chartColor;
  final int maxAmount;
  TransitionChartGroupData({
    required this.transitionRegistersMap,
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
  final int? selectBarGroupIndex; //x軸のインデックス
  final int? selectRodDataIndex; //一メモリ内のrod数インデックス
  final String? selectRodKey;
  final ScrollController chartTransitionScrollController;
  @override
  final bool isActiveDoneButton;

  const TransitionChartState({
    required this.transitionChartDateRange,
    required this.transitionSelectState,
    required this.selectCategory,
    required this.transitionChartGroupDataList,
    required this.xTitleList,
    required this.selectBarGroupIndex,
    required this.selectRodDataIndex,
    required this.selectRodKey,
    required this.isActiveDoneButton,
    required this.chartTransitionScrollController,
  });

  TransitionChartState.defaultState()
      : transitionChartDateRange = TransitionChartDateRange.month,
        transitionSelectState = TransitionSelectState.expenses,
        selectCategory = null,
        transitionChartGroupDataList = [],
        xTitleList = [],
        selectBarGroupIndex = null,
        selectRodDataIndex = null,
        selectRodKey = null,
        isActiveDoneButton = false,
        chartTransitionScrollController = ScrollController();

  TransitionChartState copyWith({
    TransitionChartDateRange? transitionChartDateRange,
    TransitionSelectState? transitionSelectState,
    Category? selectCategory,
    List<TransitionChartGroupData>? transitionChartGroupDataList,
    List<String>? xTitleList,
    int? selectBarGroupIndex,
    int? selectRodDataIndex,
    String? selectRodKey,
    bool? isActiveDoneButton,
    ScrollController? chartTransitionScrollController,
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
      selectBarGroupIndex: selectBarGroupIndex ?? this.selectBarGroupIndex,
      selectRodDataIndex: selectRodDataIndex ?? this.selectRodDataIndex,
      selectRodKey: selectRodKey ?? this.selectRodKey,
      isActiveDoneButton: isActiveDoneButton ?? this.isActiveDoneButton,
      chartTransitionScrollController: chartTransitionScrollController ??
          this.chartTransitionScrollController,
    );
  }

  TransitionChartState copyWithCategory({
    TransitionChartDateRange? transitionChartDateRange,
    TransitionSelectState? transitionSelectState,
    required Category? selectCategory,
    List<TransitionChartGroupData>? transitionChartGroupDataList,
    List<String>? xTitleList,
    ScrollController? chartTransitionScrollController,
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
      selectBarGroupIndex: selectBarGroupIndex,
      selectRodDataIndex: selectRodDataIndex,
      selectRodKey: selectRodKey,
      isActiveDoneButton: isActiveDoneButton,
      chartTransitionScrollController: chartTransitionScrollController ??
          this.chartTransitionScrollController,
    );
  }

  TransitionChartState copyWithSelectIndex({
    TransitionChartDateRange? transitionChartDateRange,
    TransitionSelectState? transitionSelectState,
    Category? selectCategory,
    List<TransitionChartGroupData>? transitionChartGroupDataList,
    List<String>? xTitleList,
    required int? selectBarGroupIndex,
    required int? selectRodDataIndex,
    required String? selectRodKey,
    ScrollController? chartTransitionScrollController,
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
      selectBarGroupIndex: selectBarGroupIndex,
      selectRodDataIndex: selectRodDataIndex,
      selectRodKey: selectRodKey,
      isActiveDoneButton: isActiveDoneButton,
      chartTransitionScrollController: chartTransitionScrollController ??
          this.chartTransitionScrollController,
    );
  }

  String selectListTitle() {
    if (transitionSelectState == TransitionSelectState.category) {
      return (selectCategory != null)
          ? ("${selectCategory!.expenses.text} / ${selectCategory!.name}")
          : "";
    } else {
      return transitionSelectState.text;
    }
  }
}

//Notifier
class TransitionChartStateNotifier
    extends RegisterEditStateNotifier<TransitionChartState> {
  late final TransitionChartState _defaultState;
  @override
  Future<TransitionChartState> build() async {
    _defaultState = TransitionChartState.defaultState();
    //初期値でグラフ表示
    initBarChart();
    return _defaultState;
  }

  Future<void> initBarChart() async {
    await reacquisitionRegisterListCallBack();
    selectBarRodFromDate(
        selectDate: DateTime(DateTime.now().year, DateTime.now().month),
        rodIndex: 0);
  }

  //RegisterDBが変更された際に実行
  Future<void> refreshRegisterList() async {
    int? rodIndex = state.valueOrNull?.selectRodDataIndex;
    String? key = state.valueOrNull?.selectRodKey;
    await reacquisitionRegisterListCallBack();
    if (rodIndex != null && key != null) {
      selectBarRodFromDate(rodIndex: rodIndex, key: key);
    }
  }

  //
  //-----セレクタ系-----
  //transitionChartStateセット（セレクタ変更）
  Future<void> setSelectTransitionChartState(
      TransitionSelectState transitionSelectState, Category? category) async {
    state = AsyncData(state.valueOrNull?.copyWithCategory(
          transitionSelectState: transitionSelectState,
          selectCategory: category,
        ) ??
        _defaultState);
    await reacquisitionRegisterListCallBack();
  }

  //transitionChartStateセット（期間変更）
  void setRangeTransitionChartState(
      TransitionChartDateRange transitionChartDateRange) async {
    state = AsyncData(state.valueOrNull
            ?.copyWith(transitionChartDateRange: transitionChartDateRange) ??
        _defaultState);
    await reacquisitionRegisterListCallBack();
  }

  //transitionChartStateセット（セレクタと期間）
  Future<void> setTransitionChartState(
    TransitionSelectState transitionSelectState,
    Category? category,
    TransitionChartDateRange transitionChartDateRange,
  ) async {
    state = AsyncData(state.valueOrNull?.copyWithCategory(
            transitionSelectState: transitionSelectState,
            selectCategory: category,
            transitionChartDateRange: transitionChartDateRange) ??
        _defaultState);
    await reacquisitionRegisterListCallBack();
  }

  //rate chartからの遷移
  Future<void> pageTransitionFromRate(
    TransitionSelectState transitionSelectState,
    Category? category,
    TransitionChartDateRange transitionChartDateRange,
    DateTime selectDate,
  ) async {
    await setTransitionChartState(
        transitionSelectState, category, transitionChartDateRange);
    //TransitionSelectState.expencesはあり得ないため、rodIndexに0を設定
    selectBarRodFromDate(selectDate: selectDate, rodIndex: 0);
  }

  //棒グラフ選択（日付から）*keyが設定されている場合、キーで選択
  void selectBarRodFromDate({
    required int rodIndex,
    String? key,
    DateTime? selectDate,
  }) {
    //キー変換
    late final String selectKey;
    if (key != null) {
      selectKey = key;
    } else if (selectDate != null) {
      switch (state.valueOrNull?.transitionChartDateRange) {
        case TransitionChartDateRange.month:
          selectKey =
              '${selectDate.year}${selectDate.month.toString().padLeft(2, '0')}';
          break;
        case TransitionChartDateRange.year:
          selectKey = '${selectDate.year}00';
          break;
        case null:
          return;
      }
    } else {
      //どちらも設定されていない場合は選択しない
      return;
    }

    //キーマッチング（ない場合は選択しない）
    int? selectBarGroupIndex;
    int? scrollIndex;
    int listLength = state.valueOrNull?.transitionChartGroupDataList[0]
            .transitionChartRodDataList.length ??
        0;
    for (int i = 0; i < listLength; i++) {
      if (state.valueOrNull?.transitionChartGroupDataList[0]
              .transitionChartRodDataList[i].key ==
          selectKey) {
        selectBarGroupIndex = i;
      }
      //最も近い値をscrollIndexに設定
      if (state.valueOrNull != null &&
          (int.tryParse(selectKey) ?? 0) <
              (int.tryParse(state.value!.transitionChartGroupDataList[0]
                      .transitionChartRodDataList[i].key) ??
                  0)) {
        scrollIndex = (i == 0) ? 0 : i - 1;
        break;
      }
    }

    if (selectBarGroupIndex != null) {
      selectBarRodFromIndex(selectBarGroupIndex, rodIndex);
    }
    setInitScrollOffset(scrollIndex ?? listLength);
  }

  //棒グラフ選択（Indexから）*ListにIndexが存在することが前提
  void selectBarRodFromIndex(int selectBarGroupIndex, int selectRodDataIndex) {
    final String? selectRodKey = state
        .valueOrNull
        ?.transitionChartGroupDataList[selectRodDataIndex]
        .transitionChartRodDataList[selectBarGroupIndex]
        .key;

    state = AsyncData(state.valueOrNull?.copyWithSelectIndex(
          selectBarGroupIndex: selectBarGroupIndex,
          selectRodDataIndex: selectRodDataIndex,
          selectRodKey: selectRodKey,
        ) ??
        _defaultState);
  }

  //スクロールoffset計算
  void setInitScrollOffset(int index) {
    var currentState = state.valueOrNull;
    if (currentState == null) {
      return;
    } else {
      double offset = barChartFigurePadding -
          ssmall +
          ((currentState.transitionSelectState ==
                      TransitionSelectState.expenses)
                  ? (barGroupWidth + barChartItemWidth + barSpace)
                  : barGroupWidth) *
              index;

      state = AsyncData(currentState.copyWith(
          chartTransitionScrollController:
              ScrollController(initialScrollOffset: offset)));
    }
  }

  //
  //選択barchartListを返す
  List<Register> getSelectedList() {
    if (state.valueOrNull?.selectRodDataIndex == null ||
        state.valueOrNull?.selectRodKey == null) {
      return [];
    } else {
      return state
              .value!
              .transitionChartGroupDataList[state.value!.selectRodDataIndex!]
              .transitionRegistersMap[state.value!.selectRodKey] ??
          [];
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

  //
  //-----バーチャート用データ-----
  //1 registerList、transitionChartSectionDataList 更新コールバック
  Future<void> reacquisitionRegisterListCallBack() async {
    state = const AsyncLoading<TransitionChartState>().copyWithPrevious(state);
    final currentState = state.valueOrNull ?? _defaultState;

    List<List<Register>> registerGroupList = [];
    late final List<Color?> colorList;
    List<Register> registerList = [];
    //1 registerList取得、グラフの色取得
    switch (currentState.transitionSelectState) {
      case TransitionSelectState.expenses:
        registerList =
            await RegisterDBProvider.getRegisterStateOfSelectExpenses(
                SelectExpenses.outgo);
        registerGroupList.add(registerList);
        registerList =
            await RegisterDBProvider.getRegisterStateOfSelectExpenses(
                SelectExpenses.income);
        registerGroupList.add(registerList);
        colorList = [Colors.red, Colors.blue];
        break;

      case TransitionSelectState.outgo:
        registerList =
            await RegisterDBProvider.getRegisterStateOfSelectExpenses(
                SelectExpenses.outgo);
        registerGroupList.add(registerList);
        colorList = [Colors.red];
        break;

      case TransitionSelectState.income:
        registerList =
            await RegisterDBProvider.getRegisterStateOfSelectExpenses(
                SelectExpenses.income);
        registerGroupList.add(registerList);
        colorList = [Colors.blue];
        break;

      case TransitionSelectState.category:
        if (currentState.selectCategory == null) {
          //ありえない想定
          registerList = [];
        } else {
          registerList = await RegisterDBProvider.getRegisterStateOfCategory(
              currentState.selectCategory!);
          registerGroupList.add(registerList);
          colorList = [
            registerList.isNotEmpty ? registerList[0].category!.color : null
          ];
        }
        break;
      case TransitionSelectState.subCategory:
        if (currentState.selectCategory == null) {
          //ありえない想定
          registerList = [];
        } else {
          registerList = await RegisterDBProvider.getRegisterStateOfCategory(
              currentState.selectCategory!);
          registerGroupList.add(registerList);
          colorList = [
            registerList.isNotEmpty ? registerList[0].subCategory!.color : null
          ];
        }
        break;
    }

    //全てEmptyの場合
    if (registerGroupList.every((list) => list.isEmpty)) {
      state = AsyncData(state.valueOrNull?.copyWith(
            transitionChartGroupDataList: [],
            xTitleList: [],
          ) ??
          _defaultState);
      return;
    }

    //range設定
    DateTime rangeMax = DateTime(0);
    DateTime rangeMin = DateTime(9999);
    if (registerGroupList.length < 2) {
      rangeMin = registerGroupList[0].first.date;
      rangeMax = registerGroupList[0].last.date;
    } else {
      for (int i = 0; i < registerGroupList.length; i++) {
        if (registerGroupList[i].isNotEmpty) {
          rangeMin = rangeMin.isBefore(registerGroupList[i].first.date)
              ? rangeMin
              : registerGroupList[i].first.date;
          rangeMax = rangeMax.isAfter(registerGroupList[i].last.date)
              ? rangeMax
              : registerGroupList[i].last.date;
        }
      }
    }

    //2 xTitle作成
    List<String> xTitleList = [];
    DateTime currentDate = rangeMin;
    switch (currentState.transitionChartDateRange) {
      case TransitionChartDateRange.month:
        while (compDateTime(currentDate, rangeMax)) {
          xTitleList.add('${currentDate.year}\n${currentDate.month}月');
          currentDate = DateTime(currentDate.year, currentDate.month + 1);
        }
        break;
      case TransitionChartDateRange.year:
        while (compDateTime(currentDate, rangeMax)) {
          xTitleList.add('${currentDate.year}');
          currentDate = DateTime(currentDate.year + 1);
        }
        break;
    }

    //3 registerList→transitionChartGroupDataList取得（ロッド数分）
    List<TransitionChartGroupData> transitionChartGroupDataList = [];
    for (int i = 0; i < registerGroupList.length; i++) {
      final TransitionChartGroupData transitionChartGroupData =
          createTransitionChartGroupData(currentState.transitionChartDateRange,
              registerGroupList[i], colorList[i], rangeMin, rangeMax);
      transitionChartGroupDataList.add(transitionChartGroupData);
    }

    //4 データ更新
    state = AsyncData(state.valueOrNull?.copyWithSelectIndex(
          transitionChartGroupDataList: transitionChartGroupDataList,
          xTitleList: xTitleList,
          selectBarGroupIndex: null,
          selectRodDataIndex: null,
          selectRodKey: null,
        ) ??
        _defaultState);
  }

  //3 registerList→TransitionChartGroupData取得
  TransitionChartGroupData createTransitionChartGroupData(
    TransitionChartDateRange dataRange,
    List<Register> registerList,
    Color? color,
    DateTime rangeMin,
    DateTime rangeMax,
  ) {
    //3.1 registerList→registerGroupMap作成（選択期間ごとにグループ化）
    final Map<String, List<Register>> registerGroupMap = {};
    //グループ化時のキーの設定
    late final String Function(DateTime) keyGenerator;
    switch (dataRange) {
      case TransitionChartDateRange.month:
        keyGenerator =
            (date) => '${date.year}${date.month.toString().padLeft(2, '0')}';
        break;
      case TransitionChartDateRange.year:
        keyGenerator = (date) => '${date.year}00';
        break;
    }

    for (Register register in registerList) {
      String key = keyGenerator(register.date);
      if (registerGroupMap.containsKey(key)) {
        registerGroupMap[key]!.add(register);
      } else {
        registerGroupMap[key] = [register];
      }
    }

    //3.2 registerGroupMap→TransitionChartデータリスト作成
    final (
      List<TransitionChartRodData> transitionChartRodDataList,
      int maxAmount
    ) = createBarChartState(
        registerGroupMap, dataRange, rangeMin, rangeMax, keyGenerator);

    return TransitionChartGroupData(
      transitionRegistersMap: registerGroupMap,
      transitionChartRodDataList: transitionChartRodDataList,
      chartColor: color,
      maxAmount: maxAmount,
    );
  }

  //3.2 registerGroupMap→TransitionChartデータリスト作成
  (List<TransitionChartRodData>, int) createBarChartState(
    Map<String, List<Register>> registerGroupMap,
    TransitionChartDateRange dateRange,
    DateTime rangeMin,
    DateTime rangeMax,
    Function keyGenerator,
  ) {
    //3.2.1 年月間隔設定
    final DateTime Function(DateTime) addDateIndex;
    switch (dateRange) {
      case TransitionChartDateRange.month:
        addDateIndex = (DateTime date) => DateTime(date.year, date.month + 1);
      case TransitionChartDateRange.year:
        addDateIndex = (DateTime date) => DateTime(date.year + 1);
    }

    //3.2.2 registerGroupMap→TransitionChartデータリスト作成（全体）
    List<TransitionChartRodData> transitionChartRodDataList = [];
    int maxAmount = 0;
    DateTime currentDate = rangeMin;
    List<String> keyList = registerGroupMap.keys.toList();
    int i = 0;
    while (compDateTime(currentDate, rangeMax)) {
      //キーの日付の時、TransitionChartデータ作成（個別）
      final String currentKey = keyGenerator(currentDate);
      if (i < keyList.length && currentKey == keyList[i]) {
        //3.2.2.1 registerGroup→TransitionChartデータ作成（個別）
        final TransitionChartRodData transitionChartRodData =
            createBarChartGroupData(currentKey, registerGroupMap[currentKey]);
        transitionChartRodDataList.add(transitionChartRodData);
        maxAmount = max(maxAmount, transitionChartRodData.value);
        i++;
      } else {
        //value0のチャートデータ追加
        transitionChartRodDataList
            .add(TransitionChartRodData(key: currentKey, value: 0));
      }
      currentDate = addDateIndex(currentDate);
    }
    return (transitionChartRodDataList, maxAmount);
  }

  //3.2.2.1 registerGroup→TransitionChartデータ作成（個別）
  TransitionChartRodData createBarChartGroupData(
      String key, List<Register>? registerGroup) {
    final int value = registerGroup
            ?.fold(0, (total, register) => total + register.amount)
            .abs() ??
        0;
    final TransitionChartRodData transitionChartRodData =
        TransitionChartRodData(key: key, value: value);

    return (transitionChartRodData);
  }

  //99 日付計算（pre<=current → true）
  bool compDateTime(DateTime pre, DateTime current) {
    return (pre.year < current.year) ||
        (pre.year == current.year && pre.month <= current.month);
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
