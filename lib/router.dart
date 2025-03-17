import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsub/views/roster/roster_screen.dart';
import 'package:subsub/screens/game_screen.dart';
import 'package:subsub/screens/field_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.people),
                  label: 'Roster',
                ),
                NavigationDestination(
                  icon: Icon(Icons.sports),
                  label: 'Game',
                ),
                NavigationDestination(
                  icon: Icon(Icons.sports_soccer),
                  label: 'Field',
                ),
              ],
              selectedIndex: _calculateSelectedIndex(state),
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/game');
                    break;
                  case 2:
                    context.go('/field');
                    break;
                }
              },
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const RosterScreen(),
          ),
          GoRoute(
            path: '/game',
            builder: (context, state) => const GameScreen(),
          ),
          GoRoute(
            path: '/field',
            builder: (context, state) => const FieldScreen(),
          ),
        ],
      ),
    ],
  );
});

int _calculateSelectedIndex(GoRouterState state) {
  final location = state.uri.path;
  if (location == '/') return 0;
  if (location == '/game') return 1;
  if (location == '/field') return 2;
  return 0;
} 