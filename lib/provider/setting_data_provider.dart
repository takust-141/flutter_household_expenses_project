import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/provider/preferences_service.dart';

//Provider
final settingDataProvider =
    NotifierProvider<SettingDataNotifier, SettingDataState>(
        SettingDataNotifier.new);

const defaultWeeks = ["月", "火", "水", "木", "金", "土", "日"];

//状態管理
@immutable
class SettingDataState {
  final int calendarStartWeek;
  final List<String> weeks;
  const SettingDataState({
    required this.calendarStartWeek,
    required this.weeks,
  });
}

//Notifier
class SettingDataNotifier extends Notifier<SettingDataState> {
  @override
  SettingDataState build() {
    _loadStartOfWeek();

    return const SettingDataState(
      calendarStartWeek: 1,
      weeks: defaultWeeks,
    );
  }

  // 非同期で設定データを取得して state を更新
  Future<void> _loadStartOfWeek() async {
    final startOfWeek = await PreferencesService.getStartOfWeek();
    state = SettingDataState(
      calendarStartWeek: startOfWeek,
      weeks: calcCalendar(startOfWeek),
    );
  }

  //値の更新
  Future<void> updateStartOfWeek(int startWeek) async {
    state = SettingDataState(
      calendarStartWeek: startWeek,
      weeks: calcCalendar(startWeek),
    );
    await PreferencesService.setStartOfWeek(startWeek);
  }

  List<String> calcCalendar(int value) {
    List<String> weeksSub = defaultWeeks.sublist(value - 1, 7);
    weeksSub.addAll(defaultWeeks.sublist(0, value - 1));
    return weeksSub;
  }
}
