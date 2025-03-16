import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/constant/constant.dart';
import 'package:household_expense_project/provider/setting_remove_ad_provider.dart';

//-------広告非表示ページ---------------------------
class RemoveAdPage extends ConsumerWidget {
  const RemoveAdPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        color: theme.colorScheme.surfaceContainer,
        padding: mediumEdgeInsets,
        child: Column(
          children: [
            ref.watch(settingRemoveAdProvider).maybeWhen(
                  skipLoadingOnRefresh: false,
                  data: (data) => CustomListItem(
                    title: "広告を非表示にする",
                    rightText: "300円",
                    onTapList: () async {
                      ref
                          .read(settingRemoveAdProvider.notifier)
                          .purchase(context);
                    },
                  ),
                  orElse: () => CustomListItem(
                    title: "広告を非表示にする",
                    rightText: "300円",
                    onTapList: () => debugPrint("orElse"),
                  ),
                ),
            SizedBox(
              height: medium,
            ),
            CustomListItem(
              title: "購入を復元する",
              rightText: (ref
                          .watch(settingRemoveAdProvider)
                          .valueOrNull
                          ?.removedAdProductState ==
                      ProductState.purchased)
                  ? "購入済み"
                  : "未購入",
              onTapList: () async {
                await ref
                    .read(settingRemoveAdProvider.notifier)
                    .restore(context);
              },
            ),
            Text("※広告の非表示は買い切りで、一度購入すれば無期限で広告が非表示になります"),
          ],
        ),
      ),
    );
  }
}

//表示リスト
class CustomListItem extends HookWidget {
  final String title;
  final String rightText;
  final Function onTapList;
  const CustomListItem(
      {required this.title,
      required this.rightText,
      required this.onTapList,
      super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final listItemColor = useState<Color>(colorScheme.surfaceBright);
    useEffect(() {
      listItemColor.value = colorScheme.surfaceBright;
      return () {};
    }, [colorScheme]);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(containreBorderRadius),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTapList(),
        onTapDown: (_) =>
            {listItemColor.value = colorScheme.surfaceContainerHighest},
        onTapUp: (_) => {listItemColor.value = colorScheme.surfaceBright},
        onTapCancel: () => {listItemColor.value = colorScheme.surfaceBright},
        child: AnimatedContainer(
          color: listItemColor.value,
          duration: listItemAnimationDuration,
          height: listHeight,
          padding: smallEdgeInsets,
          child: Row(
            children: [
              Padding(
                padding: ssmallLeftEdgeInsets,
                child: Text(
                  title,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(right: ssmall),
                child: Text(
                  rightText,
                  style: TextStyle(color: colorScheme.outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
