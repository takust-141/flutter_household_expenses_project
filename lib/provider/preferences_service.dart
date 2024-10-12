import 'package:household_expenses_project/provider/setting_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  //シングルトンパターン（インスタンスが1つで静的）
  static final PreferencesService _instance = PreferencesService._();
  factory PreferencesService() => _instance;
  PreferencesService._();

  static const String startOfWeekKey = 'startOfWeek';
  static const String startCalendarDateKey = 'startCalendarDate';

  static late final SharedPreferences prefs;

  static Future<void> getInstance() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setStartOfWeek(int startOfWeek) async {
    await prefs.setInt(startOfWeekKey, startOfWeek);
  }

  static Future<int> getStartOfWeek() async {
    final startOfWeek = prefs.getInt(startOfWeekKey) ?? defaultStartWeek;
    return startOfWeek;
  }

  //初回のみ設定（カレンダーの表示日付：初回起動日から100年前の1月）
  static Future<DateTime> setStartCalendarDate() async {
    //100年前の1月1日
    final DateTime startMonth = defaultStartCalendarDate;
    await prefs.setInt(startCalendarDateKey, startMonth.millisecondsSinceEpoch);
    return startMonth;
  }

  static Future<DateTime?> getStartCalendarDate() async {
    int? prefsDate = prefs.getInt(startCalendarDateKey);

    final DateTime? startCalendarDate = (prefsDate == null)
        ? null
        : DateTime.fromMillisecondsSinceEpoch(prefsDate);
    return startCalendarDate;
  }
}
