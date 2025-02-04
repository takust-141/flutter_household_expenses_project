import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/provider/select_expense_state.dart';

//-----SegmentedButton-----
class SelectExpenseButton extends ConsumerWidget {
  const SelectExpenseButton(this.notifierProvider, {super.key});
  final NotifierProvider<SelectExpenseStateNotifier, SelectExpenseState>
      notifierProvider;

  final double segmentedButtonHeight = 30;
  final double segmentedButtonWidth = 100;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final selectExpenseRef =
        ref.watch(notifierProvider.select((p) => p.selectExpense));
    final selectExpenseProvider = ref.read(notifierProvider.notifier);
    const Duration animationDuration = Duration(milliseconds: 180);
    const Cubic animationCurve = Curves.easeOut;

    return Container(
      decoration: BoxDecoration(
        borderRadius: segmentedButtomRadius,
        color: theme.colorScheme.inverseSurface.withValues(alpha: 0.1),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            left: (selectExpenseRef == SelectExpense.outgo)
                ? 0
                : segmentedButtonWidth,
            curve: animationCurve,
            duration: animationDuration,
            child: Container(
              height: segmentedButtonHeight,
              width: segmentedButtonWidth,
              decoration: BoxDecoration(
                borderRadius: segmentedButtomRadius,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => {
                  (selectExpenseRef == SelectExpense.outgo)
                      ? null
                      : selectExpenseProvider.changeOutgo()
                },
                child: Container(
                  alignment: Alignment.center,
                  height: segmentedButtonHeight,
                  width: segmentedButtonWidth,
                  child: AnimatedDefaultTextStyle(
                    style: theme.textTheme.titleMedium?.copyWith(
                            color: (selectExpenseRef == SelectExpense.outgo)
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.outline) ??
                        const TextStyle(),
                    duration: animationDuration,
                    curve: animationCurve,
                    child: const Text("支出"),
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => {
                  (selectExpenseRef == SelectExpense.income)
                      ? null
                      : selectExpenseProvider.changeIncome()
                },
                child: Container(
                  alignment: Alignment.center,
                  height: segmentedButtonHeight,
                  width: segmentedButtonWidth,
                  child: AnimatedDefaultTextStyle(
                    style: theme.textTheme.titleMedium?.copyWith(
                            color: (selectExpenseRef == SelectExpense.income)
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.outline) ??
                        const TextStyle(),
                    duration: animationDuration,
                    curve: animationCurve,
                    child: const Text("収入"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
