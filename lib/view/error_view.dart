import 'package:flutter/material.dart';
import 'package:household_expenses_project/constant/string.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: Center(child: Text(dbError)));
  }
}
