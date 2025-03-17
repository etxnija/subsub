import 'package:flutter_test/flutter_test.dart';
import 'package:subsub/models/game.dart';
import 'package:subsub/models/player.dart';

void main() {
  group('Game', () {
    test('should create a Game instance', () {
      final createdAt = DateTime.now();
      final game = Game(
        name: 'Game vs Team A',
        numberOfPeriods: 4,
        createdAt: createdAt,
        roster: const [],
      );
      
      expect(game.name, equals('Game vs Team A'));
      expect(game.numberOfPeriods, equals(4));
      expect(game.createdAt, equals(createdAt));
      expect(game.roster, isEmpty);
      expect(game.id, isNull);
      expect(game.status, equals(GameStatus.setup));
    });

    test('should create a Game from map', () {
      final createdAt = DateTime.now();
      final map = {
        'id': 1,
        'name': 'Game vs Team A',
        'numberOfPeriods': 4,
        'createdAt': createdAt.toIso8601String(),
        'status': GameStatus.setup.name,
      };

      final game = Game.fromMap(map);

      expect(game.id, equals(1));
      expect(game.name, equals('Game vs Team A'));
      expect(game.numberOfPeriods, equals(4));
      expect(game.createdAt.toIso8601String(), equals(createdAt.toIso8601String()));
      expect(game.status, equals(GameStatus.setup));
      expect(game.roster, isEmpty);
    });

    test('should convert Game to map', () {
      final createdAt = DateTime.now();
      const player = Player(
        id: 1,
        name: 'John Doe',
        number: 10,
      );

      final game = Game(
        id: 1,
        name: 'Game vs Team A',
        numberOfPeriods: 4,
        createdAt: createdAt,
        roster: const [player],
      );

      final map = game.toMap();

      expect(map['id'], equals(1));
      expect(map['name'], equals('Game vs Team A'));
      expect(map['numberOfPeriods'], equals(4));
      expect(map['createdAt'], equals(createdAt.toIso8601String()));
      expect(map['status'], equals(GameStatus.setup.name));
    });

    test('should copy with new values', () {
      final createdAt = DateTime.now();
      final game = Game(
        id: 1,
        name: 'Game vs Team A',
        numberOfPeriods: 4,
        createdAt: createdAt,
        roster: const [],
      );

      final newGame = game.copyWith(
        name: 'Game vs Team B',
        numberOfPeriods: 2,
      );

      expect(newGame.id, equals(1));
      expect(newGame.name, equals('Game vs Team B'));
      expect(newGame.numberOfPeriods, equals(2));
      expect(newGame.createdAt, equals(createdAt));
      expect(newGame.roster, isEmpty);
    });

    test('toString should contain all properties', () {
      final createdAt = DateTime.now();
      final game = Game(
        id: 1,
        name: 'Game vs Team A',
        numberOfPeriods: 4,
        createdAt: createdAt,
        roster: const [],
      );

      expect(game.toString(), contains('id: 1'));
      expect(game.toString(), contains('name: Game vs Team A'));
      expect(game.toString(), contains('numberOfPeriods: 4'));
      expect(game.toString(), contains('createdAt: ${createdAt.toString()}'));
      expect(game.toString(), contains('roster: []'));
      expect(game.toString(), contains('status: ${GameStatus.setup.name}'));
    });

    test('should calculate substitutes correctly', () {
      final createdAt = DateTime.now();
      const player1 = Player(id: 1, name: 'Player 1', number: 1);
      const player2 = Player(id: 2, name: 'Player 2', number: 2);
      
      final game = Game(
        name: 'Test Game',
        numberOfPeriods: 4,
        createdAt: createdAt,
        roster: const [player1, player2],
        currentPositions: const {'pos1': player1},
      );

      final subs = game.substitutes;
      expect(subs.length, equals(1));
      expect(subs.first, equals(player2));
    });
  });
} 