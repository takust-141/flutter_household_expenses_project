import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/ad_helper.dart';
import 'package:household_expense_project/view_model/preferences_service.dart';
import 'package:household_expense_project/provider/setting_theme_provider.dart';
import 'package:household_expense_project/router/router.dart';
import 'package:household_expense_project/view_model/db_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'interface/firebase_options.dart';

void main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  //画面の抜き縦固定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  //スプラッシュ
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  try {
    await MobileAds.instance.initialize();

    await Future.wait<void>([
      //DB
      DbHelper.openDataBase(),
      //Firebase
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      //admob広告
    ]);
    //PreferencesService
    PreferencesService.getInstance();
  } catch (e) {
    debugPrint(e.toString());
    rethrow;
  } finally {
    debugPrint("init main comp");
  }

  runApp(
    const ProviderScope(child: HouseholdExpenseApp()),
  );
}

class HouseholdExpenseApp extends ConsumerWidget {
  const HouseholdExpenseApp({super.key});

  Future<void> initApp() async {}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(adNotifierProvider.notifier).initAdState(context);
    return ref.watch(settingThemeProvider).maybeWhen(
          data: (themeState) => MaterialApp.router(
            title: "Household Expense App",
            theme: themeState.lightTheme,
            darkTheme: themeState.darkTheme,
            routerConfig: router,
          ),
          orElse: () => SizedBox.shrink(),
        );
  }
}
