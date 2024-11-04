import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:household_expenses_project/provider/chart_page_provider/rate_chart_provider.dart';

//-------チャートページ---------------------------
class ChartTransitionPage extends ConsumerWidget {
  const ChartTransitionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        child: Text("transition"),
      ),
    );
  }
}
