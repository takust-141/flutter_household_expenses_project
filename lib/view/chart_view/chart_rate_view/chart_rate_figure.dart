import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:household_expenses_project/provider/chart_page_provider/rate_chart_provider.dart';

class ChartRateFigure extends ConsumerWidget {
  const ChartRateFigure({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width - medium * 2;
    final rateChartState = ref.watch(rateChartProvider);
    final rateChartNotifier = ref.read(rateChartProvider.notifier);
    final double chartRadius = screenWidth * 0.7 / 2;

    //割合小数点以下1位以下切り捨て
    double floorOneDecimalPlace(double rate) {
      if (rate < 0.1) {
        return 0.1;
      }
      return (rate * 10).round() / 10;
    }

    //文字列調整
    String maxTextLimit(String text) {
      String newText = text;
      if (text.length > 10) {
        newText = "${text.substring(0, 10)}...";
      }
      return newText;
    }

    //PieChartSectionData作成
    PieChartSectionData createSectionData(
        String title, double rate, Color color, int? index) {
      final double floorRate = floorOneDecimalPlace(rate);
      String percentText = "${floorRate.toString()}%";
      if (rate < 0.1) {
        percentText = "0.1%以下";
      }

      return PieChartSectionData(
        color: color,
        value: floorRate,
        title: title,
        radius: chartRadius,
        showTitle: false,
        badgePositionPercentageOffset: 0.7,
        badgeWidget: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => {
            (index != null)
                ? rateChartNotifier.setSelectRateChartStateFromGlaph(index)
                : null
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: sssmallEdgeInsets,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${maxTextLimit(title)} ",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  percentText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      overflow: TextOverflow.ellipsis,
                      fontSize:
                          (theme.textTheme.bodyMedium?.fontSize ?? 14) - 2),
                ),
              ],
            ),
          ),
        ),
      );
    }

    //RateChartSectionData → PieChartデータ作成
    List<PieChartSectionData> createChartSections() {
      final currentRateChartDataList = ref.watch(rateChartProvider
          .select((p) => p.valueOrNull?.rateChartSectionDataList));
      if (currentRateChartDataList == null ||
          currentRateChartDataList.isEmpty) {
        return [];
      }

      final List<PieChartSectionData> pieChartSectionDataList = [];

      double rateSumValue = 0.0;
      int index = 0;
      for (RateChartSectionData rateChartSectionData
          in currentRateChartDataList) {
        //5%以下は全てその他とする（収入:支出は対象外)
        if (rateChartSectionData.rate < 5) {
          late final PieChartSectionData data;
          if (rateChartState.valueOrNull?.rateSelectState ==
              RateSelectState.expenses) {
            data = createSectionData(
              rateChartSectionData.title,
              100 - rateSumValue,
              rateChartSectionData.color,
              index,
            );
          } else {
            data = createSectionData(
              "その他",
              100 - rateSumValue,
              Colors.grey.shade800,
              null,
            );
          }
          pieChartSectionDataList.add(data);
          break;
        }
        final data = createSectionData(
          rateChartSectionData.title,
          rateChartSectionData.rate,
          rateChartSectionData.color,
          index,
        );
        pieChartSectionDataList.add(data);
        rateSumValue += data.value;
        index++;
      }

      return pieChartSectionDataList;
    }

    return rateChartState.isRefreshing
        ? const Padding(
            padding: largeEdgeInsets,
            child: SizedBox(
              height: 35,
              width: 35,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          )
        : (rateChartState.value == null ||
                rateChartState.value!.rateChartSectionDataList.isEmpty)
            ? Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  "データはありません",
                  style: theme.textTheme.bodyLarge,
                ),
              )
            : SizedBox(
                width: screenWidth * 0.9,
                height: screenWidth * 0.8,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 0,
                    sectionsSpace: 1,
                    startDegreeOffset: 270,
                    borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                            style: BorderStyle.solid)),
                    sections: createChartSections(),
                    pieTouchData: PieTouchData(
                      enabled: true,
                      touchCallback: (touchEvent, pieTouchResponse) {
                        if (touchEvent.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null ||
                            pieTouchResponse
                                    .touchedSection!.touchedSectionIndex <
                                0) {
                          //タップ以外のアクションの時は何もしない
                          return;
                        } else {
                          //タップした時、下の階層へ
                          rateChartNotifier.setSelectRateChartStateFromGlaph(
                              pieTouchResponse
                                  .touchedSection!.touchedSectionIndex);
                        }
                      },
                    ),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 0),
                ),
              );
  }
}
