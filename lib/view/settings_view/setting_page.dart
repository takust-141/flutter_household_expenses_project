import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
    var goRoute = GoRouter.of(context);
    final bannerAdHeight = useState<double>(0);

    return SafeArea(
      child: Container(
        color: theme.colorScheme.surfaceContainer,
        child: LayoutBuilder(builder: (context, boxConstraints) {
          return Column(
            children: [
              SizedBox(
                height: boxConstraints.maxHeight - bannerAdHeight.value,
                child: ListView(
                  padding: viewEdgeInsets,
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
                            setText: "カテゴリー編集",
                            onTapRoute: () {
                              ref
                                  .read(settingCategoryStateNotifierProvider
                                      .notifier)
                                  .changeOutgo();
                              goRoute.push('/setting/category_list');
                            },
                          ),
                          Divider(
                            height: 0,
                            thickness: 0.2,
                            color: theme.colorScheme.outline,
                          ),
                          SettingListItem(
                            setText: "カレンダー設定",
                            onTapRoute: () =>
                                goRoute.push('/setting/calendar_setting'),
                          ),
                          Divider(
                            height: 0,
                            thickness: 0.2,
                            color: theme.colorScheme.outline,
                          ),
                          SettingListItem(
                            setText: "定期収支設定",
                            onTapRoute: () =>
                                goRoute.push('/setting/recurring_list'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AdaptiveAdBanner(
                  key: GlobalKey(debugLabel: "setting_ad"),
                  setAdHeight: (height) => {bannerAdHeight.value = height}),
            ],
          );
        }),
      ),
    );
  }
}
