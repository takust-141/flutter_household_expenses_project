import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:household_expenses_project/component/customed_setting_keyboard.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:household_expenses_project/constant/constant.dart';

//-------カテゴリ編集ページ---------------------------
class CategoryEditPage extends StatefulWidget {
  CategoryEditPage({super.key});

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

    return KeyboardActions(
      keepFocusOnTappingNode: true,
      autoScroll: true,
      overscroll: 40,
      tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
      config: categoryKeyboardAction.buildConfig(context),
      child: Padding(
        padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
        child: Padding(
          padding: smallEdgeInsets,
          child: Column(
            children: [
              ValueListenableBuilder(
                valueListenable: cateoryColorNotifer,
                builder: (context, color, _) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: color, width: 2),
                      borderRadius: BorderRadius.circular(small),
                    ),
                    padding: smallEdgeInsets,
                    child: Column(
                      children: [
                        ValueListenableBuilder(
                          valueListenable: cateoryIconNotifer,
                          builder: (BuildContext context, iconData, _) {
                            return Icon(
                              iconData,
                              color: color,
                            );
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: categoryNameController,
                          builder: (BuildContext context, value, _) {
                            return Text(
                              categoryNameController.text,
                              style: TextStyle(color: color),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //カテゴリ名
                    Padding(
                      padding: smallEdgeInsets,
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: categoryNameController,
                        focusNode: categoryNameNode,
                        decoration: const InputDecoration(hintText: 'カテゴリ名'),
                      ),
                    ),
                    //アイコン
                    Padding(
                      padding: smallEdgeInsets,
                      child: KeyboardCustomInput<IconData>(
                        focusNode: categoryIconNode,
                        height: 65,
                        notifier: cateoryIconNotifer,
                        builder: (context, val, hasFocus) {
                          return Row(
                            children: [
                              Container(
                                padding: mediumEdgeInsets,
                                width: 100,
                                alignment: Alignment.centerRight,
                                child: Text("アイコン"),
                              ),
                              Container(
                                width: 100,
                                child: Icon(val),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    //色
                    Padding(
                      padding: smallEdgeInsets,
                      child: KeyboardCustomInput<Color>(
                        focusNode: categoryColorNode,
                        height: 65,
                        notifier: cateoryColorNotifer,
                        builder: (context, val, hasFocus) {
                          return Row(
                            children: [
                              Container(
                                width: 100,
                                padding: mediumEdgeInsets,
                                alignment: Alignment.centerRight,
                                child: const Text("color"),
                              ),
                              Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  color: val ?? Colors.transparent,
                                  borderRadius: BorderRadius.circular(small),
                                ),
                              ),
                            ],
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
