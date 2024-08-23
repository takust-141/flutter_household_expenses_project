import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String startOfWeekKey = 'startOfWeek';

  static Future<void> setStartOfWeek(int startOfWeek) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(startOfWeekKey, startOfWeek);
  }

  static Future<int> getStartOfWeek() async {
    final prefs = await SharedPreferences.getInstance();
    final startOfWeek = prefs.getInt(startOfWeekKey) ?? DateTime.sunday;
    return startOfWeek;
  }
}
