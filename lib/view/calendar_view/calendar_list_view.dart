import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:household_expenses_project/model/register.dart';
import 'package:household_expenses_project/provider/calendar_page_provider.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/provider/setting_data_provider.dart';
import 'package:household_expenses_project/view/calendar_view/calendar_modal_view.dart';

const double calendarListHeight = 50;
const double calendarDateWidth = 40;
const double calendarListPadding = small;

const double colorV = ssmall + 2;
const double colorH = 6;
const colorContainerMargin =
    EdgeInsets.symmetric(vertical: colorV, horizontal: colorH);
const colorContainerHeight =
    calendarListHeight - calendarListPadding - colorV * 2;

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

    return CustomScrollView(
      controller: listScrollController,
      slivers: [
        SliverPadding(
          padding: calendarSliverEdgeInsets,
          sliver: SliverCrossAxisGroup(
            slivers: [
              //日付
              SliverConstrainedCrossAxis(
                maxExtent: calendarDateWidth,
                sliver: SliberDateGroup(registerList: registerList),
              ),

              //リスト
              SliverMainAxisGroup(
                slivers: [
                  if (registerList.isNotEmpty)
                    SliverFixedExtentList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return RegisterListItem(index: index);
                        },
                        childCount: registerList.length,
                      ),
                      itemExtent: calendarListHeight,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//
//リストアイテム
class RegisterListItem extends HookConsumerWidget {
  final int index;
  const RegisterListItem({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final listItemColor = useState<Color>(theme.colorScheme.surfaceBright);
    final registerList = ref.watch(
            calendarPageProvider.select((p) => p.valueOrNull?.registerList)) ??
        [];

    return Container(
      height: calendarListHeight - calendarListPadding,
      padding: const EdgeInsets.only(bottom: calendarListPadding),
      child: GestureDetector(
        onTap: () {
          Register selectRegister = registerList[index];
          ref
              .read(registerEditCategoryStateNotifierProvider.notifier)
              .updateSelectBothCategory(
                  selectRegister.category, selectRegister.subCategory);
          showRegisterModal(context, ref, selectRegister, calendarPageProvider);
        },
        onTapDown: (_) =>
            {listItemColor.value = theme.colorScheme.surfaceContainerHighest},
        onTapUp: (_) => {listItemColor.value = theme.colorScheme.surfaceBright},
        onTapCancel: () =>
            {listItemColor.value = theme.colorScheme.surfaceBright},
        child: Material(
          clipBehavior: Clip.antiAlias,
          elevation: 1.0,
          color: listItemColor.value,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              (registerList[index].subCategory == null)
                  ? Container(
                      margin: colorContainerMargin,
                      height: colorContainerHeight,
                      width: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: registerList[index].category!.color,
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
                              color: registerList[index].category!.color,
                            ),
                          ),
                          Container(
                            height: colorContainerHeight * 1 / 3,
                            decoration: BoxDecoration(
                              color: registerList[index].subCategory!.color,
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
                                registerList[index].category!.name,
                                textAlign: TextAlign.start,
                                minFontSize: 12,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (registerList[index].subCategory != null) ...{
                              Flexible(
                                flex: 1,
                                child: AutoSizeText(
                                  " / ${registerList[index].subCategory!.name}",
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
                          registerList[index].memo ?? "",
                          minFontSize: 10,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
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
                child: AutoSizeText(
                  "${LogicComponent.addCommaToNum(registerList[index].amount)}円",
                  maxLines: 2,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.visible,
                  minFontSize: 10,
                  style: TextStyle(
                      color: registerList[index].category?.expenses ==
                              SelectExpenses.income
                          ? Colors.blue[900]
                          : Colors.red[900]),
                ),
              ),
              const SizedBox(width: small),
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
    if (registerList == null) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

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
                  delegate: CustomSliverHeaderDelegate(date: dayList[0]!),
                  pinned: true,
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, small, small),
                    height: (dayList.length - 1) * calendarListHeight,
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
  final double height = calendarListHeight;
  final DateTime date;

  CustomSliverHeaderDelegate({
    required this.date,
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
        padding: const EdgeInsets.fromLTRB(
            sssmall, 0, small, calendarListPadding + sssmall),
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
class CalendarMonthSumItem extends ConsumerWidget {
  // ignore: prefer_const_constructors_in_immutables
  CalendarMonthSumItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final (int totalIncome, int totalOutgo) =
        ref.read(calendarPageProvider.notifier).calcMonthSumRegister();

    return SizedBox(
      height: calendarListHeight - calendarListPadding,
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
                            ?.copyWith(height: 1.2, color: Colors.red[900]),
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
                            ?.copyWith(height: 1.2, color: Colors.blue[900]),
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
