import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/provider/setting_recurring_provider.dart';
import 'package:household_expense_project/view/settings_view/recurring_setting_view/recurring_setting_page.dart';

class RecurringSettingDetailPage extends ConsumerWidget {
  const RecurringSettingDetailPage(this.detailIndex, {super.key});
  final int detailIndex;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    //riverpod
    final settingRecurringNotifier =
        ref.read(settingRecurringyStateNotifierProvider.notifier);
    final settingRecurringState =
        ref.watch(settingRecurringyStateNotifierProvider); //リビルド用

    final List<String> selectorList =
        settingRecurringNotifier.getSelectorList(detailIndex);
    final List<String> intervalSelectorList =
        (settingRecurringState.selectRegisterRecurring != null ||
                detailIndex == 0)
            ? recurringInterval[settingRecurringState
                .selectRegisterRecurring!.recurringSetting.selectRecurring]
            : [];

    return SafeArea(
      child: Container(
        color: theme.colorScheme.surfaceContainer,
        child: ListView(
          padding: viewEdgeInsets,
          children: [
            //詳細設定
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(containreBorderRadius),
              ),
              child: Column(
                children: [
                  //週基準の時、祝日のみ
                  for (int i = ((detailIndex == 6 &&
                              settingRecurringState.selectRegisterRecurring
                                      ?.recurringSetting.criteria ==
                                  0)
                          ? 7
                          : 0);
                      i < selectorList.length;
                      i++) ...{
                    RecurringSettingSelector(
                      onTap: () => settingRecurringNotifier.setRecurringSetting(
                          detailIndex, i),
                      listTitle: selectorList[i],
                      checked: settingRecurringNotifier.getDetailChecked(
                          detailIndex, i),
                    ),
                    if (i < selectorList.length - 1)
                      Divider(
                        height: 0,
                        thickness: 0.2,
                        color: theme.colorScheme.outline,
                      ),
                  },
                ],
              ),
            ),
            //繰り返し設定の時、間隔の設定
            if (detailIndex == 0) ...{
              const SizedBox(height: medium),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(containreBorderRadius),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < intervalSelectorList.length; i++) ...{
                      RecurringSettingSelector(
                        onTap: () =>
                            settingRecurringNotifier.setRecurringSetting(8, i),
                        listTitle: intervalSelectorList[i],
                        checked:
                            settingRecurringNotifier.getDetailChecked(8, i),
                      ),
                      if (i < intervalSelectorList.length - 1)
                        Divider(
                          height: 0,
                          thickness: 0.2,
                          color: theme.colorScheme.outline,
                        ),
                    },
                  ],
                ),
              ),
            },

            //振替設定で祝日ありの時、コメント設定
            if (detailIndex == 6)
              const Padding(
                padding:
                    EdgeInsets.symmetric(vertical: smedium, horizontal: ssmall),
                child: Text("祝日は2050年まで設定されています\n2056年以降はアップデートにて順次更新されます"),
              ),
          ],
        ),
      ),
    );
  }
}
