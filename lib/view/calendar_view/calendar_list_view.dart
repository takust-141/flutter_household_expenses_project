import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/generalized_logic_component.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/model/register.dart';
import 'package:household_expense_project/provider/calendar_page_provider.dart';
import 'package:household_expense_project/provider/register_edit_state.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/provider/setting_data_provider.dart';
import 'package:household_expense_project/component/custom_register_list_view/register_modal_view.dart';

class CalendarListView extends HookConsumerWidget {
  const CalendarListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //収支リスト
    final registerList = ref.watch(
            calendarPageProvider.select((p) => p.valueOrNull?.registerList)) ??
        [];
    final listScrollController = ref.watch(calendarPageProvider
            .select((p) => p.valueOrNull?.listScrollController)) ??
        ScrollController();

    return Padding(
      padding: const EdgeInsets.only(right: scrollbarpadding),
      child: Scrollbar(
        controller: listScrollController,
        thickness: scrollbarWidth,
        radius: const Radius.circular(8.0),
        thumbVisibility: true,
        child: CustomScrollView(
          controller: listScrollController,
          slivers: [
            SliverPadding(
              padding: calendarSliverEdgeInsets,
              sliver: SliverCrossAxisGroup(
                slivers: [
                  //日付
                  SliverConstrainedCrossAxis(
                    maxExtent: registerDateWidth + ssmall,
                    sliver: SliberDateGroup(registerList: registerList),
                  ),

                  //リスト
                  SliverMainAxisGroup(
                    slivers: [
                      if (registerList.isNotEmpty)
                        SliverFixedExtentList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return RegisterListItem(
                                register: registerList[index],
                                pagaProvider: calendarPageProvider,
                              );
                            },
                            childCount: registerList.length,
                          ),
                          itemExtent: registerListHeight,
                        ),
                    ],
                  ),
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
//リストアイテム
class RegisterListItem extends HookConsumerWidget {
  final Register register;
  final AsyncNotifierProvider<RegisterEditStateNotifier, RegisterEditState>
      pagaProvider;
  const RegisterListItem(
      {super.key, required this.register, required this.pagaProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final listItemColor = useState<Color>(colorScheme.surfaceBright);
    useEffect(() {
      listItemColor.value = colorScheme.surfaceBright;
      return () {};
    }, [colorScheme]);

    return Container(
      height: registerListHeight - registerListPadding,
      padding: const EdgeInsets.fromLTRB(
          0, 0, small + scrollbarSpace, registerListPadding),
      child: GestureDetector(
        onTap: () {
          ref
              .read(registerEditCategoryStateNotifierProvider.notifier)
              .updateSelectBothCategory(
                  register.category, register.subCategory);
          showRegisterModal(context, ref, register, pagaProvider);
        },
        onTapDown: (_) =>
            {listItemColor.value = colorScheme.surfaceContainerHighest},
        onTapUp: (_) => {listItemColor.value = colorScheme.surfaceBright},
        onTapCancel: () => {listItemColor.value = colorScheme.surfaceBright},
        child: Material(
          clipBehavior: Clip.antiAlias,
          elevation: 1.0,
          color: listItemColor.value,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              (register.subCategory == null)
                  ? Container(
                      margin: colorContainerMargin,
                      height: colorContainerHeight,
                      width: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: register.category!.color,
                      ),
                    )
                  : Container(
                      margin: colorContainerMargin,
                      height: colorContainerHeight,
                      width: 4,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: colorContainerHeight * 2 / 3,
                            decoration: BoxDecoration(
                              color: register.category!.color,
                            ),
                          ),
                          Container(
                            height: colorContainerHeight * 1 / 3,
                            decoration: BoxDecoration(
                              color: register.subCategory!.color,
                            ),
                          ),
                        ],
                      ),
                    ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, ssmall, ssmall, ssmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: [
                            Flexible(
                              flex: 2,
                              child: AutoSizeText(
                                register.category!.name,
                                textAlign: TextAlign.start,
                                minFontSize: 12,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (register.subCategory != null) ...{
                              Flexible(
                                flex: 1,
                                child: AutoSizeText(
                                  " / ${register.subCategory!.name}",
                                  textAlign: TextAlign.start,
                                  minFontSize: 10,
                                  maxFontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            }
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: AutoSizeText(
                          register.memo ?? "",
                          minFontSize: 10,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const SizedBox(height: 3),
                    Expanded(
                      flex: 1,
                      child: (register.recurringId != null)
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.repeat,
                                size: 13,
                                color: colorScheme.onSurface,
                              ))
                          : const SizedBox(),
                    ),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: AutoSizeText(
                          "${LogicComponent.addCommaToNum(register.amount)}円",
                          maxLines: 2,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.visible,
                          minFontSize: 12,
                          style: TextStyle(
                              color: register.category?.expense ==
                                      SelectExpense.income
                                  ? Colors.blue[600]
                                  : Colors.red[600]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: msmall),
            ],
          ),
        ),
      ),
    );
  }
}

//
//日付リストsliver
class SliberDateGroup extends StatelessWidget {
  final List<Register>? registerList;
  const SliberDateGroup({super.key, required this.registerList});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // 日付ごとにグループ化
    Map<int, List<DateTime?>> groupedByDay = {};
    if (registerList == null || registerList!.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    //カレンダーとの対応づけのためMap型としている
    for (Register register in registerList!) {
      int day = register.date.day;
      if (!groupedByDay.containsKey(day)) {
        groupedByDay[day] = [register.date];
      } else {
        groupedByDay[day]!.add(null);
      }
    }
    List<List<DateTime?>> dayLists = groupedByDay.values.toList();

    return SliverMainAxisGroup(
      slivers: [
        for (List<DateTime?> dayList in dayLists) ...{
          if (dayList.isNotEmpty)
            SliverMainAxisGroup(
              slivers: [
                SliverPersistentHeader(
                  delegate: CustomSliverHeaderDelegate(
                      date: dayList[0]!, context: context),
                  pinned: true,
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding:
                        const EdgeInsets.fromLTRB(msmall, 0, msmall, small),
                    height: (dayList.length - 1) * registerListHeight,
                    child: VerticalDivider(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ],
            ),
        },
      ],
    );
  }
}

//デリゲート（日付ピン留めsliber用）
class CustomSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height = registerListHeight;
  final DateTime date;
  final BuildContext context;

  CustomSliverHeaderDelegate({
    required this.date,
    required this.context,
  });

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final ThemeData theme = Theme.of(context);
    return SizedBox.expand(
      child: Container(
        color: theme.colorScheme.surfaceContainer,
        padding:
            const EdgeInsets.fromLTRB(msmall, 0, msmall, registerListPadding),
        child: Column(
          children: [
            Flexible(
              flex: 3,
              child: FittedBox(
                child: Text(
                  date.day.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: FittedBox(
                child: Text(defaultWeeks[date.weekday - 1]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(CustomSliverHeaderDelegate oldDelegate) {
    if (Theme.of(oldDelegate.context) == Theme.of(context)) {
      return true;
    }
    if (oldDelegate.date.year == date.year &&
        oldDelegate.date.month == date.month &&
        oldDelegate.date.day == date.day) {
      return false;
    }
    return true;
  }
}

//
//月合計アイテム
class CalendarMonthSumItem extends HookConsumerWidget {
  const CalendarMonthSumItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    final totalAmount = useMemoized(
        () => ref.read(calendarPageProvider.notifier).calcMonthSumRegister(), [
      ref.watch(calendarPageProvider.selectAsync((p) => p.displayMonth)),
      ref.watch(calendarPageProvider.selectAsync((p) => p.registerList))
    ]);

    int totalIncome = totalAmount.$1;
    int totalOutgo = totalAmount.$2;

    return SizedBox(
      height: registerListHeight - registerListPadding,
      child: Material(
        clipBehavior: Clip.antiAlias,
        elevation: 1.0,
        color: theme.colorScheme.surfaceBright,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: small, horizontal: msmall),
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Text(
                      "合計",
                      textAlign: TextAlign.left,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                    ),
                    const SizedBox(width: ssmall),
                    Expanded(
                      child: AutoSizeText(
                        "${LogicComponent.addCommaToNum(totalIncome - totalOutgo)}円",
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.2),
                        maxFontSize: 20,
                        minFontSize: 5,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ssmall),
              const SizedBox(
                  height: double.maxFinite, child: VerticalDivider()),
              const SizedBox(width: ssmall),
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Text(
                      "支出",
                      textAlign: TextAlign.left,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                    ),
                    const SizedBox(width: ssmall),
                    Expanded(
                      child: AutoSizeText(
                        "${LogicComponent.addCommaToNum(totalOutgo)}円",
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(height: 1.2, color: Colors.red[600]),
                        maxFontSize: 20,
                        minFontSize: 5,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ssmall),
              const SizedBox(
                  height: double.maxFinite, child: VerticalDivider()),
              const SizedBox(width: ssmall),
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Text(
                      "収入",
                      textAlign: TextAlign.left,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                    ),
                    const SizedBox(width: ssmall),
                    Expanded(
                      child: AutoSizeText(
                        "${LogicComponent.addCommaToNum(totalIncome)}円",
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(height: 1.2, color: Colors.blue[600]),
                        maxFontSize: 20,
                        minFontSize: 5,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
