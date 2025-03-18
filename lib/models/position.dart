import 'package:flutter/material.dart';

@immutable
class Position {
  final String id;
  final String name;
  final String abbreviation;
  final String category; // e.g., "Forward", "Midfield", "Defense", "Goalkeeper"
  final Offset defaultLocation; // Normalized position (0-1) for field layout

  const Position({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.category,
    required this.defaultLocation,
  });

  // 7v7 positions with 2-3-1 formation
  static const List<Position> standardPositions = [
    // Goalkeeper
    Position(
      id: 'gk',
      name: 'Goalkeeper',
      abbreviation: 'GK',
      category: 'Goalkeeper',
      defaultLocation: Offset(0.5, 0.18),  // Aligned with goal area
    ),
    // Defenders (2)
    Position(
      id: 'dl',
      name: 'Left Defender',
      abbreviation: 'DL',
      category: 'Defense',
      defaultLocation: Offset(0.25, 0.35),  // Aligned with penalty area width
    ),
    Position(
      id: 'dr',
      name: 'Right Defender',
      abbreviation: 'DR',
      category: 'Defense',
      defaultLocation: Offset(0.75, 0.35),  // Aligned with penalty area width
    ),
    // Midfielders (3)
    Position(
      id: 'ml',
      name: 'Left Midfielder',
      abbreviation: 'ML',
      category: 'Midfield',
      defaultLocation: Offset(0.2, 0.58),  // Wider spread, aligned with center
    ),
    Position(
      id: 'mc',
      name: 'Center Midfielder',
      abbreviation: 'MC',
      category: 'Midfield',
      defaultLocation: Offset(0.5, 0.52),  // Just above center line
    ),
    Position(
      id: 'mr',
      name: 'Right Midfielder',
      abbreviation: 'MR',
      category: 'Midfield',
      defaultLocation: Offset(0.8, 0.58),  // Wider spread, aligned with center
    ),
    // Forward (1)
    Position(
      id: 'st',
      name: 'Striker',
      abbreviation: 'ST',
      category: 'Forward',
      defaultLocation: Offset(0.5, 0.75),  // Centered in attacking third
    ),
  ];

  // Helper method to get positions by category
  static List<Position> getByCategory(String category) {
    return standardPositions
        .where((position) => position.category == category)
        .toList();
  }

  // Helper method to get position by ID
  static Position? getById(String id) {
    try {
      return standardPositions.firstWhere((position) => position.id == id);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
      'category': category,
    };
  }

  factory Position.fromMap(Map<String, dynamic> map) {
    return Position(
      id: map['id'] as String,
      name: map['name'] as String,
      abbreviation: map['abbreviation'] as String,
      category: map['category'] as String,
      defaultLocation: const Offset(0.5, 0.5), // Default center position
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          abbreviation == other.abbreviation &&
          category == other.category;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ abbreviation.hashCode ^ category.hashCode;

  @override
  String toString() => '$name ($abbreviation)';
}
