import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

final DateTime startDay = DateTime(2023, 1, 1);
final DateTime endDay = DateTime(2026, 12, 31);

List<DateTime> getDaysInRange(DateTime startDay, DateTime endDay) {
  List<DateTime> days = [];
  DateTime current = startDay;
  while (current.isBefore(startDay) || current.isAtSameMomentAs(endDay)) {
    days.add(current);
    current = DateTime(current.year, current.month, current.day + 1);
  }
  return days;
}

//-----DatePickerKeyboard-----
class DatePickerKeyboard extends ConsumerWidget
    with KeyboardCustomPanelMixin<DateTime?>
    implements PreferredSizeWidget {
  @override
  final ValueNotifier<DateTime?> notifier;
  static const double _kKeyboardHeight = 350;

  DatePickerKeyboard({
    super.key,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = (screenWidth - (small * 2)) / 7;
    final double itemHeight =
        (_kKeyboardHeight - mediaQuery.viewPadding.bottom) / 5;

    return SafeArea(
      top: false,
      child: Container(
        height: _kKeyboardHeight - mediaQuery.viewPadding.bottom,
        padding: smallHorizontalEdgeInsets,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Wrap(
            children: <Widget>[
              for (final date in getDaysInRange(startDay, endDay))
                DatePickerKeyboardPanel(
                  date: date,
                  onTap: () => updateValue(date),
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

//日付ピッカーキーボードパネル
class DatePickerKeyboardPanel extends StatefulWidget {
  final DateTime date;
  final double width;
  final double height;
  final VoidCallback onTap;
  final ValueNotifier<DateTime?> notifier;

  const DatePickerKeyboardPanel({
    super.key,
    required this.date,
    required this.height,
    required this.width,
    required this.onTap,
    required this.notifier,
  });

  @override
  State<DatePickerKeyboardPanel> createState() => _CategoryKeyboardPanelState();
}

class _CategoryKeyboardPanelState extends State<DatePickerKeyboardPanel> {
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
            padding: widget.notifier.value == widget.date
                ? smallEdgeInsets
                : const EdgeInsets.all(small + 1),
            decoration: BoxDecoration(
              border: widget.notifier.value == widget.date
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.8),
                      width: 1),
              borderRadius: BorderRadius.circular(small),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              child: Container(
                padding: ssmallEdgeInsets,
                child: Text(widget.date.day.toString()),
              ),
            ),
          );
        });
  }
}
