import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/model/category.dart';

abstract class RegisterEditStateNotifier<T> extends AsyncNotifier<T> {
  DateTime? currentSelectDate();
  void initDoneButton();
  void formInputCheck(
      TextEditingController controller, ValueNotifier<Category?> notifier);
}

@immutable
abstract class RegisterEditState {
  bool get isActiveDoneButton;
}
