import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/router/router.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/view_model/category_db_provider.dart';

void main() async {
  //sqlite初期化用
  WidgetsFlutterBinding.ensureInitialized();

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
