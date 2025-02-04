import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum SelectExpense {
  outgo("支出"),
  income("収入");

  final String text;
  const SelectExpense(this.text);
}

abstract class SelectExpenseStateNotifier<SelectExpenseState>
    extends Notifier<SelectExpenseState> {
  void changeOutgo();
  void changeIncome();
}

@immutable
abstract class SelectExpenseState {
  SelectExpense get selectExpense;
}
