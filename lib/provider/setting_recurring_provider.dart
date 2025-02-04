import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/model/register_recurring.dart';
import 'package:household_expense_project/provider/register_recurring_list_provider.dart';
import 'package:household_expense_project/provider/setting_data_provider.dart';

final settingRecurringyStateNotifierProvider =
    NotifierProvider<SettingRecurringStateNotifier, SettingRecurrintState>(
        SettingRecurringStateNotifier.new);

const selectBaseList = ["年ごと", "月ごと", "週ごと", "日ごと"];
final List<String> recurringIntervalYear = ['1年ごと（毎年）'];
final List<String> recurringIntervalMonth = List.generate(12, (index) {
  if (index == 0) {
    return '1ヶ月ごと（毎月）';
  } else {
    return '${index + 1}ヶ月ごと';
  }
});
final List<String> recurringIntervalWeek = List.generate(10, (index) {
  if (index == 0) {
    return '1週ごと（毎週）';
  } else {
    return '${index + 1}週ごと';
  }
});
final List<String> recurringIntervalDate = List.generate(31, (index) {
  if (index == 0) {
    return '1日ごと（毎日）';
  } else {
    return '${index + 1}日ごと';
  }
});
final recurringInterval = [
  recurringIntervalYear,
  recurringIntervalMonth,
  recurringIntervalWeek,
  recurringIntervalDate
];

const subBaseList = ["曜日", "日付"];
const recurringMonthList = [
  "1月",
  "2月",
  "3月",
  "4月",
  "5月",
  "6月",
  "7月",
  "8月",
  "9月",
  "10月",
  "11月",
  "12月"
];
const recurringOrdinalList = [
  "第1週",
  "第2週",
  "第3週",
  "第4週",
  "第5週（無い場合は最終週）",
  "第6週（最終週）"
];
const recurringWeekList = defaultWeeks;
final List<String> recurringDayList = List.generate(31, (index) {
  if (index == 28) {
    return '29日（無い場合は最終日）';
  } else if (index == 29) {
    return '30日（無い場合は最終日）';
  } else if (index == 30) {
    return '31日（最終日）';
  } else {
    return '${index + 1}日';
  }
});
//振替
const rescheduleTargetList = [...recurringWeekList, "祝日"];
const rescheduleWayList = ["前日以前", "翌日以降"];

const recurringDetailTitleList = [
  "繰り返し",
  "対象月",
  "基準",
  "何週目",
  "曜日",
  "日付",
  "振替対象",
  "振替方法",
  "繰り返し間隔"
];

final List<List<String>> recurringDetailList = [
  selectBaseList,
  recurringMonthList,
  subBaseList,
  recurringOrdinalList,
  recurringWeekList,
  recurringDayList,
  rescheduleTargetList,
  rescheduleWayList,
];

@immutable
class SettingRecurrintState {
  final RegisterRecurring? selectRegisterRecurring;
  final bool isActiveAppbarDeleteButton;
  final int? backUpRecurringId; //更新用バックアップ
  final bool selectInitNotifier;

  const SettingRecurrintState({
    required this.selectRegisterRecurring,
    this.isActiveAppbarDeleteButton = false,
    this.backUpRecurringId,
    this.selectInitNotifier = false,
  });

  SettingRecurrintState copyWith({
    RegisterRecurring? selectRegisterRecurring,
    bool? isActiveAppbarDeleteButton,
    int? backUpRecurringId,
    bool? selectInitNotifier,
  }) {
    return SettingRecurrintState(
      selectRegisterRecurring:
          selectRegisterRecurring ?? this.selectRegisterRecurring,
      isActiveAppbarDeleteButton:
          isActiveAppbarDeleteButton ?? this.isActiveAppbarDeleteButton,
      backUpRecurringId: backUpRecurringId ?? this.backUpRecurringId,
      selectInitNotifier: selectInitNotifier ?? this.selectInitNotifier,
    );
  }

