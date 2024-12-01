import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/component/custom_date_picker.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/component/customed_keyboard_component.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/provider/category_list_provider.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:auto_size_text/auto_size_text.dart';

class RegisterKeyboardAction {
  RegisterKeyboardAction({
    required this.moneyTextController,
    required this.memoTextController,
    required this.moneyNode,
    required this.categoryNode,
    required this.subCategoryNode,
    required this.memoNode,
    required this.dateNode,
    required this.categoryNotifier,
    required this.subCategoryNotifier,
    required this.dateNotifier,
    required this.enableNewAdd,
    required this.provider,
  });

  //フォームコントローラー
  final TextEditingController moneyTextController;
  final TextEditingController memoTextController;
  //customKeyboard用
  final ValueNotifier<Category?> categoryNotifier;
  final ValueNotifier<Category?> subCategoryNotifier;
  final ValueNotifier<DateTime?> dateNotifier;
  //FocusNode
  final CustomFocusNode moneyNode;
  final CustomFocusNode categoryNode;
  final CustomFocusNode subCategoryNode;
  final CustomFocusNode memoNode;
  final CustomFocusNode dateNode;

  final bool enableNewAdd;

  final NotifierProvider<SelectCategoryStateNotifier, SelectCategoryState>
      provider;

  //四則演算
  bool mathFlag = false;

  //アンフォーカス時のリスナー
  void focusChange() {
    if (!moneyNode.hasFocus) {
      computeMath();
    }
  }

