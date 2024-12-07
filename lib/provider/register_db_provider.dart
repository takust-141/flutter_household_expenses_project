import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/provider/calendar_page_provider.dart';
import 'package:household_expenses_project/provider/chart_page_provider/rate_chart_provider.dart';
import 'package:household_expenses_project/provider/chart_page_provider/transition_chart_provider.dart';
import 'package:household_expenses_project/provider/search_page_provider.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/view_model/register_db_helper.dart';
import 'package:household_expenses_project/model/register.dart';

//DBProvider
class RegisterDBProvider {
  RegisterDBProvider();

  static Future<void> insertRegister(Register register, WidgetRef ref) async {
    await RegisterDBHelper.insertRegister(register);
    refresh(ref);
  }

  static Future<void> updateRegister(Register register, WidgetRef ref) async {
    await RegisterDBHelper.updateRegister(register);
    refresh(ref);
  }

  static Future<void> deleteRegister(Register register, WidgetRef ref) async {
    await RegisterDBHelper.deleteRegisterFromId(register.id!);
    refresh(ref);
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

  static Future<List<Register>> getRegisterStateOfRangeAndSelectExpenses(
      DateTime startDate,
      DateTime endDate,
      SelectExpenses selectExpenses) async {
    return await RegisterDBHelper.getRegisterOfRangeAndSelectExpenses(
        startDate, endDate, selectExpenses);
  }

  static Future<List<Register>> getRegisterStateOfRange(
      DateTime startDate, DateTime endDate) async {
    return await RegisterDBHelper.getRegisterOfRange(startDate, endDate);
  }

  static Future<List<Register>> getRegisterStateOfCategory(
      Category category) async {
    return await RegisterDBHelper.getRegisterOfCategory(category);
  }

  static Future<List<Register>> getRegisterStateOfSelectExpenses(
      SelectExpenses selectExpenses) async {
    return await RegisterDBHelper.getRegisterOfSelectExpenses(selectExpenses);
  }

  static Future<List<Register>> getAllRegisterState() async {
    return await RegisterDBHelper.getAllRegister();
  }

  //リフレッシュ処理（DB更新時のコールバック）
  static void refresh(WidgetRef ref) {
    ref.read(calendarPageProvider.notifier).refreshRegisterList();
    ref.read(rateChartProvider.notifier).refreshRegisterList();
    ref.read(transitionChartProvider.notifier).refreshRegisterList();
    ref.read(searchPageProvider.notifier).reSearchRegister();
  }
}
