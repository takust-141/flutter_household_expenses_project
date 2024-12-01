import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/component/generalized_logic_component.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/model/register.dart';
import 'package:household_expenses_project/provider/register_db_provider.dart';
import 'package:household_expenses_project/provider/register_edit_state.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/provider/setting_data_provider.dart';
import 'package:household_expenses_project/view/calendar_view/register_modal_view.dart';

//Provider
final calendarPageProvider =
    AsyncNotifierProvider<CalendarPageNotifier, CalendarPageState>(
        CalendarPageNotifier.new);

@immutable
class CalendarPageState implements RegisterEditState {
  final DateTime displayMonth;
  final DateTime selectDate;
  final List<Register> registerList;
  final Map<String, (int?, int?)> registerDaySumMap;
  final bool isShowScrollView;
  final bool isShowAccordion;
  final PageController pageViewController;
  final FixedExtentScrollController listWheelYearController;
  final FixedExtentScrollController listWheelMonthController;
  final double rotateIconAngle;
  final ScrollController listScrollController;
  @override
  final bool isActiveDoneButton;

  const CalendarPageState({
    required this.displayMonth,
    required this.selectDate,
    required this.registerList,
    required this.registerDaySumMap,
    required this.isShowScrollView,
    required this.isShowAccordion,
    required this.pageViewController,
    required this.listWheelYearController,
    required this.listWheelMonthController,
    this.rotateIconAngle = 0.5,
    this.isActiveDoneButton = true,
    required this.listScrollController,
  });

  CalendarPageState copyWith({
    DateTime? displayMonth,
    DateTime? selectDate,
    List<Register>? registerList,
    Map<String, (int?, int?)>? registerDaySumMap,
    bool? isShowScrollView,
    bool? isShowAccordion,
    double? rotateIconAngle,
    PageController? pageViewController,
    FixedExtentScrollController? listWheelYearController,
    FixedExtentScrollController? listWheelMonthController,
    bool? isActiveDoneButton,
    ScrollController? listScrollController,
  }) {
    return CalendarPageState(
      displayMonth: displayMonth ?? this.displayMonth,
      selectDate: selectDate ?? this.selectDate,
      registerList: registerList ?? this.registerList,
      registerDaySumMap: registerDaySumMap ?? this.registerDaySumMap,
      isShowScrollView: isShowScrollView ?? this.isShowScrollView,
      isShowAccordion: isShowAccordion ?? this.isShowAccordion,
      pageViewController: pageViewController ?? this.pageViewController,
      listWheelYearController:
          listWheelYearController ?? this.listWheelYearController,
      listWheelMonthController:
          listWheelMonthController ?? this.listWheelMonthController,
      rotateIconAngle: rotateIconAngle ?? this.rotateIconAngle,
      isActiveDoneButton: isActiveDoneButton ?? this.isActiveDoneButton,
      listScrollController: listScrollController ?? this.listScrollController,
    );
  }

  CalendarPageState.defaultState(
      {required DateTime startCalendarDate,
      required this.registerList,
      required this.registerDaySumMap})
      : displayMonth = DateTime.now(),
        selectDate = DateTime.now(),
        isShowScrollView = false,
        isShowAccordion = true,
        pageViewController = PageController(
            initialPage: ((DateTime.now().year - startCalendarDate.year) * 12) +
                DateTime.now().month -
                1),
        listWheelYearController = FixedExtentScrollController(),
        listWheelMonthController =
            FixedExtentScrollController(initialItem: DateTime.now().month - 1),
        rotateIconAngle = 0.5,
        isActiveDoneButton = false,
        listScrollController = ScrollController();
}

