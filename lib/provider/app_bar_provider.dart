import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/component/segmented_button.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

const rootNameRegister = 'register';
const rootNameChart = 'chart';
const rootNameSetting = 'setting';
const rootNameCategoryList = 'category_list';
const rootNameCategoryEdit = 'category_edit';
const rootNameSubCategoryEdit = 'sub_category_edit';
const rootNameCalendarSetting = 'calendar_setting';

//Provider
final appBarProvider =
    NotifierProvider<AppBarNotifier, AppBarState?>(AppBarNotifier.new);
final doneButtonProvider =
    NotifierProvider<DoneButtonNotifier, bool>(DoneButtonNotifier.new);

class DoneButtonNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void setState(String? text) {
    if (text == null || text.trim().isEmpty) {
      state = false;
    } else {
      state = true;
    }
  }
}

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
  const AppBarState({
    required this.name,
    this.appBarTitle,
    this.appBarBack = false,
    this.needBottomBar = true,
    this.cancelAndDo = false,
    this.appBarSideWidth = _defauldAppBarSideWidth,
  });

  Widget? getAppBarLeadingWidget() {
    if (cancelAndDo) {
      return const AppBarCancelWidget();
    } else if (appBarBack) {
      return const AppBarBackWidget();
    }
    return null;
  }

  Widget? getAppBarTitleWidget(TextStyle? fontStyle) {
    if (name == rootNameRegister) {
      return const SelectExpensesButton();
    }

    String? titleText = appBarTitle;

    return Consumer(
      builder: (context, ref, child) {
        if (name == rootNameCategoryEdit) {
          if (ref.read(selectCategoryNotifierProvider) == null) {
            titleText = "カテゴリー 新規追加";
          } else {
            titleText = "カテゴリー 編集";
          }
        }
        if (name == rootNameSubCategoryEdit) {
          if (ref.read(selectSubCategoryNotifierProvider) == null) {
            titleText = "サブカテゴリー 新規追加";
          } else {
            titleText = "サブカテゴリー 編集";
          }
        }
        if (titleText != null) {
          return Text(
            titleText!,
            style: fontStyle?.copyWith(fontSize: 18),
            key: ValueKey<String?>(appBarTitle),
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
    if (cancelAndDo) {
      if (name == rootNameCategoryEdit) {
        return AppBarDoneWidget(formkey);
      }
      if (name == rootNameSubCategoryEdit) {
        return AppBarDoneWidget(subFormkey);
      }
    }
    return null;
  }
}

//Notifier
class AppBarNotifier extends Notifier<AppBarState?> {
  @override
  AppBarState? build() {
    return null;
  }

  void setAppBar(String? routeName) {
    if (state?.name != routeName) {
      state = AppBarStateCollection.getAppBarState(routeName);
    }
  }
}

//Collection
class AppBarStateCollection {
  static const List<AppBarState> appBarStateStateList = [
    AppBarState(name: rootNameRegister, appBarTitle: null, appBarBack: false),
    AppBarState(
        name: rootNameCategoryList, appBarTitle: 'カテゴリー', appBarBack: true),
    AppBarState(
        name: rootNameCalendarSetting,
        appBarTitle: 'カレンダー設定',
        appBarBack: true),
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

//構成要素（パーツ）
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

class AppBarDoneWidget extends HookConsumerWidget {
  final GlobalKey<FormState>? formkey;
  const AppBarDoneWidget(this.formkey, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textColor = useState<Color>(theme.colorScheme.onSurface);

    return ref.watch(doneButtonProvider)
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
