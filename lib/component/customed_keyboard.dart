import 'package:flutter/material.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:material_symbols_icons/symbols.dart';

//フォームコントローラー
final paymentAmountTextController = TextEditingController();
//final categoryController = TextEditingController();
final subCategoryController = TextEditingController();
//customKeyboard用
final cateoryNotifer = ValueNotifier<Color>(Colors.blue);

//FocusNode
final ComputeFocusNode paymentAmountNode = ComputeFocusNode();
final CustomFocusNode categoryNode = CustomFocusNode();
final CustomFocusNode subCategoryNode = CustomFocusNode();

//四則演算
bool mathFlag = false;

KeyboardActionsConfig buildConfig(BuildContext context) {
  return KeyboardActionsConfig(
    keyboardBarElevation: 1,
    keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
    keyboardBarColor: Theme.of(context).primaryColor,
    nextFocus: true,
    defaultDoneWidget: const KeyboardClosedIcon(),
    actions: [
      KeyboardActionsItem(
        focusNode: paymentAmountNode,
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
                  onTapIcon: () => inputMath(MathSymbol.division),
                  customIcon: const DividedIcon(),
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
        focusNode: categoryNode,
        keyboardCustom: true,
        footerBuilder: (_) => CategoryPickerKeyboard(
          notifier: cateoryNotifer,
        ),
      ),
      KeyboardActionsItem(
        focusNode: subCategoryNode,
      ),
    ],
  );
}

class ComputeFocusNode extends CustomFocusNode {
  @override
  void unfocus({UnfocusDisposition disposition = UnfocusDisposition.scope}) {
    computeMath();
    super.unfocus();
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

//-----DividedIcon-----
class DividedIcon extends StatelessWidget {
  const DividedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.center,
      children: [
        Icon(Symbols.remove, weight: 700, size: customIconSize),
        Icon(Symbols.go_to_line, weight: 700, size: customIconSize),
      ],
    );
  }
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

void inputMath(MathSymbol symbol) {
  String? inputText = paymentAmountTextController.text;
  if (inputText.isNotEmpty) {
    if (int.tryParse(inputText.substring(inputText.length - 1)) != null) {
      paymentAmountTextController.text = inputText + symbol.value;
    } else {
      paymentAmountTextController.text =
          inputText.substring(0, inputText.length - 1) + symbol.value;
    }
  }
}

void computeMath() {
  String? inputText = paymentAmountTextController.text;
  if (inputText.isNotEmpty) {
    if (int.tryParse(inputText.substring(inputText.length - 1)) != null) {
      //記号と数字を分割
      final symbolPattern = RegExp(
          "[${MathSymbol.diff.value}${MathSymbol.sum.value}/${MathSymbol.multiplication.value}${MathSymbol.division.value}]");
      List<double> numList = inputText
          .split(symbolPattern)
          .map((e) => double.parse(e == "" ? "0" : e))
          .toList();
      List<String?> symbolList =
          symbolPattern.allMatches(inputText).map((e) => e.group(0)).toList();

      if (symbolList.isNotEmpty) {
        //掛割算
        var multIndex = symbolList.indexOf(MathSymbol.multiplication.value);
        var divIndex = symbolList.indexOf(MathSymbol.division.value);
        while (multIndex > -1 || divIndex > -1) {
          if (multIndex > -1
              ? (divIndex > -1 ? multIndex < divIndex : true)
              : false) {
            numList[multIndex] = numList[multIndex] * numList[multIndex + 1];
            numList.removeAt(multIndex + 1);
            symbolList.removeAt(multIndex);
            multIndex = symbolList.indexOf(MathSymbol.multiplication.value);
          } else {
            numList[divIndex] = numList[divIndex] / numList[divIndex + 1];
            numList.removeAt(divIndex + 1);
            symbolList.removeAt(divIndex);
            divIndex = symbolList.indexOf(MathSymbol.division.value);
          }
        }

        //加減算
        for (var i = 0; i < symbolList.length; i++) {
          if (symbolList[i] == MathSymbol.sum.value) {
            numList[0] += numList[i + 1];
          } else {
            numList[0] -= numList[i + 1];
          }
        }

        paymentAmountTextController.text = numList[0].toString();
      }
    } else {
      paymentAmountTextController.text =
          inputText.substring(0, inputText.length - 1);
    }
  }
}

//-----CategoryKeyboard-----
class CategoryPickerKeyboard extends StatelessWidget
    with KeyboardCustomPanelMixin<Color>
    implements PreferredSizeWidget {
  @override
  final ValueNotifier<Color> notifier;
  static const double _kKeyboardHeight = 280;

  CategoryPickerKeyboard({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = screenWidth / 5;
    final double itemHeight =
        (_kKeyboardHeight - mediaQuery.viewPadding.bottom) / 2;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: _kKeyboardHeight - mediaQuery.viewPadding.bottom,
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
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_kKeyboardHeight);
}
