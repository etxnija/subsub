class Player {
  final int? id; // null when not yet saved to database
  final String name;
  final int number;

  const Player({
    this.id,
    required this.name,
    required this.number,
  });

  Player copyWith({
    int? id,
    String? name,
    int? number,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'number': number,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as int,
      name: map['name'] as String,
      number: map['number'] as int,
    );
  }

  @override
  String toString() => 'Player(id: $id, name: $name, number: $number)';
}
