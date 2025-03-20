import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsub/models/game.dart';
import 'package:subsub/models/player.dart';
import 'package:subsub/providers/game_provider.dart';

class GameStatsScreen extends ConsumerWidget {
  final String gameId;

  const GameStatsScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gamesProvider).firstWhere((g) => g.id == gameId);

    // Get all players who participated in the game
    final allPlayers = {...game.startingLineup.values, ...game.substitutes};

    // Calculate play time for each player using the time tracking system
    final playerStats =
        allPlayers.map((player) {
            final playTimeMinutes = game.timeTracking.getMinutesPlayed(
              player.id,
            );
            final subTimeMinutes = game.timeTracking.getMinutesOnBench(
              player.id,
            );
            final totalTime = playTimeMinutes + subTimeMinutes;

            return PlayerStats(
              player: player,
              playTimeMinutes: playTimeMinutes,
              subTimeMinutes: subTimeMinutes,
              playTimePercentage:
                  totalTime > 0
                      ? ((playTimeMinutes / totalTime) * 100).round()
                      : 0,
            );
          }).toList()
          ..sort((a, b) => b.playTimeMinutes.compareTo(a.playTimeMinutes));

    return Scaffold(
      appBar: AppBar(title: Text('${game.opponent} - Stats')),
      body: ListView.builder(
        itemCount: playerStats.length,
        itemBuilder: (context, index) {
          final stats = playerStats[index];
          return ListTile(
            title: Text('#${stats.player.number} ${stats.player.name}'),
            subtitle: Text(
              'Play time: ${stats.playTimeMinutes} min (${stats.playTimePercentage}%)\n'
              'Sub time: ${stats.subTimeMinutes} min',
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Text(
                '${stats.playTimePercentage}%',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PlayerStats {
  final Player player;
  final int playTimeMinutes;
  final int subTimeMinutes;
  final int playTimePercentage;

  const PlayerStats({
    required this.player,
    required this.playTimeMinutes,
    required this.subTimeMinutes,
    required this.playTimePercentage,
  });
}
