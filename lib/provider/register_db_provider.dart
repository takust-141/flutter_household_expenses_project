import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/provider/calendar_page_provider.dart';
import 'package:household_expenses_project/view_model/register_db_helper.dart';
import 'package:household_expenses_project/model/register.dart';

//DBProvider
class RegisterDBProvider {
  RegisterDBProvider();

  static Future<List<Register>> getRegisterStateOfMonth(DateTime month) async {
    return await RegisterDBHelper.getRegisterOfMonth(month);
  }

  static Future<void> insertRegister(Register register, WidgetRef ref) async {
    await RegisterDBHelper.insertRegister(register);
    ref.read(calendarPageProvider.notifier).refreshRegisterList();
  }

  static Future<void> updateRegister(Register register, WidgetRef ref) async {
    await RegisterDBHelper.updateRegister(register);
    ref.read(calendarPageProvider.notifier).refreshRegisterList();
  }

  static Future<void> deleteRegister(Register register, WidgetRef ref) async {
    await RegisterDBHelper.deleteRegisterFromId(register.id!);
    await RegisterDBHelper.updateRegister(register);
    ref.read(calendarPageProvider.notifier).refreshRegisterList();
  }
}
