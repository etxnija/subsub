import 'dart:convert';
import 'player.dart';
import 'position.dart';
import 'player_time.dart';

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
  final Map<String, Player> startingLineup;
  final List<Player> substitutes;
  final List<GamePeriod> periods;
  final GameStatus status;
  final GameTimeTracking timeTracking;

  Game({
    required this.id,
    required this.date,
    required this.opponent,
    required this.startingLineup,
    required this.substitutes,
    required this.periods,
    this.status = GameStatus.setup,
    GameTimeTracking? timeTracking,
  }) : timeTracking = timeTracking ?? GameTimeTracking();

  Game copyWith({
    String? id,
    DateTime? date,
    String? opponent,
    Map<String, Player>? startingLineup,
    List<Player>? substitutes,
    List<GamePeriod>? periods,
    GameStatus? status,
    GameTimeTracking? timeTracking,
  }) {
    return Game(
      id: id ?? this.id,
      date: date ?? this.date,
      opponent: opponent ?? this.opponent,
      startingLineup: startingLineup ?? this.startingLineup,
      substitutes: substitutes ?? this.substitutes,
      periods: periods ?? this.periods,
      status: status ?? this.status,
      timeTracking: timeTracking ?? this.timeTracking,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'opponent': opponent,
      'startingLineup': startingLineup.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'substitutes': substitutes.map((player) => player.toMap()).toList(),
      'periods': periods.map((period) => period.toMap()).toList(),
      'status': status.toString(),
      'timeTracking': timeTracking.toMap(),
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    // Parse JSON strings for complex types
    final lineupJson = map['startingLineup'] is String 
        ? jsonDecode(map['startingLineup'] as String) as Map<String, dynamic>
        : map['startingLineup'] as Map<String, dynamic>;
    
    final lineup = lineupJson.map(
      (key, value) => MapEntry(key, Player.fromMap(value as Map<String, dynamic>)),
    );

    final substitutesJson = map['substitutes'] is String
        ? jsonDecode(map['substitutes'] as String) as List<dynamic>
        : map['substitutes'] as List<dynamic>;
    
    final substitutes = substitutesJson
        .map((item) => Player.fromMap(item as Map<String, dynamic>))
        .toList();

    final periodsJson = map['periods'] is String
        ? jsonDecode(map['periods'] as String) as List<dynamic>
        : map['periods'] as List<dynamic>;
    
    final periods = periodsJson
        .map((item) => GamePeriod.fromMap(item as Map<String, dynamic>))
        .toList();

    final timeTrackingJson = map['timeTracking'] is String
        ? jsonDecode(map['timeTracking'] as String) as Map<String, dynamic>
        : map['timeTracking'] as Map<String, dynamic>;
    
    final timeTracking = GameTimeTracking.fromMap(timeTrackingJson);

    return Game(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      opponent: map['opponent'] as String,
      startingLineup: lineup,
      substitutes: substitutes,
      periods: periods,
      status: GameStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => GameStatus.setup,
      ),
      timeTracking: timeTracking,
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

  // Helper methods for time tracking
  void recordPlayerStart(String playerId, {String? positionId}) {
    timeTracking.addRecord(
      PlayerTimeRecord(
        playerId: playerId,
        positionId: positionId,
        startTime: DateTime.now(),
      ),
    );
  }

  void recordPlayerEnd(String playerId) {
    timeTracking.endCurrentRecord(playerId);
  }

  int getMinutesPlayed(String playerId) {
    return timeTracking.getMinutesPlayed(playerId);
  }

  int getMinutesInPosition(String playerId, String positionId) {
    return timeTracking.getMinutesInPosition(playerId, positionId);
  }

  int getMinutesOnBench(String playerId) {
    return timeTracking.getMinutesOnBench(playerId);
  }

  List<Player> getSortedSubstitutes() {
    final substitutes = List<Player>.from(this.substitutes);
    
    substitutes.sort((a, b) {
      // First compare by time on bench (longest first)
      final benchTimeA = timeTracking.getSecondsOnBench(a.id);
      final benchTimeB = timeTracking.getSecondsOnBench(b.id);
      
      if (benchTimeA != benchTimeB) {
        return benchTimeB.compareTo(benchTimeA); // Longer bench time first
      }
      
      // If bench times are equal, compare by total playing time (least first)
      final playTimeA = timeTracking.getSecondsPlayed(a.id);
      final playTimeB = timeTracking.getSecondsPlayed(b.id);
      
      if (playTimeA != playTimeB) {
        return playTimeA.compareTo(playTimeB); // Less playing time first
      }
      
      // If both times are equal, maintain current order
      return 0;
    });
    
    return substitutes;
  }
}
