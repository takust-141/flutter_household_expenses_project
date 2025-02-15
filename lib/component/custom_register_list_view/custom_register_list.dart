import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/generalized_logic_component.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/model/register.dart';
import 'package:household_expense_project/provider/register_edit_state.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/provider/setting_data_provider.dart';
import 'package:household_expense_project/component/custom_register_list_view/register_modal_view.dart';
import 'package:intl/intl.dart';

class CustomRegisterList extends HookConsumerWidget {
  const CustomRegisterList({
    required this.registerList,
    required this.isDisplayYear,
    required this.registerEditProvider,
    super.key,
  });
  final List<Register> registerList;
  final bool isDisplayYear;
  final AsyncNotifierProvider<RegisterEditStateNotifier, RegisterEditState>
      registerEditProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayCount = useState(30);
    final ScrollController sliverScrollController = ScrollController();

    useEffect(() {
      sliverScrollController.addListener(
        () {
          final scrollValue = sliverScrollController.offset /
              sliverScrollController.position.maxScrollExtent;
          if (scrollValue > 0.95) {
            displayCount.value += 30;
          }
        },
      );

      return () => sliverScrollController.dispose;
    }, [sliverScrollController]);

    if (registerList.isEmpty) {
      return const SizedBox.shrink();
    }

    // 年月ごとにグループ化
    List<List<Register>> registerListGroup = [];
    int j = 0;
    for (int i = 0; (i < registerList.length && i < displayCount.value); i++) {
      if (i != 0 &&
          LogicComponent.isBeforeMonth(
              registerList[i - 1].date, registerList[i].date)) {
        registerListGroup.add(registerList.sublist(j, i));
        j = i;
      }
    }
    if (j < registerList.length) {
      registerListGroup.add(registerList.sublist(
          j, min(displayCount.value, registerList.length)));
    }

