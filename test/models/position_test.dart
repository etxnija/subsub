import 'package:flutter_test/flutter_test.dart';
import 'package:subsub/models/position.dart';

void main() {
  group('Position', () {
    test('should create a Position instance', () {
      const position = Position(
        id: 'gk',
        name: 'Goalkeeper',
        abbreviation: 'GK',
        category: 'Goalkeeper',
        defaultLocation: Offset(0.5, 0.18),
      );

      expect(position.id, equals('gk'));
      expect(position.name, equals('Goalkeeper'));
      expect(position.abbreviation, equals('GK'));
      expect(position.category, equals('Goalkeeper'));
      expect(position.defaultLocation, equals(const Offset(0.5, 0.18)));
    });

    group('standardPositions', () {
      test('should contain 7 positions for 2-3-1 formation', () {
        expect(Position.standardPositions.length, equals(7));
      });

      test('should have correct position categories', () {
        expect(
          Position.standardPositions
              .where((p) => p.category == 'Goalkeeper')
              .length,
          equals(1),
        );
        expect(
          Position.standardPositions
              .where((p) => p.category == 'Defense')
              .length,
          equals(2),
        );
        expect(
          Position.standardPositions
              .where((p) => p.category == 'Midfield')
              .length,
          equals(3),
        );
        expect(
          Position.standardPositions
              .where((p) => p.category == 'Forward')
              .length,
          equals(1),
        );
      });

      test('should have valid coordinates', () {
        for (final position in Position.standardPositions) {
          expect(position.defaultLocation.dx, greaterThanOrEqualTo(0.0));
          expect(position.defaultLocation.dx, lessThanOrEqualTo(1.0));
          expect(position.defaultLocation.dy, greaterThanOrEqualTo(0.0));
          expect(position.defaultLocation.dy, lessThanOrEqualTo(1.0));
        }
      });

      test('should have unique IDs', () {
        final ids = Position.standardPositions.map((p) => p.id).toSet();
        expect(ids.length, equals(Position.standardPositions.length));
      });

      test('goalkeeper should be positioned at the back', () {
        final goalkeeper = Position.standardPositions.firstWhere(
          (p) => p.id == 'gk',
        );
        expect(
          goalkeeper.defaultLocation.dy,
          lessThan(0.2),
        ); // Goalkeeper should be near the back
        expect(
          goalkeeper.defaultLocation.dx,
          closeTo(0.5, 0.1),
        ); // Goalkeeper should be centered
      });
    });

    group('Position helper methods', () {
      test('getByCategory should return correct positions', () {
        final goalkeepers = Position.getByCategory('Goalkeeper');
        expect(goalkeepers.length, equals(1));
        expect(goalkeepers.first.id, equals('gk'));

        final defenders = Position.getByCategory('Defense');
        expect(defenders.length, equals(2));
        expect(defenders.map((p) => p.id).toSet(), equals({'dl', 'dr'}));
      });

      test('getById should return correct position', () {
        final goalkeeper = Position.getById('gk');
        expect(goalkeeper, isNotNull);
        expect(goalkeeper!.id, equals('gk'));
        expect(goalkeeper.category, equals('Goalkeeper'));

        final nonExistent = Position.getById('nonexistent');
        expect(nonExistent, isNull);
      });
    });
  });
}
