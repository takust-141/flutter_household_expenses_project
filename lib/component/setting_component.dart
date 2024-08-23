import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:household_expenses_project/constant/config.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:material_symbols_icons/symbols.dart';

class SettingListItem extends HookWidget {
  final String setText;
  final Function onTapRoute;
  const SettingListItem(
      {required this.setText, required this.onTapRoute, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listItemColor = useState<Color>(theme.colorScheme.surfaceBright);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTapRoute(),
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
            Padding(
              padding: ssmallLeftEdgeInsets,
              child: Text(setText),
            ),
            const Spacer(),
            Icon(Symbols.chevron_right,
                weight: 300,
                size: 25,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
