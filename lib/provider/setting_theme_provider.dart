import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/constant/theme.dart';

//Provider
final settingThemeProvider =
    NotifierProvider<SettingThemeNotifier, SettingThemeState>(
        SettingThemeNotifier.new);

//状態管理
@immutable
class SettingThemeState {
  final Color seedColor;
  final double contrastLevel;
  final int brightness; //0：プラットフォームに従う、1：light、2：dark
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  const SettingThemeState({
    required this.seedColor,
    required this.contrastLevel,
    required this.brightness,
    required this.lightTheme,
    required this.darkTheme,
  });

  SettingThemeState copyWith({
    Color? seedColor,
    int? brightness,
    double? contrastLevel,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
  }) {
    return SettingThemeState(
      seedColor: seedColor ?? this.seedColor,
      brightness: brightness ?? this.brightness,
      contrastLevel: contrastLevel ?? this.contrastLevel,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }
}

//Notifier
class SettingThemeNotifier extends Notifier<SettingThemeState> {
  @override
  SettingThemeState build() {
    MaterialTheme theme =
        MaterialTheme(TextTheme().apply(fontFamily: "Noto Sans JP"));

    return SettingThemeState(
      seedColor: Colors.green,
      brightness: 0,
      contrastLevel: 0.5,
      lightTheme: theme.light().copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thickness: WidgetStateProperty.all(4), // スクロールバーの太さ
              thumbColor: WidgetStateProperty.all(
                  theme.light().colorScheme.outlineVariant), // スクロールバーの色
              radius: const Radius.circular(8.0),
            ),
          ),
      darkTheme: theme.dark().copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thickness: WidgetStateProperty.all(4), // スクロールバーの太さ
              thumbColor: WidgetStateProperty.all(
                  theme.dark().colorScheme.outlineVariant), // スクロールバーの色
              radius: const Radius.circular(8.0),
            ),
          ),
    );
  }

  void setColor(Color seedColor) {
    state = state.copyWith(
      seedColor: seedColor,
    );
  }

  void setContrast(int contrastIndex) {
    state = state.copyWith(
      contrastLevel: contrastIndex * 0.5,
    );
  }

  void setBlightness(int brightness) {
    state = state.copyWith(
      brightness: brightness,
    );
  }

  void rebuildTheme() {
    ThemeData lightTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
      seedColor: state.seedColor,
      brightness: (state.brightness != 2) ? Brightness.light : Brightness.dark,
      contrastLevel: state.contrastLevel,
    ));
    ThemeData darkTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
      seedColor: state.seedColor,
      brightness: (state.brightness != 1) ? Brightness.dark : Brightness.light,
      contrastLevel: state.contrastLevel,
    ));

    state = state.copyWith(
      lightTheme: lightTheme,
      darkTheme: darkTheme,
    );
  }
}
