import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:household_expenses_project/provider/chart_page_provider/transition_chart_provider.dart';
import 'package:household_expenses_project/view/chart_view/chart_transition_view/chart_transition_figure.dart';
import 'package:household_expenses_project/view/chart_view/chart_transition_view/chart_transition_selector.dart';

//-------チャートページ---------------------------
class ChartTransitionPage extends ConsumerWidget {
  const ChartTransitionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Column(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: large),
            const Padding(
              padding: mediumHorizontalEdgeInsets,
              child: ChartTransitionSelector(),
            ),
            const SizedBox(height: medium),
            const Divider(height: 1),
            const SizedBox(height: medium),
            if (ref.watch(transitionChartProvider).isRefreshing) ...{
              const Padding(
                padding: largeEdgeInsets,
                child: SizedBox(
                  height: 35,
                  width: 35,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            } else ...{
              const ChartTransitionFigure(),
            }

            //ChartRateDateSelector(),
            //SizedBox(height: ssmall),
          ],
        ),
      ],
    );
  }
}
