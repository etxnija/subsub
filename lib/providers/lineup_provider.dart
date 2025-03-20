import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsub/models/player.dart';
import 'package:subsub/models/position.dart';

class LineupNotifier extends StateNotifier<Map<String, Player?>> {
  LineupNotifier() : super({});

  void assignPlayer(String positionId, Player? player) {
    state = {...state, positionId: player};
  }

  void removePlayer(String positionId) {
    state = {...state, positionId: null};
  }

  Player? getPlayerAtPosition(String positionId) {
    return state[positionId];
  }

  bool isPlayerAssigned(Player player) {
    return state.values.any((p) => p?.id == player.id);
  }

  void clearAllAssignments() {
    state = {};
  }
}

final lineupProvider =
    StateNotifierProvider<LineupNotifier, Map<String, Player?>>((ref) {
      return LineupNotifier();
    });
