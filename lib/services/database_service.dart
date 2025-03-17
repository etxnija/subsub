import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/game.dart';
import '../models/player.dart';

final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService(),
);

class DatabaseService {
  static Database? _database;
  static const String databaseName = 'subsub.db';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Players table
    await db.execute('''
      CREATE TABLE players(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        number INTEGER NOT NULL
      )
    ''');

    // Games table
    await db.execute('''
      CREATE TABLE games(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        numberOfPeriods INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        status TEXT NOT NULL,
        startTime TEXT,
        endTime TEXT
      )
    ''');

    // Game roster table (many-to-many relationship)
    await db.execute('''
      CREATE TABLE game_roster(
        gameId INTEGER,
        playerId INTEGER,
        PRIMARY KEY (gameId, playerId),
        FOREIGN KEY (gameId) REFERENCES games(id) ON DELETE CASCADE,
        FOREIGN KEY (playerId) REFERENCES players(id) ON DELETE CASCADE
      )
    ''');

    // Position history table
    await db.execute('''
      CREATE TABLE position_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gameId INTEGER,
        playerId INTEGER,
        positionId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        FOREIGN KEY (gameId) REFERENCES games(id) ON DELETE CASCADE,
        FOREIGN KEY (playerId) REFERENCES players(id) ON DELETE CASCADE
      )
    ''');
  }

  // Player operations
  Future<int> insertPlayer(Player player) async {
    final db = await database;
    return await db.insert('players', player.toMap());
  }

  Future<List<Player>> getAllPlayers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('players');
    return List.generate(maps.length, (i) => Player.fromMap(maps[i]));
  }

  Future<void> updatePlayer(Player player) async {
    final db = await database;
    await db.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<void> deletePlayer(int id) async {
    final db = await database;
    await db.delete('players', where: 'id = ?', whereArgs: [id]);
  }

  // Game operations
  Future<int> insertGame(Game game) async {
    final db = await database;
    final gameId = await db.insert('games', game.toMap());

    // Insert game roster
    for (final player in game.roster) {
      await db.insert('game_roster', {'gameId': gameId, 'playerId': player.id});
    }

    return gameId;
  }

  Future<List<Game>> getRecentGames({int limit = 12}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'games',
      orderBy: 'createdAt DESC',
      limit: limit,
    );

    final games = <Game>[];
    for (final map in maps) {
      final game = Game.fromMap(map);
      // Load roster for each game
      final roster = await _getGameRoster(game.id!);
      games.add(game.copyWith(roster: roster));
    }

    return games;
  }

  Future<List<Player>> _getGameRoster(int gameId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT p.* FROM players p
      INNER JOIN game_roster gr ON gr.playerId = p.id
      WHERE gr.gameId = ?
    ''',
      [gameId],
    );

    return List.generate(maps.length, (i) => Player.fromMap(maps[i]));
  }

  Future<void> deleteGame(int id) async {
    final db = await database;
    await db.delete('games', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllGames() async {
    final db = await database;
    await db.delete('games');
    await db.delete('game_roster');
    await db.delete('position_history');
  }
}