//Notifier
class CalendarPageNotifier
    extends RegisterEditStateNotifier<CalendarPageState> {
  late CalendarPageState _defaultState;
  @override
  Future<CalendarPageState> build() async {
    ref.onDispose(() {
      state.valueOrNull?.pageViewController.dispose();
      state.valueOrNull?.listWheelYearController.dispose();
      state.valueOrNull?.listWheelMonthController.dispose();
      state.valueOrNull?.listScrollController.dispose();
    });

    final registerList =
        await RegisterDBProvider.getRegisterStateOfMonth(DateTime.now());
    final registerDaySumMap = calcDaySumRegister(registerList);

    DateTime startCalendarDate;
    try {
      final settingDate = await ref.read(settingDataProvider.future);
      startCalendarDate = settingDate.startCalendarDate;
    } catch (_) {
      startCalendarDate = defaultStartCalendarDate;
    }

    _defaultState = CalendarPageState.defaultState(
      startCalendarDate: startCalendarDate,
      registerList: registerList,
      registerDaySumMap: registerDaySumMap,
    );

    return _defaultState;
  }

  //RegisterDBが変更された際に実行
  Future<void> refreshRegisterList() async {
    state = const AsyncLoading<CalendarPageState>().copyWithPrevious(state);
    final registerList = await RegisterDBProvider.getRegisterStateOfMonth(
        state.valueOrNull?.selectDate ?? DateTime.now());
    state = await AsyncValue.guard(() async {
      return state.valueOrNull?.copyWith(
              registerList: registerList,
              registerDaySumMap: calcDaySumRegister(registerList)) ??
          _defaultState;
    });
  }

  //日付のセット（年月が異なる場合、registerListを更新
  Future<void> setDate(DateTime date) async {
    if ((state.valueOrNull?.selectDate.year != date.year ||
        state.valueOrNull?.selectDate.month != date.month)) {
      state = const AsyncLoading<CalendarPageState>().copyWithPrevious(state);
      state = await AsyncValue.guard(() async {
        List<Register> registerList =
            await RegisterDBProvider.getRegisterStateOfMonth(date);
        return state.valueOrNull?.copyWith(
              displayMonth: date,
              selectDate: date,
              registerList: registerList,
              registerDaySumMap: calcDaySumRegister(registerList),
            ) ??
            _defaultState;
      });
    } else if (state.valueOrNull?.selectDate.day != date.day) {
      state = AsyncData(state.valueOrNull?.copyWith(
            displayMonth: date,
            selectDate: date,
          ) ??
          _defaultState);
    }
  }

  //カレンダーパネルタップ
  void tapCalendarPanel(BuildContext context, DateTime date, WidgetRef ref) {
    if (LogicComponent.matchDates(state.valueOrNull?.selectDate, date)) {
      //新規register追加モーダル表示
      ref.read(registerEditCategoryStateNotifierProvider.notifier).setInit();
      showRegisterModal(context, ref, null, calendarPageProvider);
    } else {
      state = AsyncData(state.valueOrNull?.copyWith(
            displayMonth: date,
            selectDate: date,
          ) ??
          _defaultState);
      scrollListController();
    }
  }

  //Listコントローラの移動（現在のselectDateまで）
  void scrollListController() {
    if (state.valueOrNull != null) {
      ScrollController controller = state.valueOrNull!.listScrollController;
      int count = 0;
      const double calendarListHeight = 50;
      for (Register register in state.valueOrNull!.registerList) {
        if (state.valueOrNull!.selectDate.day <= register.date.day) {
          double movePosition = ((calendarListHeight * count + small) >
                  controller.position.maxScrollExtent)
              ? controller.position.maxScrollExtent
              : (calendarListHeight * count + small);
          controller.animateTo(movePosition,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic);
          return;
        }
        count++;
      }
      controller.animateTo(controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic);
    }
  }

  //表示日付の変更
  void changeDisplayMonth(DateTime date) {
    state = AsyncData(
        state.valueOrNull?.copyWith(displayMonth: date) ?? _defaultState);
  }

  //アコーディオンボタンタップ時
  Future<void> tapAccordionButton() async {
    var newState = state.valueOrNull?.copyWith(
          isShowScrollView: false,
          isShowAccordion: !state.valueOrNull!.isShowAccordion,
          rotateIconAngle: state.valueOrNull!.rotateIconAngle + 0.5,
        ) ??
        _defaultState;
    state = AsyncData(newState);
  }

  //年月ボタンタップ
  Future<void> tapMonthButton() async {
    state = const AsyncLoading<CalendarPageState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      if (state.valueOrNull != null) {
        CalendarPageState currentState = state.valueOrNull!;
        if (state.valueOrNull!.isShowScrollView) {
          //ホイールリスト→ページ

          List<Register> registerList = (LogicComponent.matchMonth(
                  currentState.selectDate, currentState.displayMonth))
              ? currentState.registerList
              : await RegisterDBProvider.getRegisterStateOfMonth(
                  currentState.displayMonth);
          return currentState.copyWith(
            selectDate: currentState.displayMonth,
            isShowScrollView: false,
            registerList: registerList,
            registerDaySumMap: calcDaySumRegister(registerList),
            pageViewController: PageController(
                initialPage: calcDiffMonthIndex(currentState.displayMonth)),
          );
        } else {
          //ページ→ホイールリスト
          final calendarStartDate = ref.read(settingDataProvider.select(
              (p) => p.value?.startCalendarDate ?? defaultStartCalendarDate));
          int yearIndex = currentState.selectDate.year - calendarStartDate.year;
          int monthIndex = currentState.selectDate.month - 1;
          return currentState.copyWith(
            isShowScrollView: true,
            isShowAccordion: true,
            rotateIconAngle: currentState.isShowAccordion
                ? currentState.rotateIconAngle
                : currentState.rotateIconAngle + 0.5,
            listWheelYearController:
                FixedExtentScrollController(initialItem: yearIndex),
            listWheelMonthController:
                FixedExtentScrollController(initialItem: monthIndex),
          );
        }
      } else {
        return _defaultState;
      }
    });
  }

  //Modal Register 編集フォーム入力チェックリスナー用（初期化）
  @override
  void initDoneButton() {
    state = AsyncData(state.valueOrNull?.copyWith(isActiveDoneButton: false) ??
        _defaultState);
  }

  //Modal Register 編集フォーム入力チェックリスナー用
  @override
  void formInputCheck(
      TextEditingController controller, ValueNotifier<Category?> notifier) {
    final bool isActive =
        controller.text.isNotEmpty && (notifier.value != null);
    state = AsyncData(
        state.valueOrNull?.copyWith(isActiveDoneButton: isActive) ??
            _defaultState);
  }

  //ページビュー Month Index計算
  int calcDiffMonthIndex(DateTime date) {
    final calendarStartDate = ref.read(settingDataProvider
        .select((p) => p.value?.startCalendarDate ?? defaultStartCalendarDate));
    return ((date.year - calendarStartDate.year) * 12) + date.month - 1;
  }

  bool matchSelectedDate(DateTime date) {
    if (state.valueOrNull != null) {
      return LogicComponent.matchDates(date, state.valueOrNull!.selectDate);
    } else {
      return false;
    }
  }

  //日合計計算
  Map<String, (int?, int?)> calcDaySumRegister(
      List<Register>? targetRegisterList) {
    final List<Register> registerList =
        targetRegisterList ?? state.valueOrNull?.registerList ?? [];
    Map<String, (int?, int?)> map = {};

    DateTime? sumDate = registerList.isNotEmpty ? registerList[0].date : null;
    int sumIncome = 0;
    int sumOutgo = 0;

    for (Register register in registerList) {
      if (LogicComponent.matchDates(sumDate, register.date)) {
        if (register.category?.expenses == SelectExpenses.outgo) {
          sumOutgo += register.amount;
        } else if (register.category?.expenses == SelectExpenses.income) {
          sumIncome += register.amount;
        }
      } else {
        map["${sumDate?.month}${sumDate?.day}"] = (
          (sumIncome != 0) ? sumIncome : null,
          (sumOutgo != 0) ? sumOutgo : null
        );
        sumDate = register.date;

        if (register.category?.expenses == SelectExpenses.outgo) {
          sumOutgo = register.amount;
        } else if (register.category?.expenses == SelectExpenses.income) {
          sumIncome = register.amount;
        }
      }
    }
    //最後の一件追加
    if (sumDate != null) {
      map["${sumDate.month}${sumDate.day}"] = (
        (sumIncome != 0) ? sumIncome : null,
        (sumOutgo != 0) ? sumOutgo : null
      );
    }
    return map;
  }

  //月合計計算
  (int, int) calcMonthSumRegister() {
    final List<Register> registerList = state.valueOrNull?.registerList ?? [];
    int totalIncome = 0;
    int totalOutgo = 0;
    for (Register register in registerList) {
      if (register.category?.expenses == SelectExpenses.income) {
        totalIncome += register.amount;
      } else if (register.category?.expenses == SelectExpenses.outgo) {
        totalOutgo += register.amount;
      }
    }
    return (totalIncome, totalOutgo);
  }

  @override
  DateTime? currentSelectDate() {
    return state.valueOrNull?.selectDate;
  }
}
