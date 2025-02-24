import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/ad_helper.dart';
import 'package:household_expense_project/constant/constant.dart';

void updateSnackBarCallBack({
  required String text,
  required BuildContext context,
  bool isError = false,
  required ref,
  bool? isNotNeedBottomHeight,
}) {
  final theme = Theme.of(context);
  double bottomHeight = 0;
  if (isNotNeedBottomHeight != true) {
    if (ref is WidgetRef) {
      bottomHeight =
          ref.read(adNotifierProvider).adSize?.height.toDouble() ?? 0;
    } else if (ref is Ref) {
      bottomHeight =
          ref.read(adNotifierProvider).adSize?.height.toDouble() ?? 0;
    }
  }

  SnackBar snackBar = SnackBar(
    content: Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: isError ? theme.colorScheme.error : theme.colorScheme.surface,
      ),
    ),
    backgroundColor: isError
        ? theme.colorScheme.errorContainer.withValues(alpha: 0.9)
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
    duration: const Duration(seconds: 4),
    padding: msmallEdgeInsets,
    margin: EdgeInsets.fromLTRB(medium, 0, medium, small + bottomHeight),
    behavior: SnackBarBehavior.floating,
    elevation: 3,
  );

  HapticFeedback.mediumImpact();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

void versionUpdateSnackBar({
  required BuildContext context,
  required ref,
}) {
  final theme = Theme.of(context);
  double bottomHeight = 0;

  if (ref is WidgetRef) {
    bottomHeight = ref.read(adNotifierProvider).adSize?.height.toDouble() ?? 0;
  } else if (ref is Ref) {
    bottomHeight = ref.read(adNotifierProvider).adSize?.height.toDouble() ?? 0;
  }

  SnackBar snackBar = SnackBar(
    content: Text(
      "バージョン更新のお知らせ\nストアよりアプリをアップデートしてご利用ください。",
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.surface,
      ),
    ),
    backgroundColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
    duration: const Duration(seconds: 4),
    padding: msmallEdgeInsets,
    margin: EdgeInsets.fromLTRB(medium, 0, medium, small + bottomHeight),
    behavior: SnackBarBehavior.floating,
    elevation: 3,
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
