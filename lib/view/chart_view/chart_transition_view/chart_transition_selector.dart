import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/custom_expand_list.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/provider/category_list_provider.dart';
import 'package:household_expense_project/provider/chart_page_provider/transition_chart_provider.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';

const double selectDisplayheight = 40;

//-------割合チャートセレクター---------------------------
class ChartTransitionSelector extends ConsumerWidget {
  const ChartTransitionSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final TransitionChartState transitionChartState =
        ref.watch(transitionChartProvider).valueOrNull ??
            TransitionChartState.defaultState();
    final transitionChartNotifier = ref.watch(transitionChartProvider.notifier);

    final categoryListMap = ref.watch(categoryListNotifierProvider);
    final List<Category> outgoCategoryList =
        categoryListMap.valueOrNull?[SelectExpense.outgo] ?? [];
    final List<Category> incomeCategoryList =
        categoryListMap.valueOrNull?[SelectExpense.income] ?? [];

    final int outgoCategoryCount = outgoCategoryList.length;

    final int incomeCategoryCount = incomeCategoryList.length;

    final MenuController menuSelectController = MenuController();
    final MenuController menuRangeController = MenuController();

    final ScrollController selectorDropDownListScrollController =
        ScrollController();

    return Row(
      children: [
        //対象カテゴリー選択
        Expanded(
          flex: 2,
          child: LayoutBuilder(builder: (context, constraints) {
            return MenuAnchor(
              alignmentOffset: const Offset(0, 4),
              controller: menuSelectController,
              style: MenuStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: chartListItemRadius,
                  ),
                ),
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                backgroundColor:
                    WidgetStateProperty.all(theme.colorScheme.surfaceBright),
                minimumSize: WidgetStateProperty.all(
                    const Size.fromHeight(selectDisplayheight * 3)),
                maximumSize: WidgetStateProperty.all(
                    const Size.fromHeight(selectDisplayheight * 5 + 4)),
              ),
              consumeOutsideTap: true,
              //メニュー内容
              menuChildren: [
                SizedBox(
                  height: selectDisplayheight * 5 + 4,
                  width: constraints.maxWidth,
                  child: RawScrollbar(
                    controller: selectorDropDownListScrollController,
                    thickness: 4,
                    radius: const Radius.circular(8.0),
                    thumbVisibility: true,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    child: SingleChildScrollView(
                        controller: selectorDropDownListScrollController,
                        child: Column(
                          children: [
                            TransitionDropDownListItem(
                                TransitionSelectState.expense,
                                null,
                                menuSelectController),
                            const Divider(height: 1, thickness: 0.5),
                            TransitionDropDownListItem(
                                TransitionSelectState.outgo,
                                null,
                                menuSelectController),
                            const Divider(height: 1, thickness: 0.5),
                            TransitionDropDownListItem(
                                TransitionSelectState.income,
                                null,
                                menuSelectController),
                            const Divider(height: 1, thickness: 0.5),

                            //支出
                            CustomExpandList(
                              itemColor: theme.colorScheme.surfaceBright,
                              title: "支出のカテゴリー",
                              padding: chartSelectEdgeInsets,
                              titleHeight: selectDisplayheight,
                              titleWidth: constraints.maxWidth,
                              childrenHeight: (selectDisplayheight + 1) *
                                  outgoCategoryCount,
                              children: [
                                for (Category outgoCategory
                                    in outgoCategoryList) ...{
                                  const Divider(height: 1, thickness: 0.5),
                                  TransitionDropDownListItem(
                                      TransitionSelectState.category,
                                      outgoCategory,
                                      menuSelectController),
                                },
                              ],
                            ),
                            const Divider(height: 1, thickness: 0.5),
                            //収入
                            CustomExpandList(
                              itemColor: theme.colorScheme.surfaceBright,
                              title: "収入のカテゴリー",
                              padding: chartSelectEdgeInsets,
                              titleHeight: selectDisplayheight,
                              titleWidth: constraints.maxWidth,
                              childrenHeight: (selectDisplayheight + 1) *
                                  incomeCategoryCount,
                              children: [
                                for (Category incomeCategory
                                    in incomeCategoryList) ...{
                                  const Divider(height: 1, thickness: 0.5),
                                  TransitionDropDownListItem(
                                      TransitionSelectState.category,
                                      incomeCategory,
                                      menuSelectController),
                                },
                              ],
                            ),
                          ],
                        )),
                  ),
                ),
              ],
              //セレクターDisplay
              builder: (BuildContext context, MenuController controller,
                  Widget? child) {
                return GestureDetector(
                  onTap: () => {
                    controller.isOpen ? controller.close() : controller.open()
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    height: selectDisplayheight,
                    width: double.maxFinite,
                    padding: chartSelectEdgeInsets,
                    decoration: BoxDecoration(
                      borderRadius: chartListItemRadius,
                      color: theme.colorScheme.surfaceBright,
                    ),
                    child: AutoSizeText(
                      transitionChartNotifier.selectListTitle(),
                      maxLines: 1,
                      minFontSize: 10,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(width: small),

        //期間選択
        Expanded(
          flex: 1,
          child: LayoutBuilder(builder: (context, constraints) {
            return MenuAnchor(
              alignmentOffset: const Offset(0, 4),
              controller: menuRangeController,
              style: MenuStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: chartListItemRadius,
                  ),
                ),
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                backgroundColor:
                    WidgetStateProperty.all(theme.colorScheme.surfaceBright),
                fixedSize: WidgetStateProperty.all(
                    const Size.fromHeight(selectDisplayheight * 2 + 1)),
              ),
              consumeOutsideTap: true,
              menuChildren: [
                SizedBox(
                  width: constraints.maxWidth,
                  height: selectDisplayheight * 2 + 1,
                  child: Column(
                    children: [
                      TransitionRnageDropDownListItem(
                          TransitionChartDateRange.month, menuRangeController),
                      const Divider(height: 1, thickness: 0.5),
                      TransitionRnageDropDownListItem(
                          TransitionChartDateRange.year, menuRangeController),
                    ],
                  ),
                ),
              ],
              builder: (BuildContext context, MenuController controller,
                  Widget? child) {
                return GestureDetector(
                  onTap: () => {
                    controller.isOpen ? controller.close() : controller.open()
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    height: selectDisplayheight,
                    width: double.maxFinite,
                    padding: chartSelectEdgeInsets,
                    decoration: BoxDecoration(
                      borderRadius: chartListItemRadius,
                      color: theme.colorScheme.surfaceBright,
                    ),
                    child: AutoSizeText(
                      transitionChartState.transitionChartDateRange.text,
                      maxLines: 1,
                      minFontSize: 10,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

//対象割合チャートカテゴリー選択リストアイテム
class TransitionDropDownListItem extends ConsumerWidget {
  const TransitionDropDownListItem(
      this.transitionSelectState, this.category, this.menuController,
      {super.key});
  final TransitionSelectState transitionSelectState;
  final Category? category;
  final MenuController menuController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transitionChartProviderNotifier =
        ref.read(transitionChartProvider.notifier);
    final transitionChartState = ref.watch(transitionChartProvider);

    final theme = Theme.of(context);
    return SizedBox(
      height: selectDisplayheight,
      child: TextButton(
        style: TextButton.styleFrom(
          textStyle: theme.textTheme.bodyMedium,
          foregroundColor: theme.colorScheme.onSurface,
          alignment: Alignment.centerLeft,
          fixedSize: const Size(double.maxFinite, selectDisplayheight),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: chartSelectEdgeInsets,
          overlayColor: theme.colorScheme.onSurface,
          backgroundColor:
              (transitionChartState.valueOrNull?.selectCategory == category &&
                      transitionChartState.valueOrNull?.transitionSelectState ==
                          transitionSelectState)
                  ? theme.colorScheme.onSurface.withOpacity(0.1)
                  : theme.colorScheme.surfaceBright,
        ),
        onPressed: () {
          transitionChartProviderNotifier.setSelectTransitionChartState(
              transitionSelectState, category);
          menuController.close();
        },
        child: transitionSelectState != TransitionSelectState.category
            ? Text(transitionSelectState.text)
            : Padding(
                padding: const EdgeInsets.only(left: medium),
                child: AutoSizeText(
                  (category?.name ?? ""),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
      ),
    );
  }
}

//割合チャートカテゴリー期間リストアイテム
class TransitionRnageDropDownListItem extends ConsumerWidget {
  const TransitionRnageDropDownListItem(
      this.transitionChartDateRange, this.menuController,
      {super.key});
  final TransitionChartDateRange transitionChartDateRange;
  final MenuController menuController;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transitionChartProviderNotifier =
        ref.read(transitionChartProvider.notifier);
    final transitionChartState = ref.watch(transitionChartProvider);

    final theme = Theme.of(context);
    return SizedBox(
      height: selectDisplayheight,
      child: TextButton(
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          fixedSize: const Size(double.maxFinite, selectDisplayheight),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: chartSelectEdgeInsets,
          overlayColor: theme.colorScheme.onSurface,
          backgroundColor:
              (transitionChartState.valueOrNull?.transitionChartDateRange ==
                      transitionChartDateRange)
                  ? theme.colorScheme.onSurface.withOpacity(0.1)
                  : theme.colorScheme.surfaceBright,
        ),
        onPressed: () {
          transitionChartProviderNotifier
              .setRangeTransitionChartState(transitionChartDateRange);
          menuController.close();
        },
        child: Text(
          transitionChartDateRange.text,
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
