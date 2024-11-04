import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:household_expenses_project/model/register.dart';
import 'package:household_expenses_project/provider/search_page_provider.dart';
import 'package:household_expenses_project/provider/setting_data_provider.dart';
import 'package:household_expenses_project/view/calendar_view/calendar_list_view.dart';
import 'package:intl/intl.dart';

//-------検索ページ---------------------------
class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final FocusNode? searchFocusNode =
        ref.watch(searchPageProvider).valueOrNull?.searchFocusNode;
    final registerList = ref.watch(searchPageProvider
            .select((p) => p.valueOrNull?.searchRegisterList)) ??
        [];

    // 年月ごとにグループ化
    Map<String, List<Register>> groupedByRegister = {};

    for (Register register in registerList) {
      String yearMonth = "${register.date.year}${register.date.month}";
      if (!groupedByRegister.containsKey(yearMonth)) {
        groupedByRegister[yearMonth] = [register];
      } else {
        groupedByRegister[yearMonth]!.add(register);
      }
    }
    List<List<Register>> registerYMLists = groupedByRegister.values.toList();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (_) => {searchFocusNode?.unfocus()},
      child: Padding(
        padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: calendarSliverEdgeInsets,
              sliver: SliverMainAxisGroup(
                slivers: [
                  for (List<Register> registerYMList in registerYMLists)
                    SearchSliverGroup(
                      registerList: registerYMList,
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
class SearchSliverGroup extends StatelessWidget {
  final List<Register> registerList;
  const SearchSliverGroup({super.key, required this.registerList});

  @override
  Widget build(BuildContext context) {
    if (registerList.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }
    final ThemeData theme = Theme.of(context);
    // 日付ごとにグループ化
    Map<int, List<DateTime?>> groupedByDay = {};

    for (Register register in registerList) {
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
        SliverPersistentHeader(
          pinned: true,
          delegate: CustomYMSliverHeaderDelegate(date: registerList[0].date),
        ),
        SliverCrossAxisGroup(
          slivers: [
            //日付
            SliverConstrainedCrossAxis(
              maxExtent: registerDateWidth,
              sliver: SliverMainAxisGroup(
                slivers: [
                  for (List<DateTime?> dayList in dayLists) ...{
                    if (dayList.isNotEmpty)
                      SliverMainAxisGroup(
                        slivers: [
                          SliverPersistentHeader(
                            delegate: CustomDaySliverHeaderDelegate(
                                date: dayList[0]!),
                            pinned: true,
                          ),
                          SliverToBoxAdapter(
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(0, 0, small, small),
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
              ),
            ),

            //リスト
            SliverMainAxisGroup(
              slivers: [
                if (registerList.isNotEmpty)
                  SliverFixedExtentList.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return RegisterListItem(
                        register: registerList[index],
                        pagaProvider: searchPageProvider,
                      );
                    },
                    itemCount: registerList.length,
                    itemExtent: registerListHeight,
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

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
      alignment: Alignment.center,
      child: SizedBox.expand(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
              sssmall, 0, small, registerListPadding + sssmall),
          child: Text(formatter.format(date),
              style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface)),
        ),
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

//デリゲート（日付ピン留めsliber用）
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
          padding: const EdgeInsets.fromLTRB(
              sssmall, 0, small, registerListPadding + sssmall),
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

//
//---検索ページ用appバー
class SearchAppBar extends HookConsumerWidget {
  const SearchAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final FocusNode? searchFocusNode = ref.watch(
        searchPageProvider.select((p) => p.valueOrNull?.searchFocusNode));
    final TextEditingController? searchTextController = ref.watch(
        searchPageProvider.select((p) => p.valueOrNull?.searchTextController));
    final cancelIconColor =
        useState<Color?>(theme.colorScheme.onSurfaceVariant);

    return Container(
      padding: appbarSearchPadding,
      height: 60,
      child: TextField(
        controller: searchTextController,
        focusNode: searchFocusNode,
        onSubmitted: (_) =>
            {ref.read(searchPageProvider.notifier).searchRegister()},
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.all(7),
          prefixIconConstraints: const BoxConstraints(maxHeight: 30),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.search,
              size: 20,
            ),
          ),
          suffixIconConstraints:
              const BoxConstraints(maxHeight: 30, maxWidth: 35),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 7),
            child: IconButton(
              iconSize: 80,
              splashRadius: 10,
              padding: const EdgeInsets.all(5),
              onPressed: () => {searchTextController?.clear()},
              icon: Icon(
                Icons.cancel,
                color: cancelIconColor.value,
                size: 20,
              ),
              splashColor: theme.colorScheme.surface.withOpacity(0.5),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: formInputBoarderRadius,
          ),
        ),
      ),
    );
  }
}
