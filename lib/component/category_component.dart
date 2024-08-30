//フォームビルダー
import 'package:flutter/material.dart';
import 'package:household_expenses_project/constant/dimension.dart';

//フォームビルダー
Widget Function(BuildContext, T, bool?) categoryFormBulder<T>({
  required String title,
  required Widget Function(T) inputWidgetBuilder,
  Key? key,
  VoidCallback? onTap,
}) {
  return (context, val, hasFocus) {
    final theme = Theme.of(context);
    return SizedBox(
      key: key,
      height: formItemHeight,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              alignment: Alignment.centerLeft,
              height: formItemHeight,
              padding: mediumRightEdgeInsets,
              child: SizedBox(
                width: formItemNameWidth,
                child: Text(title, textAlign: TextAlign.center),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: formInputBoarderRadius,
                border: hasFocus ?? false
                    ? Border.all(
                        color: theme.colorScheme.primary,
                        width: formInputBoarderWidth)
                    : Border.all(
                        color: Colors.transparent,
                        width: formInputBoarderWidth),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: formInputBoarderRadius,
                  color: theme.colorScheme.surfaceBright,
                ),
                height: formItemHeight,
                child: inputWidgetBuilder(val),
              ),
            ),
          ),
        ],
      ),
    );
  };
}

//ダイアログ
void openDialog({
  required BuildContext context,
  required String title,
  required String text,
  required Future<void> Function() onTap,
  required bool isSubCategory,
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
              Text(
                (isSubCategory ? "サブカテゴリー" : "カテゴリー") + title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: large),
              Text(text, textAlign: TextAlign.center),
              const SizedBox(height: large),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(
                          color: theme.colorScheme.primary, width: 1.3),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(containreBorderRadius),
                      ),
                    ),
                    child: const SizedBox(
                        width: 75,
                        child: Text("キャンセル", textAlign: TextAlign.center)),
                  ),
                  FilledButton(
                    onPressed: () async {
                      await onTap();
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      navigator.pop();
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(containreBorderRadius),
                      ),
                    ),
                    child: SizedBox(
                        width: 75,
                        child: Text(title, textAlign: TextAlign.center)),
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
