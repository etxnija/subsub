import 'package:subsub/models/game.dart';
import 'package:subsub/models/player.dart';
import 'package:subsub/models/player_time.dart';

class TimeTrackingManager {
  final Game game;
  Function(Game) onGameUpdated;

  TimeTrackingManager({required this.game, required this.onGameUpdated});

  void startPlayTime(String playerId, String positionId) {
    game.timeTracking.addRecord(
      PlayerTimeRecord(
        playerId: playerId,
        positionId: positionId,
        startTime: DateTime.now(),
        endTime: null,
      ),
    );
    onGameUpdated(game);
  }

  void startBenchTime(String playerId) {
    game.timeTracking.addRecord(
      PlayerTimeRecord(
        playerId: playerId,
        startTime: DateTime.now(),
        endTime: null,
      ),
    );
    onGameUpdated(game);
  }

  void endCurrentTime(String playerId) {
    game.timeTracking.endCurrentRecord(playerId);
    onGameUpdated(game);
  }

  void swapPlayers(Player player1, Player player2) {
    // End current time records for both players
    endCurrentTime(player1.id);
    endCurrentTime(player2.id);

    // Find the position IDs for both players
    String? positionId1;
    String? positionId2;

    for (final entry in game.startingLineup.entries) {
      if (entry.value.id == player1.id) {
        positionId1 = entry.key;
      }
      if (entry.value.id == player2.id) {
        positionId2 = entry.key;
      }
    }

    // Start new time records based on their new positions
    if (positionId1 != null) {
      startPlayTime(player2.id, positionId1);
    } else {
      startBenchTime(player2.id);
    }

    if (positionId2 != null) {
      startPlayTime(player1.id, positionId2);
    } else {
      startBenchTime(player1.id);
    }
  }

  void startPeriod() {
    // End any existing time records for both starting lineup and substitutes
    for (final player in game.startingLineup.values) {
      endCurrentTime(player.id);
    }
    for (final player in game.substitutes) {
      endCurrentTime(player.id);
    }

    // Start play time for players in the starting lineup
    for (final entry in game.startingLineup.entries) {
      startPlayTime(entry.value.id, entry.key);
    }

    // Start bench time for players in the substitutes list
    for (final player in game.substitutes) {
      startBenchTime(player.id);
    }
  }

  void endPeriod() {
    // End all current time records
    for (final player in game.startingLineup.values) {
      endCurrentTime(player.id);
    }
    for (final player in game.substitutes) {
      endCurrentTime(player.id);
    }
  }
}
