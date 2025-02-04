import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/model/register.dart';
import 'package:household_expense_project/provider/chart_page_provider/chart_page_provider.dart';
import 'package:household_expense_project/provider/chart_page_provider/transition_chart_provider.dart';
import 'package:household_expense_project/provider/register_db_provider.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/provider/setting_data_provider.dart';

enum RateSelectState {
  expense("収入と支出"),
  outgo("支出"),
  income("収入"),
  category("カテゴリー");

  final String text;
  const RateSelectState(this.text);
}

enum RateChartDateRange {
  month("1ヶ月"),
  year("1年");

  final String text;
  const RateChartDateRange(this.text);
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
      category: category,
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
  final RateChartDateRange rateChartDateRange;
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
    required this.rateChartDateRange,
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
      : rateChartDateRange = RateChartDateRange.month,
        rateSelectState = RateSelectState.expense,
        selectCategory = null,
        selectDate = DateTime(DateTime.now().year, DateTime.now().month, 1),
        displayDate = DateTime(DateTime.now().year, DateTime.now().month, 1),
        isShowScrollView = false,
        rateRegisterLists = [],
        rateChartSectionDataList = [],
        listWheelYearController = FixedExtentScrollController(),
        listWheelMonthController =
            FixedExtentScrollController(initialItem: DateTime.now().month - 1);

  RateChartState copyWith({
    RateChartDateRange? rateChartDateRange,
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
      rateChartDateRange: rateChartDateRange ?? this.rateChartDateRange,
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
          ? ("${selectCategory!.expense.text} / ${selectCategory!.name}")
          : "";
    } else {
      return rateSelectState.text;
    }
  }
}

//Notifier
class RateChartStateNotifier extends AsyncNotifier<RateChartState> {
  final RateChartState _defaultState = RateChartState.defaultState();
  @override
  Future<RateChartState> build() async {
    ref.onDispose(() {
      state.valueOrNull?.listWheelYearController.dispose();
      state.valueOrNull?.listWheelMonthController.dispose();
    });

    var (sortedRegisterGroupList, sortedRateChartSectionDataList) =
        await reacquisitionRegisterList();
    return _defaultState.copyWith(
        rateRegisterLists: sortedRegisterGroupList,
        rateChartSectionDataList: sortedRateChartSectionDataList);
  }

  //RegisterDBが変更された際に実行
  Future<void> refreshRegisterList() async {
    await reacquisitionRegisterListCallBack();
  }

  //rateChartStateセット（セレクタ初期化）
  Future<void> initSelectRateChartState() async {
    await setSelectRateChartState(RateSelectState.expense, null);
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
        case RateSelectState.expense:
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
  void setRangeRateChartState(RateChartDateRange rateChartDateRange) async {
    state = AsyncData(
        state.valueOrNull?.copyWith(rateChartDateRange: rateChartDateRange) ??
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
    if (state.valueOrNull?.rateChartDateRange == RateChartDateRange.month) {
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

  //chart transitionへの推移
  void goChartTransitionPage(int index) async {
    if (state.valueOrNull == null) {
      return;
    }

    final currentState = state.value!;
    late final TransitionSelectState transitionSelectState;
    late final Category? selectCategory;
    late final TransitionChartDateRange transitionChartDateRange;
    final DateTime selectDate = currentState.selectDate;

    switch (currentState.rateSelectState) {
      case RateSelectState.expense:
        if (index == 0) {
          transitionSelectState = TransitionSelectState.outgo;
          selectCategory = null;
        } else {
          transitionSelectState = TransitionSelectState.income;
          selectCategory = null;
        }
        break;
      case RateSelectState.outgo:
        transitionSelectState = TransitionSelectState.category;
        selectCategory = currentState.rateChartSectionDataList[index].category;
        break;
      case RateSelectState.income:
        transitionSelectState = TransitionSelectState.category;
        selectCategory = currentState.rateChartSectionDataList[index].category;
        break;

      case RateSelectState.category:
        transitionSelectState = TransitionSelectState.subCategory;
        selectCategory =
            currentState.rateChartSectionDataList[index].category ??
                currentState.selectCategory;
        //nullの時、親カテゴリーを入れる（parentCategoryId=nullかつsubCategoryの時：サブカテゴリーなしのデータ）
        break;
    }

    switch (currentState.rateChartDateRange) {
      case RateChartDateRange.year:
        transitionChartDateRange = TransitionChartDateRange.year;
        break;
      case RateChartDateRange.month:
        transitionChartDateRange = TransitionChartDateRange.month;
        break;
    }

    await ref.read(transitionChartProvider.notifier).pageTransitionFromRate(
          transitionSelectState,
          selectCategory,
          transitionChartDateRange,
          selectDate,
        );
  }

  //
  //registerList、rateChartSectionDataList 更新コールバック
  Future<void> reacquisitionRegisterListCallBack() async {
    var (sortedRegisterGroupList, sortedRateChartSectionDataList) =
        await reacquisitionRegisterList();
    state = AsyncData(state.valueOrNull?.copyWith(
            rateRegisterLists: sortedRegisterGroupList,
            rateChartSectionDataList: sortedRateChartSectionDataList) ??
        _defaultState);
  }

  Future<(List<List<Register>>, List<RateChartSectionData>)>
      reacquisitionRegisterList() async {
    late final DateTime startDate;
    late final DateTime endDate;
    state = const AsyncLoading<RateChartState>().copyWithPrevious(state);
    final currentState = state.valueOrNull ?? _defaultState;

    switch (currentState.rateChartDateRange) {
      case RateChartDateRange.month:
        startDate = DateTime(currentState.selectDate.year,
            currentState.selectDate.month, 1, 0, 0, 0, 0, 0);
        endDate = DateTime(currentState.selectDate.year,
            currentState.selectDate.month + 1, 0, 23, 59, 59, 999);
        break;
      case RateChartDateRange.year:
        startDate = DateTime(currentState.selectDate.year, 1, 1, 0, 0, 0, 0, 0);
        endDate =
            DateTime(currentState.selectDate.year + 1, 1, 0, 23, 59, 59, 999);
    }

    late final List<Register> registerList;
    late final List<List<Register>> registerGroupList;
    late final List<RateChartSectionData> rateChartSectionDataList;

    //registerList取得→registerGroupList作成
    switch (currentState.rateSelectState) {
      case RateSelectState.expense:
        registerList = await RegisterDBProvider.getRegisterStateOfRange(
            startDate, endDate);
        registerGroupList = registerList
            .groupListsBy<SelectExpense?>(
                (register) => register.category?.expense)
            .values
            .toList();
        break;
      case RateSelectState.outgo:
        registerList =
            await RegisterDBProvider.getRegisterStateOfRangeAndSelectExpense(
                startDate, endDate, SelectExpense.outgo);
        registerGroupList = registerList
            .groupListsBy<int?>((register) => register.category?.id)
            .values
            .toList();
        break;
      case RateSelectState.income:
        registerList =
            await RegisterDBProvider.getRegisterStateOfRangeAndSelectExpense(
                startDate, endDate, SelectExpense.income);
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

    return (sortedRegisterGroupList, sortedRateChartSectionDataList);
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
      case RateSelectState.expense:
        title = registerGroup[0].category!.expense.text;
        if (registerGroup[0].category!.expense == SelectExpense.income) {
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
