import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
class ChartSegmentedButton extends HookConsumerWidget {
  const ChartSegmentedButton(this.notifierProvider, {super.key});
  final AsyncNotifierProvider<ChartPageNotifier, ChartPageState>
      notifierProvider;

  final double segmentedButtonHeight = 30;
  final double segmentedButtonWidth = 100;
  final Duration animationDuration = const Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    //riverpod
    final ChartSegmentState chartSegmentState = ref.watch(
            notifierProvider.select((p) => p.valueOrNull?.chartSegmentState)) ??
        ChartSegmentState.rateChart;
    final selectExpensesProvider = ref.read(notifierProvider.notifier);
    final selectExpenses =
        ref.watch(notifierProvider).valueOrNull?.chartSegmentState;

    //hook
    final segmentAnimationController = useAnimationController(
      duration: animationDuration,
      initialValue:
          (selectExpenses == ChartSegmentState.transitionChart) ? 1 : 0,
    );
    useEffect(() {
      if (selectExpenses == ChartSegmentState.transitionChart) {
        segmentAnimationController.forward();
      } else {
        segmentAnimationController.reverse();
      }
      return null;
    }, [selectExpenses]);

    //アニメーション定義
    const Cubic animationCurve = Curves.easeOut;
    final segmentLeftAnimation = useMemoized(() {
      return ColorTween(
        begin: theme.colorScheme.onPrimary,
        end: theme.colorScheme.outline,
      )
          .chain(CurveTween(curve: animationCurve))
          .animate(segmentAnimationController);
    }, [segmentAnimationController]);
    final segmentRightAnimation = useMemoized(() {
      return ColorTween(
        begin: theme.colorScheme.outline,
        end: theme.colorScheme.onPrimary,
      )
          .chain(CurveTween(curve: animationCurve))
          .animate(segmentAnimationController);
    }, [segmentAnimationController]);

    //Builder内でuseAnimationを利用できないため、外で定義
    final leftColor = useAnimation(segmentLeftAnimation);
    final rightColor = useAnimation(segmentRightAnimation);

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
                },
                child: AnimatedBuilder(
                  animation: segmentLeftAnimation,
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
                            color: leftColor,
                            size: 15,
                          ),
                          const SizedBox(width: ssmall),
                          Text(
                            "割合",
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: leftColor),
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
                },
                child: AnimatedBuilder(
                  animation: segmentRightAnimation,
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
                            color: rightColor,
                            size: 17,
                          ),
                          const SizedBox(width: ssmall),
                          Text(
                            "推移",
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: rightColor),
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
