import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/provider/preferences_service.dart';

//Provider
final settingDataProvider =
    AsyncNotifierProvider<SettingDataNotifier, SettingDataState>(
        SettingDataNotifier.new);

const defaultWeeks = ["月", "火", "水", "木", "金", "土", "日"];
const defaultStartWeek = DateTime.sunday;
final defaultStartCalendarDate = DateTime(DateTime.now().year - 100, 1, 1);

//状態管理
@immutable
class SettingDataState {
  final int calendarStartWeek;
  final List<String> weeks;
  final DateTime startCalendarDate;
  const SettingDataState({
    required this.calendarStartWeek,
    required this.weeks,
    required this.startCalendarDate,
  });

  SettingDataState copyWith({
    int? calendarStartWeek,
    List<String>? weeks,
    DateTime? startCalendarDate,
  }) {
    return SettingDataState(
      calendarStartWeek: calendarStartWeek ?? this.calendarStartWeek,
      weeks: weeks ?? this.weeks,
      startCalendarDate: startCalendarDate ?? this.startCalendarDate,
    );
  }
}

//Notifier
class SettingDataNotifier extends AsyncNotifier<SettingDataState> {
  @override
  Future<SettingDataState> build() async {
    final int startOfWeek = await PreferencesService.getStartOfWeek();
    DateTime? startCalendarDate =
        await PreferencesService.getStartCalendarDate();
    startCalendarDate ??= await PreferencesService.setStartCalendarDate();

    return SettingDataState(
      calendarStartWeek: startOfWeek,
      weeks: calcCalendar(startOfWeek),
      startCalendarDate: startCalendarDate,
    );
  }

  //週始まりの更新
  Future<void> updateStartOfWeek(int startWeek) async {
    state = AsyncValue.data(state.value!.copyWith(
      calendarStartWeek: startWeek,
      weeks: calcCalendar(startWeek),
    ));
    await PreferencesService.setStartOfWeek(startWeek);
  }

  //曜日配列計算
  List<String> calcCalendar(int value) {
    List<String> weeksSub = defaultWeeks.sublist(value - 1, 7);
    weeksSub.addAll(defaultWeeks.sublist(0, value - 1));
    return weeksSub;
  }
}
