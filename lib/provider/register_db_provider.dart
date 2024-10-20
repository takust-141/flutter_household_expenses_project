import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/provider/calendar_page_provider.dart';
import 'package:household_expenses_project/provider/search_page_provider.dart';
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
    await RegisterDBHelper.updateRegister(register);
    refresh(ref);
  }

  static Future<List<Register>> getRegisterStateOfMonth(DateTime month) async {
    return await RegisterDBHelper.getRegisterOfMonth(month);
  }

  static Future<List<Register>> getRegisterStateOfText(String text) async {
    return await RegisterDBHelper.getRegisterStateOfText(text);
  }

  //リフレッシュ処理
  static void refresh(WidgetRef ref) {
    ref.read(calendarPageProvider.notifier).refreshRegisterList();
    ref.read(searchPageProvider.notifier).reSearchRegister();
  }
}
