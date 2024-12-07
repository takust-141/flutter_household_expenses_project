import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/provider/chart_page_provider/transition_chart_provider.dart';

//チャートページ用プロバイダー
final chartPageProvider =
    AsyncNotifierProvider<ChartPageNotifier, ChartPageState>(
        ChartPageNotifier.new);

enum ChartSegmentState { rateChart, transitionChart }

@immutable
class ChartPageState {
  final ChartSegmentState chartSegmentState;
  const ChartPageState({
    required this.chartSegmentState,
  });

  const ChartPageState.defaultState()
      : chartSegmentState = ChartSegmentState.rateChart;

  ChartPageState copyWith({
    ChartSegmentState? chartSegmentState,
  }) {
    return ChartPageState(
      chartSegmentState: chartSegmentState ?? this.chartSegmentState,
    );
  }
}

//Notifier
class ChartPageNotifier extends AsyncNotifier<ChartPageState> {
  @override
  Future<ChartPageState> build() async {
    return const ChartPageState.defaultState();
  }

  void changeChartSegmentToRate() {
    state = AsyncData(state.valueOrNull
            ?.copyWith(chartSegmentState: ChartSegmentState.rateChart) ??
        const ChartPageState.defaultState());
  }

  void changeChartSegmentToTransition() {
    state = AsyncData(state.valueOrNull
            ?.copyWith(chartSegmentState: ChartSegmentState.transitionChart) ??
        const ChartPageState.defaultState());
  }
}
