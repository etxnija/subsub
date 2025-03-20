import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsub/models/game.dart';
import 'package:subsub/services/database_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

// Provider for the list of games
final gamesProvider = StateNotifierProvider<GamesNotifier, List<Game>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return GamesNotifier(databaseService);
});

// Notifier to manage the games state
class GamesNotifier extends StateNotifier<List<Game>> {
  final DatabaseService _databaseService;
  static const String tableName = 'games';

  GamesNotifier(this._databaseService) : super([]) {
    loadGames();
  }

  // Load all games from the database
  Future<void> loadGames() async {
    try {
      final gamesData = await _databaseService.getAll(tableName);
      final games =
          gamesData.map((data) {
            final game = Game.fromMap(data);
            // Set up the time tracking manager's callback
            game.timeTrackingManager.onGameUpdated = (updatedGame) {
              updateGame(updatedGame);
            };
            return game;
          }).toList();
      state = games;
    } catch (e) {
      print('Error loading games: $e');
      state = [];
    }
  }

  // Add a new game
  Future<void> addGame(Game game) async {
    try {
      // Set up the time tracking manager's callback before adding
      game.timeTrackingManager.onGameUpdated = (updatedGame) {
        updateGame(updatedGame);
      };
      await _databaseService.insertGame(game);
      await loadGames();
    } catch (e) {
      debugPrint('Error adding game: $e');
      rethrow;
    }
  }

  // Update an existing game
  Future<void> updateGame(Game game) async {
    try {
      await _databaseService.updateGame(game);
      state =
          state.map((g) {
            if (g.id == game.id) {
              // Ensure the callback is preserved when updating
              game.timeTrackingManager.onGameUpdated = (updatedGame) {
                updateGame(updatedGame);
              };
              return game;
            }
            return g;
          }).toList();
    } catch (e) {
      debugPrint('Error updating game: $e');
      rethrow;
    }
  }

  // Delete a game
  Future<void> deleteGame(Game game) async {
    await _databaseService.deleteGame(game.id);
    state = state.where((g) => g.id != game.id).toList();
  }
}
