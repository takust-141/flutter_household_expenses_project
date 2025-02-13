import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/provider/app_bar_provider.dart';
import 'package:household_expense_project/router/view.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

GlobalKey<FormState>? formkey;
GlobalKey<FormState>? subFormkey;
GlobalKey<FormState>? recurringFormkey;

final RouteObserver<PageRoute> registerRouteObserver =
    RouteObserver<PageRoute>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  initialLocation: '/register',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(
            navigationShell: navigationShell, goRouterState: state);
      },
      branches: [
        StatefulShellBranch(
          observers: [registerRouteObserver],
          routes: <RouteBase>[
            GoRoute(
              path: '/register',
              name: rootNameRegister,
              builder: (context, state) => RegisterPage(
                routeObserver: registerRouteObserver,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          preload: true,
          routes: <RouteBase>[
            GoRoute(
              path: '/calendar',
              name: rootNameCalendar,
              builder: (context, state) => const CalendarPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          preload: true,
          routes: <RouteBase>[
            GoRoute(
              path: '/chart',
              name: rootNameChart,
              builder: (context, state) => const ChartPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/search',
              name: rootNameSearch,
              builder: (context, state) => const SearchPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/setting',
              name: rootNameSetting,
              builder: (context, state) => const SettingPage(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'category_list',
                  name: rootNameCategoryList,
                  builder: (context, state) => const CategoryListPage(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'category_edit',
                      name: rootNameCategoryEdit,
                      builder: (context, state) {
                        final int providerIndex = state.extra as int;
                        formkey = GlobalKey<FormState>();
                        return CategoryEditPage(
                          formKey: formkey,
                          isSubPage: false,
                          providerIndex: providerIndex,
                        );
                      },
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'sub_category_edit',
                          name: rootNameSubCategoryEdit,
                          builder: (context, state) {
                            final int providerIndex = state.extra as int;
                            subFormkey = GlobalKey<FormState>();
                            return CategoryEditPage(
                              formKey: subFormkey,
                              isSubPage: true,
                              providerIndex: providerIndex,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                GoRoute(
                  path: 'calendar_setting',
                  name: rootNameCalendarSetting,
                  builder: (context, state) => const CalendarSettingPage(),
                ),
                GoRoute(
                  path: 'recurring_list',
                  name: rootNameRecurringList,
                  builder: (context, state) => const RecurringSettingListPage(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'recurring_edit',
                      name: rootNameRecurringEdit,
                      builder: (context, state) {
                        recurringFormkey = GlobalKey<FormState>();
                        return RecurringEditPage(formkey: recurringFormkey);
                      },
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'recurring_setting',
                          name: rootNameRecurringSetting,
                          builder: (context, state) =>
                              const RecurringSettingPage(),
                          routes: <RouteBase>[
                            GoRoute(
                              path: 'recurring_setting_detail',
                              name: rootNameRecurringSettingDetail,
                              builder: (context, state) =>
                                  RecurringSettingDetailPage(
                                      state.extra as int),
                            ),
                          ],
                        ),
                        GoRoute(
                          path: 'recurring_setting_register_list',
                          name: rootNameRecurringSettingRegisterList,
                          builder: (context, state) =>
                              const RecurringSettingRegisterListPage(),
                        ),
                      ],
                    ),
                  ],
                ),
                GoRoute(
                  path: 'contact',
                  name: rootNameContact,
                  builder: (context, state) => const ContactFormPage(),
                ),
                GoRoute(
                  path: 'theme_color_setting',
                  name: rootNameThemeColorSetting,
                  builder: (context, state) => const ThemeColorSettingPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

//-----navigation-----
class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  final GoRouterState goRouterState;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    required this.goRouterState,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  static const List<NavigationDestination> allDestinations = [
    NavigationDestination(
      icon: Icon(
        Icons.edit,
        size: bottomNavIconSize,
      ),
      label: '入力',
    ),
    NavigationDestination(
      icon: Icon(
        Icons.calendar_month,
        size: bottomNavIconSize,
      ),
      label: 'カレンダー',
    ),
    NavigationDestination(
      icon: Icon(
        Icons.pie_chart,
        size: bottomNavIconSize,
      ),
      label: 'グラフ',
    ),
    NavigationDestination(
      icon: Icon(
        Icons.search,
        size: bottomNavIconSize,
      ),
      label: '検索',
    ),
    NavigationDestination(
      icon: Icon(
        Icons.settings,
        size: bottomNavIconSize,
      ),
      label: '設定',
    ),
  ];

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Future<InitializationStatus?> initGoogleMobileAds() {
      return MobileAds.instance.initialize();
    }

    return Scaffold(
      appBar: CustomAppBar(goRouterState: widget.goRouterState),
      extendBody: true,
      body: FutureBuilder<InitializationStatus?>(
          future: initGoogleMobileAds(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            return SafeArea(
              bottom: false,
              child: widget.navigationShell,
            );
          }),
      backgroundColor: theme.colorScheme.surfaceContainer,
      resizeToAvoidBottomInset: false, //キーボードによるレイアウト変更を制御
      bottomNavigationBar:
          (ref.watch(appBarProvider.select((p) => p.needBottomBar)) ?? true)
              ? NavigationBar(
                  backgroundColor: theme.scaffoldBackgroundColor,
                  surfaceTintColor: theme.scaffoldBackgroundColor,
                  selectedIndex: widget.navigationShell.currentIndex,
                  destinations: ScaffoldWithNavBar.allDestinations,
                  height: bottomAppBarHeight,
                  onDestinationSelected: (index) {
                    widget.navigationShell.goBranch(
                      index,
                      initialLocation:
                          index == widget.navigationShell.currentIndex,
                    );
                  },
                )
              : null,
    );
  }
}

//AppBar
class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final GoRouterState goRouterState;
  const CustomAppBar({required this.goRouterState, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBarState = ref.watch(appBarProvider);
    final appBarStateNotifier = ref.read(appBarProvider.notifier);
    final theme = Theme.of(context);

    final List<Widget> appBarWidget = [
      SizedBox(
        width: appBarState.appBarSideWidth,
        child: appBarStateNotifier.getAppBarLeadingWidget(),
      ),
      Expanded(
        child: Center(
          child: appBarStateNotifier
              .getAppBarTitleWidget(Theme.of(context).textTheme.titleMedium),
        ),
      ),
      SizedBox(
        width: appBarState.appBarSideWidth,
        child: appBarStateNotifier.getAppBarTailingWidget(
            formkey, subFormkey, recurringFormkey),
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarProvider.notifier).setAppBar(goRouterState);
    });

    return Material(
      elevation: 3.0,
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: Row(
            key: ValueKey(appBarState),
            mainAxisAlignment: MainAxisAlignment.start,
            children: appBarWidget,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
