enum PositionType { goalkeeper, defender, midfielder, forward }

class Position {
  final String id; // e.g., "GK", "D1", "D2", "M1", "M2", "M3", "F"
  final PositionType type;
  final double x; // Normalized position (0-1) for field layout
  final double y; // Normalized position (0-1) for field layout
  final String displayName;

  const Position({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.displayName,
  });

  // Predefined positions for 2-3-1 formation
  static const List<Position> defaultFormation = [
    Position(
      id: 'GK',
      type: PositionType.goalkeeper,
      x: 0.5,
      y: 0.1,
      displayName: 'GK',
    ),
    Position(
      id: 'D1',
      type: PositionType.defender,
      x: 0.3,
      y: 0.3,
      displayName: 'D',
    ),
    Position(
      id: 'D2',
      type: PositionType.defender,
      x: 0.7,
      y: 0.3,
      displayName: 'D',
    ),
    Position(
      id: 'M1',
      type: PositionType.midfielder,
      x: 0.2,
      y: 0.5,
      displayName: 'M',
    ),
    Position(
      id: 'M2',
      type: PositionType.midfielder,
      x: 0.5,
      y: 0.5,
      displayName: 'M',
    ),
    Position(
      id: 'M3',
      type: PositionType.midfielder,
      x: 0.8,
      y: 0.5,
      displayName: 'M',
    ),
    Position(
      id: 'F',
      type: PositionType.forward,
      x: 0.5,
      y: 0.7,
      displayName: 'F',
    ),
  ];
}
