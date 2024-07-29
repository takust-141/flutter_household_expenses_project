import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/view/view.dart';
import 'package:household_expenses_project/component/segmented_button.dart';
import 'package:household_expenses_project/provider/app_bar_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

GlobalKey<FormState>? formkey;

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
          routes: <RouteBase>[
            GoRoute(
              path: '/register',
              name: 'register',
              builder: (context, state) => RegisterPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/chart',
              name: 'chart',
              builder: (context, state) => ListViewPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/setting',
              name: 'setting',
              builder: (context, state) => SettingPage(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'category_list',
                  name: 'category_list',
                  builder: (context, state) => CategoryListPage(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'category_edit',
                      name: 'category_edit',
                      builder: (context, state) {
                        formkey = GlobalKey<FormState>();
                        return CategoryEditPage(formkey);
                      },
                    ),
                  ],
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
      icon: Icon(Icons.edit),
      label: '入力',
    ),
    NavigationDestination(
      icon: Icon(Icons.list),
      label: '一覧表示',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings),
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

    return Scaffold(
      appBar: CustomAppBar(goRouterState: widget.goRouterState),
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: widget.navigationShell,
      ),
      backgroundColor: theme.colorScheme.surfaceContainer,
      resizeToAvoidBottomInset: false, //キーボードによるレイアウト変更を制御
      bottomNavigationBar: (ref.watch(appBarProvider)?.needBottomBar ?? true)
          ? NavigationBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: theme.scaffoldBackgroundColor,
              selectedIndex: widget.navigationShell.currentIndex,
              destinations: ScaffoldWithNavBar.allDestinations,
              onDestinationSelected: (index) {
                widget.navigationShell.goBranch(
                  index,
                  initialLocation: index == widget.navigationShell.currentIndex,
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
    final theme = Theme.of(context);

    final List<Widget> appBarWidget = [
      SizedBox(
        width: appBarState?.appBarSideWidth ?? 0,
        child: appBarState?.getAppBarLeadingWidget(),
      ),
      Expanded(
        child: Center(
          child: appBarState
              ?.getAppBarTitleWidget(Theme.of(context).textTheme.titleMedium),
        ),
      ),
      SizedBox(
        width: appBarState?.appBarSideWidth ?? 0,
        child: appBarState?.getAppBarTailingWidget(formkey),
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarProvider.notifier).setAppBar(goRouterState.topRoute?.name);
    });

    return Material(
      elevation: 2.0,
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
