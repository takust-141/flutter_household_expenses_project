import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:household_expenses_project/provider/my_app_state.dart';
import 'package:household_expenses_project/router/router.dart';
import 'package:household_expenses_project/constant/constant.dart';

void main() {
  //sqlite初期化用
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const HouseholdExpensesApp());
}

class HouseholdExpensesApp extends StatelessWidget {
  const HouseholdExpensesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp.router(
        title: "Household Expenses App",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          brightness: Brightness.light,
          fontFamily: "Noto Sans JP",
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          brightness: Brightness.dark,
          fontFamily: "Noto Sans JP",
        ),
        routerConfig: router,
      ),
    );
  }
}
