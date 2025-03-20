import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subsub/models/game.dart';
import 'package:subsub/models/player.dart';
import 'package:subsub/models/player_time.dart';
import 'package:subsub/screens/game_play_screen.dart';

void main() {
  group('Substitutes Sorting', () {
    late Game game;
    late Player player1;
    late Player player2;
    late Player player3;
    late GameTimeTracking timeTracking;

    setUp(() {
      // Create test players
      player1 = Player(
        id: '1',
        name: 'Player 1',
        number: 1,
      );
      player2 = Player(
        id: '2',
        name: 'Player 2',
        number: 2,
      );
      player3 = Player(
        id: '3',
        name: 'Player 3',
        number: 3,
      );

      // Create time tracking with test records
      timeTracking = GameTimeTracking();
      
      // Create test game
      game = Game(
        id: 'test-game',
        date: DateTime.now(),
        opponent: 'Test Team',
        startingLineup: {},
        substitutes: [player1, player2, player3],
        periods: [],
        timeTracking: timeTracking,
      );
    });

    test('Sorts by bench time (longest first)', () {
      // Add time records
      timeTracking.addRecord(PlayerTimeRecord(
        playerId: player1.id,
        startTime: DateTime.now().subtract(const Duration(minutes: 30)),
        endTime: DateTime.now(),
      ));
      timeTracking.addRecord(PlayerTimeRecord(
        playerId: player2.id,
        startTime: DateTime.now().subtract(const Duration(minutes: 15)),
        endTime: DateTime.now(),
      ));
      timeTracking.addRecord(PlayerTimeRecord(
        playerId: player3.id,
        startTime: DateTime.now().subtract(const Duration(minutes: 45)),
        endTime: DateTime.now(),
      ));

      final sortedSubs = game.getSortedSubstitutes();
      
      expect(sortedSubs[0].id, '3'); // 45 minutes on bench
      expect(sortedSubs[1].id, '1'); // 30 minutes on bench
      expect(sortedSubs[2].id, '2'); // 15 minutes on bench
    });

    test('When bench times are equal, sorts by playing time (least first)', () {
      // Add equal bench time for all players
      final benchStartTime = DateTime.now().subtract(const Duration(minutes: 30));
      timeTracking.addRecord(PlayerTimeRecord(
        playerId: player1.id,
        startTime: benchStartTime,
        endTime: DateTime.now(),
      ));
      timeTracking.addRecord(PlayerTimeRecord(
        playerId: player2.id,
        startTime: benchStartTime,
        endTime: DateTime.now(),
      ));
      timeTracking.addRecord(PlayerTimeRecord(
        playerId: player3.id,
        startTime: benchStartTime,
        endTime: DateTime.now(),
      ));

      // Add different playing times
      timeTracking.addRecord(PlayerTimeRecord(
        playerId: player1.id,
        positionId: 'pos1',
        startTime: DateTime.now().subtract(const Duration(minutes: 45)),
        endTime: DateTime.now(),
      ));
      timeTracking.addRecord(PlayerTimeRecord(
        playerId: player2.id,
        positionId: 'pos2',
        startTime: DateTime.now().subtract(const Duration(minutes: 15)),
        endTime: DateTime.now(),
      ));
      timeTracking.addRecord(PlayerTimeRecord(
        playerId: player3.id,
        positionId: 'pos3',
        startTime: DateTime.now().subtract(const Duration(minutes: 30)),
        endTime: DateTime.now(),
      ));

      final sortedSubs = game.getSortedSubstitutes();
      
      expect(sortedSubs[0].id, '2'); // 15 minutes played
      expect(sortedSubs[1].id, '3'); // 30 minutes played
      expect(sortedSubs[2].id, '1'); // 45 minutes played
    });

    test('Maintains order when both times are equal', () {
      // Add equal times for all players
      final benchStartTime = DateTime.now().subtract(const Duration(minutes: 30));
      timeTracking.addRecord(PlayerTimeRecord(
        playerId: player1.id,
        startTime: benchStartTime,
        endTime: DateTime.now(),
      ));
      timeTracking.addRecord(PlayerTimeRecord(
        playerId: player2.id,
        startTime: benchStartTime,
        endTime: DateTime.now(),
      ));
      timeTracking.addRecord(PlayerTimeRecord(
        playerId: player3.id,
        startTime: benchStartTime,
        endTime: DateTime.now(),
      ));

      // Add equal playing times
      final playStartTime = DateTime.now().subtract(const Duration(minutes: 20));
      timeTracking.addRecord(PlayerTimeRecord(
        playerId: player1.id,
        positionId: 'pos1',
        startTime: playStartTime,
        endTime: DateTime.now(),
      ));
      timeTracking.addRecord(PlayerTimeRecord(
        playerId: player2.id,
        positionId: 'pos2',
        startTime: playStartTime,
        endTime: DateTime.now(),
      ));
      timeTracking.addRecord(PlayerTimeRecord(
        playerId: player3.id,
        positionId: 'pos3',
        startTime: playStartTime,
        endTime: DateTime.now(),
      ));

      final sortedSubs = game.getSortedSubstitutes();
      
      // Should maintain original order since all times are equal
      expect(sortedSubs[0].id, '1');
      expect(sortedSubs[1].id, '2');
      expect(sortedSubs[2].id, '3');
    });

    test('Handles players with no time records', () {
      // Don't add any time records
      final sortedSubs = game.getSortedSubstitutes();
      
      // Should maintain original order since no time records exist
      expect(sortedSubs[0].id, '1');
      expect(sortedSubs[1].id, '2');
      expect(sortedSubs[2].id, '3');
    });
  });
} 