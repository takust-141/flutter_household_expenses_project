import 'package:flutter/material.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/provider/select_expenses_provider.dart';

//-----SegmentedButton-----
class SelectExpensesButton extends StatefulWidget {
  const SelectExpensesButton({super.key});

  @override
  State<SelectExpensesButton> createState() => _SelectExpensesButtonState();
}

class _SelectExpensesButtonState extends State<SelectExpensesButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.colorScheme.inverseSurface.withOpacity(0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
              child: Container(
                  child: const Padding(
            padding: segmentedButtonPadding,
            child: Text("収入"),
          ))),
          GestureDetector(
              child: Container(
                  child: const Padding(
            padding: segmentedButtonPadding,
            child: Text("支出"),
          ))),
        ],
      ),
    );
  }
}
