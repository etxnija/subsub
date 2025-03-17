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
  final int? id;
  final String name;
  final int numberOfPeriods;
  final DateTime createdAt;
  final List<Player> roster;
  final GameStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<PlayerPosition> positionHistory;
  final Map<String, Player?> currentPositions; // position.id -> Player

  const Game({
    this.id,
    required this.name,
    required this.numberOfPeriods,
    required this.createdAt,
    required this.roster,
    this.status = GameStatus.setup,
    this.startTime,
    this.endTime,
    this.positionHistory = const [],
    this.currentPositions = const {},
  });

  Game copyWith({
    int? id,
    String? name,
    int? numberOfPeriods,
    DateTime? createdAt,
    List<Player>? roster,
    GameStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    List<PlayerPosition>? positionHistory,
    Map<String, Player?>? currentPositions,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      numberOfPeriods: numberOfPeriods ?? this.numberOfPeriods,
      createdAt: createdAt ?? this.createdAt,
      roster: roster ?? this.roster,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      positionHistory: positionHistory ?? this.positionHistory,
      currentPositions: currentPositions ?? this.currentPositions,
    );
  }

  // Get players who are currently not on the field (substitutes)
  List<Player> get substitutes {
    final onField = currentPositions.values.whereType<Player>().toList();
    return roster.where((p) => !onField.contains(p)).toList();
  }

  // Get total play time for a player
  Duration getPlayTime(Player player) {
    return positionHistory
        .where((pp) => pp.player.id == player.id)
        .map((pp) => pp.duration)
        .fold(Duration.zero, (prev, curr) => prev + curr);
  }

  // Get total bench time for a player
  Duration getBenchTime(Player player) {
    if (!roster.contains(player)) return Duration.zero;
    if (status != GameStatus.inProgress) return Duration.zero;

    final totalGameTime = DateTime.now().difference(startTime!);
    final playTime = getPlayTime(player);
    return totalGameTime - playTime;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'numberOfPeriods': numberOfPeriods,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Game(id: $id, name: $name, numberOfPeriods: $numberOfPeriods, createdAt: $createdAt, status: $status, roster: $roster)';
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] as int,
      name: map['name'] as String,
      numberOfPeriods: map['numberOfPeriods'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      status: GameStatus.values.firstWhere((e) => e.name == map['status']),
      startTime:
          map['startTime'] != null
              ? DateTime.parse(map['startTime'] as String)
              : null,
      endTime:
          map['endTime'] != null
              ? DateTime.parse(map['endTime'] as String)
              : null,
      roster:
          [], // Initialize with empty roster, should be populated separately
    );
  }
}
