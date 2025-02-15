import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/segmented_button.dart';
import 'package:household_expense_project/constant/constant.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/provider/setting_recurring_provider.dart';
import 'package:household_expense_project/view/calendar_view/calendar_page.dart';
import 'package:household_expense_project/view/chart_view/chart_page.dart';
import 'package:household_expense_project/view/search_view/search_page.dart';
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
const rootNameRecurringList = 'recurring_list';
const rootNameRecurringEdit = 'recurring_edit';
const rootNameRecurringSetting = 'recurring_setting';
const rootNameRecurringSettingDetail = 'recurring_setting_detail';
const rootNameRecurringSettingRegisterList = 'recurring_setting_register_list';
const rootNameContact = 'contact';
const rootNameThemeColorSetting = 'theme_color_setting';

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
  AppBarState(
      name: rootNameRecurringList, appBarTitle: '定期収支設定', appBarBack: true),
  AppBarState(
      name: rootNameRecurringSetting, appBarTitle: '繰り返し設定', appBarBack: true),
  AppBarState(name: rootNameRecurringSettingDetail, appBarBack: true),
  AppBarState(
    name: rootNameRecurringEdit,
    appBarTitle: '定期収支編集',
    appBarBack: true,
    needBottomBar: false,
    cancelAndDo: true,
    appBarSideWidth: 100,
  ),
  AppBarState(
      name: rootNameRecurringSettingRegisterList,
      appBarTitle: '定期明細一覧',
      appBarBack: true),
  AppBarState(name: rootNameContact, appBarTitle: 'お問い合わせ', appBarBack: true),
  AppBarState(
    name: rootNameThemeColorSetting,
    appBarTitle: 'テーマカラー設定',
    appBarBack: true,
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

  AppBarState copyWithTitle({String? title}) {
    return AppBarState(
      name: name,
      appBarTitle: title,
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

  AppBarState copyWithIsActiveDeleteButton(bool isActive) {
    return AppBarState(
      name: name,
      appBarTitle: appBarTitle,
      appBarBack: appBarBack,
      cancelAndDo: cancelAndDo,
      needBottomBar: needBottomBar,
      appBarSideWidth: appBarSideWidth,
      isActiveCategoryDoneButton: isActiveCategoryDoneButton,
    );
  }
}

//Notifier
class AppBarNotifier extends Notifier<AppBarState> {
  @override
  AppBarState build() {
    return const AppBarState(name: '');
  }

  void setAppBar(GoRouterState goRouterState) {
    String? routeName = goRouterState.topRoute?.name;
    if (state.name != routeName) {
      var newState = const AppBarState(name: '');
      for (AppBarState appBarState in appBarStateStateList) {
        if (appBarState.name == routeName) {
          newState = appBarState;
          break;
        }
      }
      state = newState;
      if (state.name == rootNameRecurringSettingDetail) {
        state = state.copyWithTitle(
            title: recurringDetailTitleList[goRouterState.extra as int]);
      }

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

  //appbarの削除ボタン更新
  void updateActiveDeleteButton(bool isActive) {
    state = state.copyWithIsActiveDeleteButton(isActive);
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
      return SelectExpenseButton(registerCategoryStateNotifierProvider);
    }
    if (state.name == rootNameCategoryList) {
      return SelectExpenseButton(settingCategoryStateNotifierProvider);
    }
    if (state.name == rootNameRecurringList) {
      return SelectExpenseButton(registerEditCategoryStateNotifierProvider);
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
        if (state.name == rootNameRecurringEdit) {
          if (ref.read(settingRecurringyStateNotifierProvider
                  .select((p) => p.selectRegisterRecurring)) ==
              null) {
            titleText = " 新規追加";
          } else {
            titleText = " 編集";
          }
          titleText =
              "定期${ref.read(registerEditCategoryStateNotifierProvider.select((p) => p.selectExpense.text))}${titleText!}";
        }
        if (titleText != null) {
          return Text(
            titleText!,
            style: fontStyle?.copyWith(
                fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
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
      GlobalKey<FormState>? formkey,
      GlobalKey<FormState>? subFormkey,
      GlobalKey<FormState>? recurringFormkey) {
    if (state.cancelAndDo) {
      final ProviderListenable<bool> listenableProvider =
          appBarProvider.select((p) => p.isActiveCategoryDoneButton);
      if (state.name == rootNameCategoryEdit) {
        return AppBarDoneWidget(formkey, listenableProvider);
      }
      if (state.name == rootNameSubCategoryEdit) {
        return AppBarDoneWidget(subFormkey, listenableProvider);
      }
    }
    if (state.name == rootNameRecurringEdit) {
      final ProviderListenable<bool> listenableRecurringProvider =
          settingRecurringyStateNotifierProvider
              .select((p) => p.isActiveAppbarDeleteButton);
      return AppBarDoneWidget(
        recurringFormkey,
        listenableRecurringProvider,
        isDelete: true,
      );
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
    useEffect(() {
      backIconColor.value = theme.colorScheme.onSurface;
      return () {};
    }, [theme]);

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
    useEffect(() {
      textColor.value = theme.colorScheme.onSurface;
      return () {};
    }, [theme]);

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
  final ProviderListenable<bool> listenableProvider;
  final bool isDelete;
  const AppBarDoneWidget(
    this.formkey,
    this.listenableProvider, {
    super.key,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textColor = useState<Color>(theme.colorScheme.onSurface);
    useEffect(() {
      textColor.value = theme.colorScheme.onSurface;
      return () {};
    }, [theme]);

    return ref.watch(listenableProvider) ?? false
        ? GestureDetector(
            child: AnimatedContainer(
              duration: listItemAnimationDuration,
              child: Padding(
                padding: const EdgeInsets.only(right: appbarSidePadding),
                child: Text(
                  isDelete ? "削除" : "完了",
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
              formkey?.currentState?.save();
            },
            onTapDown: (_) => {textColor.value = theme.colorScheme.outline},
            onTapUp: (_) => {textColor.value = theme.colorScheme.onSurface},
            onTapCancel: () => {textColor.value = theme.colorScheme.onSurface},
          )
        : Padding(
            padding: const EdgeInsets.only(right: appbarSidePadding),
            child: Text(
              isDelete ? "削除" : "完了",
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
