import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/provider/preferences_service.dart';
import 'package:household_expense_project/provider/setting_theme_provider.dart';
import 'package:household_expense_project/router/router.dart';
import 'package:household_expense_project/constant/constant.dart';
import 'package:household_expense_project/view_model/db_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'interface/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    //DB
    await DbHelper.openDataBase();
    //PreferencesService
    await PreferencesService.getInstance();
    //Firebase
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    rethrow;
  }

  runApp(
    const ProviderScope(child: HouseholdExpenseApp()),
  );
}

class HouseholdExpenseApp extends ConsumerWidget {
  const HouseholdExpenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: "Household Expense App",
      theme: ref.watch(settingThemeProvider.select((p) => p.lightTheme)),
      darkTheme: ref.watch(settingThemeProvider.select((p) => p.darkTheme)),
      routerConfig: router,
    );
  }
}
