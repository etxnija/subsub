import 'package:subsub/models/game.dart';
import 'package:subsub/models/player.dart';
import 'package:subsub/managers/time_tracking_manager.dart';

class SubstitutionManager {
  final Game game;
  final TimeTrackingManager timeTracking;
  final Function(Game) onGameUpdated;

  SubstitutionManager({
    required this.game,
    required this.timeTracking,
    required this.onGameUpdated,
  });

  void swapPlayers(Player player1, Player player2) {
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

    // Create a new starting lineup with the swapped players
    final newLineup = Map<String, Player>.from(game.startingLineup);
    if (positionId1 != null) {
      newLineup[positionId1!] = player2;
    }
    if (positionId2 != null) {
      newLineup[positionId2!] = player1;
    }

    // Update the game with the new lineup
    final updatedGame = game.copyWith(startingLineup: newLineup);

    onGameUpdated(updatedGame);

    // Update time tracking for the swapped players
    timeTracking.swapPlayers(player1, player2);
  }

  void moveToBench(Player player) {
    // Find the position ID for the player
    String? positionId;
    for (final entry in game.startingLineup.entries) {
      if (entry.value.id == player.id) {
        positionId = entry.key;
      }
    }

    if (positionId != null) {
      // Create a new starting lineup without the player
      final newLineup = Map<String, Player>.from(game.startingLineup);
      newLineup.remove(positionId);

      // Add player to substitutes
      final newSubstitutes = List<Player>.from(game.substitutes);
      newSubstitutes.add(player);

      // Update the game
      final updatedGame = game.copyWith(
        startingLineup: newLineup,
        substitutes: newSubstitutes,
      );

      onGameUpdated(updatedGame);

      // Update time tracking
      timeTracking.endCurrentTime(player.id);
      timeTracking.startBenchTime(player.id);
    }
  }

  void moveToField(Player player, String positionId) {
    // Remove player from substitutes
    final newSubstitutes = List<Player>.from(game.substitutes);
    newSubstitutes.remove(player);

    // Add player to starting lineup
    final newLineup = Map<String, Player>.from(game.startingLineup);
    newLineup[positionId] = player;

    // Update the game
    final updatedGame = game.copyWith(
      startingLineup: newLineup,
      substitutes: newSubstitutes,
    );

    onGameUpdated(updatedGame);

    // Update time tracking
    timeTracking.endCurrentTime(player.id);
    timeTracking.startPlayTime(player.id, positionId);
  }
}
