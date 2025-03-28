import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:material_symbols_icons/symbols.dart';

class SettingListItem extends HookWidget {
  final String setText;
  final Function onTapList;
  const SettingListItem(
      {required this.setText, required this.onTapList, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final listItemColor = useState<Color>(colorScheme.surfaceBright);
    useEffect(() {
      listItemColor.value = colorScheme.surfaceBright;
      return () {};
    }, [colorScheme]);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTapList(),
      onTapDown: (_) =>
          {listItemColor.value = colorScheme.surfaceContainerHighest},
      onTapUp: (_) => {listItemColor.value = colorScheme.surfaceBright},
      onTapCancel: () => {listItemColor.value = colorScheme.surfaceBright},
      child: AnimatedContainer(
        color: listItemColor.value,
        duration: listItemAnimationDuration,
        height: listHeight,
        padding: smallEdgeInsets,
        child: Row(
          children: [
            Padding(
              padding: ssmallLeftEdgeInsets,
              child: Text(setText),
            ),
            const Spacer(),
            Icon(Symbols.chevron_right,
                weight: 300, size: 25, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

//汎用ダイアログ
void openDialog({
  required BuildContext context,
  required String title,
  required String text,
  required String buttonText,
  required Future Function()? onTap,
  Widget? aditionalWidget,
}) async {
  final theme = Theme.of(context);
  final navigator = Navigator.of(context);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogRadius),
        ),
        child: Container(
          padding: largeEdgeInsets,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(dialogRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AutoSizeText(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: large),
              AutoSizeText(text, textAlign: TextAlign.left),
              if (aditionalWidget != null) ...{
                const SizedBox(height: large),
                aditionalWidget,
              },
              const SizedBox(height: large),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: smallEdgeInsets,
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(
                            color: theme.colorScheme.primary, width: 1.3),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(containreBorderRadius),
                        ),
                      ),
                      child: const AutoSizeText(
                        "キャンセル",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        if (onTap != null) {
                          await onTap();
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          navigator.pop();
                        }
                      },
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(containreBorderRadius),
                        ),
                      ),
                      child: AutoSizeText(
                        buttonText,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

//汎用ダイアログ（複数ボタン）
Future<void> openDialogContainWidget({
  required BuildContext context,
  required String title,
  required List<String> buttonTextList,
  required List<Future<void> Function()?> onTapList,
}) async {
  final theme = Theme.of(context);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogRadius),
        ),
        child: Container(
          padding: largeEdgeInsets,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(dialogRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AutoSizeText(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: large),
              for (int i = 0; i < onTapList.length; i++)
                Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.only(bottom: small),
                  child: FilledButton(
                    onPressed: (onTapList[i] != null)
                        ? () async {
                            await onTapList[i]!();
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(containreBorderRadius),
                      ),
                    ),
                    child: AutoSizeText(
                      (i < buttonTextList.length) ? buttonTextList[i] : "",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      minFontSize: 10,
                    ),
                  ),
                ),
              const SizedBox(height: small),
              SizedBox(
                width: double.maxFinite,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: smallEdgeInsets,
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(
                        color: theme.colorScheme.primary, width: 1.3),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(containreBorderRadius),
                    ),
                  ),
                  child: const AutoSizeText(
                    "キャンセル",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

//更新インジケーターオーバーレイ
class IndicatorOverlay {
  OverlayEntry? indicatorOverlayEntry;

  void insertOverlay(BuildContext context) {
    indicatorOverlayEntry = OverlayEntry(builder: (context) {
      return Container(
        color: Colors.black.withValues(alpha: 0.1),
        child: const Center(
          child: Padding(
            padding: largeEdgeInsets,
            child: SizedBox(
              height: 35,
              width: 35,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
        ),
      );
    });
    // メニューを表示
    Overlay.of(context, rootOverlay: true).insert(indicatorOverlayEntry!);
  }

  // オーバーレイ削除
  void removeOverlay() {
    indicatorOverlayEntry?.remove(); // オーバーレイを削除
    indicatorOverlayEntry = null;
  }
}
