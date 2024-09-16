import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/provider/preferences_service.dart';
import 'package:household_expenses_project/provider/setting_data_provider.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

//-----DatePickerKeyboard-----
class DatePickerKeyboard extends StatefulHookConsumerWidget
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
  ConsumerState<DatePickerKeyboard> createState() => _DatePickerKeyboardState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(DatePickerKeyboard._kKeyboardHeight);
}

class _DatePickerKeyboardState extends ConsumerState<DatePickerKeyboard> {
  final formatter = DateFormat('yyyy年 M月');
  final Duration swipeDuration = const Duration(milliseconds: 250);
  final Curve swipeCurve = Curves.easeInOutCirc;
  final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<DateTime> calcDateTime(DateTime selectMonth) {
    final lastDateThisMonth =
        DateTime(selectMonth.year, selectMonth.month + 1, 0);
    final firstDateThisMonth = DateTime(selectMonth.year, selectMonth.month, 1);
    final targetList = List<DateTime>.generate(lastDateThisMonth.day,
        (i) => firstDateThisMonth.add(Duration(days: i)));
    return targetList;
  }

  late PageController _pageViewController;
  late FixedExtentScrollController _listWheelYearController;
  late FixedExtentScrollController _listWheelMonthController;

  int calcDiffMonthIndex(DateTime? targetMonth) {
    return 1200 +
        (((targetMonth?.year ?? 0) - currentMonth.year) * 12) +
        (targetMonth?.month ?? 0) -
        currentMonth.month;
  }

