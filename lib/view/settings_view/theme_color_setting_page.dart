import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/constant/constant.dart';
import 'package:household_expense_project/constant/keyboard_components.dart';
import 'package:household_expense_project/provider/setting_theme_provider.dart';

//-------テーマカラー設定ページ---------------------------
class ThemeColorSettingPage extends ConsumerWidget {
  const ThemeColorSettingPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final List<Color> seedColorList = keyboardColors;

    final selectSeedColor =
        ref.watch(settingThemeProvider.select((p) => p.seedColor));

    final themeNotifier = ref.read(settingThemeProvider.notifier);

    return SafeArea(
      child: Container(
        color: theme.colorScheme.surfaceContainer,
        padding: mediumEdgeInsets,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                textAlign: TextAlign.end,
                "明るさ設定",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Row(
              spacing: small,
              children: [
                Expanded(child: BlightnessButton(0)),
                Expanded(child: BlightnessButton(1)),
                Expanded(child: BlightnessButton(2)),
              ],
            ),
            SizedBox(height: medium),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                textAlign: TextAlign.end,
                "コントラスト",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Row(
              spacing: small,
              children: [
                Expanded(child: ContrastButton(0)),
                Expanded(child: ContrastButton(1)),
                Expanded(child: ContrastButton(2)),
              ],
            ),
            SizedBox(height: medium),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                textAlign: TextAlign.end,
                "ベースカラー",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            for (int i = 0; i < seedColorList.length; i += 5) ...{
              Row(
                spacing: small,
                children: [
                  Expanded(child: ColorSelector(color: seedColorList[i])),
                  Expanded(child: ColorSelector(color: seedColorList[i + 1])),
                  Expanded(child: ColorSelector(color: seedColorList[i + 2])),
                  Expanded(child: ColorSelector(color: seedColorList[i + 3])),
                  Expanded(child: ColorSelector(color: seedColorList[i + 4])),
                ],
              ),
              SizedBox(height: small),
            },
            SizedBox(height: medium),
            Flexible(
              child: Column(
                children: [
                  Flexible(
                    child: TextButton(
                      onPressed: () => themeNotifier.rebuildTheme(),
                      style: TextButton.styleFrom(
                        fixedSize:
                            const Size(double.maxFinite, registerButtonHeight),
                        padding: smallEdgeInsets,
                        overlayColor: theme.colorScheme.onPrimary,
                        disabledBackgroundColor: Color.lerp(
                            theme.colorScheme.primary,
                            theme.colorScheme.surface,
                            0.7),
                        disabledForegroundColor: Color.lerp(
                            theme.colorScheme.onPrimary,
                            theme.colorScheme.surface,
                            0.7),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: registerButtomRadius,
                        ),
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                            fontSize:
                                (theme.textTheme.titleMedium?.fontSize ?? 0) +
                                    2),
                      ),
                      child: const AutoSizeText(
                        "更　　新",
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorSelector extends ConsumerWidget {
  const ColorSelector({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectSeedColor =
        ref.watch(settingThemeProvider.select((p) => p.seedColor));
    return LayoutBuilder(builder: (context, boxConstraints) {
      return SizedBox(
        height: boxConstraints.maxWidth * 0.8,
        child: ElevatedButton(
          onPressed: () {
            ref.read(settingThemeProvider.notifier).setColor(color);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color, // ボタンの背景色
            side: BorderSide(
              color: (selectSeedColor == color)
                  ? theme.colorScheme.tertiary
                  : color,
              width: 3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(small),
            ),
          ),
          child: SizedBox.shrink(),
        ),
      );
    });
  }
}

//明るさ設定ボタン
class BlightnessButton extends ConsumerWidget {
  const BlightnessButton(this.blightnessIndex, {super.key});

  final int blightnessIndex;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final String text = ["デフォルト", "ライト", "ダーク"][blightnessIndex];

    final settingBrightness =
        ref.watch(settingThemeProvider.select((p) => p.brightness));
    final isSelect = (settingBrightness == blightnessIndex);

    return OutlinedButton(
      onPressed: () => ref
          .read(settingThemeProvider.notifier)
          .setBlightness(blightnessIndex),
      style: OutlinedButton.styleFrom(
        backgroundColor:
            isSelect ? theme.colorScheme.primaryContainer : Colors.transparent,
        foregroundColor: isSelect
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        side: BorderSide(
          color: theme.colorScheme.primary,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: registerButtomRadius,
        ),
      ),
      child: AutoSizeText(
        text,
        maxLines: 1,
      ),
    );
  }
}

//コントラストボタン
class ContrastButton extends ConsumerWidget {
  const ContrastButton(this.contrastIndex, {super.key});

  final int contrastIndex;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final String text = ["低", "中", "高"][contrastIndex];

    final contrastLevel =
        ref.watch(settingThemeProvider.select((p) => p.contrastLevel));
    final isSelect = (contrastLevel == contrastIndex * 0.5);

    return OutlinedButton(
      onPressed: () =>
          ref.read(settingThemeProvider.notifier).setContrast(contrastIndex),
      style: OutlinedButton.styleFrom(
        backgroundColor:
            isSelect ? theme.colorScheme.primaryContainer : Colors.transparent,
        foregroundColor: isSelect
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        side: BorderSide(
          color: theme.colorScheme.primary,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: registerButtomRadius,
        ),
      ),
      child: AutoSizeText(
        text,
        maxLines: 1,
      ),
    );
  }
}