  SettingRecurrintState copyWithRegisterRecurring({
    required RegisterRecurring? selectRegisterRecurring,
    bool? selectInitNotifier,
  }) {
    return SettingRecurrintState(
      selectRegisterRecurring: selectRegisterRecurring,
      isActiveAppbarDeleteButton: isActiveAppbarDeleteButton,
      backUpRecurringId: backUpRecurringId,
      selectInitNotifier: selectInitNotifier ?? this.selectInitNotifier,
    );
  }
}

//Notifier(index 0~5：繰り返し設定、6,7：振替、8：間隔)
class SettingRecurringStateNotifier extends Notifier<SettingRecurrintState> {
  @override
  SettingRecurrintState build() {
    return const SettingRecurrintState(
      selectRegisterRecurring: null,
    );
  }

  void setSelectRegisterRecurring(RegisterRecurring? registerRecurring) async {
    if (state.backUpRecurringId == null) {
      state = state.copyWithRegisterRecurring(
        selectRegisterRecurring: registerRecurring,
        selectInitNotifier: !state.selectInitNotifier,
      );
    } else {
      state = SettingRecurrintState(
        selectRegisterRecurring: ref
            .read(registerRecurringListNotifierProvider.notifier)
            .getRegisterRecurringFromId(state.backUpRecurringId!),
        isActiveAppbarDeleteButton: state.isActiveAppbarDeleteButton,
        backUpRecurringId: null,
        selectInitNotifier: !state.selectInitNotifier,
      );
    }
  }

  void setInitNotifier() {
    state = state.copyWith(selectInitNotifier: !state.selectInitNotifier);
  }

  //更新用selectBackUp
  void setSelectRegisterRecurringBackUp() {
    state = SettingRecurrintState(
      selectRegisterRecurring: state.selectRegisterRecurring,
      isActiveAppbarDeleteButton: state.isActiveAppbarDeleteButton,
      backUpRecurringId: state.selectRegisterRecurring?.id,
    );
  }

  void copyWithRecurringSetting({
    //指定なしの場合は変更なし
    RecurringSetting? recurringSetting,
    RescheduleSetting? rescheduleSetting,
  }) {
    state = state.copyWith(
        selectRegisterRecurring: state.selectRegisterRecurring?.copyWith(
            recurringSetting: recurringSetting,
            rescheduleSetting: rescheduleSetting));
  }

  //
  //繰り返し設定変更（ボタン押下時）
  void setRecurringSetting(int detailIndex, int index) {
    final RecurringSetting recurringSetting =
        state.selectRegisterRecurring?.recurringSetting ??
            RecurringSetting.defaultState();
    final RescheduleSetting rescheduleSetting =
        state.selectRegisterRecurring?.rescheduleSetting ??
            RescheduleSetting.defaultState();

    if (detailIndex == 0) {
      RecurringSetting initRecurringSetting = RecurringSetting.defaultState();
      if (index == 0) {
        //毎年の時（初期化）
      } else if (index == 1) {
        //毎月の時、対象月を全選択
        initRecurringSetting = initRecurringSetting
            .copyWith(recurringMonth: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);
      } else if (index == 2) {
        //毎週の時、基準を曜日に（初期値）
      } else if (index == 3) {
        //毎日の時、基準を日付に
        initRecurringSetting = initRecurringSetting.copyWith(criteria: 1);
      }
      copyWithRecurringSetting(
        recurringSetting: initRecurringSetting.copyWith(selectRecurring: index),
        rescheduleSetting: RescheduleSetting.defaultState(),
      );
      return;
    } else if (detailIndex == 1) {
      copyWithRecurringSetting(
          recurringSetting:
              recurringSetting.copyWithRecurringMonthChange(index: index));
    } else if (detailIndex == 2) {
      List<int> newOrdinalWeekList =
          List.from(recurringSetting.recurringOrdinalWeek);
      List<int> newWeekList = List.from(recurringSetting.recurringWeek);
      int recurringDate = recurringSetting.recurringDate;
      if (index == 0) {
        //曜日
        recurringDate = 0;
      } else {
        //日付
        newOrdinalWeekList = [0, 0, 0, 0, 0, 0];
        newWeekList = [0, 0, 0, 0, 0, 0, 0];
      }
      copyWithRecurringSetting(
        recurringSetting: recurringSetting.copyWith(
          criteria: index,
          recurringOrdinalWeek: newOrdinalWeekList,
          recurringWeek: newWeekList,
          recurringDate: recurringDate,
        ),
        rescheduleSetting: RescheduleSetting.defaultState(),
      );
    } else if (detailIndex == 3) {
      copyWithRecurringSetting(
          recurringSetting: recurringSetting.copyWithRecurringOrdinalWeekChange(
              index: index));
    } else if (detailIndex == 4) {
      copyWithRecurringSetting(
          recurringSetting:
              recurringSetting.copyWithRecurringWeekChange(week: index));
    } else if (detailIndex == 5) {
      copyWithRecurringSetting(
          recurringSetting: recurringSetting.copyWith(recurringDate: index));
    } else if (detailIndex == 6) {
      copyWithRecurringSetting(
          rescheduleSetting:
              rescheduleSetting.copyWithRescheduleTargetChange(index: index));
    } else if (detailIndex == 7) {
      copyWithRecurringSetting(
          rescheduleSetting: rescheduleSetting.copyWith(rescheduleWay: index));
    } else if (detailIndex == 8) {
      copyWithRecurringSetting(
          recurringSetting:
              recurringSetting.copyWith(recurringInterval: index));
    }
  }

