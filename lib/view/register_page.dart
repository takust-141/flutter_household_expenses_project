import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/component/customed_register_keyboard.dart';

//-------入力画面------------
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //フォームコントローラー
  final TextEditingController paymentAmountTextController =
      TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();

  //customKeyboard用
  final cateoryNotifer = ValueNotifier<Color>(Colors.blue);

  //FocusNode
  final CustomFocusNode paymentAmountNode = CustomFocusNode();
  final CustomFocusNode categoryNode = CustomFocusNode();
  final CustomFocusNode subCategoryNode = CustomFocusNode();
  final CustomFocusNode sampleNode = CustomFocusNode();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    RegisterKeyboardAction registerKeyboardAction = RegisterKeyboardAction(
      paymentAmountTextController: paymentAmountTextController,
      subCategoryController: subCategoryController,
      cateoryNotifer: cateoryNotifer,
      paymentAmountNode: paymentAmountNode,
      categoryNode: categoryNode,
      subCategoryNode: subCategoryNode,
    );

    return KeyboardActions(
      keepFocusOnTappingNode: true,
      autoScroll: true,
      overscroll: 40,
      tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
      config: registerKeyboardAction.buildConfig(context),
      child: Padding(
        padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
        child: Padding(
          padding: viewEdgeInsets,
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //金額
                Row(
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
                                "[0-9.${MathSymbol.sum.value}${MathSymbol.diff.value}${MathSymbol.multiplication.value}${MathSymbol.division.value}]"),
                          ),
                        ],
                        style:
                            const TextStyle(fontSize: 20, letterSpacing: 1.5),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: medium),
                      child: Text(currencyUnit, style: TextStyle(fontSize: 25)),
                    ),
                  ],
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
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.disabled)
                          ? null
                          : theme.colorScheme.onPrimary;
                    }),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.disabled)
                          ? null
                          : theme.colorScheme.primary;
                    }),
                  ),
                  onPressed: (null),
                  child: const Text('送信'),
                ),
                TextFormField(
                  focusNode: sampleNode,
                ),

                Container(
                  width: 100,
                  height: 100,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: Colors.red,
                  ),
                  alignment: Alignment.topLeft,
                  child: Container(
                    alignment: Alignment.topLeft,
                    height: 30,
                    width: 200,
                    color: Colors.blue,
                    child: Container(
                      height: 200,
                      width: 70,
                      color: Colors.yellow,
                    ),
                  ),
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
