import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/model/my_app_state.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:material_symbols_icons/symbols.dart';

//-------入力画面------------

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //フォームコントローラー
  final _paymentAmountTextController = TextEditingController();
  final _lastNameTextController = TextEditingController();
  final _usernameTextController = TextEditingController();

  //FocusNode
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText7 = FocusNode();

  //customKeyboard用
  final custom2Notifier = ValueNotifier<Color>(Colors.blue);

  //四則演算
  bool mathFlag = false;

  void inputMath(MathSymbol symbol) {
    String? inputText = _paymentAmountTextController.text;
    if (inputText.isNotEmpty) {
      if (int.tryParse(inputText.substring(inputText.length - 1)) != null) {
        _paymentAmountTextController.text = inputText + symbol.value;
      } else {
        _paymentAmountTextController.text =
            inputText.substring(0, inputText.length - 1) + symbol.value;
      }
    }
  }

  void computeMath() {
    String? inputText = _paymentAmountTextController.text;
    if (inputText.isNotEmpty) {
      if (int.tryParse(inputText.substring(inputText.length - 1)) != null) {
        //記号と数字を分割
        final symbolPattern = RegExp(
            "[${MathSymbol.sum.value}${MathSymbol.diff.value}/${MathSymbol.multiplication.value}]");
        List<int> numList = inputText
            .split(symbolPattern)
            .map((e) => int.parse(e == "" ? "0" : e))
            .toList();
        List<String?> symbolList =
            symbolPattern.allMatches(inputText).map((e) => e.group(0)).toList();

        if (symbolList.isNotEmpty) {
          //掛け算
          while (symbolList.contains(MathSymbol.multiplication.value)) {
            var xIndex = symbolList.indexOf(MathSymbol.multiplication.value);
            numList[xIndex] = numList[xIndex] * numList[xIndex + 1];
            numList.removeAt(xIndex + 1);
            symbolList.removeAt(xIndex);
          }

          //加減算
          for (var i = 0; i < symbolList.length; i++) {
            if (symbolList[i] == MathSymbol.sum.value) {
              numList[0] += numList[i + 1];
            } else {
              numList[0] -= numList[i + 1];
            }
          }

          _paymentAmountTextController.text = numList[0].toString();
        }
      }
    }
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardBarElevation: 1,
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Theme.of(context).primaryColor,
      nextFocus: true,
      defaultDoneWidget: const KeyboardClosedIcon(),
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
          toolbarButtons: [
            (node) => Padding(
                  padding: keyboardInkWellPadding,
                  child: KeyboardGestureDetector(
                    onTapIcon: () => inputMath(MathSymbol.sum),
                    customIcon: const Icon(Symbols.add,
                        weight: 700, size: customIconSize),
                  ),
                ),
            (node) => Padding(
                  padding: keyboardInkWellPadding,
                  child: KeyboardGestureDetector(
                    onTapIcon: () => inputMath(MathSymbol.diff),
                    customIcon: const Icon(Symbols.remove,
                        weight: 700, size: customIconSize),
                  ),
                ),
            (node) => Padding(
                  padding: keyboardInkWellPadding,
                  child: KeyboardGestureDetector(
                    onTapIcon: () => inputMath(MathSymbol.multiplication),
                    customIcon: const Icon(Symbols.close,
                        weight: 700, size: customIconSize),
                  ),
                ),
            (node) => Padding(
                  padding: keyboardInkWellPadding,
                  child: KeyboardGestureDetector(
                    onTapIcon: () => computeMath(),
                    customIcon: const Icon(Symbols.equal,
                        weight: 400, size: customIconSize),
                  ),
                ),
            (node) => Padding(
                  padding: keyboardClosedIconPadding,
                  child: KeyboardGestureDetector(
                    onTapIcon: () => node.unfocus(),
                    customIcon: const KeyboardClosedIcon(),
                  ),
                ),
          ],
        ),
        KeyboardActionsItem(
          focusNode: _nodeText2,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText7,
          footerBuilder: (_) => ColorPickerKeyboard(
            notifier: custom2Notifier,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return KeyboardActions(
      autoScroll: true,
      overscroll: 40,
      tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
      config: _buildConfig(context),
      child: Padding(
        padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
        child: Padding(
          padding: sidePadding,
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //金額（円）
                Padding(
                  padding: smallEdgeInsets,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          focusNode: _nodeText1,
                          controller: _paymentAmountTextController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: '金額',
                            suffixIcon: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  0, sssmall, ssmall, sssmall),
                              child: IconButton(
                                onPressed: () =>
                                    _paymentAmountTextController.clear(),
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
                  child: TextFormField(
                    controller: _lastNameTextController,
                    focusNode: _nodeText2,
                    decoration: const InputDecoration(hintText: 'カテゴリ'),
                  ),
                ),
                Padding(
                  padding: smallEdgeInsets,
                  child: TextFormField(
                    keyboardType: TextInputType.datetime,
                    controller: _usernameTextController,
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
                KeyboardCustomInput<Color>(
                  focusNode: _nodeText7,
                  height: 65,
                  notifier: custom2Notifier,
                  builder: (context, val, hasFocus) {
                    return Container(
                      width: double.maxFinite,
                      color: val ?? Colors.transparent,
                    );
                  },
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
    _paymentAmountTextController.dispose();
    super.dispose();
  }
}

//-----KeyboardGestureDetector-----

class KeyboardGestureDetector extends InkWell {
  KeyboardGestureDetector(
      {super.key,
      //required node,
      required Function onTapIcon,
      required Widget customIcon})
      : super(
          customBorder: const CircleBorder(),
          onTap: () => onTapIcon(),
          child: Padding(
            padding: keyboardCustomIconPadding,
            child: customIcon,
          ),
        );
}

//-----KeyboardClosedIcon-----

class KeyboardClosedIcon extends StatelessWidget {
  const KeyboardClosedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.keyboard, size: keyboardIconSize),
        SizedBox(
          width: keyboardIconSize,
          height: keyboardIconSize - small,
          child: CustomPaint(
            painter: SlashPainter(
                lineColor: IconTheme.of(context).color,
                backgroundColor: Theme.of(context).primaryColor,
                downRight: true),
          ),
        ),
      ],
    );
  }
}

//-----customKeyboard-----
class ColorPickerKeyboard extends StatelessWidget
    with KeyboardCustomPanelMixin<Color>
    implements PreferredSizeWidget {
  final ValueNotifier<Color> notifier;
  static const double _kKeyboardHeight = 200;

  ColorPickerKeyboard({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final double rows = 3;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = screenWidth / 5;
    final double itemHeight = _kKeyboardHeight / 2;

    return Container(
      height: _kKeyboardHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            for (final color in Colors.primaries)
              GestureDetector(
                onTap: () {
                  updateValue(color);
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: itemWidth,
                        height: itemHeight,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(color: Colors.black),
                        ),
                      ),
                      Container(
                        width: itemWidth,
                        height: itemHeight,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(_kKeyboardHeight);
}

//-----SegmentedButton-----

enum SelectExpenses { outgo, income }

class SelectExpensesButton extends StatefulWidget {
  const SelectExpensesButton({super.key});

  @override
  State<SelectExpensesButton> createState() => _SelectExpensesButtonState();
}

class _SelectExpensesButtonState extends State<SelectExpensesButton> {
  SelectExpenses selectedExpenses = SelectExpenses.outgo;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SelectExpenses>(
      segments: const <ButtonSegment<SelectExpenses>>[
        ButtonSegment<SelectExpenses>(
          value: SelectExpenses.outgo,
          label: Text(labelOutgo),
          //icon: Icon(Icons.calendar_view_day)
        ),
        ButtonSegment<SelectExpenses>(
          value: SelectExpenses.income,
          label: Text(labelIncome),
          //icon: Icon(Icons.calendar_view_week)
        ),
      ],
      selected: <SelectExpenses>{selectedExpenses},
      onSelectionChanged: (Set<SelectExpenses> newSelection) {
        setState(() {
          selectedExpenses = newSelection.first;
        });
      },
      showSelectedIcon: false,
      style: segmentedButtonStyle,
    );
  }
}
