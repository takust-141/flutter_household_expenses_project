import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/view/chart_view/chart_transition_view/chart_transition_figure.dart';
import 'package:household_expense_project/view/chart_view/chart_transition_view/chart_transition_selector.dart';

//-------チャートページ---------------------------
class ChartTransitionPage extends ConsumerWidget {
  const ChartTransitionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: large),
        Padding(
          padding: mediumHorizontalEdgeInsets,
          child: ChartTransitionSelector(),
        ),
        SizedBox(height: medium),
        Divider(height: 1),
        SizedBox(height: medium),
        ChartTransitionFigure(),
      ],
    );
  }
}
