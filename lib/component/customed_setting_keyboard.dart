import 'package:flutter/material.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/constant/keyboard_components.dart';
import 'package:household_expenses_project/component/customed_keyboard_component.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class CategoryKeyboardAction {
  CategoryKeyboardAction({
    required this.categoryNameController,
    required this.cateoryIconNotifer,
    required this.cateoryColorNotifer,
    required this.categoryNameNode,
    required this.categoryIconNode,
    required this.categoryColorNode,
  });

  TextEditingController categoryNameController;
  //customKeyboard用
  final cateoryIconNotifer;
  final cateoryColorNotifer;
  //FocusNode
  final CustomFocusNode categoryNameNode;
  final CustomFocusNode categoryIconNode;
  final CustomFocusNode categoryColorNode;

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
          focusNode: categoryNameNode,
        ),
        KeyboardActionsItem(
          focusNode: categoryIconNode,
          keyboardCustom: true,
          footerBuilder: (_) => CategoryIconPickerKeyboard(
            notifier: cateoryIconNotifer,
          ),
        ),
        KeyboardActionsItem(
          focusNode: categoryColorNode,
          keyboardCustom: true,
          footerBuilder: (_) => CategoryColorPickerKeyboard(
            notifier: cateoryColorNotifer,
          ),
        ),
      ],
    );
  }
}

//-----アイコンキーボード-----
class CategoryIconPickerKeyboard extends StatelessWidget
    with KeyboardCustomPanelMixin<IconData>
    implements PreferredSizeWidget {
  @override
  final ValueNotifier<IconData> notifier;
  static const double _kKeyboardHeight = 280;

  CategoryIconPickerKeyboard({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double keyboardAreaWidth = screenWidth - small;
    final double keyboardAreaHeight =
        _kKeyboardHeight - mediaQuery.viewPadding.bottom - small;
    final double itemWidth = keyboardAreaWidth / 5;
    final double itemHeight = keyboardAreaHeight / 4;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: _kKeyboardHeight - mediaQuery.viewPadding.bottom,
        child: SingleChildScrollView(
          child: Wrap(
            children: <Widget>[
              for (var keyboardIcon in keyboardIcons)
                IconKeyboardButton(
                  onTap: () => updateValue(keyboardIcon),
                  itemWidth: itemWidth,
                  itemHeight: itemHeight,
                  itemIcon: keyboardIcon,
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

// アイコンキーボード用ボタン
class IconKeyboardButton extends StatefulWidget {
  final VoidCallback onTap;
  final double itemWidth;
  final double itemHeight;
  final IconData itemIcon;
  final ValueNotifier<IconData> notifier;

  const IconKeyboardButton({
    super.key,
    required this.onTap,
    required this.itemWidth,
    required this.itemHeight,
    required this.itemIcon,
    required this.notifier,
  });
  @override
  State<IconKeyboardButton> createState() => _IconKeyboardButtonState();
}

class _IconKeyboardButtonState extends State<IconKeyboardButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: ssmallEdgeInsets,
      width: widget.itemWidth,
      height: widget.itemHeight,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: widget.notifier,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                border: widget.notifier.value == widget.itemIcon
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(small),
              ),
              child: Icon(widget.itemIcon),
            );
          },
        ),
      ),
    );
  }
}

//-----カラーキーボード-----
class CategoryColorPickerKeyboard extends StatelessWidget
    with KeyboardCustomPanelMixin<Color>
    implements PreferredSizeWidget {
  @override
  final ValueNotifier<Color> notifier;
  static const double _kKeyboardHeight = 260;

  CategoryColorPickerKeyboard({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double keyboardAreaWidth = screenWidth - small;
    final double keyboardAreaHeight =
        _kKeyboardHeight - mediaQuery.viewPadding.bottom - small;
    final double itemWidth = keyboardAreaWidth / 5;
    final double itemHeight = keyboardAreaHeight / 4;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: _kKeyboardHeight - mediaQuery.viewPadding.bottom,
        child: Column(
          children: [
            Padding(
              padding: ssmallEdgeInsets,
              child: SizedBox(
                height: keyboardAreaHeight,
                child: Wrap(
                  children: <Widget>[
                    for (var i = 0; i < keyboardColors.length; i++)
                      ColorKeyboardButton(
                        onTap: () => updateValue(keyboardColors[i]),
                        itemWidth: itemWidth,
                        itemHeight: itemHeight,
                        itemColor: keyboardColors[i],
                        notifier: notifier,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_kKeyboardHeight);
}

// カラーキーボード用ボタン
class ColorKeyboardButton extends StatefulWidget {
  final VoidCallback onTap;
  final double itemWidth;
  final double itemHeight;
  final Color itemColor;
  final ValueNotifier<Color> notifier;

  const ColorKeyboardButton({
    super.key,
    required this.onTap,
    required this.itemWidth,
    required this.itemHeight,
    required this.itemColor,
    required this.notifier,
  });
  @override
  State<ColorKeyboardButton> createState() => _ColorKeyboardButtonState();
}

class _ColorKeyboardButtonState extends State<ColorKeyboardButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: ssmallEdgeInsets,
      width: widget.itemWidth,
      height: widget.itemHeight,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: widget.notifier,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                color: widget.itemColor,
                border: widget.notifier.value == widget.itemColor
                    ? Border.all(color: theme.colorScheme.primary, width: 3)
                    : null,
                borderRadius: BorderRadius.circular(small),
              ),
            );
          },
        ),
      ),
    );
  }
}
