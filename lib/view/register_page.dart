import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/model/my_app_state.dart';
import 'package:household_expenses_project/component/customed_keyboard.dart';

//-------入力画面------------

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return KeyboardActions(
      keepFocusOnTappingNode: true,
      autoScroll: true,
      overscroll: 40,
      tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
      config: buildConfig(context),
      child: Padding(
        padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
        child: Padding(
          padding: sidePadding,
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //金額
                Padding(
                  padding: smallEdgeInsets,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          focusNode: paymentAmountNode,
                          controller: paymentAmountTextController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: '金額',
                            suffixIcon: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  0, sssmall, ssmall, sssmall),
                              child: IconButton(
                                onPressed: () =>
                                    paymentAmountTextController.clear(),
                                icon: const Icon(Icons.cancel),
                                iconSize: 20,
                              ),
                            ),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20),
                            FilteringTextInputFormatter.allow(
                              RegExp(
                                  "[0-9${MathSymbol.sum.value}${MathSymbol.diff.value}${MathSymbol.multiplication.value}]"),
                            ),
                          ],
                          style:
                              const TextStyle(fontSize: 20, letterSpacing: 1.5),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: medium),
                        child:
                            Text(currencyUnit, style: TextStyle(fontSize: 25)),
                      ),
                    ],
                  ),
                ),
                //カテゴリ
                Padding(
                  padding: smallEdgeInsets,
                  child: KeyboardCustomInput<Color>(
                    focusNode: categoryNode,
                    height: 65,
                    notifier: cateoryNotifer,
                    builder: (context, val, hasFocus) {
                      return Container(
                        width: double.maxFinite,
                        color: val ?? Colors.transparent,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: smallEdgeInsets,
                  child: TextFormField(
                    keyboardType: TextInputType.datetime,
                    controller: subCategoryController,
                    focusNode: subCategoryNode,
                    decoration: const InputDecoration(hintText: 'サブカテゴリ'),
                  ),
                ),
                SizedBox(height: 120),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : theme.colorScheme.onPrimary;
                    }),
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : theme.colorScheme.primary;
                    }),
                  ),
                  onPressed: null,
                  child: const Text('送信'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    paymentAmountTextController.dispose();
    subCategoryController.dispose();
    super.dispose();
  }
}
