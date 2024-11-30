import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/component/generalized_logic_component.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:household_expenses_project/provider/chart_page_provider/chart_page_provider.dart';
import 'package:household_expenses_project/provider/chart_page_provider/transition_chart_provider.dart';

class ChartTransitionFigure extends ConsumerWidget {
  const ChartTransitionFigure({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    //riverpod
    final transitionChartNotifier = ref.read(transitionChartProvider.notifier);
    final TransitionChartState transitionChartState =
        ref.watch(transitionChartProvider).valueOrNull ??
            TransitionChartState.defaultState();
    final bool isExpenses = transitionChartState.transitionSelectState ==
        TransitionSelectState.expenses;
    //chartパラメーター
    const double barChartHeight = 250;
    const BorderRadius barChartRadius =
        BorderRadius.vertical(top: Radius.circular(2));
    const double xTitleSize = 25;
    const double barChartItemWidth = 25;
    const double barGroupSpace = medium;
    const double barGroupWidth = barChartItemWidth + barGroupSpace;

    //グラフエリアのwidth
    double getBarChartWidth() {
      if (transitionChartNotifier.isEmptyRegisterList()) {
        return 0;
      }
      late final double barChartWidth;
      final int listLength = transitionChartState
          .transitionChartGroupDataList.first.transitionChartRodDataList.length;
      if (isExpenses) {
        barChartWidth = listLength * (barGroupWidth + barChartItemWidth + 2);
      } else {
        barChartWidth = listLength * barGroupWidth;
      }
      return barChartWidth;
    }

    //TransitionChartSectionData → BarChartデータリスト作成
    List<BarChartGroupData> createBarChartGroupDataList() {
      if (transitionChartNotifier.isEmptyRegisterList()) {
        return [];
      }

      final List<BarChartGroupData> barChartGroupDataList = [];
      for (int i = 0;
          i <
              transitionChartState.transitionChartGroupDataList.first
                  .transitionChartRodDataList.length;
          i++) {
        //BarChartデータ作成
        final data = BarChartGroupData(
          x: i,
          //一目盛りあたりのライン
          barRods: [
            for (int j = 0;
                j < transitionChartState.transitionChartGroupDataList.length;
                j++)
              BarChartRodData(
                toY: transitionChartState.transitionChartGroupDataList[j]
                    .transitionChartRodDataList[i].value
                    .toDouble(),
                color: transitionChartState
                        .transitionChartGroupDataList[j].chartColor ??
                    Theme.of(context).colorScheme.primary,
                width: barChartItemWidth,
                borderRadius: barChartRadius,
                //borderSide:
              ),
          ],
          showingTooltipIndicators: [0, 1],
          barsSpace: 2,
        );
        barChartGroupDataList.add(data);
      }
      return barChartGroupDataList;
    }

    //タイトル取得
    Widget getBottomTitles(double value, TitleMeta meta) {
      final Widget text = SizedBox(
        height: xTitleSize,
        width: xTitleSize,
        child: Text(
          transitionChartState.xTitleList[value.toInt()],
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 9,
          ),
          maxLines: 2,
        ),
      );

      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: sssmall, //margin
        child: text,
      );
    }

    //数→漢字数値丸め込み
    String formatNumberInJapanese(int amount) {
      if (amount >= 10000000000000000) {
        return '${(amount / 10000000000000000).toStringAsFixed(1)}京';
      } else if (amount >= 1000000000000) {
        return '${(amount / 1000000000000).toStringAsFixed(1)}兆';
      } else if (amount >= 100000000) {
        return '${(amount / 100000000).toStringAsFixed(1)}億';
      } else if (amount >= 10000) {
        return '${(amount / 10000).toStringAsFixed(1)}万';
      } else {
        return LogicComponent.addCommaToNum(amount);
      }
    }

    //グラフ上のバッチ取得
    BarTouchData getBarTouchData() {
      return BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: const EdgeInsets.only(bottom: 2),
          tooltipMargin: 0,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              formatNumberInJapanese(rod.toY.round()),
              theme.textTheme.bodySmall?.copyWith(
                    color: [
                      rod.color ?? theme.colorScheme.primary,
                      Colors.blue
                    ][rodIndex],
                    fontSize: 8,
                  ) ??
                  TextStyle(
                    color: [
                      rod.color ?? theme.colorScheme.primary,
                      Colors.blue
                    ][rodIndex],
                    fontSize: 8,
                  ),
            );
          },
        ),
      );
    }

    //return
    return (transitionChartNotifier.isEmptyRegisterList())
        ? Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              "データはありません",
              style: theme.textTheme.bodyLarge,
            ),
          )
        : Column(
            children: [
              SizedBox(
                width: screenWidth,
                height: barChartHeight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: medium),
                      SizedBox(
                        width: getBarChartWidth(),
                        child: BarChart(
                          BarChartData(
                            barGroups: createBarChartGroupDataList(),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(),
                              rightTitles: const AxisTitles(),
                              topTitles: const AxisTitles(),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: getBottomTitles,
                                  reservedSize:
                                      xTitleSize + sssmall * 2, //タイトルの高さ
                                ),
                              ),
                            ),
                            groupsSpace: barGroupSpace,
                            alignment: BarChartAlignment.center,
                            maxY: transitionChartNotifier
                                    .getMaxAmount()
                                    .toDouble() *
                                1.1,
                            minY: 0,
                            baselineY: 0,
                            borderData: FlBorderData(
                              show: false,
                            ),
                            gridData: const FlGridData(show: false),
                            barTouchData: getBarTouchData(),
                          ),
                          swapAnimationDuration: Duration.zero,
                        ),
                      ),
                      const SizedBox(width: medium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: medium),
              const Divider(height: 1),
            ],
          );
  }
}
