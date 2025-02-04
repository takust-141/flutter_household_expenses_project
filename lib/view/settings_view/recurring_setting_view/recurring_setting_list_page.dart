import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/constant/config.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/model/register_recurring.dart';
import 'package:household_expense_project/provider/register_recurring_list_provider.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/provider/setting_recurring_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

class RecurringSettingListPage extends ConsumerWidget {
  const RecurringSettingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    //riverpod
    final List<RegisterRecurring> registerRecurringList =
        ref.watch(registerRecurringListNotifierProvider).valueOrNull?[ref.watch(
                registerEditCategoryStateNotifierProvider
                    .select((p) => p.selectExpense))] ??
            [];
    final int registerRecurringListLength = registerRecurringList.length;

    return SafeArea(
      child: Container(
        color: theme.colorScheme.surfaceContainer,
        child: ListView(
          padding: viewEdgeInsets,
          children: [
            //繰り返しリスト
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(containreBorderRadius),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < registerRecurringListLength; i++) ...{
                    RegisterRecurringListItem(
                      registerRecurring: registerRecurringList[i],
                    ),
                    if (i != registerRecurringListLength - 1)
                      Divider(
                        height: 0,
                        thickness: 0.2,
                        color: theme.colorScheme.outline,
                      ),
                  }
                ],
              ),
            ),
            //新規追加
            const SizedBox(height: small),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(containreBorderRadius),
              ),
              child: RegisterRecurringListItem(
                  registerRecurring: RegisterRecurring.initialState()),
            ),
          ],
        ),
      ),
    );
  }
}

//繰り返しRegisterListItem
class RegisterRecurringListItem extends HookConsumerWidget {
  final RegisterRecurring registerRecurring;
  const RegisterRecurringListItem({
    super.key,
    required this.registerRecurring,
  });
  static const String _defaultName = "新規追加";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNewAdd = (registerRecurring.id == null);
    final theme = Theme.of(context);
    final listItemColor = useState<Color>(theme.colorScheme.surfaceBright);
    var goRoute = GoRouter.of(context);
    final Color defaultColor = theme.colorScheme.onSurfaceVariant;
    final provider = settingRecurringyStateNotifierProvider;
    final notifier = ref.read(provider.notifier);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        //select RegisterRecurring設定（nullの時、新規）
        //キーボード用設定
        if (isNewAdd) {
          ref
              .read(registerEditCategoryStateNotifierProvider.notifier)
              .setInit(isCurrentExpense: true);
          //削除ボタン無効化
          notifier.updateAppbarDeleteButton(false);
        } else {
          ref
              .read(registerEditCategoryStateNotifierProvider.notifier)
              .updateSelectBothCategory(
                  registerRecurring.category, registerRecurring.subCategory);
          //削除ボタン有効化
          notifier.updateAppbarDeleteButton(true);
        }
        notifier.setSelectRegisterRecurring(registerRecurring); //新規の時はdefault
        goRoute.go('/setting/recurring_list/recurring_edit');
      },
      onTapDown: (_) =>
          {listItemColor.value = theme.colorScheme.surfaceContainerHighest},
      onTapUp: (_) => {listItemColor.value = theme.colorScheme.surfaceBright},
      onTapCancel: () =>
          {listItemColor.value = theme.colorScheme.surfaceBright},
      child: AnimatedContainer(
        color: listItemColor.value,
        height: listHeight,
        duration: listItemAnimationDuration,
        padding: smallEdgeInsets,
        child: Row(
          children: [
            isNewAdd
                ? Icon(
                    Symbols.variable_add,
                    color: defaultColor,
                  )
                : Container(
                    padding: sssmallEdgeInsets,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            registerRecurring.category?.color ?? defaultColor,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      registerRecurring.category?.icon,
                      color: registerRecurring.category?.color ?? defaultColor,
                      size: 16,
                      weight: 600,
                    ),
                  ),
            const SizedBox(width: small),
            Expanded(
              child: Text(
                (!isNewAdd)
                    ? ("${registerRecurring.memo ?? ""}（${registerRecurring.subCategory?.name ?? registerRecurring.category?.name ?? ""}）")
                    : _defaultName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Symbols.chevron_right,
                weight: 300,
                size: 25,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
