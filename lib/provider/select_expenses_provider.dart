import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum SelectExpenses { outgo, income }

final selectExpenses = NotifierProvider<SelectExpensesNotifier, SelectExpenses>(
    SelectExpensesNotifier.new);

class SelectExpensesNotifier extends Notifier<SelectExpenses> {
  @override
  SelectExpenses build() {
    return SelectExpenses.income;
  }

  void changeIncome() {
    state = SelectExpenses.income;
  }

  void changeOutgo() {
    state = SelectExpenses.outgo;
  }
}
