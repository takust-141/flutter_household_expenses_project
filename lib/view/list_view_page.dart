import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:household_expenses_project/provider/app_bar_provider.dart';

//-------ページ１（ホーム）---------------------------
class ListViewPage extends StatelessWidget {
  ListViewPage({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
          physics: null,
          controller: _scrollController,
          child: Column(
            children: [
              TextField(),
              SizedBox(height: 500),
              TextFormField(),
              SizedBox(height: 500),
            ],
          )),
    );
  }
}
