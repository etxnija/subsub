import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../services/database_service.dart';

final databaseProvider = Provider((ref) => DatabaseService());

final rosterProvider = StateNotifierProvider<RosterNotifier, List<Player>>((ref) {
  final database = ref.watch(databaseProvider);
  return RosterNotifier(database);
});

class RosterNotifier extends StateNotifier<List<Player>> {
  final DatabaseService _database;

  RosterNotifier(this._database) : super([]) {
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    state = await _database.getAllPlayers();
  }

  Future<void> addPlayer(String name, int number) async {
    final player = Player(name: name, number: number);
    final id = await _database.insertPlayer(player);
    state = [...state, player.copyWith(id: id)];
  }

  Future<void> updatePlayer(Player player) async {
    await _database.updatePlayer(player);
    state = [
      for (final p in state)
        if (p.id == player.id) player else p
    ];
  }

  Future<void> deletePlayer(int id) async {
    await _database.deletePlayer(id);
    state = state.where((p) => p.id != id).toList();
  }
} 