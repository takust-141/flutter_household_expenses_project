import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/model/register_recurring.dart';
import 'package:household_expense_project/provider/register_recurring_list_provider.dart';
import 'package:household_expense_project/provider/reorderable_provider.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/provider/setting_recurring_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

class RecurringSettingListPage extends HookConsumerWidget {
  const RecurringSettingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    //hooks
    final ValueNotifier<List<RegisterRecurring>> registerRecurringList =
        useState([
      ...ref.watch(registerRecurringListNotifierProvider).valueOrNull?[
              ref.watch(registerEditCategoryStateNotifierProvider
                  .select((p) => p.selectExpense))] ??
          []
    ]);

    useEffect(() {
      registerRecurringList.value = [
        ...ref.watch(registerRecurringListNotifierProvider).valueOrNull?[
                ref.watch(registerEditCategoryStateNotifierProvider
                    .select((p) => p.selectExpense))] ??
            []
      ];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(reorderableProvider.notifier).initReorderState();
      });
      return () {};
    }, [
      ref.watch(registerRecurringListNotifierProvider).valueOrNull?[ref.watch(
          registerEditCategoryStateNotifierProvider
              .select((p) => p.selectExpense))]
    ]);

    final isReorder =
        ref.watch(reorderableProvider.select((p) => p.isRecurringReorder));

    return SafeArea(
      child: Container(
        color: theme.colorScheme.surfaceContainer,
        child: ReorderableListView(
          padding: viewEdgeInsets,
          buildDefaultDragHandles: false,
          onReorder: (int oldIndex, int newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final RegisterRecurring item =
                registerRecurringList.value.removeAt(oldIndex);
            registerRecurringList.value.insert(newIndex, item);

            registerRecurringList.value = [
              ...registerRecurringList.value
            ]; //useStateリビルド用の再割り当て
            //update用セット
            ref
                .read(reorderableProvider.notifier)
                .setReorderRecurringList(registerRecurringList.value);
          },
          //新規追加
          footer: isReorder
              ? SizedBox.shrink()
              : Container(
                  margin: EdgeInsets.only(
                      top: (registerRecurringList.value.isNotEmpty)
                          ? medium
                          : 0),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(containreBorderRadius),
                  ),
                  child: RegisterRecurringListItem(
                      registerRecurring: RegisterRecurring.initialState()),
                ),
          children: [
            //繰り返しリスト
            for (int i = 0; i < registerRecurringList.value.length; i++) ...{
              (isReorder)
                  ? ReorderableDragStartListener(
                      key: Key("${registerRecurringList.value[i].id}"),
                      index: i,
                      child: RegisterRecurringListItem(
                        key: Key("${registerRecurringList.value[i].id}"),
                        registerRecurring: registerRecurringList.value[i],
                        isTop: i == 0,
                        isBottom: i == registerRecurringList.value.length - 1,
                        isDivider: i != registerRecurringList.value.length - 1,
                      ),
                    )
                  : RegisterRecurringListItem(
                      key: Key("${registerRecurringList.value[i].id}"),
                      registerRecurring: registerRecurringList.value[i],
                      isTop: i == 0,
                      isBottom: i == registerRecurringList.value.length - 1,
                      isDivider: i != registerRecurringList.value.length - 1,
                    ),
            },
          ],
        ),
      ),
    );
  }
}

//繰り返しRegisterListItem
class RegisterRecurringListItem extends HookConsumerWidget {
  final RegisterRecurring registerRecurring;
  final bool isTop;
  final bool isBottom;
  final bool isDivider;
  const RegisterRecurringListItem({
    super.key,
    required this.registerRecurring,
    this.isTop = false,
    this.isBottom = false,
    this.isDivider = false,
  });
  static const String _defaultName = "新規追加";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNewAdd = (registerRecurring.id == null);
    final theme = Theme.of(context);
    final listItemColor = useState<Color>(theme.colorScheme.surfaceBright);
    useEffect(() {
      listItemColor.value = theme.colorScheme.surfaceBright;
      return () {};
    }, [theme]);
    var goRoute = GoRouter.of(context);
    final Color defaultColor = theme.colorScheme.onSurfaceVariant;
    final provider = settingRecurringyStateNotifierProvider;
    final notifier = ref.read(provider.notifier);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (!ref
            .read(reorderableProvider.select((p) => p.isRecurringReorder))) {
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
        }
      },
      onTapDown: (_) =>
          {listItemColor.value = theme.colorScheme.surfaceContainerHighest},
      onTapUp: (_) => {listItemColor.value = theme.colorScheme.surfaceBright},
      onTapCancel: () =>
          {listItemColor.value = theme.colorScheme.surfaceBright},
      child: AnimatedContainer(
        height: listHeight,
        duration: listItemAnimationDuration,
        padding: smallEdgeInsets,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: listItemColor.value,
          border: isDivider
              ? Border(
                  bottom: BorderSide(
                    width: 0.2,
                    color: theme.colorScheme.outline,
                  ),
                )
              : Border(),
          borderRadius: BorderRadius.vertical(
            top: isTop ? Radius.circular(containreBorderRadius) : Radius.zero,
            bottom:
                isBottom ? Radius.circular(containreBorderRadius) : Radius.zero,
          ),
        ),
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
            (ref.watch(reorderableProvider.select((p) => p.isRecurringReorder)))
                ? Icon(Symbols.reorder,
                    weight: 300,
                    size: 25,
                    color: theme.colorScheme.onSurfaceVariant)
                : Icon(Symbols.chevron_right,
                    weight: 300,
                    size: 25,
                    color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
