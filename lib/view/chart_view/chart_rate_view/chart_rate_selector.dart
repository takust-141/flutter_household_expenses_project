import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/component/custom_expand_list.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/provider/category_list_provider.dart';
import 'package:household_expenses_project/provider/chart_page_provider/rate_chart_provider.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';

const double selectDisplayheight = 40;

//-------割合チャートセレクター---------------------------
class ChartRateSelector extends ConsumerWidget {
  const ChartRateSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final RateChartState rateChartState =
        ref.watch(rateChartProvider).valueOrNull ??
            RateChartState.defaultState();

    final categoryListMap = ref.watch(categoryListNotifierProvider);
    final List<Category> outgoCategoryList =
        categoryListMap.valueOrNull?[SelectExpenses.outgo] ?? [];
    final List<Category> incomeCategoryList =
        categoryListMap.valueOrNull?[SelectExpenses.income] ?? [];

    final int outgoCategoryCount = outgoCategoryList.length;

    final int incomeCategoryCount = incomeCategoryList.length;

    final MenuController menuSelectController = MenuController();
    final MenuController menuRangeController = MenuController();

    final double selectorWidth =
        (mediaQuery.size.width - small - medium - medium) / 3 * 2;
    final double rangeSelectorWidth = selectorWidth / 2;
    final ScrollController selectorDropDownListScrollController =
        ScrollController();

    return Row(
      children: [
        //対象カテゴリー選択
        Expanded(
          flex: 2,
          child: MenuAnchor(
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
                width: selectorWidth,
                child: RawScrollbar(
                  controller: selectorDropDownListScrollController,
                  thickness: 4,
                  thumbColor: theme.colorScheme.outlineVariant,
                  radius: const Radius.circular(8.0),
                  thumbVisibility: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  child: SingleChildScrollView(
                      controller: selectorDropDownListScrollController,
                      child: Column(
                        children: [
                          RateDropDownListItem(RateSelectState.expenses, null,
                              menuSelectController),
                          const Divider(height: 1, thickness: 0.5),
                          RateDropDownListItem(RateSelectState.outgo, null,
                              menuSelectController),
                          const Divider(height: 1, thickness: 0.5),
                          RateDropDownListItem(RateSelectState.income, null,
                              menuSelectController),
                          const Divider(height: 1, thickness: 0.5),

                          //支出
                          CustomExpandList(
                            itemColor: theme.colorScheme.surfaceBright,
                            title: "支出のカテゴリー",
                            padding: chartSelectEdgeInsets,
                            titleHeight: selectDisplayheight,
                            titleWidth: selectorWidth,
                            childrenHeight:
                                (selectDisplayheight + 1) * outgoCategoryCount,
                            children: [
                              for (Category outgoCategory
                                  in outgoCategoryList) ...{
                                const Divider(height: 1, thickness: 0.5),
                                RateDropDownListItem(RateSelectState.category,
                                    outgoCategory, menuSelectController),
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
                            titleWidth: selectorWidth,
                            childrenHeight:
                                (selectDisplayheight + 1) * incomeCategoryCount,
                            children: [
                              for (Category incomeCategory
                                  in incomeCategoryList) ...{
                                const Divider(height: 1, thickness: 0.5),
                                RateDropDownListItem(RateSelectState.category,
                                    incomeCategory, menuSelectController),
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
                    rateChartState.selectListTitle(),
                    maxLines: 1,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: small),

        //期間選択
        Expanded(
          flex: 1,
          child: MenuAnchor(
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
                width: rangeSelectorWidth,
                height: selectDisplayheight * 2 + 1,
                child: Column(
                  children: [
                    RateRnageDropDownListItem(
                        RateDateRange.month, menuRangeController),
                    const Divider(height: 1, thickness: 0.5),
                    RateRnageDropDownListItem(
                        RateDateRange.year, menuRangeController),
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
                    rateChartState.rateDateRange.text,
                    maxLines: 1,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

//対象割合チャートカテゴリー選択リストアイテム
class RateDropDownListItem extends ConsumerWidget {
  const RateDropDownListItem(
      this.rateSelectState, this.category, this.menuController,
      {super.key});
  final RateSelectState rateSelectState;
  final Category? category;
  final MenuController menuController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rateChartProviderNotifier = ref.read(rateChartProvider.notifier);
    final rateChartState = ref.watch(rateChartProvider);

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
              (rateChartState.valueOrNull?.selectCategory == category &&
                      rateChartState.valueOrNull?.rateSelectState ==
                          rateSelectState)
                  ? theme.colorScheme.onSurface.withOpacity(0.1)
                  : theme.colorScheme.surfaceBright,
        ),
        onPressed: () {
          rateChartProviderNotifier.setSelectRateChartState(
              rateSelectState, category);
          menuController.close();
        },
        child: rateSelectState != RateSelectState.category
            ? Text(rateSelectState.text)
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
class RateRnageDropDownListItem extends ConsumerWidget {
  const RateRnageDropDownListItem(this.rateDateRange, this.menuController,
      {super.key});
  final RateDateRange rateDateRange;
  final MenuController menuController;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rateChartProviderNotifier = ref.read(rateChartProvider.notifier);
    final rateChartState = ref.watch(rateChartProvider);

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
              (rateChartState.valueOrNull?.rateDateRange == rateDateRange)
                  ? theme.colorScheme.onSurface.withOpacity(0.1)
                  : theme.colorScheme.surfaceBright,
        ),
        onPressed: () {
          rateChartProviderNotifier.setRangeRateChartState(rateDateRange);
          menuController.close();
        },
        child: Text(
          rateDateRange.text,
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
