import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/component/generalized_logic_component.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:household_expenses_project/provider/calendar_page_provider.dart';
import 'package:household_expenses_project/provider/setting_data_provider.dart';
import 'package:household_expenses_project/view/calendar_view/calendar_list_view.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat('yyyy年 M月');
const Duration swipeDuration = Duration(milliseconds: 250);
const Curve swipeCurve = Curves.easeInOutCirc;

const Duration accodionDuration = Duration(milliseconds: 500);

const double calendarHeight = 280;
const double weekHeight = 23 + small;
const double calendarMonthHeight = 45.0 + ssmall * 2;
const double calendarPanelAreaHeight = calendarHeight - weekHeight;
const double itemHeight = calendarPanelAreaHeight / 6;

//-------カレンダーページ---------------------------
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  List<DateTime> calcDateTime(DateTime selectMonth) {
    final lastDateThisMonth =
        DateTime(selectMonth.year, selectMonth.month + 1, 0);
    final firstDateThisMonth = DateTime(selectMonth.year, selectMonth.month, 1);
    final targetList = List<DateTime>.generate(lastDateThisMonth.day,
        (i) => firstDateThisMonth.add(Duration(days: i)));
    return targetList;
  }

  final AsyncNotifierProvider<CalendarPageNotifier, CalendarPageState>
      calendarProvider = calendarPageProvider;

  @override
  Widget build(BuildContext context) {
    final calendarProviderNotifier = ref.read(calendarProvider.notifier);
    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double calendarPanelAreaWidth = screenWidth;

    const double calendarHeightWithoutMonth =
        weekHeight + calendarPanelAreaHeight;

    final double itemWidth = calendarPanelAreaWidth / 7;

    //画面サイズ取得
    double pageHeight = mediaQuery.size.height -
        AppBar().preferredSize.height -
        mediaQuery.padding.bottom -
        MediaQueryData.fromView(View.of(context)).padding.top;

    final weeks = ref.watch(
        settingDataProvider.select((p) => p.value?.weeks ?? defaultWeeks));
    final settingStartWeek = ref.watch(settingDataProvider
        .select((p) => p.value?.calendarStartWeek ?? defaultStartWeek));
    final calendarStartDate = ref.watch(settingDataProvider
        .select((p) => p.value?.startCalendarDate ?? defaultStartCalendarDate));

    final displayMonth = ref.watch(
            calendarProvider.select((p) => p.valueOrNull?.displayMonth)) ??
        DateTime.now();

    //年月WheelListView用パラメータ
    final isShowScrollView = ref.watch(
            calendarProvider.select((p) => p.valueOrNull?.isShowScrollView)) ??
        false;
    final wheelWidth = mediaQuery.size.width / 2 - large;

    //カレンダー表示用
    final isShowAccordion = ref.watch(
            calendarProvider.select((p) => p.valueOrNull?.isShowAccordion)) ??
        true;

    //パネルエリアを返す
    Widget getPanelAreaOfMonth(DateTime month) {
      final int spaceDatePanel =
          (DateTime(month.year, month.month, 1).weekday - settingStartWeek) % 7;
      final lastDay = DateTime(month.year, month.month + 1, 0);
      final int endSpaceDatePanel =
          (settingStartWeek - 1 - lastDay.weekday) % 7 +
              ((spaceDatePanel + lastDay.day) <= 35 ? 7 : 0);
      return Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: <Widget>[
          for (int i = 0; i < spaceDatePanel; i++)
            Container(
              width: itemWidth,
              height: itemHeight,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                border:
                    Border.all(color: theme.colorScheme.outline, width: 0.1),
              ),
            ),
          //日付パネル
          for (final date in calcDateTime(month))
            DatePickerPanel(
              date: date,
              width: itemWidth,
              calendarProvider: calendarProvider,
            ),
          for (int i = 0; i < endSpaceDatePanel; i++)
            Container(
              width: itemWidth,
              height: itemHeight,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                border:
                    Border.all(color: theme.colorScheme.outline, width: 0.1),
              ),
            ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
      height: pageHeight,
      width: mediaQuery.size.width,
      child: Column(
        //逆順(影の描画順序のために逆順としている)
        verticalDirection: VerticalDirection.up,
        children: [
          //リスト表示
          Expanded(
            child: Stack(
              children: [
                Column(
                  verticalDirection: VerticalDirection.up,
                  children: [
                    const Expanded(
                      child: CalendarListView(),
                    ),
                    CalendarMonthSumItem(),
                  ],
                ),
                IgnorePointer(
                  ignoring: !isShowScrollView,
                  child: AnimatedContainer(
                    color: isShowScrollView
                        ? theme.colorScheme.shadow.withOpacity(0.4)
                        : Colors.transparent,
                    duration: const Duration(milliseconds: 200),
                  ),
                ),
              ],
            ),
          ),

          //アコーディオン　カレンダーエリア
          Material(
            elevation: 1.0,
            child: AnimatedContainer(
              curve: Curves.easeInOutCubic,
              duration: accodionDuration,
              color: theme.colorScheme.surfaceBright,
              height: isShowAccordion ? calendarHeightWithoutMonth : 0.0,
              child: AnimatedSwitcher(
                duration: accodionDuration,
                child: isShowScrollView
                    ? //ドラムロールピッカー
                    Row(
                        children: [
                          const SizedBox(width: large),
                          //年
                          SizedBox(
                            width: wheelWidth,
                            height: calendarHeightWithoutMonth,
                            child: ListWheelScrollView(
                              controller: ref.watch(calendarProvider.select(
                                  (p) =>
                                      p.valueOrNull?.listWheelYearController)),
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                HapticFeedback.selectionClick();
                                calendarProviderNotifier.changeDisplayMonth(
                                    DateTime(index + calendarStartDate.year,
                                        displayMonth.month, 1));
                              },
                              itemExtent: calendarHeightWithoutMonth / 8,
                              offAxisFraction: -0.4,
                              overAndUnderCenterOpacity: 0.5,
                              magnification: 1.1,
                              children: [
                                for (int i = 0;
                                    i <=
                                        currentMonth.year -
                                            calendarStartDate.year +
                                            100;
                                    i++)
                                  Container(
                                    alignment: Alignment.centerRight,
                                    height:
                                        theme.textTheme.bodyMedium?.fontSize,
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
                                          ref
                                              .watch(calendarProvider.select(
                                                  (p) => p.valueOrNull
                                                      ?.listWheelYearController))
                                              ?.animateToItem(i,
                                                  duration: swipeDuration,
                                                  curve: swipeCurve);
                                        },
                                        child: Text(
                                          "${calendarStartDate.year + i}年",
                                          textAlign: TextAlign.end,
                                        )),
                                  ),
                              ],
                            ),
                          ),
                          //月
                          SizedBox(
                            width: wheelWidth,
                            height: calendarHeightWithoutMonth,
                            child: ListWheelScrollView(
                              controller: ref.watch(calendarProvider.select(
                                  (p) =>
                                      p.valueOrNull?.listWheelMonthController)),
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                HapticFeedback.selectionClick();
                                calendarProviderNotifier.changeDisplayMonth(
                                    DateTime(displayMonth.year, index + 1, 1));
                              },
                              offAxisFraction: 0.4,
                              itemExtent: calendarHeightWithoutMonth / 8,
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
                                          ref
                                              .watch(calendarProvider.select(
                                                  (p) => p.valueOrNull
                                                      ?.listWheelMonthController))
                                              ?.animateToItem(i,
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

                    //ページビュー（アコーディオンメニューにより高さが可変のため、ScrollViewでラップ）
                    : SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(
                              width: mediaQuery.size.width,
                              height: weekHeight,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  //曜日表示
                                  for (final week in weeks)
                                    Container(
                                      alignment: Alignment.center,
                                      width: itemWidth,
                                      height: weekHeight,
                                      child: Text(
                                        week,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            //Calendarパネル表示
                            SizedBox(
                              width: calendarPanelAreaWidth,
                              height: calendarPanelAreaHeight,
                              child: ref.watch(calendarProvider).whenOrNull(
                                    data: (data) => PageView.builder(
                                      itemCount: (currentMonth.year -
                                              calendarStartDate.year +
                                              101) *
                                          12,
                                      controller: data.pageViewController,
                                      onPageChanged: (page) {
                                        calendarProviderNotifier.setDate(
                                          DateTime(calendarStartDate.year,
                                              1 + page, 1),
                                        );
                                      },
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return getPanelAreaOfMonth(DateTime(
                                            calendarStartDate.year, 1 + index));
                                      },
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//日付パネル
class DatePickerPanel extends HookConsumerWidget {
  final DateTime date;
  final double width;
  final AsyncNotifierProvider<CalendarPageNotifier, CalendarPageState>
      calendarProvider;

  const DatePickerPanel({
    super.key,
    required this.date,
    required this.width,
    required this.calendarProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final panelItemColor = useState<Color>(theme.colorScheme.surfaceBright);
    final calendarPageState = ref.watch(calendarProvider);
    final calendarProviderNotifier = ref.read(calendarProvider.notifier);

    final bool isSelectedDate =
        calendarProviderNotifier.matchSelectedDate(date);

    const double lineHeight = (itemHeight - 4) / 3;

    Map<String, (int?, int?)> registerDaySumMap = ref.watch(
            calendarProvider.select((p) => p.valueOrNull?.registerDaySumMap)) ??
        {};

    return GestureDetector(
      onTap: () => ref
          .read(calendarProvider.notifier)
          .tapCalendarPanel(context, date, ref),
      onTapDown: (_) =>
          {panelItemColor.value = theme.colorScheme.surfaceContainerHighest},
      onTapUp: (_) => {panelItemColor.value = theme.colorScheme.surfaceBright},
      onTapCancel: () =>
          {panelItemColor.value = theme.colorScheme.surfaceBright},
      child: Container(
        alignment: Alignment.center,
        width: width,
        height: itemHeight,
        padding: isSelectedDate
            ? const EdgeInsets.symmetric(vertical: 0.5, horizontal: 1.5)
            : const EdgeInsets.symmetric(vertical: 1.9, horizontal: 2.9),
        decoration: isSelectedDate
            ? BoxDecoration(
                color: Color.lerp(theme.colorScheme.primaryContainer,
                    panelItemColor.value, 0.5),
                border:
                    Border.all(color: theme.colorScheme.primary, width: 1.5),
              )
            : BoxDecoration(
                color: panelItemColor.value,
                border:
                    Border.all(color: theme.colorScheme.outline, width: 0.1),
              ),
        child: Column(
          children: [
            SizedBox(
              height: lineHeight,
              width: width,
              child: Text(
                date.day.toString(),
                textAlign: TextAlign.center,
                style: LogicComponent.matchDates(DateTime.now(), date)
                    ? theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        height: 1.0,
                        fontSize: 12,
                      )
                    : theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.0,
                        fontSize: 12,
                      ),
              ),
            ),
            calendarPageState.maybeWhen(
              skipLoadingOnRefresh: false,
              data: (data) {
                return Column(
                  children: [
                    const SizedBox(height: 1),
                    SizedBox(
                      height: lineHeight - 0.5,
                      width: width,
                      child: Text(
                        LogicComponent.addCommaToNum(
                          int.tryParse(
                              registerDaySumMap["${date.month}${date.day}"]
                                      ?.$1
                                      ?.toString() ??
                                  ""),
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[900],
                          fontSize: 10,
                          height: 1,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: lineHeight - 0.5,
                      width: width,
                      child: Text(
                        LogicComponent.addCommaToNum(
                          int.tryParse(
                              registerDaySumMap["${date.month}${date.day}"]
                                      ?.$2
                                      ?.toString() ??
                                  ""),
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.red[900],
                          fontSize: 10,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                );
              },
              orElse: () {
                return const SizedBox(height: lineHeight * 2);
              },
            ),
          ],
        ),
      ),
    );
  }
}

//
//appbar用ヘッダ（appbarで利用）
class CalendarAppBar extends ConsumerWidget {
  CalendarAppBar({super.key});
  final AsyncNotifierProvider<CalendarPageNotifier, CalendarPageState>
      calendarProvider = calendarPageProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final calendarProviderNotifier = ref.read(calendarProvider.notifier);

    //年月表示
    return ref.watch(calendarProvider).maybeWhen(
          data: (data) => Container(
            padding: ssmallVerticalEdgeInsets,
            height: calendarMonthHeight,
            child: Row(
              children: [
                const Spacer(),
                SizedBox(
                  width: IconTheme.of(context).size ?? 0 + msmall,
                ),
                //ボタン pre
                IconButton(
                    icon: const Icon(Icons.keyboard_arrow_left),
                    iconSize: IconTheme.of(context).size!,
                    color: theme.colorScheme.onSurface,
                    disabledColor: theme.colorScheme.onSurface.withOpacity(0.4),
                    onPressed: (!data.isShowScrollView)
                        ? () {
                            data.pageViewController.previousPage(
                              duration: swipeDuration,
                              curve: swipeCurve,
                            );
                          }
                        : null),
                const SizedBox(width: large),

                //年月ボタン
                ElevatedButton(
                  style: data.isShowScrollView
                      ? ButtonStyle(
                          elevation: WidgetStateProperty.all(1),
                          overlayColor: WidgetStateProperty.all(
                              theme.colorScheme.shadow.withOpacity(0.1)),
                          backgroundColor: WidgetStateProperty.all(Color.lerp(
                              theme.colorScheme.surfaceDim,
                              theme.colorScheme.shadow,
                              0.1)),
                        )
                      : ButtonStyle(
                          elevation: WidgetStateProperty.all(0),
                          overlayColor: WidgetStateProperty.all(
                              theme.colorScheme.shadow.withOpacity(0.1)),
                          backgroundColor: WidgetStateProperty.all(
                            theme.colorScheme.surfaceDim,
                          ),
                        ),
                  onPressed: () {
                    calendarProviderNotifier.tapMonthButton();
                  },
                  child: Text(formatter.format(data.displayMonth),
                      style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface)),
                ),
                const SizedBox(width: large),

                //ボタン after
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_right),
                  iconSize: IconTheme.of(context).size!,
                  color: theme.iconTheme.color,
                  disabledColor: theme.colorScheme.onSurface.withOpacity(0.4),
                  onPressed: (!data.isShowScrollView)
                      ? () {
                          data.pageViewController.nextPage(
                            duration: swipeDuration,
                            curve: swipeCurve,
                          );
                        }
                      : null,
                ),
                const Spacer(),

                //トグルボタン
                GestureDetector(
                  onTap: !data.isShowScrollView
                      ? () {
                          calendarProviderNotifier.tapAccordionButton();
                        }
                      : null,
                  child: Padding(
                    padding: msmallRightEdgeInsets,
                    child: AnimatedRotation(
                      turns: ref.watch(calendarProvider
                              .select((p) => p.valueOrNull?.rotateIconAngle)) ??
                          0,
                      duration: accodionDuration,
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.arrow_drop_down_circle_outlined,
                        size: 27,
                        color: !data.isShowScrollView
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          orElse: () => const SizedBox(),
        );
  }
}
