import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/model/register.dart';
import 'package:household_expenses_project/provider/register_db_provider.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';

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
  final List<TransitionChartRodData> transitionChartRodDataList;
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
class TransitionChartState {
  final TransitionChartDateRange transitionChartDateRange;
  final TransitionSelectState transitionSelectState;
  final Category? selectCategory;
  final DateTime selectDate;
  final List<TransitionChartGroupData> transitionChartGroupDataList;
  final List<String> xTitleList;

  const TransitionChartState({
    required this.transitionChartDateRange,
    required this.transitionSelectState,
    required this.selectCategory,
    required this.selectDate,
    required this.transitionChartGroupDataList,
    required this.xTitleList,
  });

  TransitionChartState.defaultState()
      : transitionChartDateRange = TransitionChartDateRange.month,
        transitionSelectState = TransitionSelectState.expenses,
        selectCategory = null,
        selectDate = DateTime.now(),
        transitionChartGroupDataList = [],
        xTitleList = [];

  TransitionChartState copyWith({
    TransitionChartDateRange? transitionChartDateRange,
    TransitionSelectState? transitionSelectState,
    Category? selectCategory,
    DateTime? selectDate,
    List<TransitionChartGroupData>? transitionChartGroupDataList,
    List<String>? xTitleList,
  }) {
    return TransitionChartState(
      transitionChartDateRange:
          transitionChartDateRange ?? this.transitionChartDateRange,
      transitionSelectState:
          transitionSelectState ?? this.transitionSelectState,
      selectCategory: selectCategory ?? this.selectCategory,
      selectDate: selectDate ?? this.selectDate,
      transitionChartGroupDataList:
          transitionChartGroupDataList ?? this.transitionChartGroupDataList,
      xTitleList: xTitleList ?? this.xTitleList,
    );
  }

  TransitionChartState copyWithCategory({
    TransitionChartDateRange? transitionChartDateRange,
    TransitionSelectState? transitionSelectState,
    required Category? selectCategory,
    DateTime? selectDate,
    List<TransitionChartGroupData>? transitionChartGroupDataList,
    List<String>? xTitleList,
  }) {
    return TransitionChartState(
      transitionChartDateRange:
          transitionChartDateRange ?? this.transitionChartDateRange,
      transitionSelectState:
          transitionSelectState ?? this.transitionSelectState,
      selectCategory: selectCategory,
      selectDate: selectDate ?? this.selectDate,
      transitionChartGroupDataList:
          transitionChartGroupDataList ?? this.transitionChartGroupDataList,
      xTitleList: xTitleList ?? this.xTitleList,
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
class TransitionChartStateNotifier extends AsyncNotifier<TransitionChartState> {
  late final TransitionChartState _defaultState;
  @override
  Future<TransitionChartState> build() async {
    ref.onDispose(() {
      //state.valueOrNull?.listWheelYearController.dispose();
    });
    _defaultState = TransitionChartState.defaultState();
    return _defaultState;
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

  //transitionChartStateセット（グラフタッチ時のセレクタ変更）
  /*
  Future<void> setSelectTransitionChartStateFromGlaph(int index) async {
    if (state.valueOrNull != null) {
      final TransitionChartState transitionChartState = state.value!;
      late final TransitionSelectState newSelectState;
      late final Category? newCategory;
      switch (transitionChartState.transitionSelectState) {
        case TransitionSelectState.expenses:
          newSelectState = transitionChartState
              .transitionChartSectionDataMap[index].transitionSelectState;
          newCategory = null;
          break;
        case TransitionSelectState.income:
        case TransitionSelectState.outgo:
          newSelectState = TransitionSelectState.category;
          newCategory = transitionChartState
              .transitionChartSectionDataMap[index].category;
          break;
        case TransitionSelectState.category:
          //カテゴリー以下はないため、何もしない
          return;
        case TransitionSelectState.subCategory:
      }
      state = AsyncData(state.valueOrNull?.copyWith(
            transitionSelectState: newSelectState,
            selectCategory: newCategory,
          ) ??
          _defaultState);
      await reacquisitionRegisterListCallBack();
    }
  }*/

  //transitionChartStateセット（期間変更）
  void setRangeTransitionChartState(
      TransitionChartDateRange transitionChartDateRange) async {
    state = AsyncData(state.valueOrNull
            ?.copyWith(transitionChartDateRange: transitionChartDateRange) ??
        _defaultState);
    await reacquisitionRegisterListCallBack();
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
          //ありえない想定？
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

    if (registerList.isEmpty) {
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
        rangeMin = rangeMin.isBefore(registerGroupList[i].first.date)
            ? rangeMin
            : registerGroupList[i].first.date;
        rangeMax = rangeMax.isAfter(registerGroupList[i].last.date)
            ? rangeMax
            : registerGroupList[i].last.date;
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
          xTitleList.add('${currentDate.year}}');
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
    state = AsyncData(state.valueOrNull?.copyWith(
          transitionChartGroupDataList: transitionChartGroupDataList,
          xTitleList: xTitleList,
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
        keyGenerator = (date) => '${date.year}';
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
      if (i < keyList.length &&
          (currentDate.year == int.tryParse(keyList[i].substring(0, 4)) ||
              currentDate.month == int.tryParse(keyList[i].substring(4, 6)))) {
        //3.2.2.1 registerGroup→TransitionChartデータ作成（個別）
        final TransitionChartRodData transitionChartRodData =
            createBarChartGroupData(keyList[i], registerGroupMap[keyList[i]]);
        transitionChartRodDataList.add(transitionChartRodData);
        maxAmount = max(maxAmount, transitionChartRodData.value);
        i++;
      } else {
        //value0のチャートデータ追加
        transitionChartRodDataList.add(
            TransitionChartRodData(key: keyGenerator(currentDate), value: 0));
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
}
