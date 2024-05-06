import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:household_expenses_project/view/register_page.dart';
import 'package:household_expenses_project/view/setting_page.dart';
import 'package:household_expenses_project/view/list_view_page.dart';
import 'package:household_expenses_project/component/segmented_button.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  initialLocation: '/register',
  routes: [
    StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/register',
                builder: (context, state) => RegisterPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chart',
                builder: (context, state) => ListViewPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: '/setting',
                builder: (context, state) => SettingPage(),
              ),
            ],
          ),
        ]),
  ],
);

//-----navigation-----
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));
  final StatefulNavigationShell navigationShell;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          Spacer(),
          SelectExpensesButton(),
          Spacer(),
        ],
      ),
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: navigationShell,
      ),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      resizeToAvoidBottomInset: false, //キーボードによるレイアウト変更を制御
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: allDestinations,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
