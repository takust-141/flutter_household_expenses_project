import 'package:flutter/material.dart';
import 'package:household_expenses_project/constant/constant.dart';

//-----SegmentedButton-----

enum SelectExpenses { outgo, income }

class SelectExpensesButton extends StatefulWidget {
  const SelectExpensesButton({super.key});

  @override
  State<SelectExpensesButton> createState() => _SelectExpensesButtonState();
}

class _SelectExpensesButtonState extends State<SelectExpensesButton> {
  SelectExpenses selectedExpenses = SelectExpenses.outgo;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SelectExpenses>(
      segments: const <ButtonSegment<SelectExpenses>>[
        ButtonSegment<SelectExpenses>(
          value: SelectExpenses.outgo,
          label: Text(labelOutgo),
          //icon: Icon(Icons.calendar_view_day)
        ),
        ButtonSegment<SelectExpenses>(
          value: SelectExpenses.income,
          label: Text(labelIncome),
          //icon: Icon(Icons.calendar_view_week)
        ),
      ],
      selected: <SelectExpenses>{selectedExpenses},
      onSelectionChanged: (Set<SelectExpenses> newSelection) {
        setState(() {
          selectedExpenses = newSelection.first;
        });
      },
      showSelectedIcon: false,
      style: segmentedButtonStyle,
    );
  }
}
