import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/provider/preferences_service.dart';
import 'package:household_expense_project/router/router.dart';
import 'package:household_expense_project/constant/constant.dart';
import 'package:household_expense_project/view_model/db_helper.dart';

void main() async {
  //sqlite初期化用
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await DbHelper.openDataBase();
    await PreferencesService.getInstance();
  } catch (e) {
    rethrow;
  }

  runApp(
    const ProviderScope(child: HouseholdExpenseApp()),
  );
}

class HouseholdExpenseApp extends StatelessWidget {
  const HouseholdExpenseApp({super.key});
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme =
        Theme.of(context).textTheme.apply(fontFamily: "Noto Sans JP");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp.router(
      title: "Household Expense App",
      theme: theme.light().copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thickness: WidgetStateProperty.all(4), // スクロールバーの太さ
              thumbColor: WidgetStateProperty.all(
                  theme.light().colorScheme.outlineVariant), // スクロールバーの色
              radius: const Radius.circular(8.0),
            ),
          ),
      darkTheme: theme.dark().copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thickness: WidgetStateProperty.all(4), // スクロールバーの太さ
              thumbColor: WidgetStateProperty.all(
                  theme.dark().colorScheme.outlineVariant), // スクロールバーの色
              radius: const Radius.circular(8.0),
            ),
          ),
      routerConfig: router,
    );
  }
}
