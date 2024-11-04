import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
  late final ChartPageState _defaultState;
  @override
  Future<ChartPageState> build() async {
    _defaultState = const ChartPageState(
      chartSegmentState: ChartSegmentState.rateChart,
    );
    return _defaultState;
  }

  void changeChartSegmentToRate() {
    state = AsyncData(state.valueOrNull
            ?.copyWith(chartSegmentState: ChartSegmentState.rateChart) ??
        _defaultState);
  }

  void changeChartSegmentToTransition() {
    state = AsyncData(state.valueOrNull
            ?.copyWith(chartSegmentState: ChartSegmentState.transitionChart) ??
        _defaultState);
  }
}
