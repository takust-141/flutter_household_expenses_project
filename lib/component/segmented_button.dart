import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:household_expenses_project/provider/select_expenses_provider.dart';

//-----SegmentedButton-----
class SelectExpensesButton extends ConsumerStatefulWidget {
  const SelectExpensesButton(this.notifierProvider, {super.key});
  final NotifierProvider<SelectExpensesNotifier, SelectExpenses>
      notifierProvider;

  @override
  ConsumerState<SelectExpensesButton> createState() =>
      _SelectExpensesButtonState();
}

class _SelectExpensesButtonState extends ConsumerState<SelectExpensesButton> {
  final double segmentedButtonHeight = 30;
  final double segmentedButtonWidth = 100;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final selectExpensesRef = ref.watch(widget.notifierProvider);
    final selectExpensesProvider = ref.read(widget.notifierProvider.notifier);
    const Duration animationDuration = Duration(milliseconds: 180);
    const Cubic animationCurve = Curves.easeOut;

    return Container(
      decoration: BoxDecoration(
        borderRadius: segmentedButtomRadius,
        color: theme.colorScheme.inverseSurface.withOpacity(0.1),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            left: (selectExpensesRef == SelectExpenses.income)
                ? 0
                : segmentedButtonWidth,
            curve: animationCurve,
            duration: animationDuration,
            child: Container(
              height: segmentedButtonHeight,
              width: segmentedButtonWidth,
              decoration: BoxDecoration(
                borderRadius: segmentedButtomRadius,
                color: theme.colorScheme
                    .primary, // Color.lerp(theme.colorScheme.primary, theme.colorScheme.surfaceContainerLowest, 0.5),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => {
                  (selectExpensesRef == SelectExpenses.income)
                      ? null
                      : selectExpensesProvider.changeIncome()
                },
                child: Container(
                  alignment: Alignment.center,
                  height: segmentedButtonHeight,
                  width: segmentedButtonWidth,
                  child: AnimatedDefaultTextStyle(
                    style: theme.textTheme.titleMedium?.copyWith(
                            color: (selectExpensesRef == SelectExpenses.income)
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.outline) ??
                        const TextStyle(),
                    duration: animationDuration,
                    curve: animationCurve,
                    child: const Text("収入"),
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => {
                  (selectExpensesRef == SelectExpenses.outgo)
                      ? null
                      : selectExpensesProvider.changeOutgo()
                },
                child: Container(
                  alignment: Alignment.center,
                  height: segmentedButtonHeight,
                  width: segmentedButtonWidth,
                  child: AnimatedDefaultTextStyle(
                    style: theme.textTheme.titleMedium?.copyWith(
                            color: (selectExpensesRef == SelectExpenses.outgo)
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.outline) ??
                        const TextStyle(),
                    duration: animationDuration,
                    curve: animationCurve,
                    child: const Text("支出"),
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
