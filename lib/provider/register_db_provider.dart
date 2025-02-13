import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/register_snackbar.dart';
import 'package:household_expense_project/component/setting_component.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/provider/calendar_page_provider.dart';
import 'package:household_expense_project/provider/chart_page_provider/rate_chart_provider.dart';
import 'package:household_expense_project/provider/chart_page_provider/transition_chart_provider.dart';
import 'package:household_expense_project/provider/search_page_provider.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/view_model/register_db_helper.dart';
import 'package:household_expense_project/model/register.dart';

//DBProvider
class RegisterDBProvider {
  RegisterDBProvider();

  static Future<void> insertRegister(
      Register register, WidgetRef ref, BuildContext context) async {
    bool isError = false;
    final IndicatorOverlay indicatorOverlay = IndicatorOverlay();
    indicatorOverlay.insertOverlay(context);
    try {
      await RegisterDBHelper.insertRegister(register);
    } catch (e) {
      isError = true;
      rethrow;
    } finally {
      //register関連更新
      await refresh(ref);
      indicatorOverlay.removeOverlay();
      //スナックバー表示
      if (context.mounted) {
        updateSnackBarCallBack(
          text: isError ? '明細の登録に失敗しました' : '明細を登録しました',
          context: context,
          isError: isError,
          ref: ref,
        );
      }
    }
  }

  //更新
  static Future<void> updateRegister(
      Register register, WidgetRef ref, BuildContext context) async {
    bool isError = false;
    final IndicatorOverlay indicatorOverlay = IndicatorOverlay();
    indicatorOverlay.insertOverlay(context);
    try {
      await RegisterDBHelper.updateRegister(register);
    } catch (e) {
      isError = true;
      rethrow;
    } finally {
      //register関連更新
      await refresh(ref);
      indicatorOverlay.removeOverlay();
      //スナックバー表示
      if (context.mounted) {
        updateSnackBarCallBack(
          text: isError ? '明細の更新に失敗しました' : '明細を更新しました',
          context: context,
          isError: isError,
          ref: ref,
        );
      }
    }
  }

  //レジスター削除（1件）
  static Future<void> deleteRegisterFromId(
      Register register, WidgetRef ref, BuildContext context) async {
    bool isError = false;
    final IndicatorOverlay indicatorOverlay = IndicatorOverlay();
    indicatorOverlay.insertOverlay(context);
    try {
      await RegisterDBHelper.deleteRegisterFromId(register.id!);
    } catch (e) {
      isError = true;
      rethrow;
    } finally {
      //register関連更新
      await refresh(ref);
      indicatorOverlay.removeOverlay();
      //スナックバー表示
      if (context.mounted) {
        updateSnackBarCallBack(
          text: isError ? '明細の削除に失敗しました' : '明細を削除しました',
          context: context,
          isError: isError,
          ref: ref,
        );
      }
    }
  }

  static Future<List<Register>> getRegisterStateOfMonth(DateTime month) async {
    DateTime startOfMonth = DateTime(month.year, month.month, 1, 0, 0, 0, 0);
    DateTime endOfMonth =
        DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);
    return await RegisterDBHelper.getRegisterOfRange(startOfMonth, endOfMonth);
  }

  static Future<List<Register>> getRegisterStateOfText(String text) async {
    return await RegisterDBHelper.getRegisterOfText(text);
  }

  //rate graph用
  static Future<List<Register>> getRegisterStateOfRangeAndCategoryList(
      DateTime startDate, DateTime endDate, List<Category> categoryList) async {
    return await RegisterDBHelper.getRegisterOfRangeAndCategoryList(
        startDate, endDate, categoryList);
  }

  static Future<List<Register>> getRegisterStateOfRangeAndSelectExpense(
      DateTime startDate, DateTime endDate, SelectExpense selectExpense) async {
    return await RegisterDBHelper.getRegisterOfRangeAndSelectExpense(
        startDate, endDate, selectExpense);
  }

  static Future<List<Register>> getRegisterStateOfRange(
      DateTime startDate, DateTime endDate) async {
    return await RegisterDBHelper.getRegisterOfRange(startDate, endDate);
  }

  static Future<List<Register>> getRegisterStateOfRangeAndCategory(
      DateTime startDate, DateTime endDate, Category category) async {
    return await RegisterDBHelper.getRegisterOfRangeAndCategory(
        startDate, endDate, category);
  }

  static Future<List<Register>> getRegisterStateOfRangeAndSubCategory(
      DateTime startDate, DateTime endDate, Category category) async {
    return await RegisterDBHelper.getRegisterOfRangeAndSubCategory(
        startDate, endDate, category);
  }

  static Future<List<Register>> getRegisterStateOfSelectExpense(
      SelectExpense selectExpense) async {
    return await RegisterDBHelper.getRegisterOfSelectExpense(selectExpense);
  }

  static Future<List<Register>> getAllRegisterState() async {
    return await RegisterDBHelper.getAllRegister();
  }

  //register更新時のリフレッシュ処理（DB更新時のコールバック）
  static Future<void> refresh(WidgetRef ref) async {
    await Future.wait([
      ref.read(calendarPageProvider.notifier).refreshRegisterList(),
      ref.read(rateChartProvider.notifier).refreshRegisterList(),
      ref.read(transitionChartProvider.notifier).refreshRegisterList(),
      ref.read(searchPageProvider.notifier).reSearchRegister()
    ]);
  }

  //カテゴリー削除時のリフレッシュ //recurring register更新時のリフレッシュ
  static Future<void> refreshFromCategory(Ref ref) async {
    //セレクタの初期化（ChartPage）＋リフレッシュ
    await Future.wait([
      ref.read(calendarPageProvider.notifier).refreshRegisterList(),
      ref.read(rateChartProvider.notifier).refreshRegisterList(),
      ref
          .read(transitionChartProvider.notifier)
          .initSelectTransitionChartState(),
      ref.read(searchPageProvider.notifier).reSearchRegister(),
    ]);
  }
}
