import 'package:flutter/material.dart';
import 'package:household_expense_project/constant/constant.dart';
import 'package:material_symbols_icons/symbols.dart';

//-----KeyboardGestureDetector-----
class KeyboardGestureDetector extends InkWell {
  KeyboardGestureDetector(
      {super.key,
      bool isCircle = true,
      required Function onTapIcon,
      required Widget customIcon})
      : super(
          customBorder: isCircle
              ? const CircleBorder()
              : const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
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
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                downRight: true),
          ),
        ),
      ],
    );
  }
}
