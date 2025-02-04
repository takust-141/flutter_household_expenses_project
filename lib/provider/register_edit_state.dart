import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/model/category.dart';

/*
「RegisterEdit」
calendar_list_viewのRegisterListItem用（registerListでmodalによる編集）
RegisterEditStateをimplementしたproviderと対象のregisterを設定する

<例>
return RegisterListItem(
    register: registerList[index],
    pagaProvider: searchPageProvider,
);

currentSelectDateは新規追加用なので、不要な場合はnullを返せば良い

selectCategoryStateProviderは内部でregisterEditCategoryStateNotifierProviderが利用されるが、
複数のmodalが競合しないため問題ない
*/

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
