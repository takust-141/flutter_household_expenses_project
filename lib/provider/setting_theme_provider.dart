import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/theme_mono.dart';
import 'package:household_expense_project/constant/theme.dart';
import 'package:household_expense_project/view_model/preferences_service.dart';

//Provider
final settingThemeProvider =
    AsyncNotifierProvider<SettingThemeNotifier, SettingThemeState>(
        SettingThemeNotifier.new);

//状態管理
@immutable
class SettingThemeState {
  final int brightness; //0：プラットフォームに従う、1：light、2：dark
  final double contrastLevel;
  final Color seedColor;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  const SettingThemeState({
    required this.brightness,
    required this.contrastLevel,
    required this.seedColor,
    required this.lightTheme,
    required this.darkTheme,
  });

  SettingThemeState copyWith({
    int? brightness,
    double? contrastLevel,
    Color? seedColor,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
  }) {
    return SettingThemeState(
      brightness: brightness ?? this.brightness,
      contrastLevel: contrastLevel ?? this.contrastLevel,
      seedColor: seedColor ?? this.seedColor,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }
}

//Notifier
class SettingThemeNotifier extends AsyncNotifier<SettingThemeState> {
  final TextTheme _notoTextTheme =
      TextTheme().apply(fontFamily: "Noto Sans JP");
  late final SettingThemeState _defaultState;
  final _defaultBrightness = 0;
  final _defaultContrastLevel = 0.0;
  final _defaultSeedColor = themeColorList[0];

  @override
  Future<SettingThemeState> build() async {
    final (ThemeData defaultLightTheme, ThemeData defaultDarkTheme) =
        getThemeData(
            _defaultBrightness, _defaultContrastLevel, _defaultSeedColor);
    _defaultState = SettingThemeState(
      brightness: _defaultBrightness,
      contrastLevel: _defaultContrastLevel,
      seedColor: _defaultSeedColor,
      lightTheme: defaultLightTheme,
      darkTheme: defaultDarkTheme,
    );

    final (int initBrightness, double initContrastLevel, Color initSeedColor) =
        await PreferencesService.getTheme();
    final (ThemeData lightTheme, ThemeData darkTheme) =
        getThemeData(initBrightness, initContrastLevel, initSeedColor);

    return SettingThemeState(
      brightness: initBrightness,
      contrastLevel: initContrastLevel,
      seedColor: initSeedColor,
      lightTheme: lightTheme,
      darkTheme: darkTheme,
    );
  }

  void setColor(Color seedColor) {
    final prestate = state.valueOrNull ?? _defaultState;
    state = AsyncData(prestate.copyWith(seedColor: seedColor));
  }

  void setContrast(int contrastIndex) {
    final prestate = state.valueOrNull ?? _defaultState;
    state = AsyncData(prestate.copyWith(contrastLevel: contrastIndex * 0.5));
  }

  void setBlightness(int brightness) {
    final prestate = state.valueOrNull ?? _defaultState;
    state = AsyncData(prestate.copyWith(brightness: brightness));
  }

  void rebuildTheme() {
    ThemeData lightTheme;
    ThemeData darkTheme;
    final prestate = state.valueOrNull ?? _defaultState;
    //モノクロ設定
    if (prestate.seedColor == Colors.grey.shade800) {
      if (prestate.contrastLevel == 0.0) {
        lightTheme = MonoMaterialTheme(_notoTextTheme).light();
        darkTheme = MonoMaterialTheme(_notoTextTheme).dark();
      } else if (prestate.contrastLevel == 0.5) {
        lightTheme = MonoMaterialTheme(_notoTextTheme).lightMediumContrast();
        darkTheme = MonoMaterialTheme(_notoTextTheme).darkMediumContrast();
      } else {
        lightTheme = MonoMaterialTheme(_notoTextTheme).lightHighContrast();
        darkTheme = MonoMaterialTheme(_notoTextTheme).darkHighContrast();
      }
      if (prestate.brightness == 1) {
        darkTheme = lightTheme;
      } else if (prestate.brightness == 2) {
        lightTheme = darkTheme;
      }
    } else {
      (lightTheme, darkTheme) = getThemeData(
          prestate.brightness, prestate.contrastLevel, prestate.seedColor);
    }
    PreferencesService.setTheme(
        prestate.brightness, prestate.contrastLevel, prestate.seedColor);

    state = AsyncData(prestate.copyWith(
      lightTheme: lightTheme,
      darkTheme: darkTheme,
    ));
  }

  //ThemeData作成関数
  (ThemeData, ThemeData) getThemeData(
      int brightness, double contrastLevel, Color seedColor) {
    final lightTheme = ThemeData(
        textTheme: _notoTextTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: (brightness != 2) ? Brightness.light : Brightness.dark,
          contrastLevel: contrastLevel,
        ));
    final darkTheme = ThemeData(
        textTheme: _notoTextTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: (brightness != 1) ? Brightness.dark : Brightness.light,
          contrastLevel: contrastLevel,
        ));
    return (lightTheme, darkTheme);
  }
}
