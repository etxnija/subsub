import 'package:flutter_test/flutter_test.dart';
import 'package:subsub/models/game.dart';
import 'package:subsub/models/player.dart';
import 'package:subsub/models/position.dart';

void main() {
  group('Game', () {
    test('should create a Game instance', () {
      final date = DateTime.now();
      final game = Game(
        id: 'game1',
        date: date,
        opponent: 'Team A',
        startingLineup: {},
        substitutes: const [],
        periods: Game.defaultPeriods(),
      );

      expect(game.id, equals('game1'));
      expect(game.date, equals(date));
      expect(game.opponent, equals('Team A'));
      expect(game.startingLineup, isEmpty);
      expect(game.substitutes, isEmpty);
      expect(game.periods.length, equals(3)); // Default periods
      expect(game.status, equals(GameStatus.setup));
    });

    test('should create a Game from map', () {
      final date = DateTime.now();
      final Map<String, dynamic> map = {
        'id': 'game1',
        'date': date.toIso8601String(),
        'opponent': 'Team A',
        'startingLineup': <String, dynamic>{},
        'substitutes': <dynamic>[],
        'periods': <dynamic>[],
        'status': GameStatus.setup.toString(),
        'timeTracking': <String, dynamic>{'playerRecords': <String, dynamic>{}},
      };

      final game = Game.fromMap(map);

      expect(game.id, equals('game1'));
      expect(game.date.toIso8601String(), equals(date.toIso8601String()));
      expect(game.opponent, equals('Team A'));
      expect(game.startingLineup, isEmpty);
      expect(game.substitutes, isEmpty);
      expect(game.periods, isEmpty);
      expect(game.status, equals(GameStatus.setup));
    });

    test('should convert Game to map', () {
      final date = DateTime.now();
      final player = Player(id: 'player1', name: 'John Doe', number: 10);

      final game = Game(
        id: 'game1',
        date: date,
        opponent: 'Team A',
        startingLineup: {'gk': player},
        substitutes: const [],
        periods: Game.defaultPeriods(),
      );

      final map = game.toMap();

      expect(map['id'], equals('game1'));
      expect(map['date'], equals(date.toIso8601String()));
      expect(map['opponent'], equals('Team A'));
      expect(map['startingLineup'], isNotEmpty);
      expect(map['substitutes'], isEmpty);
      expect(map['periods'], hasLength(3));
      expect(map['status'], equals(GameStatus.setup.toString()));
    });

    test('should copy with new values', () {
      final date = DateTime.now();
      final game = Game(
        id: 'game1',
        date: date,
        opponent: 'Team A',
        startingLineup: {},
        substitutes: const [],
        periods: Game.defaultPeriods(),
      );

      final newGame = game.copyWith(
        opponent: 'Team B',
        status: GameStatus.inProgress,
      );

      expect(newGame.id, equals('game1'));
      expect(newGame.date, equals(date));
      expect(newGame.opponent, equals('Team B'));
      expect(newGame.startingLineup, isEmpty);
      expect(newGame.substitutes, isEmpty);
      expect(newGame.periods.length, equals(3));
      expect(newGame.status, equals(GameStatus.inProgress));
    });

    test('should calculate substitutes correctly', () {
      final date = DateTime.now();
      final player1 = Player(id: 'player1', name: 'Player 1', number: 1);
      final player2 = Player(id: 'player2', name: 'Player 2', number: 2);

      final game = Game(
        id: 'game1',
        date: date,
        opponent: 'Team A',
        startingLineup: {'gk': player1},
        substitutes: [player2],
        periods: Game.defaultPeriods(),
      );

      expect(game.substitutes.length, equals(1));
      expect(game.substitutes.first.id, equals('player2'));
    });

    group('Game time tracking', () {
      test('should track player time correctly', () {
        final date = DateTime.now();
        final player = Player(id: 'player1', name: 'John Doe', number: 10);

        final game = Game(
          id: 'game1',
          date: date,
          opponent: 'Team A',
          startingLineup: {'gk': player},
          substitutes: const [],
          periods: Game.defaultPeriods(),
        );

        game.recordPlayerStart(player.id, positionId: 'gk');
        expect(game.getMinutesPlayed(player.id), equals(0)); // Just started

        game.recordPlayerEnd(player.id);
        expect(game.getMinutesPlayed(player.id), greaterThanOrEqualTo(0));
      });

      test('should track bench time correctly', () {
        final date = DateTime.now();
        final player = Player(id: 'player1', name: 'John Doe', number: 10);

        final game = Game(
          id: 'game1',
          date: date,
          opponent: 'Team A',
          startingLineup: {},
          substitutes: [player],
          periods: Game.defaultPeriods(),
        );

        expect(
          game.getMinutesOnBench(player.id),
          equals(0),
        ); // Game hasn't started
      });
    });
  });
}
