import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

//Provider
final settingDataProvider =
    NotifierProvider<SettingDataNotifier, SettingDataState>(
        SettingDataNotifier.new);

//状態管理
@immutable
class SettingDataState {
  final bool calendarStartWeek;
  const SettingDataState({
    required this.calendarStartWeek,
  });
}

//Notifier
class SettingDataNotifier extends Notifier<SettingDataState> {
  @override
  SettingDataState build() {
    return SettingDataState(calendarStartWeek: true);
  }
}
