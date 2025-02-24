import 'package:flutter/material.dart';
import 'package:household_expense_project/constant/theme.dart';
import 'package:household_expense_project/provider/setting_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  //シングルトンパターン（インスタンスが1つで静的）
  static final PreferencesService _instance = PreferencesService._();
  factory PreferencesService() => _instance;
  PreferencesService._();

  static const String startCalendarDateKey = 'startCalendarDate';
  static const String startOfWeekKey = 'startOfWeek';
  static const String themeSeedColorKey = 'themeSeedColor';
  static const String themeBrightnessKey = 'themeBrightness';
  static const String themeContrastLevelKey = 'themeContrastLevel';
  static const String versionFlagKey = 'versionFlag';

  static late final SharedPreferencesAsync asyncPrefs;

  static void getInstance() {
    asyncPrefs = SharedPreferencesAsync();
  }

  //初回のみ設定（カレンダーの表示日付：初回起動日から100年前の1月）
  static Future<DateTime> setStartCalendarDate() async {
    //100年前の1月1日
    final DateTime startMonth = defaultStartCalendarDate;
    await asyncPrefs.setInt(
        startCalendarDateKey, startMonth.millisecondsSinceEpoch);
    return startMonth;
  }

  //カレンダー基準日取得
  static Future<DateTime?> getStartCalendarDate() async {
    final int? prefsDate = await asyncPrefs.getInt(startCalendarDateKey);
    final DateTime? startCalendarDate = (prefsDate == null)
        ? null
        : DateTime.fromMillisecondsSinceEpoch(prefsDate);
    return startCalendarDate;
  }

  //
  //startOfWeek
  static Future<void> setStartOfWeek(int startOfWeek) async {
    await asyncPrefs.setInt(startOfWeekKey, startOfWeek);
  }

  static Future<int> getStartOfWeek() async {
    final startOfWeek =
        await asyncPrefs.getInt(startOfWeekKey) ?? defaultStartWeek;
    return startOfWeek;
  }

  //
  //Theme設定
  static Future<void> setTheme(
      int brightness, double contrustLevel, Color seedColor) async {
    await asyncPrefs.setInt(themeBrightnessKey, brightness);
    await asyncPrefs.setDouble(themeContrastLevelKey, contrustLevel);
    await asyncPrefs.setString(
        themeSeedColorKey, seedColor.toARGB32().toString());
  }

  static Future<(int, double, Color)> getTheme() async {
    final int brightness =
        await asyncPrefs.getInt(themeBrightnessKey) ?? 0; //初期値デフォルト
    final double contrustLevel =
        await asyncPrefs.getDouble(themeContrastLevelKey) ?? 0.0; //初期値0.0
    final String? seedColorString =
        await asyncPrefs.getString(themeSeedColorKey);
    final Color seedColor =
        themeColorMap[seedColorString] ?? themeColorMap['default']!; //初期値

    return (brightness, contrustLevel, seedColor);
  }

  //
  //バージョン通知 （0：メッセージ不要、1：メッセージ必要）
  static Future<void> setVersionFlag(int versionFlag) async {
    await asyncPrefs.setInt(versionFlagKey, versionFlag);
  }

  static Future<int> getVersionFlag() async {
    final int versionFlag = await asyncPrefs.getInt(versionFlagKey) ?? 0;

    return versionFlag;
  }
}
