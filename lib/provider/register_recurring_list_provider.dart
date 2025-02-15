import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/generalized_logic_component.dart';
import 'package:household_expense_project/component/register_snackbar.dart';
import 'package:household_expense_project/component/setting_component.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/model/register.dart';
import 'package:household_expense_project/model/register_recurring.dart';
import 'package:household_expense_project/provider/register_db_provider.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/provider/setting_recurring_provider.dart';
import 'package:household_expense_project/view_model/register_db_helper.dart';
import 'package:household_expense_project/view_model/register_recurring_db_helper.dart';
import 'package:holiday_jp/holiday_jp.dart' as holiday_jp;

//繰り返し収支のリスト
//Provider
final registerRecurringListNotifierProvider = AsyncNotifierProvider<
    RegisterRecurringNotifier,
    Map<SelectExpense, List<RegisterRecurring>>>(RegisterRecurringNotifier.new);

//RegisterRecurringNotifier
class RegisterRecurringNotifier
    extends AsyncNotifier<Map<SelectExpense, List<RegisterRecurring>>> {
  //初期作業・初期値
  @override
  Future<Map<SelectExpense, List<RegisterRecurring>>> build() async {
    return await getAllRegisterRecurringList();
  }

  Future<Map<SelectExpense, List<RegisterRecurring>>>
      getAllRegisterRecurringList() async {
    final registerRecurringListMap = {
      SelectExpense.outgo:
          await RegisterRecurringDBHelper.getRegisterRecurringOfSelectExpense(
              SelectExpense.outgo),
      SelectExpense.income:
          await RegisterRecurringDBHelper.getRegisterRecurringOfSelectExpense(
              SelectExpense.income),
    };

    return registerRecurringListMap;
  }

  //insert
  Future insertRegisterRecurring({
    required int amount,
    required Category category,
    Category? subCategory,
    String? memo,
    required DateTime startDate,
    DateTime? endDate,
    required RecurringSetting recurringSetting,
    required RescheduleSetting rescheduleSetting,
    required BuildContext context,
  }) async {
    state = const AsyncValue.loading();
    final IndicatorOverlay indicatorOverlay = IndicatorOverlay();
    indicatorOverlay.insertOverlay(context);

    try {
      final List<RegisterRecurring> list =
          state.valueOrNull?[category.expense] ?? [];
      //order計算
      int maxOrder = 0;
      for (int i = 0; i < list.length; i++) {
        maxOrder = max(maxOrder, list[i].order ?? 0);
      }
      //registerRecurring登録
      RegisterRecurring registerRecurring = RegisterRecurring(
        amount: amount,
        category: category,
        subCategory: subCategory,
        memo: memo,
        startDate: startDate,
        endDate: endDate,
        order: maxOrder + 1,
        recurringSetting: recurringSetting,
        rescheduleSetting: rescheduleSetting,
      );

      int insertId = await RegisterRecurringDBHelper.insertRegisterRecurring(
          registerRecurring);

      //繰り返し日付計算
      List<DateTime> recurringDateList = calcRecurringDateList(
        startDate: startDate,
        endDate: endDate,
        recurringSetting: recurringSetting,
        rescheduleSetting: rescheduleSetting,
      );

      //register（繰り返し収支）リスト作成
      List<Register> insertRegisterList = [];
      for (DateTime recurringDate in recurringDateList) {
        final Register insertRegister = Register(
          amount: amount,
          category: category,
          subCategory: subCategory,
          memo: memo,
          date: recurringDate,
          recurringId: insertId,
          registrationDate: DateTime.now(),
        );
        insertRegisterList.add(insertRegister);
      }

      //registerList登録
      await RegisterDBHelper.insertRegisterList(insertRegisterList);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('Error: $e');
      rethrow;
    } finally {
      //register recurring List更新
      state = AsyncData(await getAllRegisterRecurringList());
      //register表示の更新
      RegisterDBProvider.refreshFromCategory(ref);
      indicatorOverlay.removeOverlay();
    }
  }

  //繰り返しの日付計算
  List<DateTime> calcRecurringDateList({
    required DateTime startDate,
    DateTime? endDate,
    required RecurringSetting recurringSetting,
    required RescheduleSetting rescheduleSetting,
  }) {
    List<DateTime> recurringDateList = [];
    //終了日が設定されていない場合は100年後まで
    endDate ??= DateTime(DateTime.now().year + 101, 1, 0);

    //振替関数作成（範囲外の場合はNullを返す）
    late final (DateTime?, int) Function(DateTime, DateTime, DateTime)
        rescheduleDate;
    if (!rescheduleSetting.rescheduleTarget.contains(1)) {
      //振替なしの場合は範囲チェックのみ
      rescheduleDate = (targetDate, startDate, endDate) {
        int rangeFlag =
            LogicComponent.isDateInRange(targetDate, startDate, endDate);
        if (rangeFlag == 0) {
          return (targetDate, 0);
        } else {
          return (null, rangeFlag);
        }
      };
    } else {
      //振替条件（trueの時、振替）
      late final bool Function(DateTime) isTargetDate;
      late final bool Function(DateTime) rescheduleHoliday;
      if (rescheduleSetting.rescheduleTarget[7] == 1) {
        //祝日振替ありの時
        rescheduleHoliday = (date) => holiday_jp.isHoliday(date);
      } else {
        rescheduleHoliday = (date) => false;
      }
      isTargetDate = (date) {
        return rescheduleHoliday(date) ||
            (rescheduleSetting.rescheduleTarget[date.weekday - 1] == 1);
      };

      //振替先
      late final DateTime Function(DateTime) reschedule;
      if (rescheduleSetting.rescheduleWay == 0) {
        reschedule = (date) => date.subtract(const Duration(days: 1));
      } else {
        reschedule = (date) => date.add(const Duration(days: 1));
      }

      rescheduleDate = (targetDate, startDate, endDate) {
        DateTime calcDate = targetDate;
        int rangeFlag =
            LogicComponent.isDateInRange(targetDate, startDate, endDate);
        while (isTargetDate(calcDate)) {
          if (rangeFlag == 0) {
            //振替対象の間、リスケジュール
            calcDate = reschedule(calcDate);
            rangeFlag =
                LogicComponent.isDateInRange(targetDate, startDate, endDate);
          } else {
            return (null, rangeFlag);
          }
        }
        return (calcDate, rangeFlag);
      };
    }

    //繰り返し結果の日付List作成
    switch (recurringSetting.selectRecurring) {
      case 0:
        //毎年
        recurringDateList = calcRecurringDateListOfMonth(
            recurringSetting, startDate, endDate, rescheduleDate);
      case 1:
        //毎月
        recurringDateList = calcRecurringDateListOfMonth(
            recurringSetting, startDate, endDate, rescheduleDate);

      case 2:
        //毎週

        for (int i = 0; i < recurringSetting.recurringWeek.length; i++) {
          if (recurringSetting.recurringWeek[i] == 1) {
            DateTime calcDate =
                DateTime(startDate.year, startDate.month, startDate.day);
            int targetWeekday = i + 1;
            if (targetWeekday != calcDate.weekday) {
              // 次の対象曜日までの日数を計算
              int daysToNextTarget = (targetWeekday - calcDate.weekday + 7) % 7;
              calcDate = calcDate.add(Duration(days: daysToNextTarget));
            }

            int intervalOffsetWeek = recurringSetting.recurringInterval;
            (DateTime?, int) rescheduledDate =
                rescheduleDate(calcDate, startDate, endDate);

            //endDateを超えない間
            while (rescheduledDate.$2 != 2) {
              //スキップ判定
              if (rescheduledDate.$1 != null) {
                if (intervalOffsetWeek >= recurringSetting.recurringInterval) {
                  //振替後の日付を格納（calcDateを振替日に更新はしない）
                  recurringDateList.add(rescheduledDate.$1!);
                  intervalOffsetWeek = 0;
                } else {
                  intervalOffsetWeek++;
                }
              } //startDateより前の場合は、初回の日付をずらす

              calcDate = calcDate.add(const Duration(days: 7));
              rescheduledDate = rescheduleDate(calcDate, startDate, endDate);
            }
          }
        }
        rescheduleSetting.rescheduleTarget;

      case 3:
        //毎日
        DateTime calcDate =
            DateTime(startDate.year, startDate.month, startDate.day);
        (DateTime?, int) rescheduledDate =
            rescheduleDate(calcDate, startDate, endDate);

        int intervalOffsetDate = recurringSetting.recurringInterval;

        //endDateを超えない間
        while (rescheduledDate.$2 != 2) {
          //スキップ判定
          if (rescheduledDate.$1 != null) {
            if (intervalOffsetDate >= recurringSetting.recurringInterval) {
              recurringDateList.add(rescheduledDate.$1!);
              intervalOffsetDate = 0;
            } else {
              intervalOffsetDate++;
            }
          } //startDateより前の場合は、初回の日付をずらす
          calcDate = calcDate.add(const Duration(days: 1));
          rescheduledDate = rescheduleDate(calcDate, startDate, endDate);
        }
      default:
    }

    // ソート（昇順）
    recurringDateList.sort((a, b) => a.compareTo(b));
    // 重複排除
    final List<DateTime> uniqueSortedrecurringDateList =
        recurringDateList.toSet().toList();

    return uniqueSortedrecurringDateList;
  }

  //calcRecurringDateListのパーツ
  List<DateTime> calcRecurringDateListOfMonth(
    RecurringSetting recurringSetting,
    DateTime startDate,
    DateTime endDate,
    (DateTime?, int) Function(DateTime, DateTime, DateTime) rescheduleDate,
  ) {
    List<DateTime> recurringDateList = [];
    int intervalOffsetMonth = recurringSetting.recurringInterval;

    if (recurringSetting.criteria == 0) {
      //曜日基準
      DateTime calcDate = DateTime(startDate.year, startDate.month, 1);
      bool isEnd = false;
      while (!isEnd) {
        //スキップ判定
        if (recurringSetting.selectRecurring == 0) {
          //年ごと
          if (recurringSetting.recurringMonth[calcDate.month - 1] == 0) {
            calcDate = DateTime(calcDate.year, calcDate.month + 1, 1);
            continue;
          }
        } else if (recurringSetting.selectRecurring == 1) {
          //月ごと
          if (intervalOffsetMonth >= recurringSetting.recurringInterval) {
            intervalOffsetMonth = 0;
          } else {
            intervalOffsetMonth++;
            calcDate = DateTime(calcDate.year, calcDate.month + 1, 1);
            continue;
          }
        }

        //j曜日
        for (int j = 0; j < recurringSetting.recurringWeek.length; j++) {
          if (recurringSetting.recurringWeek[j] == 1) {
            // 最初の指定曜日までの日数を計算
            int daysToFirstTargetDay = (j + 1 - calcDate.weekday + 7) % 7;
            // 最初の指定曜日の日付を計算
            DateTime firstTargetDay =
                calcDate.add(Duration(days: daysToFirstTargetDay));

            //第i週
            for (int i = 0;
                i < recurringSetting.recurringOrdinalWeek.length;
                i++) {
              if (recurringSetting.recurringOrdinalWeek[i] == 1) {
                // 第nth回目の曜日の日付を計算
                DateTime nthTargetDay =
                    firstTargetDay.add(Duration(days: i * 7));

                //月跨ぎ処理
                while (LogicComponent.isBeforeMonth(calcDate, nthTargetDay)) {
                  nthTargetDay = nthTargetDay.subtract(const Duration(days: 7));
                }

                final rescheduledDate =
                    rescheduleDate(nthTargetDay, startDate, endDate);
                if (rescheduledDate.$1 != null) {
                  //範囲内であれば振替後の日付を格納
                  recurringDateList.add(rescheduledDate.$1!);
                } else if (rescheduledDate.$2 == 2) {
                  //endDateを超えたら終了
                  isEnd = true;
                  break;
                }
              }
            }
          }
        }
        calcDate = DateTime(calcDate.year, calcDate.month + 1, 1);
      }
    } else {
      //日付基準
      DateTime calcMonth = DateTime(startDate.year, startDate.month);
      bool isEnd = false;
      while (!isEnd) {
        //スキップ判定
        if (recurringSetting.selectRecurring == 0) {
          //年ごと
          if (recurringSetting.recurringMonth[calcMonth.month - 1] == 0) {
            calcMonth = DateTime(calcMonth.year, calcMonth.month + 1);
            continue;
          }
        } else if (recurringSetting.selectRecurring == 1) {
          //月ごと
          if (intervalOffsetMonth >= recurringSetting.recurringInterval) {
            intervalOffsetMonth = 0;
          } else {
            intervalOffsetMonth++;
            calcMonth = DateTime(calcMonth.year, calcMonth.month + 1, 1);
            continue;
          }
        }

        DateTime calcDate = DateTime(calcMonth.year, calcMonth.month,
            recurringSetting.recurringDate + 1);
        //月跨ぎ処理
        while (!LogicComponent.matchMonth(calcMonth, calcDate)) {
          calcDate = calcDate.subtract(const Duration(days: 1));
        }

        final rescheduledDate = rescheduleDate(calcDate, startDate, endDate);
        if (rescheduledDate.$1 != null) {
          //範囲内であれば振替後の日付を格納
          recurringDateList.add(rescheduledDate.$1!);
        } else if (rescheduledDate.$2 == 2) {
          //endDateを超えたら終了
          isEnd = true;
          break;
        }
        calcMonth = DateTime(calcDate.year, calcDate.month + 1);
      }
    }
    return recurringDateList;
  }

  //削除処理
  //recurring削除 → register削除 → サブカテゴリーとメインカテゴリー削除 → リスト、各state更新
  Future<void> deleteRegisterRecurringFromId(
      int id, BuildContext context) async {
    bool isError = false;
    state = const AsyncValue.loading();
    final IndicatorOverlay indicatorOverlay = IndicatorOverlay();
    indicatorOverlay.insertOverlay(context);
    try {
      //各register削除→registerRecrring削除
      await RegisterRecurringDBHelper.deleteRegisterRecurringFromId(id);
    } catch (e, stackTrace) {
      isError = true;
      state = AsyncValue.error(e, stackTrace);
    } finally {
      //register recurring List更新
      state = AsyncData(await getAllRegisterRecurringList());
      //register表示の更新
      RegisterDBProvider.refreshFromCategory(ref);
      //selectRegisterRecurringの更新 ＊基本的にnullで更新（バックアップがある時のみバックアップを設定）
      ref
          .read(settingRecurringyStateNotifierProvider.notifier)
          .setSelectRegisterRecurring(null);

      indicatorOverlay.removeOverlay();
      //スナックバー表示
      if (context.mounted) {
        updateSnackBarCallBack(
          text: isError ? '定期収支の削除に失敗しました' : '定期収支を削除しました',
          context: context,
          isError: isError,
          ref: ref,
          isNotNeedBottomHeight: true,
        );
      }
    }
  }

  //update
  //繰り返し収支更新（繰り返し画面から）
  Future updateRegisterRecurring(
    RegisterRecurring newRegisterrecurring,
    BuildContext context,
  ) async {
    state = const AsyncValue.loading();
    final IndicatorOverlay indicatorOverlay = IndicatorOverlay();
    indicatorOverlay.insertOverlay(context);
    bool isError = false;

    //繰り返し日付計算
    List<DateTime> recurringDateList = calcRecurringDateList(
      startDate: newRegisterrecurring.startDate,
      endDate: newRegisterrecurring.endDate,
      recurringSetting: newRegisterrecurring.recurringSetting,
      rescheduleSetting: newRegisterrecurring.rescheduleSetting,
    );

    //register（繰り返し収支）リスト作成
    List<Register> insertRegisterList = [];
    for (DateTime recurringDate in recurringDateList) {
      final Register insertRegister = Register(
        amount: newRegisterrecurring.amount!,
        category: newRegisterrecurring.category,
        subCategory: newRegisterrecurring.subCategory,
        memo: newRegisterrecurring.memo,
        date: recurringDate,
        recurringId: newRegisterrecurring.id,
        registrationDate: DateTime.now(),
      );
      insertRegisterList.add(insertRegister);
    }
    try {
      //各register更新（削除→新規登録）→registerRecrring更新
      await RegisterRecurringDBHelper.updateRegisterRecurring(
          newRegisterrecurring, insertRegisterList);
    } catch (e, stackTrace) {
      isError = true;
      state = AsyncValue.error(e, stackTrace);
    } finally {
      //register recurring List更新
      state = AsyncData(await getAllRegisterRecurringList());
      //register表示の更新
      RegisterDBProvider.refreshFromCategory(ref);
      //selectRegisterRecurringの更新 ＊基本的にnullで更新（バックアップがある時のみバックアップを設定）
      ref
          .read(settingRecurringyStateNotifierProvider.notifier)
          .setSelectRegisterRecurring(null);
      indicatorOverlay.removeOverlay();
      //スナックバー表示
      if (context.mounted) {
        updateSnackBarCallBack(
          text: isError ? '定期収支の更新に失敗しました' : '定期収支を更新しました',
          context: context,
          isError: isError,
          ref: ref,
          isNotNeedBottomHeight: true,
        );
      }
    }
  }

  //繰り返し収支更新（繰り返し画面から）※期間のみの更新、範囲リストからの削除と追加のみ
  Future updateRegisterRecurringOfRangeList(
    RegisterRecurring newRegisterrecurring,
    List<(DateTime, DateTime?)> addDateRangeList,
    List<(DateTime, DateTime?)> delDateRangeList,
    BuildContext context,
  ) async {
    state = const AsyncValue.loading();
    final IndicatorOverlay indicatorOverlay = IndicatorOverlay();
    indicatorOverlay.insertOverlay(context);
    bool isError = false;

    //追加用
    List<DateTime> addRecurringDateList = [];
    for ((DateTime, DateTime?) addDateRange in addDateRangeList) {
      //繰り返し日付計算
      List<DateTime> recurringDateList = calcRecurringDateList(
        startDate: addDateRange.$1,
        endDate: addDateRange.$2,
        recurringSetting: newRegisterrecurring.recurringSetting,
        rescheduleSetting: newRegisterrecurring.rescheduleSetting,
      );
      addRecurringDateList.addAll(recurringDateList);
    }

    //register（繰り返し収支）リスト作成
    List<Register> insertRegisterList = [];
    for (DateTime recurringDate in addRecurringDateList) {
      final Register insertRegister = Register(
        amount: newRegisterrecurring.amount!,
        category: newRegisterrecurring.category,
        subCategory: newRegisterrecurring.subCategory,
        memo: newRegisterrecurring.memo,
        date: recurringDate,
        recurringId: newRegisterrecurring.id,
        registrationDate: DateTime.now(),
      );
      insertRegisterList.add(insertRegister);
    }

    try {
      //各register更新（削除+追加）→registerRecrring更新
      await RegisterRecurringDBHelper.insertAndDeleteRegisterRecurring(
          newRegisterrecurring, insertRegisterList, delDateRangeList);
    } catch (e, stackTrace) {
      isError = true;
      state = AsyncValue.error(e, stackTrace);
    } finally {
      //register recurring List更新
      state = AsyncData(await getAllRegisterRecurringList());
      //register表示の更新
      RegisterDBProvider.refreshFromCategory(ref);
      //selectRegisterRecurringの更新 ＊基本的にnullで更新（バックアップがある時のみバックアップを設定）
      ref
          .read(settingRecurringyStateNotifierProvider.notifier)
          .setSelectRegisterRecurring(null);
      indicatorOverlay.removeOverlay();
      //スナックバー表示
      if (context.mounted) {
        updateSnackBarCallBack(
          text: isError ? '定期収支の更新に失敗しました' : '定期収支を更新しました',
          context: context,
          isError: isError,
          ref: ref,
          isNotNeedBottomHeight: true,
        );
      }
    }
  }

  //繰り返し収支更新（Registerから）
  Future updateRegisterRecurringFromRegister(
    Register newRegister,
    BuildContext context,
  ) async {
    state = const AsyncValue.loading();
    final IndicatorOverlay indicatorOverlay = IndicatorOverlay();
    indicatorOverlay.insertOverlay(context);
    bool isError = false;

    try {
      //各register更新→registerRecrring更新
      await RegisterRecurringDBHelper.updateRegisterRecurringFromRegister(
          newRegister);
    } catch (e, stackTrace) {
      isError = true;
      state = AsyncValue.error(e, stackTrace);
    } finally {
      //register recurring List更新
      state = AsyncData(await getAllRegisterRecurringList());
      //register表示の更新
      RegisterDBProvider.refreshFromCategory(ref);
      //selectRegisterRecurringの更新 ＊基本的にnullで更新（バックアップがある時のみバックアップを設定）
      ref
          .read(settingRecurringyStateNotifierProvider.notifier)
          .setSelectRegisterRecurring(null);
      indicatorOverlay.removeOverlay();
      //スナックバー表示
      if (context.mounted) {
        updateSnackBarCallBack(
          text: isError ? '定期収支の更新に失敗しました' : '定期収支を更新しました',
          context: context,
          isError: isError,
          ref: ref,
          isNotNeedBottomHeight: true,
        );
      }
    }
  }

  //update
  //繰り返しを個別収支から編集（その日以降を全て更新）
  Future updateRegisterRecurringFromRegisterAfterBaseDate(
    Register newRegister,
    DateTime baseDate,
    BuildContext context,
  ) async {
    state = const AsyncValue.loading();
    final IndicatorOverlay indicatorOverlay = IndicatorOverlay();
    indicatorOverlay.insertOverlay(context);
    bool isError = false;

    try {
      //各register更新→registerRecrring更新
      await RegisterRecurringDBHelper
          .updateRegisterRecurringFromRegisterAfterBaseDate(
              newRegister, baseDate);
    } catch (e, stackTrace) {
      isError = true;
      state = AsyncValue.error(e, stackTrace);
    } finally {
      //register recurring List更新
      state = AsyncData(await getAllRegisterRecurringList());
      //register表示の更新
      RegisterDBProvider.refreshFromCategory(ref);
      //selectRegisterRecurringの更新 ＊基本的にnullで更新（バックアップがある時のみバックアップを設定）
      ref
          .read(settingRecurringyStateNotifierProvider.notifier)
          .setSelectRegisterRecurring(null);

      indicatorOverlay.removeOverlay();
      //スナックバー表示
      if (context.mounted) {
        updateSnackBarCallBack(
          text: isError ? '定期収支の更新に失敗しました' : '定期収支を更新しました',
          context: context,
          isError: isError,
          ref: ref,
          isNotNeedBottomHeight: true,
        );
      }
    }
  }

  //IdからList内のRegisterRecurringを取得
  RegisterRecurring? getRegisterRecurringFromId(int recurringId) {
    final List<RegisterRecurring> registerRecurringList = state.valueOrNull?[
            ref.watch(registerEditCategoryStateNotifierProvider
                .select((p) => p.selectExpense))] ??
        [];
    for (RegisterRecurring registerRecurring in registerRecurringList) {
      if (registerRecurring.id == recurringId) {
        return registerRecurring;
      }
    }
    return null;
  }

  //カテゴリー削除時のリフレッシュ
  Future<void> refreshFromCategory(Ref ref) async {
    //リフレッシュ
    state = AsyncData(await getAllRegisterRecurringList());
  }
}
