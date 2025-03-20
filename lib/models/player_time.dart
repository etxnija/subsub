import 'package:subsub/models/player.dart';
import 'package:subsub/models/position.dart';

class PlayerTimeRecord {
  final String playerId;
  final String? positionId;
  final DateTime startTime;
  final DateTime? endTime;

  PlayerTimeRecord({
    required this.playerId,
    this.positionId,
    required this.startTime,
    this.endTime,
  });

  int get durationMinutes {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inMinutes;
  }

  int get durationSeconds {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inSeconds;
  }

  String get formattedDuration {
    final seconds = durationSeconds;
    if (seconds < 60) {
      return '${seconds}s';
    }
    return '${seconds ~/ 60}m';
  }

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
      'positionId': positionId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  factory PlayerTimeRecord.fromMap(Map<String, dynamic> map) {
    return PlayerTimeRecord(
      playerId: map['playerId'] as String,
      positionId: map['positionId'] as String?,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
    );
  }
}

class GameTimeTracking {
  Map<String, List<PlayerTimeRecord>> playerRecords;

  GameTimeTracking({
    Map<String, List<PlayerTimeRecord>>? playerRecords,
  }) : playerRecords = playerRecords ?? {};

  int getSecondsPlayed(String playerId) {
    final records = playerRecords[playerId] ?? [];
    return records.fold(0, (sum, record) => sum + record.durationSeconds);
  }

  int getSecondsOnBench(String playerId) {
    final records = playerRecords[playerId] ?? [];
    return records
        .where((record) => record.positionId == null)
        .fold(0, (sum, record) => sum + record.durationSeconds);
  }

  int getMinutesPlayed(String playerId) {
    return getSecondsPlayed(playerId) ~/ 60;
  }

  int getMinutesOnBench(String playerId) {
    return getSecondsOnBench(playerId) ~/ 60;
  }

  String getFormattedTime(String playerId) {
    final records = playerRecords[playerId] ?? [];
    if (records.isEmpty) return '0s';
    final totalSeconds = records.fold(0, (sum, record) => sum + record.durationSeconds);
    if (totalSeconds < 60) {
      return '${totalSeconds}s';
    }
    return '${totalSeconds ~/ 60}m';
  }

  String getFormattedBenchTime(String playerId) {
    final records = playerRecords[playerId] ?? [];
    final benchRecords = records.where((record) => record.positionId == null);
    if (benchRecords.isEmpty) return '0s';
    final totalSeconds = benchRecords.fold(0, (sum, record) => sum + record.durationSeconds);
    if (totalSeconds < 60) {
      return '${totalSeconds}s';
    }
    return '${totalSeconds ~/ 60}m';
  }

  int getMinutesInPosition(String playerId, String positionId) {
    final records = playerRecords[playerId] ?? [];
    return records
        .where((record) => record.positionId == positionId)
        .fold(0, (sum, record) => sum + record.durationMinutes);
  }

  void addRecord(PlayerTimeRecord record) {
    if (!playerRecords.containsKey(record.playerId)) {
      playerRecords[record.playerId] = [];
    }
    playerRecords[record.playerId]!.add(record);
  }

  void endCurrentRecord(String playerId) {
    final records = playerRecords[playerId] ?? [];
    if (records.isNotEmpty) {
      final lastRecord = records.last;
      if (lastRecord.endTime == null) {
        records[records.length - 1] = PlayerTimeRecord(
          playerId: lastRecord.playerId,
          positionId: lastRecord.positionId,
          startTime: lastRecord.startTime,
          endTime: DateTime.now(),
        );
      }
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'playerRecords': playerRecords.map(
        (key, value) => MapEntry(
          key,
          value.map((record) => record.toMap()).toList(),
        ),
      ),
    };
  }

  factory GameTimeTracking.fromMap(Map<String, dynamic> map) {
    return GameTimeTracking(
      playerRecords: (map['playerRecords'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List).map((record) => PlayerTimeRecord.fromMap(record)).toList(),
        ),
      ),
    );
  }
} 