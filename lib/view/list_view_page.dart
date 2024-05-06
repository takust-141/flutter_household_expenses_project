import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:household_expenses_project/model/my_app_state.dart';

//-------ページ１（ホーム）---------------------------
class ListViewPage extends StatelessWidget {
  ListViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    return Center();
  }
}
