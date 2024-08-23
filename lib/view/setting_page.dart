import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:household_expenses_project/component/setting_component.dart';
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
                  setText: "カレンダー設定",
                  onTapRoute: () => goRoute.push('/setting/calendar_setting'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
