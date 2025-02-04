import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:household_expense_project/constant/constant.dart';

void updateSnackBarCallBack({
  required String text,
  required BuildContext context,
  bool isError = false,
}) {
  final theme = Theme.of(context);
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
    margin: const EdgeInsets.fromLTRB(medium, 0, medium, small),
    behavior: SnackBarBehavior.floating,
    elevation: 3,
  );

  HapticFeedback.lightImpact();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
