import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/provider/chart_page_provider/chart_page_provider.dart';
import 'package:household_expense_project/provider/chart_page_provider/transition_chart_provider.dart';
import 'package:household_expense_project/view/chart_view/chart_rate_view/chart_rate_page.dart';
import 'package:household_expense_project/view/chart_view/chart_transition_view/chart_transition_page.dart';

//-------チャートページ---------------------------
class ChartPage extends ConsumerWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraint) {
      return SafeArea(
        child: SizedBox(
          height: constraint.maxHeight,
          width: constraint.maxWidth,
          child: PageView(
            controller: ref.watch(
                chartPageProvider.select((p) => p.valueOrNull?.pageController)),
            scrollDirection: Axis.horizontal,
            children: const [
              ChartRatePage(),
              ChartTransitionPage(),
            ],
          ),
        ),
      );
    });
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
    final selectExpenseProvider = ref.read(notifierProvider.notifier);

    //hook
    final segmentAnimationController = useAnimationController(
      duration: animationDuration,
      initialValue:
          (chartSegmentState == ChartSegmentState.transitionChart) ? 1 : 0,
    );
    useEffect(() {
      PageController? pageController = ref.watch(
          chartPageProvider.select((p) => p.valueOrNull?.pageController));
      void pageListener() async {
        if (pageController?.page == 0) {
          await segmentAnimationController.reverse();
          ref.read(transitionChartProvider.notifier).setLoadingState(2);
        } else if (pageController?.page == 1) {
          await segmentAnimationController.forward();
          ref.read(transitionChartProvider.notifier).setLoadingState(2);
        }
      }

      pageController?.addListener(pageListener);

      // クリーンアップ: ウィジェットが破棄されるときにリスナーを削除
      return () => pageController?.removeListener(pageListener);
    }, [
      ref.watch(chartPageProvider.select((p) => p.valueOrNull?.pageController)),
      segmentAnimationController
    ]);

    //アニメーション定義
    const Cubic animationCurve = Curves.easeOut;
    final segmentLeftAnimation = ColorTween(
      begin: theme.colorScheme.onPrimary,
      end: theme.colorScheme.outline,
    )
        .chain(CurveTween(curve: animationCurve))
        .animate(segmentAnimationController);

    final segmentRightAnimation = ColorTween(
      begin: theme.colorScheme.outline,
      end: theme.colorScheme.onPrimary,
    )
        .chain(CurveTween(curve: animationCurve))
        .animate(segmentAnimationController);

    //Builder内でuseAnimationを利用できないため、外で定義
    final leftColor = useAnimation(segmentLeftAnimation);
    final rightColor = useAnimation(segmentRightAnimation);

    return Container(
      decoration: BoxDecoration(
        borderRadius: segmentedButtomRadius,
        color: theme.colorScheme.inverseSurface.withValues(alpha: 0.1),
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
                    selectExpenseProvider.changeChartSegmentToRate();
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
                    selectExpenseProvider.changeChartSegmentToTransition();
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
