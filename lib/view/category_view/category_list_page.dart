import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:household_expenses_project/constant/constant.dart';

//-------カテゴリリストページ---------------------------
class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

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
                const CategoryListItem(
                    categoryName: "カテゴリ編1",
                    color: Colors.red,
                    iconData: Icons.home,
                    path: 'item3'),
                Divider(
                  height: 0,
                  thickness: 0.2,
                  color: theme.colorScheme.outline,
                ),
                const CategoryListItem(
                    categoryName: "カテゴリ編2",
                    color: Colors.red,
                    iconData: Icons.home,
                    path: 'item2'),
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
            child: CategoryListItem(
              categoryName: "新規追加",
              leading: Icon(
                Symbols.variable_add,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              path: '/setting/category_list/category_edit',
            ),
          ),
        ],
      ),
    );
  }
}

//カテゴリListItem
class CategoryListItem extends HookWidget {
  final String categoryName;
  final Color? color;
  final IconData? iconData;
  final Widget? leading;
  final String path;
  const CategoryListItem({
    super.key,
    required this.categoryName,
    this.color,
    this.iconData,
    this.leading,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    var goRoute = GoRouter.of(context);
    final theme = Theme.of(context);
    final listItemColor = useState<Color>(theme.colorScheme.surfaceBright);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => goRoute.go(path),
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
            leading ??
                (iconData != null
                    ? Container(
                        padding: sssmallEdgeInsets,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color ?? theme.colorScheme.onSurfaceVariant,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          iconData,
                          color: color,
                          size: 16,
                        ),
                      )
                    : const SizedBox()),
            const SizedBox(width: small),
            Text(categoryName),
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
