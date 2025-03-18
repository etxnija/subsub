import 'dart:convert';
import 'player.dart';
import 'position.dart';

enum GameStatus { setup, inProgress, paused, completed }

class PlayerPosition {
  final Player player;
  final Position position;
  final DateTime startTime;
  DateTime? endTime;

  PlayerPosition({
    required this.player,
    required this.position,
    required this.startTime,
    this.endTime,
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  Map<String, dynamic> toMap() {
    return {
      'playerId': player.id,
      'positionId': position.id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }
}

class Game {
  final String id;
  final DateTime date;
  final String opponent;
  final Map<String, Player> startingLineup; // Position ID -> Player
  final List<Player> substitutes;

  const Game({
    required this.id,
    required this.date,
    required this.opponent,
    required this.startingLineup,
    required this.substitutes,
  });

  Game copyWith({
    String? id,
    DateTime? date,
    String? opponent,
    Map<String, Player>? startingLineup,
    List<Player>? substitutes,
  }) {
    return Game(
      id: id ?? this.id,
      date: date ?? this.date,
      opponent: opponent ?? this.opponent,
      startingLineup: startingLineup ?? this.startingLineup,
      substitutes: substitutes ?? this.substitutes,
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, Map<String, dynamic>> lineup = {};
    startingLineup.forEach((key, value) {
      lineup[key] = value.toMap();
    });

    return {
      'id': id,
      'date': date.toIso8601String(),
      'opponent': opponent,
      'startingLineup': jsonEncode(lineup),
      'substitutes': jsonEncode(substitutes.map((p) => p.toMap()).toList()),
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    // Parse lineup
    final lineupJson = jsonDecode(map['startingLineup'] as String) as Map<String, dynamic>;
    final Map<String, Player> lineup = {};
    
    lineupJson.forEach((key, value) {
      lineup[key] = Player.fromMap(value as Map<String, dynamic>);
    });

    // Parse substitutes
    final subsJson = jsonDecode(map['substitutes'] as String) as List<dynamic>;
    final subs = subsJson
      .map((item) => Player.fromMap(item as Map<String, dynamic>))
      .toList();

    return Game(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      opponent: map['opponent'] as String,
      startingLineup: lineup,
      substitutes: subs,
    );
  }
}
