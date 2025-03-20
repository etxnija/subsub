import 'package:flutter_test/flutter_test.dart';
import 'package:subsub/models/player.dart';

void main() {
  group('Player', () {
    test('should create a Player instance', () {
      const player = Player(id: 'player1', name: 'John Doe', number: 10);

      expect(player.id, equals('player1'));
      expect(player.name, equals('John Doe'));
      expect(player.number, equals(10));
    });

    test('should create a Player from map', () {
      final map = {'id': 'player1', 'name': 'John Doe', 'number': 10};

      final player = Player.fromMap(map);

      expect(player.id, equals('player1'));
      expect(player.name, equals('John Doe'));
      expect(player.number, equals(10));
    });

    test('should convert Player to map', () {
      const player = Player(id: 'player1', name: 'John Doe', number: 10);

      final map = player.toMap();

      expect(map['id'], equals('player1'));
      expect(map['name'], equals('John Doe'));
      expect(map['number'], equals(10));
    });

    test('should copy with new values', () {
      const player = Player(id: 'player1', name: 'John Doe', number: 10);

      final newPlayer = player.copyWith(name: 'Jane Doe', number: 11);

      expect(newPlayer.id, equals('player1'));
      expect(newPlayer.name, equals('Jane Doe'));
      expect(newPlayer.number, equals(11));
    });

    test('toString should contain all properties', () {
      const player = Player(id: 'player1', name: 'John Doe', number: 10);

      expect(player.toString(), contains('id: player1'));
      expect(player.toString(), contains('name: John Doe'));
      expect(player.toString(), contains('number: 10'));
    });
  });
}
