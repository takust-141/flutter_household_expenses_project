import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/model/register.dart';
import 'package:household_expenses_project/provider/register_db_provider.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/provider/setting_data_provider.dart';

enum RateDateRange {
  month("1ヶ月"),
  year("1年");

  final String text;
  const RateDateRange(this.text);
}

enum RateSelectState {
  category("カテゴリー"),
  income("収入"),
  outgo("支出"),
  expenses("収入と支出");

  final String text;
  const RateSelectState(this.text);
}

//PieChart用
@immutable
class RateChartSectionData {
  final String title;
  final int value;
  final Color color;
  final double rate;
  final RateSelectState rateSelectState;
  final Category? category;
  const RateChartSectionData({
    required this.title,
    required this.value,
    required this.color,
    required this.rate,
    required this.rateSelectState,
    this.category,
  });
  RateChartSectionData copyWith({
    String? title,
    int? value,
    Color? color,
    double? rate,
    RateSelectState? rateSelectState,
  }) {
    return RateChartSectionData(
      title: title ?? this.title,
      value: value ?? this.value,
      color: color ?? this.color,
      rate: rate ?? this.rate,
      rateSelectState: rateSelectState ?? this.rateSelectState,
      category: category ?? this.category,
    );
  }
}

//割合チャート用
final rateChartProvider =
    AsyncNotifierProvider<RateChartStateNotifier, RateChartState>(
        RateChartStateNotifier.new);

//RateChartState
@immutable
class RateChartState {
  final RateDateRange rateDateRange;
  final RateSelectState rateSelectState;
  final Category? selectCategory;
  final DateTime selectDate;
  final DateTime displayDate;
  final List<List<Register>> rateRegisterLists;
  final List<RateChartSectionData> rateChartSectionDataList;
  final bool isShowScrollView;
  final FixedExtentScrollController listWheelYearController;
  final FixedExtentScrollController listWheelMonthController;
  const RateChartState({
    required this.rateDateRange,
    required this.rateSelectState,
    required this.selectCategory,
    required this.selectDate,
    required this.rateRegisterLists,
    required this.rateChartSectionDataList,
    required this.isShowScrollView,
    required this.displayDate,
    required this.listWheelYearController,
    required this.listWheelMonthController,
  });

  RateChartState.defaultState()
      : rateDateRange = RateDateRange.month,
        rateSelectState = RateSelectState.expenses,
        selectCategory = null,
        selectDate = DateTime.now(),
        displayDate = DateTime.now(),
        isShowScrollView = false,
        rateRegisterLists = [],
        rateChartSectionDataList = [],
        listWheelYearController = FixedExtentScrollController(),
        listWheelMonthController =
            FixedExtentScrollController(initialItem: DateTime.now().month - 1);

  RateChartState copyWith({
    RateDateRange? rateDateRange,
    RateSelectState? rateSelectState,
    Category? selectCategory,
    DateTime? selectDate,
    DateTime? displayDate,
    List<List<Register>>? rateRegisterLists,
    List<RateChartSectionData>? rateChartSectionDataList,
    Category? category,
    bool? isShowScrollView,
    FixedExtentScrollController? listWheelYearController,
    FixedExtentScrollController? listWheelMonthController,
  }) {
    return RateChartState(
      rateDateRange: rateDateRange ?? this.rateDateRange,
      rateSelectState: rateSelectState ?? this.rateSelectState,
      selectCategory: selectCategory ?? this.selectCategory,
      selectDate: selectDate ?? this.selectDate,
      displayDate: displayDate ?? this.displayDate,
      rateRegisterLists: rateRegisterLists ?? this.rateRegisterLists,
      rateChartSectionDataList:
          rateChartSectionDataList ?? this.rateChartSectionDataList,
      isShowScrollView: isShowScrollView ?? this.isShowScrollView,
      listWheelYearController:
          listWheelYearController ?? this.listWheelYearController,
      listWheelMonthController:
          listWheelMonthController ?? this.listWheelMonthController,
    );
  }

  String selectListTitle() {
    if (rateSelectState == RateSelectState.category) {
      return (selectCategory != null)
          ? ("${selectCategory!.expenses.text} / ${selectCategory!.name}")
          : "";
    } else {
      return rateSelectState.text;
    }
  }
}

//Notifier
class RateChartStateNotifier extends AsyncNotifier<RateChartState> {
  late final RateChartState _defaultState;
  @override
  Future<RateChartState> build() async {
    ref.onDispose(() {
      state.valueOrNull?.listWheelYearController.dispose();
      state.valueOrNull?.listWheelMonthController.dispose();
    });
    _defaultState = RateChartState.defaultState();
    return _defaultState;
  }

