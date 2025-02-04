import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/provider/chart_page_provider/transition_chart_provider.dart';

//チャートページ用プロバイダー
final chartPageProvider =
    AsyncNotifierProvider<ChartPageNotifier, ChartPageState>(
        ChartPageNotifier.new);

enum ChartSegmentState { rateChart, transitionChart }

@immutable
class ChartPageState {
  final ChartSegmentState chartSegmentState;
  final PageController pageController;
  const ChartPageState({
    required this.chartSegmentState,
    required this.pageController,
  });

  ChartPageState.defaultState()
      : chartSegmentState = ChartSegmentState.rateChart,
        pageController = PageController(initialPage: 0);

  ChartPageState copyWith({
    ChartSegmentState? chartSegmentState,
    PageController? pageController,
  }) {
    return ChartPageState(
      chartSegmentState: chartSegmentState ?? this.chartSegmentState,
      pageController: pageController ?? this.pageController,
    );
  }
}

//Notifier
class ChartPageNotifier extends AsyncNotifier<ChartPageState> {
  @override
  Future<ChartPageState> build() async {
    return ChartPageState.defaultState();
  }

  void changeChartSegmentToRate() {
    state = AsyncData(state.valueOrNull
            ?.copyWith(chartSegmentState: ChartSegmentState.rateChart) ??
        ChartPageState.defaultState());
    state.valueOrNull?.pageController.jumpToPage(0);
  }

  void changeChartSegmentToTransition() {
    ref.read(transitionChartProvider.notifier).setLoadingState(1);
    state = AsyncData(state.valueOrNull
            ?.copyWith(chartSegmentState: ChartSegmentState.transitionChart) ??
        ChartPageState.defaultState());
    state.valueOrNull?.pageController.jumpToPage(1);
  }
}
