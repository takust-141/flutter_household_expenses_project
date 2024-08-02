import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/component/customed_keyboard_component.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/view_model/category_db_provider.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:material_symbols_icons/symbols.dart';

class RegisterKeyboardAction {
  RegisterKeyboardAction({
    required this.moneyTextController,
    required this.moneyNode,
    required this.cateoryNotifer,
    required this.subCateoryNotifer,
    required this.categoryNode,
    required this.subCategoryNode,
  });

  //フォームコントローラー
  final TextEditingController moneyTextController;
  //customKeyboard用
  final ValueNotifier<Category?> cateoryNotifer;
  final ValueNotifier<Category?> subCateoryNotifer;
  //FocusNode
  final CustomFocusNode moneyNode;
  final CustomFocusNode categoryNode;
  final CustomFocusNode subCategoryNode;

  //四則演算
  bool mathFlag = false;

  KeyboardActionsConfig buildConfig(BuildContext context) {
    moneyNode.addListener(() {
      if (!moneyNode.hasFocus) {
        computeMath();
      }
    });

    return KeyboardActionsConfig(
      keyboardBarElevation: 1,
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Theme.of(context).scaffoldBackgroundColor,
      keyboardSeparatorColor: Theme.of(context).scaffoldBackgroundColor,
      nextFocus: true,
      defaultDoneWidget: const KeyboardClosedIcon(),
      actions: [
        KeyboardActionsItem(
          focusNode: moneyNode,
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
            subNotifier: subCateoryNotifer,
          ),
        ),
        KeyboardActionsItem(
          focusNode: subCategoryNode,
          keyboardCustom: true,
          footerBuilder: (_) => CategoryPickerKeyboard(
            notifier: subCateoryNotifer,
            sub: true,
          ),
        ),
      ],
    );
  }

  void inputMath(MathSymbol symbol) {
    String? inputText = moneyTextController.text;
    if (inputText.isNotEmpty) {
      if (int.tryParse(inputText.substring(inputText.length - 1)) != null) {
        moneyTextController.text = inputText + symbol.value;
      } else {
        moneyTextController.text =
            inputText.substring(0, inputText.length - 1) + symbol.value;
      }
    }
  }

  void computeMath() {
    String? inputText = moneyTextController.text;
    bool errorFlag = false;
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
              if (numList[divIndex + 1] == 0) {
                errorFlag = true;
                break;
              }
              numList[divIndex] = numList[divIndex] / numList[divIndex + 1];
              numList.removeAt(divIndex + 1);
              symbolList.removeAt(divIndex);
              divIndex = symbolList.indexOf(MathSymbol.division.value);
            }
          }

          if (errorFlag) {
            numList[0] = 0;
          } else {
            //加減算
            for (var i = 0; i < symbolList.length; i++) {
              if (symbolList[i] == MathSymbol.sum.value) {
                numList[0] += numList[i + 1];
              } else {
                numList[0] -= numList[i + 1];
              }
            }
          }

          moneyTextController.text = numList[0].round().toString();
        }
      } else {
        moneyTextController.text = inputText.substring(0, inputText.length - 1);
      }
    }
  }
}

//-----CategoryKeyboard-----
class CategoryPickerKeyboard extends ConsumerWidget
    with KeyboardCustomPanelMixin<Category?>
    implements PreferredSizeWidget {
  @override
  final ValueNotifier<Category?> notifier;
  static const double _kKeyboardHeight = 280;
  final bool sub;
  final ValueNotifier<Category?>? subNotifier;

  CategoryPickerKeyboard({
    super.key,
    required this.notifier,
    this.sub = false,
    this.subNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = (screenWidth - (small * 2)) / 3;
    final double itemHeight =
        (_kKeyboardHeight - mediaQuery.viewPadding.bottom) / 3;
    final AsyncValue<List<Category>> categoryListProvider;
    if (sub) {
      categoryListProvider = ref.watch(subCategorListNotifierProvider);
    } else {
      categoryListProvider = ref.watch(categorListNotifierProvider);
    }

    return SafeArea(
      top: false,
      child: Container(
        height: _kKeyboardHeight - mediaQuery.viewPadding.bottom,
        padding: smallHorizontalEdgeInsets,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Wrap(
            children: <Widget>[
              sub
                  ? CategoryKeyboardPanel(
                      category: null,
                      onTap: () => updateValue(null),
                      width: itemWidth,
                      height: itemHeight,
                      notifier: notifier,
                    )
                  : const SizedBox(),
              if (categoryListProvider.value != null &&
                  categoryListProvider.value!.isNotEmpty)
                for (final category in categoryListProvider.value!)
                  CategoryKeyboardPanel(
                    category: category,
                    onTap: sub
                        ? () => updateValue(category)
                        : () {
                            updateValue(category);
                            ref
                                .read(selectCategoryNotifierProvider.notifier)
                                .updateCategory(category);
                            subNotifier?.value = null;
                          },
                    width: itemWidth,
                    height: itemHeight,
                    notifier: notifier,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_kKeyboardHeight);
}

//カテゴリーキーボードパネル
class CategoryKeyboardPanel extends StatefulWidget {
  final Category? category;
  final double width;
  final double height;
  final VoidCallback onTap;
  final ValueNotifier<Category?> notifier;

  const CategoryKeyboardPanel({
    super.key,
    required this.category,
    required this.height,
    required this.width,
    required this.onTap,
    required this.notifier,
  });

  @override
  State<CategoryKeyboardPanel> createState() => _CategoryKeyboardPanelState();
}

class _CategoryKeyboardPanelState extends State<CategoryKeyboardPanel> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
        animation: widget.notifier,
        builder: (context, _) {
          return Container(
            width: widget.width - ssmall * 2,
            height: widget.height - ssmall * 2,
            margin: ssmallEdgeInsets,
            padding: widget.notifier.value == widget.category
                ? smallEdgeInsets
                : const EdgeInsets.all(small + 1),
            decoration: BoxDecoration(
              border: widget.notifier.value == widget.category
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.8),
                      width: 1),
              //color: theme.colorScheme.surfaceContainer.withOpacity(0.7),
              borderRadius: BorderRadius.circular(small),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              child: (widget.category != null)
                  ? Column(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Icon(
                              widget.category!.icon,
                              color: widget.category!.color,
                              weight: 400,
                            ),
                          ),
                        ),
                        Text(
                          widget.category!.name,
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        "サブカテゴリー\nなし",
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          );
        });
  }
}