  //
  //詳細Listのチェック判定
  bool getDetailChecked(int detailIndex, int index) {
    final RecurringSetting recurringSetting =
        state.selectRegisterRecurring?.recurringSetting ??
            RecurringSetting.defaultState();
    final RescheduleSetting rescheduleSetting =
        state.selectRegisterRecurring?.rescheduleSetting ??
            RescheduleSetting.defaultState();
    if (detailIndex == 0) {
      return index == recurringSetting.selectRecurring;
    } else if (detailIndex == 1) {
      return recurringSetting.recurringMonth[index] == 1;
    } else if (detailIndex == 2) {
      return index == recurringSetting.criteria;
    } else if (detailIndex == 3) {
      return recurringSetting.recurringOrdinalWeek[index] == 1;
    } else if (detailIndex == 4) {
      return recurringSetting.recurringWeek[index] == 1;
    } else if (detailIndex == 5) {
      return index == recurringSetting.recurringDate;
    } else if (detailIndex == 6) {
      return rescheduleSetting.rescheduleTarget[index] == 1;
    } else if (detailIndex == 7) {
      return index == rescheduleSetting.rescheduleWay;
    } else if (detailIndex == 8) {
      return index == recurringSetting.recurringInterval;
    }
    return false;
  }

  //現在の選択を表示
  String getSubText(int detailIndex) {
    final RecurringSetting recurringSetting =
        state.selectRegisterRecurring?.recurringSetting ??
            RecurringSetting.defaultState();
    final RescheduleSetting rescheduleSetting =
        state.selectRegisterRecurring?.rescheduleSetting ??
            RescheduleSetting.defaultState();
    if (detailIndex == 0) {
      return recurringInterval[recurringSetting.selectRecurring]
          [recurringSetting.recurringInterval];
    } else if (detailIndex == 1) {
      if (recurringSetting.recurringMonth.reduce((a, b) => a + b) == 12) {
        return "全ての月";
      } else {
        return getStringFromLists(
            recurringDetailList[detailIndex], recurringSetting.recurringMonth);
      }
    } else if (detailIndex == 2) {
      return recurringDetailList[detailIndex][recurringSetting.criteria];
    } else if (detailIndex == 3) {
      return getStringFromLists(recurringDetailList[detailIndex],
          recurringSetting.recurringOrdinalWeek);
    } else if (detailIndex == 3) {
      return getStringFromLists(recurringDetailList[detailIndex],
          recurringSetting.recurringOrdinalWeek);
    } else if (detailIndex == 4) {
      return getStringFromLists(
          recurringDetailList[detailIndex], recurringSetting.recurringWeek);
    } else if (detailIndex == 5) {
      return recurringDetailList[detailIndex][recurringSetting.recurringDate];
    } else if (detailIndex == 6) {
      if (getStringFromLists(recurringDetailList[detailIndex],
              rescheduleSetting.rescheduleTarget) ==
          "") {
        return "振替なし";
      } else {
        return getStringFromLists(recurringDetailList[detailIndex],
            rescheduleSetting.rescheduleTarget);
      }
    } else if (detailIndex == 7) {
      return recurringDetailList[detailIndex][rescheduleSetting.rescheduleWay];
    } else if (detailIndex == 8) {
      switch (recurringSetting.selectRecurring) {
        case 0:
          break;
        case 1:
          if (recurringSetting.recurringInterval <
              recurringIntervalMonth.length) {
            return recurringIntervalMonth[recurringSetting.recurringInterval];
          }
        case 2:
          if (recurringSetting.recurringInterval <
              recurringIntervalWeek.length) {
            return recurringIntervalWeek[recurringSetting.recurringInterval];
          }
        case 3:
          if (recurringSetting.recurringInterval <
              recurringIntervalDate.length) {
            return recurringIntervalDate[recurringSetting.recurringInterval];
          }
      }
    }
    return "";
  }

