import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsub/views/roster/roster_screen.dart';
import 'package:subsub/screens/games_screen.dart';
import 'package:subsub/screens/game_play_screen.dart';
import 'package:subsub/screens/game_stats_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/games',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              destinations: const [
                NavigationDestination(icon: Icon(Icons.sports), label: 'Games'),
                NavigationDestination(
                  icon: Icon(Icons.people),
                  label: 'Roster',
                ),
              ],
              selectedIndex: _calculateSelectedIndex(state),
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go('/games');
                    break;
                  case 1:
                    context.go('/');
                    break;
                }
              },
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/games',
            builder: (context, state) => const GamesScreen(),
            routes: [
              GoRoute(
                path: 'play/:gameId',
                builder: (context, state) {
                  final gameId = state.pathParameters['gameId']!;
                  return GamePlayScreen(gameId: gameId);
                },
              ),
              GoRoute(
                path: 'stats/:gameId',
                builder: (context, state) {
                  final gameId = state.pathParameters['gameId']!;
                  return GameStatsScreen(gameId: gameId);
                },
              ),
            ],
          ),
          GoRoute(path: '/', builder: (context, state) => const RosterScreen()),
        ],
      ),
    ],
  );
});

int _calculateSelectedIndex(GoRouterState state) {
  final location = state.uri.path;
  if (location == '/games') return 0;
  if (location == '/') return 1;
  return 0;
}
