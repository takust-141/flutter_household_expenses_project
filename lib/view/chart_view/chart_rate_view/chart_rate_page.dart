import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:household_expenses_project/provider/chart_page_provider/rate_chart_provider.dart';
import 'package:household_expenses_project/provider/setting_data_provider.dart';
import 'package:household_expenses_project/view/chart_view/chart_rate_view/chart_rate_figure.dart';
import 'package:household_expenses_project/view/chart_view/chart_rate_view/chart_rate_list_item.dart';
import 'package:household_expenses_project/view/chart_view/chart_rate_view/chart_rate_selector.dart';
import 'package:intl/intl.dart';

const double selectDisplayheight = 40;
const Duration swipeDuration = Duration(milliseconds: 250);
const Curve swipeCurve = Curves.easeInOutCirc;

//-------割合チャートページ---------------------------
class ChartRatePage extends ConsumerWidget {
  const ChartRatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final bool isShowScrollSelector = ref.watch(
            rateChartProvider.select((p) => p.valueOrNull?.isShowScrollView)) ??
        false;
    final List<RateChartSectionData> rateChartSectionDataList = ref.watch(
            rateChartProvider
                .select((p) => p.valueOrNull?.rateChartSectionDataList)) ??
        [];
    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(medium, large, medium, 0),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChartRateSelector(),
            SizedBox(height: medium),
            Divider(height: 1),
            SizedBox(height: small),
            ChartRateDateSelector(),
            SizedBox(height: ssmall),
          ],
        ),
      ),
      if (!isShowScrollSelector) ...{
        const ChartRateFigure(),
        (ref.watch(rateChartProvider).value == null ||
                ref
                    .watch(rateChartProvider)
                    .value!
                    .rateChartSectionDataList
                    .isEmpty)
            ? const SizedBox()
            : const Padding(
                padding: EdgeInsets.symmetric(horizontal: medium),
                child: Divider(height: 1),
              ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: medium),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: small),
                  for (int i = 0; i < rateChartSectionDataList.length; i++) ...{
                    RateChartListItem(
                      text: rateChartSectionDataList[i].title,
                      rate: rateChartSectionDataList[i].rate,
                      color: rateChartSectionDataList[i].color,
                      amount: rateChartSectionDataList[i].value,
                      index: i,
                    ),
                  }
                ],
              ),
            ),
          ),
        ),
      } else ...{
        const SizedBox(
          height: 260,
          child: ListWheelDateSelector(260),
        ),
        Expanded(
          child: Container(
            color: theme.colorScheme.shadow.withOpacity(0.4),
          ),
        ),
      },
      SizedBox(height: mediaQuery.padding.bottom),
    ]);
  }
}

//日付セレクタ（ホイールリスト、ドラムロールピッカー）
class ListWheelDateSelector extends ConsumerWidget {
  final double areaHeight;
  const ListWheelDateSelector(this.areaHeight, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final double wheelWidth = mediaQuery.size.width / 2 - large;
    final pageNotifier = ref.read(rateChartProvider.notifier);
    final DateTime displayDate = ref.watch(
            rateChartProvider.select((p) => p.valueOrNull?.displayDate)) ??
        DateTime.now();

    final RateDateRange dateRange = ref.watch(
            rateChartProvider.select((p) => p.valueOrNull?.rateDateRange)) ??
        RateDateRange.month;

    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    final calendarStartDate = ref.watch(settingDataProvider
        .select((p) => p.value?.startCalendarDate ?? defaultStartCalendarDate));
    FixedExtentScrollController yearController = ref.watch(rateChartProvider
            .select((p) => p.valueOrNull?.listWheelYearController)) ??
        FixedExtentScrollController();
    FixedExtentScrollController monthController = ref.watch(rateChartProvider
            .select((p) => p.valueOrNull?.listWheelMonthController)) ??
        FixedExtentScrollController();

    return Row(
      children: [
        const SizedBox(width: large),
        //年
        SizedBox(
          width:
              (dateRange == RateDateRange.month) ? wheelWidth : wheelWidth * 2,
          height: areaHeight,
          child: ListWheelScrollView(
            controller: yearController,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              HapticFeedback.selectionClick();
              pageNotifier.setDisplayDateTime(DateTime(
                  index + calendarStartDate.year, displayDate.month, 1));
            },
            itemExtent: areaHeight / 8,
            offAxisFraction: (dateRange == RateDateRange.month) ? -0.4 : 0,
            overAndUnderCenterOpacity: 0.5,
            magnification: 1.1,
            children: [
              for (int i = 0;
                  i <= currentMonth.year - calendarStartDate.year + 100;
                  i++)
                Container(
                  alignment: (dateRange == RateDateRange.month)
                      ? Alignment.centerRight
                      : Alignment.center,
                  height: theme.textTheme.bodyMedium?.fontSize,
                  width: wheelWidth,
                  child: TextButton(
                      style: ButtonStyle(
                        overlayColor: WidgetStateProperty.all(
                            theme.colorScheme.shadow.withOpacity(0.1)),
                        splashFactory: NoSplash.splashFactory,
                        foregroundColor: WidgetStateProperty.all(
                            theme.colorScheme.onSurface),
                      ),
                      onPressed: () {
                        yearController.animateToItem(i,
                            duration: swipeDuration, curve: swipeCurve);
                      },
                      child: Text(
                        "${calendarStartDate.year + i}年",
                        textAlign: (dateRange == RateDateRange.month)
                            ? TextAlign.end
                            : TextAlign.center,
                      )),
                ),
            ],
          ),
        ),
        if (dateRange == RateDateRange.month)
          //月
          SizedBox(
            width: wheelWidth,
            height: areaHeight,
            child: ListWheelScrollView(
              controller: monthController,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                HapticFeedback.selectionClick();
                pageNotifier.setDisplayDateTime(
                    DateTime(displayDate.year, index + 1, 1));
              },
              offAxisFraction: 0.4,
              itemExtent: areaHeight / 8,
              overAndUnderCenterOpacity: 0.5,
              magnification: 1.1,
              useMagnifier: true,
              children: [
                for (int i = 0; i < 12; i++)
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 13,
                    width: wheelWidth,
                    child: TextButton(
                        style: ButtonStyle(
                          overlayColor: WidgetStateProperty.all(
                              theme.colorScheme.shadow.withOpacity(0.1)),
                          foregroundColor: WidgetStateProperty.all(
                              theme.colorScheme.onSurface),
                        ),
                        onPressed: () {
                          monthController.animateToItem(i,
                              duration: swipeDuration, curve: swipeCurve);
                        },
                        child: Text("${i + 1}月", textAlign: TextAlign.start)),
                  ),
              ],
            ),
          ),
        const SizedBox(width: large),
      ],
    );
  }
}