    return Padding(
      padding: const EdgeInsets.only(right: scrollbarpadding),
      child: Scrollbar(
        controller: sliverScrollController,
        thickness: scrollbarWidth,
        radius: const Radius.circular(8.0),
        thumbVisibility: true,
        child: CustomScrollView(
          controller: sliverScrollController,
          slivers: [
            SliverPadding(
              padding: customRegisterListPadding,
              sliver: SliverMainAxisGroup(
                slivers: [
                  for (List<Register> sliverRegisterList in registerListGroup)
                    if (sliverRegisterList.isNotEmpty)
                      MainSliverGroup(
                        registerList: sliverRegisterList,
                        isDisplayYear: isDisplayYear,
                        registerEditProvider: registerEditProvider,
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
//リストsliver
class MainSliverGroup extends StatelessWidget {
  final List<Register> registerList;
  final bool isDisplayYear;
  final AsyncNotifierProvider<RegisterEditStateNotifier, RegisterEditState>
      registerEditProvider;
  const MainSliverGroup({
    required this.registerList,
    required this.isDisplayYear,
    required this.registerEditProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        if (isDisplayYear)
          //年月
          SliverPersistentHeader(
            pinned: true,
            delegate:
                CustomYMSliverHeaderDelegate(date: registerList.first.date),
          ),

        //registerリスト表示
        SliverFixedExtentList.builder(
          itemBuilder: (BuildContext context, int index) {
            return RegisterListItem(
              register: registerList[index],
              registerEditProvider: registerEditProvider,
              isNewDate: (index == 0 ||
                  LogicComponent.isBeforeDate(
                      registerList[index - 1].date, registerList[index].date)),
              isNewDatePre: (index < registerList.length - 1 &&
                  LogicComponent.isBeforeDate(
                      registerList[index].date, registerList[index + 1].date)),
            );
          },
          itemCount: registerList.length,
          itemExtent: registerListHeight,
        ),
      ],
    );
  }
}

//
//リストアイテム
class RegisterListItem extends HookConsumerWidget {
  final Register register;
  final AsyncNotifierProvider<RegisterEditStateNotifier, RegisterEditState>
      registerEditProvider;
  final bool isNewDate;
  final bool isNewDatePre;
  const RegisterListItem({
    super.key,
    required this.register,
    required this.registerEditProvider,
    required this.isNewDate,
    required this.isNewDatePre,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final listItemColor = useState<Color>(colorScheme.surfaceBright);
    useEffect(() {
      listItemColor.value = colorScheme.surfaceBright;
      return () {};
    }, [colorScheme]);

    return Row(
      children: [
        const SizedBox(width: ssmall),
        //日付
        Container(
          alignment: Alignment.center,
          width: registerDateWidth + ssmall,
          child: (isNewDate)
              ? SizedBox.expand(
                  child: Container(
                    color: colorScheme.surfaceContainer,
                    padding: const EdgeInsets.fromLTRB(
                        msmall, 0, msmall, registerListPadding),
                    child: Column(
                      children: [
                        Flexible(
                          flex: 3,
                          child: FittedBox(
                            child: Text(
                              register.date.day.toString(),
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: FittedBox(
                            child:
                                Text(defaultWeeks[register.date.weekday - 1]),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  padding: EdgeInsets.fromLTRB(msmall, 0, msmall,
                      (isNewDatePre) ? registerListPadding : 0),
                  height: registerListHeight,
                  child: VerticalDivider(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
        ),

        //リスト
        Expanded(
          child: Container(
            height: registerListHeight,
            padding: const EdgeInsets.fromLTRB(
                0, 0, small + scrollbarSpace, registerListPadding),
            child: GestureDetector(
              onTap: () {
                ref
                    .read(registerEditCategoryStateNotifierProvider.notifier)
                    .updateSelectBothCategory(
                        register.category, register.subCategory);
                showRegisterModal(context, ref, register, registerEditProvider);
              },
              onTapDown: (_) =>
                  {listItemColor.value = colorScheme.surfaceContainerHighest},
              onTapUp: (_) => {listItemColor.value = colorScheme.surfaceBright},
              onTapCancel: () =>
                  {listItemColor.value = colorScheme.surfaceBright},
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
                        padding: const EdgeInsets.fromLTRB(
                            0, ssmall, ssmall, ssmall),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
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
          ),
        ),
      ],
    );
  }
}

//
//デリゲート（年月ピン留めsliber用）
class CustomYMSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height = registerListHeight - 20;
  final DateTime date;
  final formatter = DateFormat('yyyy年 M月');

  CustomYMSliverHeaderDelegate({
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
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding:
            const EdgeInsets.fromLTRB(msmall, 0, small, registerListPadding),
        child: Text(formatter.format(date),
            overflow: TextOverflow.visible,
            style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                shadows: [
                  Shadow(blurRadius: 10.0, color: theme.colorScheme.surface),
                  Shadow(blurRadius: 12.0, color: theme.colorScheme.surface),
                  Shadow(blurRadius: 14.0, color: theme.colorScheme.surface),
                  Shadow(blurRadius: 16.0, color: theme.colorScheme.surface),
                  Shadow(blurRadius: 18.0, color: theme.colorScheme.surface),
                ])),
      ),
    );
  }

  @override
  bool shouldRebuild(CustomYMSliverHeaderDelegate oldDelegate) {
    if (oldDelegate.date.year == date.year &&
        oldDelegate.date.month == date.month) {
      return false;
    }
    return true;
  }
}

//
//
//デリゲート（日付ピン留めsliber用）：未使用
class CustomDaySliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height = registerListHeight;
  final DateTime date;

  CustomDaySliverHeaderDelegate({
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
    return Align(
      alignment: Alignment.center,
      child: SizedBox.expand(
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
      ),
    );
  }

  @override
  bool shouldRebuild(CustomDaySliverHeaderDelegate oldDelegate) {
    if (oldDelegate.date.year == date.year &&
        oldDelegate.date.month == date.month &&
        oldDelegate.date.day == date.day) {
      return false;
    }
    return true;
  }
}
