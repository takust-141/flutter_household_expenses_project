import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/provider/calendar_page_provider.dart';
import 'package:provider/provider.dart';
import 'package:household_expenses_project/provider/app_bar_provider.dart';

//-------チャートページ---------------------------
class ChartPage extends ConsumerWidget {
  ChartPage({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    debugPrint("${ref.watch(calendarPageProvider).isLoading}");
    debugPrint("${ref.watch(calendarPageProvider).valueOrNull?.selectDate}");

    return Center(
      child: SingleChildScrollView(
          physics: null,
          controller: _scrollController,
          child: Column(
            children: [
              TextField(),
              ref.watch(calendarPageProvider).maybeWhen(
                    skipLoadingOnRefresh: false,
                    data: (data) => Text("date"),
                    orElse: () => Text("else"),
                  ),
              SizedBox(height: 500),
              TextFormField(),
              SizedBox(height: 500),
            ],
          )),
    );
  }
}
