import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:household_expenses_project/component/customed_setting_keyboard.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:household_expenses_project/constant/constant.dart';

//-------カテゴリ編集ページ---------------------------
class CategoryEditPage extends StatefulWidget {
  final bool addNewCategory;
  CategoryEditPage({
    super.key,
    this.addNewCategory = false,
  });

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  //デフォルト
  static const defaultIcon = Symbols.home;
  static const defaultColor = Colors.blue;
  //フォームコントローラー
  TextEditingController categoryNameController = TextEditingController();
  //customKeyboard用
  final cateoryIconNotifer = ValueNotifier<IconData>(defaultIcon);
  final cateoryColorNotifer = ValueNotifier<Color>(defaultColor);
  //FocusNode
  final CustomFocusNode categoryNameNode = CustomFocusNode();
  final CustomFocusNode categoryIconNode = CustomFocusNode();
  final CustomFocusNode categoryColorNode = CustomFocusNode();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final CategoryKeyboardAction categoryKeyboardAction =
        CategoryKeyboardAction(
      categoryNameController: categoryNameController,
      cateoryIconNotifer: cateoryIconNotifer,
      cateoryColorNotifer: cateoryColorNotifer,
      categoryNameNode: categoryNameNode,
      categoryIconNode: categoryIconNode,
      categoryColorNode: categoryColorNode,
    );

    return Container(
      color: theme.colorScheme.surfaceContainer,
      child: KeyboardActions(
        keepFocusOnTappingNode: true,
        autoScroll: true,
        overscroll: 10,
        tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
        config: categoryKeyboardAction.buildConfig(context),
        child: Padding(
          padding: EdgeInsets.only(bottom: medium),
          child: Padding(
            padding: viewEdgeInsets,
            child: Column(
              children: [
                //-----カテゴリカード表示-----
                ValueListenableBuilder(
                  valueListenable: cateoryColorNotifer,
                  builder: (context, color, _) {
                    return Container(
                      width: categoryCardHeight,
                      height: categoryCardWidth,
                      padding: smallEdgeInsets,
                      margin: mediumEdgeInsets,
                      decoration: BoxDecoration(
                        border: Border.all(color: color, width: 3),
                        borderRadius: BorderRadius.circular(small),
                      ),
                      child: Column(
                        children: [
                          ValueListenableBuilder(
                            valueListenable: cateoryIconNotifer,
                            builder: (BuildContext context, iconData, _) {
                              return Icon(
                                iconData,
                                color: color,
                                size: 60,
                                weight: 300,
                              );
                            },
                          ),
                          const Spacer(),
                          ValueListenableBuilder(
                            valueListenable: categoryNameController,
                            builder: (BuildContext context, value, _) {
                              return Text(
                                categoryNameController.text,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 13,
                                ),
                              );
                            },
                          ),
                          const Spacer(),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: medium),

                //-----フォーム-----
                Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //カテゴリ名
                      CategoryEditItem(
                        categoryName: "カテゴリ名",
                        inputWidget: CustomTextFormField(
                          focusNode: categoryNameNode,
                          inputWidgetHPaddding: small,
                          inputWidgetHeight: formItemHeight - 4,
                          child: TextFormField(
                            autofocus: false,
                            focusNode: categoryNameNode,
                            keyboardType: TextInputType.text,
                            controller: categoryNameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: smallHorizontalEdgeInsets,
                            ),
                          ),
                        ),
                      ),

                      //アイコン
                      CategoryEditItem(
                        categoryName: "アイコン",
                        inputWidget: KeyboardCustomInput<IconData>(
                          focusNode: categoryIconNode,
                          notifier: cateoryIconNotifer,
                          builder: (context, val, hasFocus) {
                            return Icon(val, size: 30);
                          },
                        ),
                      ),

                      //色
                      CategoryEditItem(
                        categoryName: "カラー",
                        inputWidget: KeyboardCustomInput<Color>(
                          focusNode: categoryColorNode,
                          notifier: cateoryColorNotifer,
                          builder: (context, val, hasFocus) {
                            return Container(
                              decoration: BoxDecoration(
                                color: val,
                                borderRadius: formInputInnerBoarderRadius,
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 120),
                      TextButton(
                        style: ButtonStyle(
                          foregroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            return states.contains(WidgetState.disabled)
                                ? null
                                : theme.colorScheme.onPrimary;
                          }),
                          backgroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            return states.contains(WidgetState.disabled)
                                ? null
                                : theme.colorScheme.primary;
                          }),
                        ),
                        onPressed: () => context.pop(),
                        child: const Text('送信'),
                      ),
                    ],
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
    categoryNameController.dispose();
    super.dispose();
  }
}

//カテゴリカード
class CategoryCard extends StatelessWidget {
  final String categoryName;
  final Color color;
  final IconData iconData;
  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.color,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(small),
      ),
      padding: smallEdgeInsets,
      child: Column(
        children: [
          Icon(
            iconData,
            color: color,
          ),
          Text(
            categoryName,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}

//カテゴリEdit Item
class CategoryEditItem extends HookWidget {
  final CustomFocusNode? focusNode;
  final Widget inputWidget;
  final String categoryName;
  const CategoryEditItem({
    super.key,
    required this.inputWidget,
    required this.categoryName,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFocusState = useState<bool>(false);

    return Container(
      margin: mediumEdgeInsets,
      height: formItemHeight,
      child: Row(
        children: [
          SizedBox(
            width: formItemNameWidth,
            child: Text(categoryName, textAlign: TextAlign.center),
          ),
          const SizedBox(width: medium),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: formInputBoarderRadius,
                border: hasFocusState.value
                    ? Border.all(
                        color: theme.colorScheme.primary,
                        width: formInputBoarderWidth)
                    : Border.all(
                        color: Colors.transparent,
                        width: formInputBoarderWidth),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: formInputBoarderRadius,
                  color: theme.colorScheme.surfaceBright,
                ),
                height: formItemHeight,
                child: Focus(
                  focusNode: focusNode,
                  child: inputWidget,
                  onFocusChange: (hasFocus) {
                    hasFocusState.value = hasFocus;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