  @override
  void initState() {
    super.initState();
    _pageViewController =
        PageController(initialPage: calcDiffMonthIndex(widget.notifier.value));
    _listWheelYearController = FixedExtentScrollController();
    _listWheelMonthController = FixedExtentScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double keyboardContainerHeight =
        DatePickerKeyboard._kKeyboardHeight - mediaQuery.viewPadding.bottom;
    final double keyboardPanelAreaHeight =
        keyboardContainerHeight - keyboardMonthHeight - weekHeight;
    final double keyboardPanelAreaWidth = mediaQuery.size.width - (small * 2);

    final double itemWidth = (screenWidth - (small * 2)) / 7;
    final double itemHeight = keyboardPanelAreaHeight / 6;

    final weeks = ref.watch(settingDataProvider.select((value) => value.weeks));
    final isSelectedWeek = ref
        .watch(settingDataProvider.select((value) => value.calendarStartWeek));

    final viewMonth = useState<DateTime>(widget.notifier.value ?? currentMonth);

    //年月WheelListView用パラメータ
    final ValueNotifier<bool> showScrollView = useState(false);
    final wheelWidth = mediaQuery.size.width / 2 - small - large;

    //パネルエリアを返す
    Widget getPanelAreaOfMonth(DateTime month) {
      int spaceWeek =
          (DateTime(month.year, month.month, 1).weekday - isSelectedWeek) % 7;
      int endSpaceWeek =
          (isSelectedWeek - DateTime(month.year, month.month + 1, 0).weekday) %
              7;
      return Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: <Widget>[
          for (int i = 0; i < spaceWeek; i++)
            SizedBox(
              width: itemWidth - 1,
              height: itemHeight,
            ),
          for (final date in calcDateTime(month))
            DatePickerKeyboardPanel(
              date: date,
              onTap: () => widget.updateValue(date),
              width: itemWidth,
              height: itemHeight,
              notifier: widget.notifier,
            ),
          for (int i = 0; i < endSpaceWeek; i++)
            SizedBox(
              width: itemWidth - 1,
              height: itemHeight,
            ),
        ],
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        height: keyboardContainerHeight,
        padding: smallHorizontalEdgeInsets,
        width: mediaQuery.size.width,
        child: Column(
          children: [
            //年月表示
            SizedBox(
              height: keyboardMonthHeight,
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.keyboard_arrow_left),
                      iconSize: IconTheme.of(context).size!,
                      color: IconTheme.of(context).color,
                      disabledColor: Theme.of(context).disabledColor,
                      onPressed: (!showScrollView.value)
                          ? () {
                              _pageViewController.previousPage(
                                duration: swipeDuration,
                                curve: swipeCurve,
                              );
                            }
                          : null),
                  const SizedBox(width: large),
                  //年月ボタン
                  TextButton(
                    style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(
                          theme.colorScheme.shadow.withOpacity(0.1)),
                    ),
                    onPressed: () {
                      if (!showScrollView.value) {
                        _listWheelYearController = FixedExtentScrollController(
                            initialItem:
                                viewMonth.value.year - currentMonth.year + 100);
                        _listWheelMonthController = FixedExtentScrollController(
                            initialItem: viewMonth.value.month - 1);
                      } else {
                        _pageViewController = PageController(
                            initialPage: calcDiffMonthIndex(viewMonth.value));
                      }
                      showScrollView.value = !showScrollView.value;
                    },
                    child: Text(formatter.format(viewMonth.value),
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: large),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_right),
                    iconSize: IconTheme.of(context).size!,
                    color: IconTheme.of(context).color,
                    disabledColor: Theme.of(context).disabledColor,
                    onPressed: (!showScrollView.value)
                        ? () {
                            _pageViewController.nextPage(
                              duration: swipeDuration,
                              curve: swipeCurve,
                            );
                          }
                        : null,
                  ),
                  const Spacer(),
                ],
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: showScrollView.value
                  ? //ドラムロールピッカー
                  Row(
                      children: [
                        const SizedBox(width: large),
                        //年
                        SizedBox(
                          width: wheelWidth,
                          height: weekHeight + keyboardPanelAreaHeight,
                          child: ListWheelScrollView(
                            controller: _listWheelYearController,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              HapticFeedback.selectionClick();
                              viewMonth.value = DateTime(
                                  index - 100 + currentMonth.year,
                                  viewMonth.value.month);
                            },
                            itemExtent:
                                (weekHeight + keyboardPanelAreaHeight) / 8,
                            offAxisFraction: -0.4,
                            overAndUnderCenterOpacity: 0.5,
                            magnification: 1.1,
                            children: [
                              for (int i = 0; i <= 200; i++)
                                Container(
                                  alignment: Alignment.centerRight,
                                  height: theme.textTheme.bodyMedium?.fontSize,
                                  width: wheelWidth,
                                  child: TextButton(
                                      style: ButtonStyle(
                                        overlayColor: WidgetStateProperty.all(
                                            theme.colorScheme.shadow
                                                .withOpacity(0.1)),
                                        splashFactory: NoSplash.splashFactory,
                                        foregroundColor:
                                            WidgetStateProperty.all(
                                                theme.colorScheme.onSurface),
                                      ),
                                      onPressed: () {
                                        _listWheelYearController.animateToItem(
                                            i,
                                            duration: swipeDuration,
                                            curve: swipeCurve);
                                      },
                                      child: Text(
                                        "${currentMonth.year + i - 100}年",
                                        textAlign: TextAlign.end,
                                      )),
                                ),
                            ],
                          ),
                        ),
                        //月
                        SizedBox(
                          width: wheelWidth,
                          height: weekHeight + keyboardPanelAreaHeight,
                          child: ListWheelScrollView(
                            controller: _listWheelMonthController,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              HapticFeedback.selectionClick();
                              viewMonth.value =
                                  DateTime(viewMonth.value.year, index + 1);
                            },
                            offAxisFraction: 0.4,
                            itemExtent:
                                (weekHeight + keyboardPanelAreaHeight) / 8,
                            overAndUnderCenterOpacity: 0.5,
                            magnification: 1.1,
                            useMagnifier: true,
                            children: [
                              for (int i = 0; i < 12; i++)
                                Container(
                                  alignment: Alignment.centerLeft,
                                  height: 13,
                                  width: wheelWidth,
                                  child: TextButton(
                                      style: ButtonStyle(
                                        overlayColor: WidgetStateProperty.all(
                                            theme.colorScheme.shadow
                                                .withOpacity(0.1)),
                                        foregroundColor:
                                            WidgetStateProperty.all(
                                                theme.colorScheme.onSurface),
                                      ),
                                      onPressed: () {
                                        _listWheelMonthController.animateToItem(
                                            i,
                                            duration: swipeDuration,
                                            curve: swipeCurve);
                                      },
                                      child: Text("${i + 1}月",
                                          textAlign: TextAlign.start)),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: large),
                      ],
                    )
                  //ページビュー
                  : Column(
                      children: [
                        SizedBox(
                          width: mediaQuery.size.width - (small * 2),
                          height: weekHeight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //曜日表示
                              for (final week in weeks)
                                Container(
                                  alignment: Alignment.center,
                                  width: itemWidth - 1,
                                  height: weekHeight,
                                  child: Text(
                                    week,
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        //Day表示
                        SizedBox(
                          width: keyboardPanelAreaWidth,
                          height: keyboardPanelAreaHeight,
                          child: PageView.builder(
                            itemCount: 2400,
                            controller: _pageViewController,
                            onPageChanged: (page) {
                              viewMonth.value = DateTime(currentMonth.year,
                                  currentMonth.month + (page - 1200));
                            },
                            itemBuilder: (BuildContext context, int index) {
                              return getPanelAreaOfMonth(DateTime(
                                  currentMonth.year,
                                  currentMonth.month + (index - 1200)));
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
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
  late double length;
  late EdgeInsets edgeInsetsRadius;
  @override
  void initState() {
    super.initState();
    if (widget.width < widget.height) {
      length = widget.width;
      edgeInsetsRadius = EdgeInsets.symmetric(
          horizontal: sssmall,
          vertical: sssmall + (widget.height - length) / 2);
    } else {
      length = widget.height;
      edgeInsetsRadius = EdgeInsets.symmetric(
          horizontal: sssmall + (widget.width - length) / 2, vertical: sssmall);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: widget.notifier,
      builder: (context, _) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            alignment: Alignment.center,
            width: length - (sssmall * 2) - 1,
            height: length - sssmall * 2,
            margin: edgeInsetsRadius,
            padding: isSameDay(widget.notifier.value, widget.date)
                ? null
                : const EdgeInsets.all(2),
            decoration: isSameDay(widget.notifier.value, widget.date)
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: theme.colorScheme.primary, width: 2),
                  )
                : const BoxDecoration(shape: BoxShape.circle),
            child: Text(widget.date.day.toString(),
                style: isSameDay(widget.date, DateTime.now())
                    ? theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        height: 1.0,
                        fontSize: length / 2.3,
                      )
                    : theme.textTheme.bodyLarge?.copyWith(
                        height: 1.0,
                        fontSize: length / 2.3,
                      )),
          ),
        );
      },
    );
  }

  bool isSameDay(DateTime? day1, DateTime? day2) {
    if (day1 == null || day2 == null) {
      return false;
    }
    if (day1.year == day2.year &&
        day1.month == day2.month &&
        day1.day == day2.day) {
      return true;
    }
    return false;
  }
}
