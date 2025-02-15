import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/view_model/preferences_service.dart';
import 'package:household_expense_project/provider/setting_theme_provider.dart';
import 'package:household_expense_project/router/router.dart';
import 'package:household_expense_project/view_model/db_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'interface/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    //DB
    await DbHelper.openDataBase();
    //PreferencesService
    PreferencesService.getInstance();
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
    return ref.watch(
      settingThemeProvider.select(
        (state) => state.maybeWhen(
          data: (themeState) => MaterialApp.router(
            title: "Household Expense App",
            theme: themeState.lightTheme,
            darkTheme: themeState.darkTheme,
            routerConfig: router,
          ),
          orElse: () => SizedBox.shrink(),
        ),
      ),
    );
  }
}
