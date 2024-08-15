import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/provider/app_bar_provider.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/view_model/category_db_provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:household_expenses_project/constant/constant.dart';

//-------カテゴリリストページ---------------------------
class CategoryListPage extends ConsumerWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final categoryListProvider = ref.watch(categoryListNotifierProvider);
    final int numOfCategory = categoryListProvider.value?.length ?? 0;

    return Container(
      color: theme.colorScheme.surfaceContainer,
      padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
      child: ListView(
        padding: viewEdgeInsets,
        children: [
          //カテゴリリスト
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(containreBorderRadius),
            ),
            child: Column(
              children: [
                for (int i = 0; i < numOfCategory; i++) ...{
                  CategoryListItem(
                    category: categoryListProvider.value![i],
                  ),
                  if (i != numOfCategory - 1)
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
            child: const CategoryListItem(isNewAdd: true, category: null),
          ),
        ],
      ),
    );
  }
}

//カテゴリListItem
class CategoryListItem extends HookConsumerWidget {
  final Category? category;
  final bool isNewAdd;
  const CategoryListItem({
    super.key,
    required this.category,
    this.isNewAdd = false,
  });
  final String _defaultName = "新規追加";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final listItemColor = useState<Color>(theme.colorScheme.surfaceBright);
    var goRoute = GoRouter.of(context);
    final Color defaultColor = theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        ref
            .read(selectCategoryNotifierProvider.notifier)
            .updateCategory(category);
        ref.read(doneButtonProvider.notifier).setState(category?.name);
        goRoute.go('/setting/category_list/category_edit');
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
                        color: category?.color ?? defaultColor,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      category?.icon,
                      color: category?.color ?? defaultColor,
                      size: 16,
                      weight: 600,
                    ),
                  ),
            const SizedBox(width: small),
            Text(category?.name ?? _defaultName),
            const Spacer(),
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
