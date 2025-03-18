import 'dart:convert';
import 'player.dart';
import 'position.dart';

enum GameStatus { setup, inProgress, paused, completed }

class GamePeriod {
  final int number;
  final int durationMinutes;
  DateTime? startTime;
  DateTime? endTime;

  GamePeriod({
    required this.number,
    required this.durationMinutes,
    this.startTime,
    this.endTime,
  });

  bool get isActive => startTime != null && endTime == null;
  bool get isCompleted => startTime != null && endTime != null;
  
  Duration get elapsed {
    if (startTime == null) return Duration.zero;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!);
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'durationMinutes': durationMinutes,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  factory GamePeriod.fromMap(Map<String, dynamic> map) {
    return GamePeriod(
      number: map['number'] as int,
      durationMinutes: map['durationMinutes'] as int,
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime'] as String) : null,
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
    );
  }
}

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
  final List<GamePeriod> periods;
  final GameStatus status;

  const Game({
    required this.id,
    required this.date,
    required this.opponent,
    required this.startingLineup,
    required this.substitutes,
    this.periods = const [],
    this.status = GameStatus.setup,
  });

  Game copyWith({
    String? id,
    DateTime? date,
    String? opponent,
    Map<String, Player>? startingLineup,
    List<Player>? substitutes,
    List<GamePeriod>? periods,
    GameStatus? status,
  }) {
    return Game(
      id: id ?? this.id,
      date: date ?? this.date,
      opponent: opponent ?? this.opponent,
      startingLineup: startingLineup ?? this.startingLineup,
      substitutes: substitutes ?? this.substitutes,
      periods: periods ?? this.periods,
      status: status ?? this.status,
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
      'periods': jsonEncode(periods.map((p) => p.toMap()).toList()),
      'status': status.index,
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

    // Parse periods
    List<GamePeriod> periods = [];
    if (map['periods'] != null) {
      final periodsJson = jsonDecode(map['periods'] as String) as List<dynamic>;
      periods = periodsJson
        .map((item) => GamePeriod.fromMap(item as Map<String, dynamic>))
        .toList();
    }

    return Game(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      opponent: map['opponent'] as String,
      startingLineup: lineup,
      substitutes: subs,
      periods: periods,
      status: GameStatus.values[map['status'] as int? ?? 0],
    );
  }

  // Helper to create default 7v7 game periods
  static List<GamePeriod> defaultPeriods({int count = 3, int durationMinutes = 15}) {
    return List.generate(
      count,
      (index) => GamePeriod(
        number: index + 1,
        durationMinutes: durationMinutes,
      ),
    );
  }
}
