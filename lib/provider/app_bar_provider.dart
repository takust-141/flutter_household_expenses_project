import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/component/segmented_button.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:material_symbols_icons/symbols.dart';

//Provider
final appBarProvider = StateNotifierProvider<AppBarStateNotifier, AppBarState?>(
    (ref) => AppBarStateNotifier(null));

final needAppBarAnimationProvider = StateProvider<bool>((ref) => false);

//状態管理
@immutable
class AppBarState {
  final String name;
  final String? appBarTitle;
  final bool appBarBack;
  final bool needBottomBar;
  const AppBarState({
    required this.name,
    this.appBarTitle,
    required this.appBarBack,
    this.needBottomBar = true,
  });

  Widget? getAppBarBackWidget() {
    if (appBarBack == true) {
      return const AppBarBackWidget();
    }
    return null;
  }

  Widget? getAppBarTitleWidget(TextStyle? fontStyle) {
    if (name == 'register') {
      return const SelectExpensesButton();
    }

    if (appBarTitle != null) {
      return Text(
        appBarTitle!,
        style: fontStyle,
        key: ValueKey<String?>(appBarTitle),
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return null;
    }
  }
}

//ここで値を変化させるメソッドを定義
class AppBarStateNotifier extends StateNotifier<AppBarState?> {
  AppBarStateNotifier(super.state);

  void setAppBar(String? routeName) {
    state = AppBarStateCollection.getAppBarState(routeName);
  }
}

class AppBarStateCollection {
  static const List<AppBarState> appBarStateStateList = [
    AppBarState(name: 'register', appBarTitle: null, appBarBack: false),
    AppBarState(name: 'category_list', appBarTitle: 'カテゴリー', appBarBack: true),
    AppBarState(
        name: 'category_edit',
        appBarTitle: '日用品（後で変数にする）あああああああ',
        appBarBack: true,
        needBottomBar: false),
  ];

  static AppBarState? getAppBarState(String? name) {
    if (name != null) {
      for (var appBarState in appBarStateStateList) {
        if (appBarState.name == name) {
          return appBarState;
        }
      }
    }
    return null;
  }
}

class AppBarBackWidget extends HookWidget {
  const AppBarBackWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backIconColor = useState<Color>(theme.colorScheme.onSurface);

    return GestureDetector(
      child: AnimatedContainer(
        duration: listItemAnimationDuration,
        child: Icon(
          color: backIconColor.value,
          Symbols.chevron_left,
          weight: 300,
          size: 40,
        ),
      ),
      onTap: () => context.pop(),
      onTapDown: (_) => {backIconColor.value = theme.colorScheme.outline},
      onTapUp: (_) => {backIconColor.value = theme.colorScheme.onSurface},
      onTapCancel: () => {backIconColor.value = theme.colorScheme.onSurface},
    );
  }
}