  KeyboardActionsConfig buildConfig(BuildContext context) {
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
            notifier: categoryNotifier,
            enableNewAdd: enableNewAdd,
            provider: provider,
          ),
        ),
        KeyboardActionsItem(
          focusNode: subCategoryNode,
          keyboardCustom: true,
          footerBuilder: (_) => CategoryPickerKeyboard(
            notifier: subCategoryNotifier,
            sub: true,
            enableNewAdd: enableNewAdd,
            parentNotifier: categoryNotifier,
            provider: provider,
          ),
        ),
        KeyboardActionsItem(
          focusNode: memoNode,
        ),
        KeyboardActionsItem(
          focusNode: dateNode,
          keyboardCustom: true,
          footerBuilder: (_) => DatePickerKeyboard(
            notifier: dateNotifier,
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
      if (int.tryParse(inputText.substring(inputText.length - 1)) == null) {
        inputText = inputText.substring(0, inputText.length - 1);
      }
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
        while (0 <= multIndex || 0 <= divIndex) {
          if (0 <= multIndex
              ? (0 <= divIndex ? multIndex < divIndex : true)
              : false) {
            //掛け算
            numList[multIndex] = numList[multIndex] * numList[multIndex + 1];
            numList.removeAt(multIndex + 1);
            symbolList.removeAt(multIndex);
            multIndex = symbolList.indexOf(MathSymbol.multiplication.value);
            divIndex = symbolList.indexOf(MathSymbol.division.value);
          } else {
            //割り算
            if (numList[divIndex + 1] == 0) {
              errorFlag = true;
              break;
            }
            numList[divIndex] = numList[divIndex] / numList[divIndex + 1];
            numList.removeAt(divIndex + 1);
            symbolList.removeAt(divIndex);
            multIndex = symbolList.indexOf(MathSymbol.multiplication.value);
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
      } else {
        moneyTextController.text = (int.tryParse(inputText) ?? 0).toString();
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
  final bool enableNewAdd;
  final ValueNotifier<Category?>? parentNotifier;
  final NotifierProvider<SelectCategoryStateNotifier, SelectCategoryState>
      provider;

  CategoryPickerKeyboard({
    super.key,
    required this.notifier,
    this.sub = false,
    required this.enableNewAdd,
    this.parentNotifier,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = (screenWidth - (small * 2)) / 3;
    final double itemHeight =
        (_kKeyboardHeight - mediaQuery.viewPadding.bottom) / 3;

    final List<Category> categoryList;
    late final bool isParentCategoryNull;

    if (sub) {
      categoryList = ref.watch(provider.select((p) => p.subCategoryList)) ?? [];
      isParentCategoryNull =
          ref.watch(provider.select((p) => p.category)) != null;
    } else {
      categoryList = ref.watch(categoryListNotifierProvider).valueOrNull?[
              ref.watch(provider.select((p) => p.selectExpenses))] ??
          [];
      isParentCategoryNull = true;
    }

    final selectCategoryStateProvider = ref.read(provider.notifier);

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
                      onTap: () {
                        selectCategoryStateProvider
                            .updateSelectSubCategory(null);
                      },
                      width: itemWidth,
                      height: itemHeight,
                      notifier: notifier,
                    )
                  : const SizedBox(),
              for (final category in categoryList)
                CategoryKeyboardPanel(
                  category: category,
                  onTap: sub
                      ? () {
                          selectCategoryStateProvider
                              .updateSelectSubCategory(category);
                        }
                      : () {
                          if (category != notifier.value) {
                            selectCategoryStateProvider
                                .updateSelectParentCategory(category);
                          }
                        },
                  width: itemWidth,
                  height: itemHeight,
                  notifier: notifier,
                ),
              if (isParentCategoryNull && enableNewAdd)
                //新規 カテゴリー
                AddCategoryKeyboardPanel(
                  category: null,
                  sub: sub,
                  width: itemWidth,
                  height: itemHeight,
                  notifier: notifier,
                  provider: provider,
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
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: Container(
              width: widget.width - ssmall * 2,
              height: widget.height - ssmall * 2,
              margin: ssmallEdgeInsets,
              padding: widget.notifier.value?.id == widget.category?.id
                  ? smallEdgeInsets
                  : const EdgeInsets.all(small + 1),
              decoration: BoxDecoration(
                border: widget.notifier.value?.id == widget.category?.id
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.8),
                        width: 1),
                borderRadius: BorderRadius.circular(small),
              ),
              child: (widget.category != null)
                  ? Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: FittedBox(
                            child: Icon(
                              widget.category!.icon,
                              color: widget.category!.color,
                              weight: 400,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: AutoSizeText(
                              widget.category!.name,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              minFontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "サブカテゴリー\nなし",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
            ),
          );
        });
  }
}

//カテゴリー新規追加
class AddCategoryKeyboardPanel extends HookConsumerWidget {
  final Category? category;
  final double width;
  final double height;
  final bool sub;
  final ValueNotifier<Category?> notifier;
  final NotifierProvider<SelectCategoryStateNotifier, SelectCategoryState>
      provider;

  const AddCategoryKeyboardPanel({
    super.key,
    required this.category,
    required this.height,
    required this.width,
    required this.sub,
    required this.notifier,
    required this.provider,
  });

  //registerページからカテゴリー新規追加時
  void goAddCategoryView(
      GoRouter goRoute,
      bool sub,
      WidgetRef ref,
      NotifierProvider<SelectCategoryStateNotifier, SelectCategoryState>
          provider,
      BuildContext context) {
    FocusScope.of(context).unfocus();
    if (sub) {
      ref.read(provider.notifier).setNextInitState(sub);
      goRoute.push('/setting/category_list/category_edit/sub_category_edit',
          extra: provider);
    } else {
      ref.read(provider.notifier).setNextInitState(sub);
      goRoute.push('/setting/category_list/category_edit', extra: provider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final panelBoarder = useState<bool>(false);
    final GoRouter goRoute = GoRouter.of(context);

    return AnimatedBuilder(
        animation: notifier,
        builder: (context, _) {
          return Container(
            width: width - ssmall * 2,
            height: height - ssmall * 2,
            margin: ssmallEdgeInsets,
            padding: notifier.value == category
                ? smallEdgeInsets
                : const EdgeInsets.all(small + 1),
            decoration: BoxDecoration(
              border: panelBoarder.value
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.8),
                      width: 1),
              borderRadius: BorderRadius.circular(small),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  goAddCategoryView(goRoute, sub, ref, provider, context),
              onTapDown: (_) => panelBoarder.value = true,
              onTapUp: (_) => panelBoarder.value = false,
              onTapCancel: () => panelBoarder.value = false,
              child: (category != null)
                  ? Column(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Icon(
                              category!.icon,
                              color: category!.color,
                              weight: 400,
                            ),
                          ),
                        ),
                        Text(
                          category!.name,
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                  : const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "新規追加",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
            ),
          );
        });
  }
}