  //rateChartStateセット（セレクタ変更）
  Future<void> setSelectRateChartState(
      RateSelectState rateSelectState, Category? category) async {
    state = AsyncData(state.valueOrNull?.copyWith(
          rateSelectState: rateSelectState,
          selectCategory: category,
        ) ??
        _defaultState);
    await reacquisitionRegisterListCallBack();
  }

  //rateChartStateセット（グラフタッチ時のセレクタ変更）
  Future<void> setSelectRateChartStateFromGlaph(int index) async {
    if (state.valueOrNull != null) {
      final RateChartState rateChartState = state.value!;
      late final RateSelectState newSelectState;
      late final Category? newCategory;
      switch (rateChartState.rateSelectState) {
        case RateSelectState.expenses:
          newSelectState =
              rateChartState.rateChartSectionDataList[index].rateSelectState;
          newCategory = null;
          break;
        case RateSelectState.income:
        case RateSelectState.outgo:
          newSelectState = RateSelectState.category;
          newCategory = rateChartState.rateChartSectionDataList[index].category;
          break;
        case RateSelectState.category:
          //カテゴリー以下はないため、何もしない
          return;
      }
      state = AsyncData(state.valueOrNull?.copyWith(
            rateSelectState: newSelectState,
            selectCategory: newCategory,
          ) ??
          _defaultState);
      await reacquisitionRegisterListCallBack();
    }
  }

  //rateChartStateセット（期間変更）
  void setRangeRateChartState(RateDateRange rateDateRange) async {
    state = AsyncData(
        state.valueOrNull?.copyWith(rateDateRange: rateDateRange) ??
            _defaultState);
    await reacquisitionRegisterListCallBack();
  }

  //日付変更
  Future<void> setDateTime(DateTime date) async {
    state = AsyncData(
        state.valueOrNull?.copyWith(selectDate: date, displayDate: date) ??
            _defaultState);
    await reacquisitionRegisterListCallBack();
  }

  //表示日付変更
  void setDisplayDateTime(DateTime date) {
    state = AsyncData(
        state.valueOrNull?.copyWith(displayDate: date) ?? _defaultState);
  }

  //日付ボタンタップ
  Future<void> tapDateButton() async {
    if (state.value?.isShowScrollView == true) {
      state = AsyncData(state.valueOrNull?.copyWith(
            isShowScrollView: !state.value!.isShowScrollView,
          ) ??
          _defaultState);
      await setDateTime(state.value!.displayDate);
    } else if (state.value?.isShowScrollView == false) {
      //ホイールリスト表示
      final calendarStartDate = ref.read(settingDataProvider.select(
          (p) => p.value?.startCalendarDate ?? defaultStartCalendarDate));

      int yearIndex =
          state.valueOrNull!.selectDate.year - calendarStartDate.year;
      int monthIndex = state.valueOrNull!.selectDate.month - 1;

      state = AsyncData(state.valueOrNull?.copyWith(
            isShowScrollView: !state.value!.isShowScrollView,
            listWheelYearController:
                FixedExtentScrollController(initialItem: yearIndex),
            listWheelMonthController:
                FixedExtentScrollController(initialItem: monthIndex),
          ) ??
          _defaultState);
    }
  }

  //日付矢印ボタンタップ
  Future<void> tapDateArrowButton(int diff) async {
    if (state.valueOrNull == null) return;
    late final DateTime newDisplayDate;
    final DateTime oldDisplayDate = state.valueOrNull!.displayDate;
    if (state.valueOrNull?.rateDateRange == RateDateRange.month) {
      //年更新
      newDisplayDate =
          DateTime(oldDisplayDate.year, oldDisplayDate.month + diff);
    } else {
      //月更新
      newDisplayDate =
          DateTime(oldDisplayDate.year + diff, oldDisplayDate.month);
    }

    await setDateTime(newDisplayDate);
  }

