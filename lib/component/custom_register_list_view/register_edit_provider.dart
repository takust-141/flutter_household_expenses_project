//Provider
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/provider/register_edit_state.dart';

final customRegisterEditNotifier =
    AsyncNotifierProvider<CustomRegisterEditNotifier, CustomRegisterEditState>(
        CustomRegisterEditNotifier.new);

@immutable
class CustomRegisterEditState implements RegisterEditState {
  @override
  final bool isActiveDoneButton;

  const CustomRegisterEditState({
    required this.isActiveDoneButton,
  });

  CustomRegisterEditState copyWith({
    bool? isActiveDoneButton,
  }) {
    return CustomRegisterEditState(
      isActiveDoneButton: isActiveDoneButton ?? this.isActiveDoneButton,
    );
  }
}

//Notifier
class CustomRegisterEditNotifier
    extends RegisterEditStateNotifier<CustomRegisterEditState> {
  late final CustomRegisterEditState _defaultState;
  @override
  Future<CustomRegisterEditState> build() async {
    _defaultState = const CustomRegisterEditState(isActiveDoneButton: false);
    return _defaultState;
  }

  @override
  void formInputCheck(
      TextEditingController controller, ValueNotifier<Category?> notifier) {
    final bool isActive =
        controller.text.isNotEmpty && (notifier.value != null);
    state = AsyncData(
        state.valueOrNull?.copyWith(isActiveDoneButton: isActive) ??
            _defaultState);
  }

  //新規追加用（検索ページからは新規追加は不可のため、nullを返す）
  @override
  DateTime? currentSelectDate() {
    return null;
  }

  @override
  void initDoneButton() {
    state = AsyncData(state.valueOrNull?.copyWith(isActiveDoneButton: false) ??
        _defaultState);
  }
}
