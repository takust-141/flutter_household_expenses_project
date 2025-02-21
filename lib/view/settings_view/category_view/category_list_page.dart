import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/provider/app_bar_provider.dart';
import 'package:household_expense_project/provider/reorderable_provider.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/provider/category_list_provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:household_expense_project/constant/constant.dart';

//-------カテゴリリストページ---------------------------
class CategoryListPage extends HookConsumerWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final settingCategoryState =
        ref.watch(settingCategoryStateNotifierProvider);

    //hooks
    final ValueNotifier<List<Category>> categoryList = useState([
      ...ref
              .watch(categoryListNotifierProvider)
              .valueOrNull?[settingCategoryState.selectExpense] ??
          []
    ]);

    useEffect(() {
      categoryList.value = [
        ...ref
                .watch(categoryListNotifierProvider)
                .valueOrNull?[settingCategoryState.selectExpense] ??
            []
      ];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(reorderableProvider.notifier).initReorderState();
      });
      return () {};
    }, [
      ref
          .watch(categoryListNotifierProvider)
          .valueOrNull?[settingCategoryState.selectExpense]
    ]);

    final isReorder =
        ref.watch(reorderableProvider.select((p) => p.isCategoryReorder));

    return SafeArea(
      child: DecoratedBox(
        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer),
        child: ReorderableListView(
          padding: viewEdgeInsets,
          buildDefaultDragHandles: false,
          onReorder: (int oldIndex, int newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final Category item = categoryList.value.removeAt(oldIndex);
            categoryList.value.insert(newIndex, item);

            categoryList.value = [...categoryList.value]; //useStateリビルド用の再割り当て
            //update用セット
            ref
                .read(reorderableProvider.notifier)
                .setReorderCategoryList(categoryList.value);
          },
          //新規追加
          footer: isReorder
              ? SizedBox.shrink()
              : Container(
                  margin: EdgeInsets.only(top: medium),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(containreBorderRadius),
                  ),
                  child: const CategoryListItem(isNewAdd: true, category: null),
                ),
          children: [
            for (int i = 0; i < categoryList.value.length; i++) ...{
              (isReorder)
                  ? ReorderableDragStartListener(
                      key: Key("${categoryList.value[i].id}"),
                      index: i,
                      child: CategoryListItem(
                        key: Key("${categoryList.value[i].id}"),
                        category: categoryList.value[i],
                        isTop: i == 0,
                        isBottom: i == categoryList.value.length - 1,
                        isDivider: i != categoryList.value.length - 1,
                      ),
                    )
                  : CategoryListItem(
                      key: Key("${categoryList.value[i].id}"),
                      category: categoryList.value[i],
                      isTop: i == 0,
                      isBottom: i == categoryList.value.length - 1,
                      isDivider: i != categoryList.value.length - 1,
                    ),
            }
          ],
        ),
      ),
    );
  }
}

//カテゴリListItem
class CategoryListItem extends HookConsumerWidget {
  final Category? category;
  final bool isNewAdd;
  final bool isTop;
  final bool isBottom;
  final bool isDivider;
  const CategoryListItem({
    super.key,
    required this.category,
    this.isNewAdd = false,
    this.isTop = false,
    this.isBottom = false,
    this.isDivider = false,
  });
  final String _defaultName = "新規追加";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final listItemColor = useState<Color>(theme.colorScheme.surfaceBright);
    var goRoute = GoRouter.of(context);
    final Color defaultColor = theme.colorScheme.onSurfaceVariant;

    useEffect(() {
      listItemColor.value = theme.colorScheme.surfaceBright;
      return () {};
    }, [theme]);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (!ref.read(reorderableProvider.select((p) => p.isCategoryReorder))) {
          ref
              .read(settingCategoryStateNotifierProvider.notifier)
              .updateSelectParentCategory(category);
          ref
              .read(appBarProvider.notifier)
              .updateActiveCategoryDoneButton(category?.name);

          //settingCategoryStateNotifierProviderをセット
          goRoute.go('/setting/category_list/category_edit', extra: 0);
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
            Expanded(
              child: Text(
                category?.name ?? _defaultName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            (ref.watch(reorderableProvider.select((p) => p.isCategoryReorder)))
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