  //
  //registerList、rateChartSectionDataList 更新コールバック
  Future<void> reacquisitionRegisterListCallBack() async {
    late final DateTime startDate;
    late final DateTime endDate;
    state = const AsyncLoading<RateChartState>().copyWithPrevious(state);
    final currentState = state.valueOrNull ?? _defaultState;

    switch (currentState.rateDateRange) {
      case RateDateRange.month:
        startDate = DateTime(
            currentState.selectDate.year, currentState.selectDate.month, 1);
        endDate = DateTime(
            currentState.selectDate.year, currentState.selectDate.month + 1, 0);
        break;
      case RateDateRange.year:
        startDate = DateTime(currentState.selectDate.year, 1, 1);
        endDate = DateTime(currentState.selectDate.year + 1, 1, 0);
    }

    late final List<Register> registerList;
    late final List<List<Register>> registerGroupList;
    late final List<RateChartSectionData> rateChartSectionDataList;

    //registerList取得→registerGroupList作成
    switch (currentState.rateSelectState) {
      case RateSelectState.expenses:
        registerList = await RegisterDBProvider.getRegisterStateOfRange(
            startDate, endDate);
        registerGroupList = registerList
            .groupListsBy<SelectExpenses?>(
                (register) => register.category?.expenses)
            .values
            .toList();
        break;
      case RateSelectState.outgo:
        registerList =
            await RegisterDBProvider.getRegisterStateOfRangeAndSelectExpenses(
                startDate, endDate, SelectExpenses.outgo);
        registerGroupList = registerList
            .groupListsBy<int?>((register) => register.category?.id)
            .values
            .toList();
        break;
      case RateSelectState.income:
        registerList =
            await RegisterDBProvider.getRegisterStateOfRangeAndSelectExpenses(
                startDate, endDate, SelectExpenses.income);
        registerGroupList = registerList
            .groupListsBy<int?>((register) => register.category?.id)
            .values
            .toList();
        break;

      case RateSelectState.category:
        final categoryList = [currentState.selectCategory!];
        registerList =
            await RegisterDBProvider.getRegisterStateOfRangeAndCategoryList(
                startDate, endDate, categoryList);
        registerGroupList = registerList
            .groupListsBy<int?>((register) => register.subCategory?.id)
            .values
            .toList();
        break;
    }
    //registerGroupList→チャート用データリスト作成
    rateChartSectionDataList = createRateChartSectionDataList(
        registerGroupList, currentState.rateSelectState);

    //割合の大きい順に並び替え
    List<int> indices =
        List.generate(rateChartSectionDataList.length, (index) => index);
    indices.sort((a, b) => rateChartSectionDataList[b]
        .rate
        .compareTo(rateChartSectionDataList[a].rate));

    List<List<Register>> sortedRegisterGroupList = [];
    List<RateChartSectionData> sortedRateChartSectionDataList = [];
    for (var index in indices) {
      sortedRegisterGroupList.add(registerGroupList[index]);
      sortedRateChartSectionDataList.add(rateChartSectionDataList[index]);
    }

    state = AsyncData(state.valueOrNull?.copyWith(
            rateRegisterLists: sortedRegisterGroupList,
            rateChartSectionDataList: sortedRateChartSectionDataList) ??
        _defaultState);
  }

  //registerGroupList→チャート用データリスト作成
  List<RateChartSectionData> createRateChartSectionDataList(
      List<List<Register>> registerGroupList, RateSelectState rateSelectState) {
    List<RateChartSectionData> sectionDataList = [];
    int totalAmount = 0;

    for (List<Register> registerGroup in registerGroupList) {
      final data = createRateChartSectionData(registerGroup, rateSelectState);
      totalAmount += data.value;
      sectionDataList.add(data);
    }

    List<RateChartSectionData> rateChartSectionDataList = [];
    for (RateChartSectionData section in sectionDataList) {
      rateChartSectionDataList
          .add(section.copyWith(rate: (section.value / totalAmount) * 100));
    }
    return rateChartSectionDataList;
  }

  //registerGroup→チャート用データ作成
  RateChartSectionData createRateChartSectionData(
      List<Register> registerGroup, RateSelectState rateSelectState) {
    late final String title;
    late final Color color;
    late final Category? setCategory;
    late final RateSelectState setRateSelectState;

    switch (rateSelectState) {
      case RateSelectState.expenses:
        title = registerGroup[0].category!.expenses.text;
        if (registerGroup[0].category!.expenses == SelectExpenses.income) {
          color = Colors.blue;
          setRateSelectState = RateSelectState.income;
        } else {
          color = Colors.red;
          setRateSelectState = RateSelectState.outgo;
        }
        setCategory = null;
        break;
      case RateSelectState.income:
      case RateSelectState.outgo:
        title = registerGroup[0].category!.name;
        color = registerGroup[0].category!.color;
        setRateSelectState = RateSelectState.category;
        setCategory = registerGroup[0].category;
        break;
      case RateSelectState.category:
        title = registerGroup[0].subCategory?.name ?? "サブカテゴリーなし";
        color = registerGroup[0].subCategory?.color ??
            registerGroup[0].category!.color;
        setRateSelectState =
            RateSelectState.category; //サブカテゴリー以下はなく、使用しないためここではcategoryをセット
        setCategory = registerGroup[0].subCategory;
        break;
    }

    final int sumAmount = registerGroup
        .fold(0, (total, register) => total + register.amount)
        .abs();

    return RateChartSectionData(
      title: title,
      color: color,
      value: sumAmount,
      rate: 0,
      category: setCategory,
      rateSelectState: setRateSelectState,
    );
  }
}
