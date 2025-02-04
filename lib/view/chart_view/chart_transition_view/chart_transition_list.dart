import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/custom_register_list_view/custom_register_list.dart';
import 'package:household_expense_project/model/register.dart';
import 'package:household_expense_project/provider/chart_page_provider/transition_chart_provider.dart';

class ChartTransitionList extends ConsumerWidget {
  const ChartTransitionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //riverpod
    final TransitionChartState? transitionChartState =
        ref.watch(transitionChartProvider).valueOrNull;
    final List<Register> registerList = (!(transitionChartState == null ||
            (transitionChartState.selectRodDataIndex >
                transitionChartState.transitionChartGroupDataList.length) ||
            (transitionChartState.selectBarGroupIndex >
                transitionChartState
                    .transitionChartGroupDataList[
                        transitionChartState.selectRodDataIndex]
                    .transitionRegistersList
                    .length)))
        ? transitionChartState
            .transitionChartGroupDataList[
                transitionChartState.selectRodDataIndex]
            .transitionRegistersList[transitionChartState.selectBarGroupIndex]
        : [];

    return SafeArea(
      child: CustomRegisterList(
        registerList: registerList,
        isDisplayYear: true,
        registerEditProvider: transitionChartProvider,
      ),
    );
  }
}
