import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/ad_helper.dart';
import 'package:household_expense_project/component/setting_component.dart';
import 'package:household_expense_project/constant/constant.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';

//-------設定ページ---------------------------
class SettingPage extends HookConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final goRoute = GoRouter.of(context);

    return SafeArea(
      child: Container(
        color: theme.colorScheme.surfaceContainer,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: viewEdgeInsets,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(containreBorderRadius),
                      ),
                      child: Column(
                        children: [
                          SettingListItem(
                            setText: "広告を非表示",
                            onTapList: () => goRoute.push('/setting/remove_ad'),
                          ),
                          Divider(
                            height: 0.2,
                            thickness: 0.2,
                            color: theme.colorScheme.outline,
                          ),
                          SettingListItem(
                            setText: "カテゴリー編集",
                            onTapList: () {
                              ref
                                  .read(settingCategoryStateNotifierProvider
                                      .notifier)
                                  .changeOutgo();
                              goRoute.push('/setting/category_list');
                            },
                          ),
                          Divider(
                            height: 0.2,
                            thickness: 0.2,
                            color: theme.colorScheme.outline,
                          ),
                          SettingListItem(
                            setText: "カレンダー開始日設定",
                            onTapList: () =>
                                goRoute.push('/setting/calendar_setting'),
                          ),
                          Divider(
                            height: 0.2,
                            thickness: 0.2,
                            color: theme.colorScheme.outline,
                          ),
                          SettingListItem(
                            setText: "定期収支設定",
                            onTapList: () =>
                                goRoute.push('/setting/recurring_list'),
                          ),
                          Divider(
                            height: 0.2,
                            thickness: 0.2,
                            color: theme.colorScheme.outline,
                          ),
                          SettingListItem(
                            setText: "問い合わせ",
                            onTapList: () => goRoute.push('/setting/contact'),
                          ),
                          Divider(
                            height: 0.2,
                            thickness: 0.2,
                            color: theme.colorScheme.outline,
                          ),
                          SettingListItem(
                            setText: "テーマカラー設定",
                            onTapList: () =>
                                goRoute.push('/setting/theme_color_setting'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const AdaptiveAdBanner(4, key: GlobalObjectKey("setting_ad")),
          ],
        ),
      ),
    );
  }
}
