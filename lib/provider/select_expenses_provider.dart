import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/view_model/category_db_provider.dart';

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
    ref
        .read(categoryListNotifierProvider.notifier)
        .reacquisitionCategoryList(state);
  }

  void changeOutgo() {
    state = SelectExpenses.outgo;
    ref
        .read(categoryListNotifierProvider.notifier)
        .reacquisitionCategoryList(state);
  }
}
