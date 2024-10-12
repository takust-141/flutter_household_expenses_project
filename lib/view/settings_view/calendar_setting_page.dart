import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/provider/preferences_service.dart';
import 'package:household_expenses_project/provider/setting_data_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

const Map<int, String> weeks = {
  DateTime.monday: '月曜日',
  DateTime.tuesday: '火曜日',
  DateTime.wednesday: '水曜日',
  DateTime.thursday: '木曜日',
  DateTime.friday: '金曜日',
  DateTime.saturday: '土曜日',
  DateTime.sunday: '日曜日',
};

//-------カレンダー設定ページ---------------------------
class CalendarSettingPage extends StatelessWidget {
  const CalendarSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var goRoute = GoRouter.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainer,
      child: ListView(
        padding: viewEdgeInsets,
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(containreBorderRadius),
            ),
            child: const Column(
              children: [
                StartOfWeek(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StartOfWeek extends StatefulHookConsumerWidget {
  const StartOfWeek({super.key});

  @override
  ConsumerState<StartOfWeek> createState() => _StartOfWeekState();
}

class _StartOfWeekState extends ConsumerState<StartOfWeek> {
  final FocusNode _startOfWeekFocusNode = FocusNode();
  final MenuController _menuController = MenuController();

  @override
  void dispose() {
    _startOfWeekFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelectedWeek = useState(DateTime.sunday);
    final listItemColor = useState<Color>(theme.colorScheme.surfaceBright);

    //初期値セット
    useEffect(() {
      PreferencesService.getStartOfWeek().then((value) {
        isSelectedWeek.value = value;
      });
      return null;
    }, []);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_menuController.isOpen) {
          _menuController.close();
        } else {
          _menuController.open();
        }
      },
      onTapDown: (_) =>
          {listItemColor.value = theme.colorScheme.surfaceContainerHighest},
      onTapUp: (_) => {listItemColor.value = theme.colorScheme.surfaceBright},
      onTapCancel: () =>
          {listItemColor.value = theme.colorScheme.surfaceBright},
      child: AnimatedContainer(
        color: listItemColor.value,
        duration: listItemAnimationDuration,
        height: listHeight,
        padding: smallEdgeInsets,
        child: Row(
          children: [
            const Padding(
              padding: ssmallLeftEdgeInsets,
              child: Text("週の開始曜日"),
            ),
            const Spacer(),
            MenuAnchor(
              alignmentOffset: const Offset(sssmall, small),
              style: MenuStyle(
                padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
              ),
              controller: _menuController,
              childFocusNode: _startOfWeekFocusNode,
              menuChildren: [
                for (int week in weeks.keys)
                  MenuItemButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            theme.colorScheme.surfaceBright)),
                    onPressed: () {
                      isSelectedWeek.value = week;
                      ref
                          .read(settingDataProvider.notifier)
                          .updateStartOfWeek(week);
                    },
                    child: Text(
                      weeks[week]!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
              ],
              builder: (_, MenuController controller, Widget? child) {
                return Row(
                  children: [
                    Padding(
                      padding: mediumHorizontalEdgeInsets,
                      child: Text(weeks[isSelectedWeek.value]!),
                    ),
                    Icon(Symbols.unfold_more,
                        weight: 300,
                        size: 25,
                        color: theme.colorScheme.onSurfaceVariant),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
