import 'package:flutter_test/flutter_test.dart';
import 'package:subsub/models/position.dart';

void main() {
  group('Position', () {
    test('should create a Position instance', () {
      const position = Position(
        id: 'GK',
        type: PositionType.goalkeeper,
        x: 0.5,
        y: 0.1,
        displayName: 'GK',
      );
      
      expect(position.id, equals('GK'));
      expect(position.type, equals(PositionType.goalkeeper));
      expect(position.x, equals(0.5));
      expect(position.y, equals(0.1));
      expect(position.displayName, equals('GK'));
    });

    group('defaultFormation', () {
      test('should contain 7 positions for 2-3-1 formation', () {
        const formation = Position.defaultFormation;
        expect(formation.length, equals(7));
      });

      test('should have correct position types', () {
        const formation = Position.defaultFormation;

        expect(formation.where((p) => p.type == PositionType.goalkeeper).length,
            equals(1));
        expect(formation.where((p) => p.type == PositionType.defender).length,
            equals(2));
        expect(formation.where((p) => p.type == PositionType.midfielder).length,
            equals(3));
        expect(formation.where((p) => p.type == PositionType.forward).length,
            equals(1));
      });

      test('should have valid coordinates', () {
        for (final position in Position.defaultFormation) {
          expect(position.x, greaterThanOrEqualTo(0.0));
          expect(position.x, lessThanOrEqualTo(1.0));
          expect(position.y, greaterThanOrEqualTo(0.0));
          expect(position.y, lessThanOrEqualTo(1.0));
        }
      });

      test('should have unique IDs', () {
        final ids = Position.defaultFormation.map((p) => p.id).toSet();
        expect(ids.length, equals(Position.defaultFormation.length));
      });

      test('goalkeeper should be positioned at the back', () {
        const goalkeeper = Position(
          id: 'GK',
          type: PositionType.goalkeeper,
          x: 0.5,
          y: 0.1,
          displayName: 'GK',
        );

        expect(goalkeeper.y, lessThan(0.2)); // Goalkeeper should be near the back
        expect(goalkeeper.x, closeTo(0.5, 0.1)); // Goalkeeper should be centered
      });
    });
  });
}