//
// 日付セレクター
class ChartRateDateSelector extends ConsumerWidget {
  const ChartRateDateSelector({super.key});

  static const double dateSelectorHeight = 45.0 + ssmall * 2;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rateChartNotifier = ref.read(rateChartProvider.notifier);
    final formatterMonth = DateFormat('yyyy年 M月');
    final formatterYear = DateFormat('yyyy年');

    //年月表示
    return ref.watch(rateChartProvider).maybeWhen(
          data: (data) => Container(
            padding: ssmallVerticalEdgeInsets,
            height: dateSelectorHeight,
            child: Row(
              children: [
                const Spacer(),
                //ボタン pre
                IconButton(
                    icon: const Icon(Icons.keyboard_arrow_left),
                    iconSize: IconTheme.of(context).size ?? 24,
                    color: theme.colorScheme.onSurface,
                    disabledColor: theme.colorScheme.onSurface.withOpacity(0.4),
                    onPressed: (!data.isShowScrollView)
                        ? () => {rateChartNotifier.tapDateArrowButton(-1)}
                        : null),
                const SizedBox(width: large),
                //年・年月ボタン
                ElevatedButton(
                  style: data.isShowScrollView
                      ? ButtonStyle(
                          elevation: WidgetStateProperty.all(1),
                          overlayColor: WidgetStateProperty.all(
                              theme.colorScheme.shadow.withOpacity(0.1)),
                          backgroundColor: WidgetStateProperty.all(Color.lerp(
                              theme.colorScheme.surfaceContainer,
                              theme.colorScheme.shadow,
                              0.1)),
                        )
                      : ButtonStyle(
                          elevation: WidgetStateProperty.all(0),
                          overlayColor: WidgetStateProperty.all(
                              theme.colorScheme.shadow.withOpacity(0.1)),
                          backgroundColor: WidgetStateProperty.all(
                            theme.colorScheme.surfaceContainer,
                          ),
                        ),
                  onPressed: () {
                    rateChartNotifier.tapDateButton();
                  },
                  child: Text(
                      (data.rateDateRange == RateDateRange.month)
                          ? formatterMonth.format(data.displayDate)
                          : formatterYear.format(data.displayDate),
                      style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface)),
                ),
                const SizedBox(width: large),

                //ボタン after
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_right),
                  iconSize: IconTheme.of(context).size ?? 24,
                  color: theme.iconTheme.color,
                  disabledColor: theme.colorScheme.onSurface.withOpacity(0.4),
                  onPressed: (!data.isShowScrollView)
                      ? () => {rateChartNotifier.tapDateArrowButton(1)}
                      : null,
                ),
                const Spacer(),
              ],
            ),
          ),
          orElse: () => const SizedBox(height: dateSelectorHeight),
        );
  }
}
