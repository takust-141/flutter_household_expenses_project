import 'package:flutter/material.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/component/customed_keyboard_component.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:material_symbols_icons/symbols.dart';

class CategoryKeyboardAction {
  CategoryKeyboardAction({
    required this.categoryNameController,
    required this.cateoryIconNotifer,
    required this.categoryIconNode,
    required this.categoryNameNode,
  });

  TextEditingController categoryNameController;
  //customKeyboard用
  final cateoryIconNotifer;
  //FocusNode
  final CustomFocusNode categoryIconNode;
  final CustomFocusNode categoryNameNode;

  KeyboardActionsConfig buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardBarElevation: 1,
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Theme.of(context).scaffoldBackgroundColor,
      nextFocus: true,
      defaultDoneWidget: const KeyboardClosedIcon(),
      actions: [
        KeyboardActionsItem(
          focusNode: categoryNameNode,
        ),
        KeyboardActionsItem(
          focusNode: categoryIconNode,
          keyboardCustom: true,
          footerBuilder: (_) => CategoryIconPickerKeyboard(
            notifier: cateoryIconNotifer,
          ),
        ),
      ],
    );
  }
}

//-----CategoryKeyboard-----
class CategoryIconPickerKeyboard extends StatelessWidget
    with KeyboardCustomPanelMixin<Color>
    implements PreferredSizeWidget {
  @override
  final ValueNotifier<Color> notifier;
  static const double _kKeyboardHeight = 280;

  CategoryIconPickerKeyboard({super.key, required this.notifier});

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
