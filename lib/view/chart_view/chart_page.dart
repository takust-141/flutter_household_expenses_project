import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:household_expenses_project/provider/chart_page_provider/chart_page_provider.dart';
import 'package:household_expenses_project/view/chart_view/chart_rate_view/chart_rate_page.dart';
import 'package:household_expenses_project/view/chart_view/chart_transition_view/chart_transition_page.dart';

//-------チャートページ---------------------------
class ChartPage extends ConsumerWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return (ref.watch(chartPageProvider).valueOrNull?.chartSegmentState ==
            ChartSegmentState.rateChart)
        ? const ChartRatePage()
        : const ChartTransitionPage();
  }
}

//
//---チャートappバー
class ChartAppBar extends StatelessWidget {
  const ChartAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        ChartSegmentedButton(chartPageProvider),
        const Spacer(),
      ],
    );
  }
}

//-----SegmentedButton-----
class ChartSegmentedButton extends ConsumerStatefulWidget {
  const ChartSegmentedButton(this.notifierProvider, {super.key});
  final AsyncNotifierProvider<ChartPageNotifier, ChartPageState>
      notifierProvider;

  @override
  ConsumerState<ChartSegmentedButton> createState() =>
      _ChartSegmentedButtonState();
}

class _ChartSegmentedButtonState extends ConsumerState<ChartSegmentedButton>
    with SingleTickerProviderStateMixin {
  final double segmentedButtonHeight = 30;
  final double segmentedButtonWidth = 100;

  late final AnimationController _animationController;
  final Duration animationDuration = const Duration(milliseconds: 180);

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: animationDuration,
    );

    if (ref.read(widget.notifierProvider).valueOrNull?.chartSegmentState ==
        ChartSegmentState.transitionChart) {
      _animationController.value = 1.0; // 完了状態
    }
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    //アニメーション定義
    const Cubic animationCurve = Curves.easeOut;
    final Animation<Color?> leftAnimation = ColorTween(
      begin: theme.colorScheme.onPrimary,
      end: theme.colorScheme.outline,
    ).chain(CurveTween(curve: animationCurve)).animate(_animationController);
    final Animation<Color?> rightAnimation = ColorTween(
      begin: theme.colorScheme.outline,
      end: theme.colorScheme.onPrimary,
    ).chain(CurveTween(curve: animationCurve)).animate(_animationController);

    final ChartSegmentState chartSegmentState = ref.watch(widget
            .notifierProvider
            .select((p) => p.valueOrNull?.chartSegmentState)) ??
        ChartSegmentState.rateChart;
    final selectExpensesProvider = ref.read(widget.notifierProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        borderRadius: segmentedButtomRadius,
        color: theme.colorScheme.inverseSurface.withOpacity(0.1),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            left: (chartSegmentState == ChartSegmentState.rateChart)
                ? 0
                : segmentedButtonWidth,
            curve: animationCurve,
            duration: animationDuration,
            child: Container(
              height: segmentedButtonHeight,
              width: segmentedButtonWidth,
              decoration: BoxDecoration(
                borderRadius: segmentedButtomRadius,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (chartSegmentState != ChartSegmentState.rateChart) {
                    selectExpensesProvider.changeChartSegmentToRate();
                  }
                  _animationController.reverse();
                },
                child: AnimatedBuilder(
                  animation: leftAnimation,
                  builder: (context, child) {
                    return Container(
                      alignment: Alignment.center,
                      height: segmentedButtonHeight,
                      width: segmentedButtonWidth,
                      child: Row(
                        children: [
                          const Spacer(flex: 3),
                          Icon(
                            Icons.pie_chart,
                            color: leftAnimation.value,
                            size: 15,
                          ),
                          const SizedBox(width: ssmall),
                          Text(
                            "割合",
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: leftAnimation.value),
                          ),
                          const Spacer(flex: 4),
                        ],
                      ),
                    );
                  },
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (chartSegmentState != ChartSegmentState.transitionChart) {
                    selectExpensesProvider.changeChartSegmentToTransition();
                  }
                  _animationController.forward();
                },
                child: AnimatedBuilder(
                  animation: rightAnimation,
                  builder: (context, child) {
                    return Container(
                      alignment: Alignment.center,
                      height: segmentedButtonHeight,
                      width: segmentedButtonWidth,
                      child: Row(
                        children: [
                          const Spacer(flex: 3),
                          Icon(
                            Icons.bar_chart,
                            color: rightAnimation.value,
                            size: 17,
                          ),
                          const SizedBox(width: ssmall),
                          Text(
                            "推移",
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: rightAnimation.value),
                          ),
                          const Spacer(flex: 4),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
