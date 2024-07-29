import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:household_expenses_project/provider/app_bar_provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:household_expenses_project/constant/constant.dart';

//-------設定ページ---------------------------
class SettingPage extends StatelessWidget {
  SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var goRoute = GoRouter.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainer,
      child: ListView(
        padding: viewEdgeInsets,
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(containreBorderRadius),
            ),
            child: Column(
              children: [
                SettingListItem(
                  setText: "カテゴリー編集",
                  onTapRoute: () => goRoute.push('/setting/category_list'),
                ),
                Divider(
                  height: 0,
                  thickness: 0.2,
                  color: theme.colorScheme.outline,
                ),
                SettingListItem(
                  setText: "設定",
                  onTapRoute: () => goRoute.pushNamed('category_edit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingListItem extends HookWidget {
  final String setText;
  final Function onTapRoute;
  const SettingListItem(
      {required this.setText, required this.onTapRoute, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listItemColor = useState<Color>(theme.colorScheme.surfaceBright);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTapRoute(),
      onTapDown: (_) =>
          {listItemColor.value = theme.colorScheme.surfaceContainerHighest},
      onTapUp: (_) => {listItemColor.value = theme.colorScheme.surfaceBright},
      onTapCancel: () =>
          {listItemColor.value = theme.colorScheme.surfaceBright},
      child: AnimatedContainer(
        color: listItemColor.value,
        duration: listItemAnimationDuration,
        height: listHeight,
        padding: smallEdgeInsets,
        child: Row(
          children: [
            Padding(
              padding: ssmallLeftEdgeInsets,
              child: Text(setText),
            ),
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
