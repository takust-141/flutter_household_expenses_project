import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/component/generalized_logic_component.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:household_expenses_project/provider/calendar_page_provider.dart';
import 'package:household_expenses_project/provider/chart_page_provider/rate_chart_provider.dart';

//リストアイテム
class RateChartListItem extends HookConsumerWidget {
  final String text;
  final Color color;
  final int amount;
  final double rate;
  final int? index;
  const RateChartListItem(
      {required this.text,
      required this.color,
      required this.amount,
      required this.rate,
      this.index,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final listItemColor = useState<Color>(theme.colorScheme.surfaceBright);
    final listItemIconBackColor =
        useState<Color>(theme.colorScheme.surfaceBright);
    final rateChartNotifier = ref.read(rateChartProvider.notifier);

    const double listItemHeight = 50;

    String roundSecondToString(double num) {
      final double calcNum = (num * 100).round() / 100;
      return (calcNum == 0) ? "0.00%以下" : "$calcNum%";
    }

    return Container(
      height: listItemHeight,
      padding: const EdgeInsets.only(bottom: small),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: (index != null)
                  ? () => {
                        rateChartNotifier
                            .setSelectRateChartStateFromGlaph(index!)
                      }
                  : null,
              onTapDown: (_) => {
                listItemColor.value = theme.colorScheme.surfaceContainerHighest
              },
              onTapUp: (_) =>
                  {listItemColor.value = theme.colorScheme.surfaceBright},
              onTapCancel: () =>
                  {listItemColor.value = theme.colorScheme.surfaceBright},
              child: Material(
                clipBehavior: Clip.antiAlias,
                elevation: 1.0,
                color: listItemColor.value,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    Container(
                      margin: colorContainerMargin,
                      height: colorContainerHeight,
                      width: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: color,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            0, ssmall, ssmall, ssmall),
                        child: AutoSizeText(
                          text,
                          textAlign: TextAlign.start,
                          minFontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: AutoSizeText(
                        "${LogicComponent.addCommaToNum(amount)}円",
                        maxLines: 2,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.visible,
                        minFontSize: 10,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: AutoSizeText(
                        roundSecondToString(rate),
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.visible,
                        minFontSize: 10,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    ),
                    const SizedBox(width: small),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: small),

          //推移チャート移動ボタン
          SizedBox(
            width: theme.iconTheme.size ?? 24 + small,
            height: listItemHeight - small,
            child: GestureDetector(
              onTap: null, //推移移動
              onTapDown: (_) => {
                listItemIconBackColor.value =
                    theme.colorScheme.surfaceContainerHighest
              },
              onTapUp: (_) => {
                listItemIconBackColor.value = theme.colorScheme.surfaceBright
              },
              onTapCancel: () => {
                listItemIconBackColor.value = theme.colorScheme.surfaceBright
              },
              child: Material(
                clipBehavior: Clip.antiAlias,
                elevation: 1.0,
                color: listItemIconBackColor.value,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.keyboard_arrow_right,
                  color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
