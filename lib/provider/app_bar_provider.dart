import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/component/segmented_button.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/view/calendar_view/calendar_page.dart';
import 'package:household_expenses_project/view/chart_view/chart_page.dart';
import 'package:household_expenses_project/view/search_view/search_page.dart';
import 'package:material_symbols_icons/symbols.dart';

const rootNameRegister = 'register';
const rootNameCalendar = 'calendar';
const rootNameChart = 'chart';
const rootNameSearch = 'search';
const rootNameSetting = 'setting';
const rootNameCategoryList = 'category_list';
const rootNameCategoryEdit = 'category_edit';
const rootNameSubCategoryEdit = 'sub_category_edit';
const rootNameCalendarSetting = 'calendar_setting';

const List<AppBarState> appBarStateStateList = [
  AppBarState(name: rootNameRegister, appBarTitle: null, appBarBack: false),
  AppBarState(
    name: rootNameCalendar,
    appBarBack: false,
    appBarSideWidth: 0,
  ),
  AppBarState(
    name: rootNameChart,
    appBarBack: false,
    appBarSideWidth: 0,
  ),
  AppBarState(
    name: rootNameSearch,
    appBarBack: false,
    appBarSideWidth: 0,
  ),
  AppBarState(
      name: rootNameCategoryList, appBarTitle: 'カテゴリー', appBarBack: true),
  AppBarState(
      name: rootNameCalendarSetting, appBarTitle: 'カレンダー設定', appBarBack: true),
  AppBarState(
    name: rootNameCategoryEdit,
    appBarTitle: null,
    needBottomBar: false,
    cancelAndDo: true,
    appBarSideWidth: 100,
  ),
  AppBarState(
    name: rootNameSubCategoryEdit,
    appBarTitle: null,
    needBottomBar: false,
    cancelAndDo: true,
    appBarSideWidth: 100,
  ),
];

//Provider
final appBarProvider =
    NotifierProvider<AppBarNotifier, AppBarState>(AppBarNotifier.new);

const double _defauldAppBarSideWidth = 56;

//状態管理
@immutable
class AppBarState {
  final String name;
  final String? appBarTitle;
  final bool appBarBack;
  final bool cancelAndDo;
  final bool needBottomBar;
  final double appBarSideWidth;
  final bool isActiveCategoryDoneButton;
  const AppBarState({
    required this.name,
    this.appBarTitle,
    this.appBarBack = false,
    this.needBottomBar = true,
    this.cancelAndDo = false,
    this.appBarSideWidth = _defauldAppBarSideWidth,
    this.isActiveCategoryDoneButton = false,
  });

  AppBarState copyWith({String? name}) {
    return AppBarState(
      name: name ?? this.name,
      appBarTitle: appBarTitle,
      appBarBack: appBarBack,
      cancelAndDo: cancelAndDo,
      needBottomBar: needBottomBar,
      appBarSideWidth: appBarSideWidth,
      isActiveCategoryDoneButton: isActiveCategoryDoneButton,
    );
  }

  AppBarState copyWithCategoryDoneButton(bool isActive) {
    return AppBarState(
      name: name,
      appBarTitle: appBarTitle,
      appBarBack: appBarBack,
      cancelAndDo: cancelAndDo,
      needBottomBar: needBottomBar,
      appBarSideWidth: appBarSideWidth,
      isActiveCategoryDoneButton: isActive,
    );
  }
}

//Notifier
class AppBarNotifier extends Notifier<AppBarState> {
  @override
  AppBarState build() {
    return const AppBarState(name: '');
  }

  void setAppBar(String? routeName) {
    if (state.name != routeName) {
      var newState = const AppBarState(name: '');
      for (AppBarState appBarState in appBarStateStateList) {
        if (appBarState.name == routeName) {
          newState = appBarState;
        }
      }
      state = newState;

      //カテゴリー編集の時、完了ボタン判定
      if (state.name == rootNameCategoryEdit) {
        updateActiveCategoryDoneButton(ref
            .read(
                settingCategoryStateNotifierProvider.select((p) => p.category))
            ?.name);
      }
      if (state.name == rootNameSubCategoryEdit) {
        updateActiveCategoryDoneButton(ref
            .read(settingCategoryStateNotifierProvider
                .select((p) => p.subCategory))
            ?.name);
      }
    }
  }

