import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/provider/chart_page_provider/rate_chart_provider.dart';
import 'package:household_expenses_project/provider/preferences_service.dart';
import 'package:household_expenses_project/router/router.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/view/chart_view/chart_rate_view/chart_rate_page.dart';
import 'package:household_expenses_project/view_model/db_helper.dart';

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
    const ProviderScope(child: HouseholdExpensesApp()),
  );
}

class HouseholdExpensesApp extends ConsumerWidget {
  const HouseholdExpensesApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextTheme textTheme =
        Theme.of(context).textTheme.apply(fontFamily: "Noto Sans JP");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp.router(
      title: "Household Expenses App",
      theme: theme.light(),
      darkTheme: theme.dark(),
      routerConfig: router,
    );
  }
}