  //セレクターリスト取得
  List<String> getSelectorList(int index) {
    if (index < recurringDetailList.length) {
      return recurringDetailList[index];
    } else {
      return [];
    }
  }

  //詳細リスト用、サブタイトル取得
  String getStringFromLists(List<String> textList, List<int> indexList) {
    List<String> selectedStrings = [];
    for (int i = 0; i < indexList.length; i++) {
      if (indexList[i] == 1) {
        selectedStrings.add(textList[i]);
      }
    }
    return selectedStrings.join(","); // 結果を結合して返す
  }

  //振替
  bool isReschedule() {
    //振替日が一つでも設定されていればtrue
    return (state.selectRegisterRecurring?.rescheduleSetting.rescheduleTarget
            .contains(1) ??
        false);
  }

  bool isSettedMonth() {
    RecurringSetting? recurringSetting =
        state.selectRegisterRecurring?.recurringSetting;
    if (recurringSetting?.criteria == 0) {
      if ((recurringSetting?.recurringOrdinalWeek.contains(1) ?? false) &&
          (recurringSetting?.recurringWeek.contains(1) ?? false)) {
        return true;
      }
    }
    return false;
  }

  //RegisterRecurringの登録時チェック（nullがないか）
  bool registerFormCheck() {
    bool isSetted = false;
    RecurringSetting? recurringSetting =
        state.selectRegisterRecurring?.recurringSetting;
    switch (recurringSetting?.selectRecurring) {
      case 0:
        //月
        if (!(recurringSetting?.recurringMonth.contains(1) ?? false)) {
          isSetted = false;
          break;
        } else {
          if (recurringSetting?.criteria == 0) {
            //週目と曜日
            if (isSettedMonth()) {
              isSetted = true;
            }
          } else {
            isSetted = true;
          }
        }
      case 1:
        //週目と曜日
        if (recurringSetting?.criteria == 0) {
          //週目と曜日
          if (isSettedMonth()) {
            isSetted = true;
          }
        } else {
          isSetted = true;
        }
      case 2:
        //曜日
        if (recurringSetting?.recurringWeek.contains(1) ?? false) {
          isSetted = true;
        }
      case 3:
        isSetted = true;
      default:
        isSetted = false;
        break;
    }
    return isSetted;
  }

  //Appbar削除ボタン有効化無効化
  void updateAppbarDeleteButton(bool isActive) {
    state = state.copyWith(isActiveAppbarDeleteButton: isActive);
  }

  //初期化
  void clearRegisterRecurring() {
    state = state.copyWith(
      selectRegisterRecurring: null,
    );
  }
}