  //appbarの完了ボタン更新
  void updateActiveCategoryDoneButton(String? text) {
    if (text == null || text.trim().isEmpty) {
      state = state.copyWithCategoryDoneButton(false);
    } else {
      state = state.copyWithCategoryDoneButton(true);
    }
  }

  //appbar設定
  Widget? getAppBarLeadingWidget() {
    if (state.cancelAndDo) {
      return const AppBarCancelWidget();
    } else if (state.appBarBack) {
      return const AppBarBackWidget();
    }
    return null;
  }

  Widget? getAppBarTitleWidget(TextStyle? fontStyle) {
    if (state.name == rootNameRegister) {
      return SelectExpensesButton(registerCategoryStateNotifierProvider);
    }
    if (state.name == rootNameCategoryList) {
      return SelectExpensesButton(settingCategoryStateNotifierProvider);
    }
    if (state.name == rootNameCalendar) {
      return CalendarAppBar();
    }
    if (state.name == rootNameSearch) {
      return const SearchAppBar();
    }
    if (state.name == rootNameChart) {
      return const ChartAppBar();
    }

    String? titleText = state.appBarTitle;

    return Consumer(
      builder: (context, ref, child) {
        if (state.name == rootNameCategoryEdit) {
          if (ref.read(settingCategoryStateNotifierProvider
                  .select((p) => p.category)) ==
              null) {
            titleText = "カテゴリー 新規追加";
          } else {
            titleText = "カテゴリー 編集";
          }
        }
        if (state.name == rootNameSubCategoryEdit) {
          if (ref.read(settingCategoryStateNotifierProvider
                  .select((p) => p.subCategory)) ==
              null) {
            titleText = "サブカテゴリー 新規追加";
          } else {
            titleText = "サブカテゴリー 編集";
          }
        }
        if (titleText != null) {
          return Text(
            titleText!,
            style: fontStyle?.copyWith(fontSize: 18),
            key: ValueKey<String?>(state.appBarTitle),
            overflow: TextOverflow.ellipsis,
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget? getAppBarTailingWidget(
      GlobalKey<FormState>? formkey, GlobalKey<FormState>? subFormkey) {
    if (state.cancelAndDo) {
      if (state.name == rootNameCategoryEdit) {
        return AppBarDoneWidget(formkey);
      }
      if (state.name == rootNameSubCategoryEdit) {
        return AppBarDoneWidget(subFormkey);
      }
    }
    return null;
  }
}

//戻るボタン
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

//キャンセルボタン
class AppBarCancelWidget extends HookWidget {
  const AppBarCancelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = useState<Color>(theme.colorScheme.onSurface);

    return GestureDetector(
      child: AnimatedContainer(
        duration: listItemAnimationDuration,
        child: Padding(
          padding: const EdgeInsets.only(left: appbarSidePadding),
          child: Text(
            "キャンセル",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: textColor.value,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      onTap: () => context.pop(),
      onTapDown: (_) => {textColor.value = theme.colorScheme.outline},
      onTapUp: (_) => {textColor.value = theme.colorScheme.onSurface},
      onTapCancel: () => {textColor.value = theme.colorScheme.onSurface},
    );
  }
}

//完了ボタン
class AppBarDoneWidget extends HookConsumerWidget {
  final GlobalKey<FormState>? formkey;
  const AppBarDoneWidget(this.formkey, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textColor = useState<Color>(theme.colorScheme.onSurface);

    return ref.watch(
                appBarProvider.select((p) => p.isActiveCategoryDoneButton)) ??
            false
        ? GestureDetector(
            child: AnimatedContainer(
              duration: listItemAnimationDuration,
              child: Padding(
                padding: const EdgeInsets.only(right: appbarSidePadding),
                child: Text(
                  "完了",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: textColor.value,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            onTap: () {
              debugPrint("onTap");
              formkey?.currentState?.save();
            },
            onTapDown: (_) => {textColor.value = theme.colorScheme.outline},
            onTapUp: (_) => {textColor.value = theme.colorScheme.onSurface},
            onTapCancel: () => {textColor.value = theme.colorScheme.onSurface},
          )
        : Padding(
            padding: const EdgeInsets.only(right: appbarSidePadding),
            child: Text(
              "完了",
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme.colorScheme.outline,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
  }
}
