import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/custom_register_list_view/custom_register_list.dart';
import 'package:household_expense_project/component/custom_register_list_view/register_edit_provider.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/model/register.dart';
import 'package:household_expense_project/provider/setting_recurring_provider.dart';
import 'package:household_expense_project/view_model/register_db_helper.dart';

class RecurringSettingRegisterListPage extends ConsumerWidget {
  const RecurringSettingRegisterListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<List<Register>> getDisplayRegisterList() async {
      List<Register> registerList = [];
      int? recurringId = ref.watch(settingRecurringyStateNotifierProvider
          .select((p) => p.selectRegisterRecurring?.id));
      //リビルド用
      ref.watch(settingRecurringyStateNotifierProvider
          .select((p) => p.selectInitNotifier));
      if (recurringId != null) {
        registerList =
            await RegisterDBHelper.getRegisterOfRecurringId(recurringId);
      }
      return registerList;
    }

    return SafeArea(
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer),
        child: FutureBuilder(
          future: getDisplayRegisterList(),
          builder: (context, AsyncSnapshot<List<Register>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data?.isNotEmpty != true) {
                const SizedBox.shrink();
              }
              return CustomRegisterList(
                registerList: snapshot.data!,
                isDisplayYear: true,
                registerEditProvider: customRegisterEditNotifier,
              );
            } else if (snapshot.hasError) {
              return const SizedBox.shrink();
            } else {
              return Container(
                color: Colors.black.withValues(alpha: 0.1),
                child: const Center(
                  child: Padding(
                    padding: largeEdgeInsets,
                    child: SizedBox(
                      height: 35,
                      width: 35,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
