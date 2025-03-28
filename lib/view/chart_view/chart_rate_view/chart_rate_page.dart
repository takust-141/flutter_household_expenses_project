import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/provider/chart_page_provider/rate_chart_provider.dart';
import 'package:household_expense_project/provider/setting_data_provider.dart';
import 'package:household_expense_project/view/chart_view/chart_rate_view/chart_rate_figure.dart';
import 'package:household_expense_project/view/chart_view/chart_rate_view/chart_rate_list_item.dart';
import 'package:household_expense_project/view/chart_view/chart_rate_view/chart_rate_selector.dart';
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

    final rateChartNotifier = ref.read(rateChartProvider.notifier);
    final bool isShowScrollSelector = ref.watch(
            rateChartProvider.select((p) => p.valueOrNull?.isShowScrollView)) ??
        false;
    final List<RateChartSectionData> rateChartSectionDataList = ref.watch(
            rateChartProvider
                .select((p) => p.valueOrNull?.rateChartSectionDataList)) ??
        [];
    return Column(
      children: [
        const SizedBox(height: large),
        const Padding(
          padding: mediumHorizontalEdgeInsets,
          child: ChartRateSelector(),
        ),
        const SizedBox(height: medium),
        const Divider(height: 1),
        const Padding(
          padding: mediumHorizontalEdgeInsets,
          child: ChartRateDateSelector(),
        ),
        if (!isShowScrollSelector) ...{
          const ChartRateFigure(),
          const SizedBox(height: medium),
          (ref.watch(rateChartProvider).valueOrNull == null ||
                  ref
                      .watch(rateChartProvider)
                      .value!
                      .rateChartSectionDataList
                      .isEmpty)
              ? const SizedBox()
              : const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: medium),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: small),
                    for (int i = 0;
                        i < rateChartSectionDataList.length;
                        i++) ...{
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
            child: GestureDetector(
              onTap: () => rateChartNotifier.tapDateButton(),
              child: Container(
                color: theme.colorScheme.shadow.withValues(alpha: 0.4),
              ),
            ),
          ),
        },
      ],
    );
  }
}

//日付セレクタ（ホイールリスト、ドラムロールピッカー）
class ListWheelDateSelector extends ConsumerWidget {
  final double areaHeight;
  const ListWheelDateSelector(this.areaHeight, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pageNotifier = ref.read(rateChartProvider.notifier);
    final DateTime displayDate = ref.watch(
            rateChartProvider.select((p) => p.valueOrNull?.displayDate)) ??
        DateTime.now();

    final RateChartDateRange dateRange = ref.watch(rateChartProvider
            .select((p) => p.valueOrNull?.rateChartDateRange)) ??
        RateChartDateRange.month;

    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    final calendarStartDate = ref.watch(settingDataProvider
        .select((p) => p.value?.startCalendarDate ?? defaultStartCalendarDate));
    FixedExtentScrollController yearController = ref.watch(rateChartProvider
            .select((p) => p.valueOrNull?.listWheelYearController)) ??
        FixedExtentScrollController();
    FixedExtentScrollController monthController = ref.watch(rateChartProvider
            .select((p) => p.valueOrNull?.listWheelMonthController)) ??
        FixedExtentScrollController();

    return Padding(
      padding: largeEdgeInsets,
      child: Row(
        children: [
          //年
          Expanded(
            child: SizedBox(
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
                offAxisFraction:
                    (dateRange == RateChartDateRange.month) ? -0.4 : 0,
                overAndUnderCenterOpacity: 0.5,
                magnification: 1.1,
                children: [
                  for (int i = 0;
                      i <= currentMonth.year - calendarStartDate.year + 100;
                      i++)
                    Container(
                      alignment: (dateRange == RateChartDateRange.month)
                          ? Alignment.centerRight
                          : Alignment.center,
                      height: theme.textTheme.bodyMedium?.fontSize,
                      child: TextButton(
                          style: ButtonStyle(
                            overlayColor: WidgetStateProperty.all(theme
                                .colorScheme.shadow
                                .withValues(alpha: 0.1)),
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
                            textAlign: (dateRange == RateChartDateRange.month)
                                ? TextAlign.end
                                : TextAlign.center,
                          )),
                    ),
                ],
              ),
            ),
          ),
          if (dateRange == RateChartDateRange.month)
            //月
            Expanded(
              child: SizedBox(
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
                        child: TextButton(
                            style: ButtonStyle(
                              overlayColor: WidgetStateProperty.all(theme
                                  .colorScheme.shadow
                                  .withValues(alpha: 0.1)),
                              foregroundColor: WidgetStateProperty.all(
                                  theme.colorScheme.onSurface),
                            ),
                            onPressed: () {
                              monthController.animateToItem(i,
                                  duration: swipeDuration, curve: swipeCurve);
                            },
                            child:
                                Text("${i + 1}月", textAlign: TextAlign.start)),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
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
                    disabledColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.4),
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
                              theme.colorScheme.shadow.withValues(alpha: 0.1)),
                          backgroundColor: WidgetStateProperty.all(Color.lerp(
                              theme.colorScheme.surfaceContainer,
                              theme.colorScheme.shadow,
                              0.1)),
                        )
                      : ButtonStyle(
                          elevation: WidgetStateProperty.all(0),
                          overlayColor: WidgetStateProperty.all(
                              theme.colorScheme.shadow.withValues(alpha: 0.1)),
                          backgroundColor: WidgetStateProperty.all(
                            theme.colorScheme.surfaceContainer,
                          ),
                        ),
                  onPressed: () {
                    rateChartNotifier.tapDateButton();
                  },
                  child: Text(
                      (data.rateChartDateRange == RateChartDateRange.month)
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
                  disabledColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.4),
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
