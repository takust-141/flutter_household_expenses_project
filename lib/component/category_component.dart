//フォームビルダー
import 'package:flutter/material.dart';
import 'package:household_expense_project/constant/dimension.dart';

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
