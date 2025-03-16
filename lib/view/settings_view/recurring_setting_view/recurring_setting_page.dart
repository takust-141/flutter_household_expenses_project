import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/provider/setting_recurring_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

//繰り返し設定
class RecurringSettingPage extends ConsumerWidget {
  const RecurringSettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    //riverpod
    final recurringSetting = ref
        .watch(settingRecurringyStateNotifierProvider
            .select((p) => p.selectRegisterRecurring))!
        .recurringSetting;
    final settingRecurringNotifier =
        ref.read(settingRecurringyStateNotifierProvider.notifier);

    return SafeArea(
      child: Container(
        color: theme.colorScheme.surfaceContainer,
        child: ListView(
          padding: viewEdgeInsets,
          children: [
            //繰り返し基準
            Container(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(bottom: medium),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(containreBorderRadius),
              ),
              child: RecurringSettingListItem(
                isDetail: true,
                index: 0,
                subText: settingRecurringNotifier.getSubText(0),
              ),
            ),
            //詳細設定
            if (recurringSetting.selectRecurring != 3) ...{
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(containreBorderRadius),
                ),
                child: Column(
                  children: [
                    if (recurringSetting.selectRecurring == 0 ||
                        recurringSetting.selectRecurring == 1) ...{
                      if (recurringSetting.selectRecurring == 0) ...{
                        //対象月
                        RecurringSettingListItem(
                          isDetail: true,
                          index: 1,
                          subText: settingRecurringNotifier.getSubText(1),
                          isNotActive: recurringSetting.selectRecurring == 1,
                        ),
                        Divider(
                          height: 0,
                          thickness: 0.2,
                          color: theme.colorScheme.outline,
                        ),
                      },
                      //基準
                      RecurringSettingListItem(
                        isDetail: true,
                        index: 2,
                        subText: settingRecurringNotifier.getSubText(2),
                        isNotActive: recurringSetting.selectRecurring == 2,
                      ),
                      Divider(
                        height: 0,
                        thickness: 0.2,
                        color: theme.colorScheme.outline,
                      ),
                    },
                    if (recurringSetting.criteria == 0) ...{
                      if (recurringSetting.selectRecurring == 0 ||
                          recurringSetting.selectRecurring == 1) ...{
                        RecurringSettingListItem(
                          isDetail: true,
                          index: 3,
                          subText: settingRecurringNotifier.getSubText(3),
                        ),
                        Divider(
                          height: 0,
                          thickness: 0.2,
                          color: theme.colorScheme.outline,
                        ),
                      },
                      RecurringSettingListItem(
                        isDetail: true,
                        index: 4,
                        subText: settingRecurringNotifier.getSubText(4),
                      ),
                    } else ...{
                      RecurringSettingListItem(
                        isDetail: true,
                        index: 5,
                        subText: settingRecurringNotifier.getSubText(5),
                      ),
                    },
                  ],
                ),
              ),
              const SizedBox(height: medium),
            },
            //振替設定
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(containreBorderRadius),
              ),
              child: Column(
                children: [
                  RecurringSettingListItem(
                    isDetail: true,
                    index: 6,
                    subText: settingRecurringNotifier.getSubText(6),
                  ),
                  if (settingRecurringNotifier.isReschedule()) ...{
                    Divider(
                      height: 0,
                      thickness: 0.2,
                      color: theme.colorScheme.outline,
                    ),
                    RecurringSettingListItem(
                      isDetail: true,
                      index: 7,
                      subText: settingRecurringNotifier.getSubText(7),
                    ),
                    Divider(
                      height: 0,
                      thickness: 0.2,
                      color: theme.colorScheme.outline,
                    ),
                  }
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
//繰り返しListItem
class RecurringSettingListItem extends HookWidget {
  final int? index;
  final String? listTitle;
  final String? subText;
  final String? nextRoot;
  final bool isDetail;
  final bool isNotActive;

  const RecurringSettingListItem({
    super.key,
    this.index,
    this.listTitle,
    this.subText,
    this.nextRoot,
    this.isDetail = false,
    this.isNotActive = false,
  });
  static const String detailRoot =
      '/setting/recurring_list/recurring_edit/recurring_setting/recurring_setting_detail';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var goRoute = GoRouter.of(context);
    final listItemColor = useState<Color>(theme.colorScheme.surfaceBright);
    useEffect(() {
      listItemColor.value = theme.colorScheme.surfaceBright;
      return () {};
    }, [theme]);

    void onTapList() {
      if (isNotActive) {
        return;
      } else if (isDetail && index != null) {
        goRoute.go(detailRoot, extra: index!);
      } else if (nextRoot != null) {
        goRoute.go(nextRoot!);
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTapList(),
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
            const SizedBox(width: small),
            Text(
              listTitle ?? recurringDetailTitleList[index ?? 0],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: medium),
            Expanded(
              child: AutoSizeText(
                textAlign: TextAlign.end,
                subText ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            Icon(
              Symbols.chevron_right,
              weight: 300,
              size: 25,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

//
//繰り返し設定セレクタ
class RecurringSettingSelector extends HookWidget {
  final String listTitle;
  final Function onTap;
  final bool checked;

  const RecurringSettingSelector({
    super.key,
    required this.listTitle,
    required this.onTap,
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listItemColor = useState<Color>(theme.colorScheme.surfaceBright);
    useEffect(() {
      listItemColor.value = theme.colorScheme.surfaceBright;
      return () {};
    }, [theme]);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(),
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
            const SizedBox(width: small),
            Expanded(
              child: Text(
                listTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: small),
            if (checked)
              Icon(
                Symbols.check,
                weight: 800,
                size: 25,
                color: theme.colorScheme.primary,
              ),
            const SizedBox(width: small),
          ],
        ),
      ),
    );
  }
}
