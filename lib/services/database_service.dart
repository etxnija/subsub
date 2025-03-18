import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

import '../models/player.dart';
import '../models/game.dart';

final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService(),
);

class DatabaseService {
  static Database? _database;
  static const String databaseName = 'subsub.db';
  static const int _databaseVersion = 5; // Increase version to add periods

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);
    
    // Close the database if it's open
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    // Delete the database file
    await deleteDatabase(path);
    
    // Reinitialize the database
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);

    return await openDatabase(
      path, 
      version: _databaseVersion, 
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // For simplicity, just drop and recreate all tables
    await db.execute('DROP TABLE IF EXISTS games');
    await db.execute('DROP TABLE IF EXISTS players');
    await db.execute('DROP TABLE IF EXISTS game_roster');
    await db.execute('DROP TABLE IF EXISTS position_history');
    await db.execute('DROP TABLE IF EXISTS game_lineup');
    
    // Recreate tables
    await _createDatabase(db, newVersion);
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Players table with STRING ID
    await db.execute('''
      CREATE TABLE players(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        number INTEGER NOT NULL
      )
    ''');

    // Games table with STRING ID
    await db.execute('''
      CREATE TABLE games(
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        opponent TEXT NOT NULL,
        startingLineup TEXT NOT NULL,
        substitutes TEXT NOT NULL,
        periods TEXT NOT NULL DEFAULT '[]',
        status INTEGER NOT NULL DEFAULT 0
      )
    ''');
    
    // Game lineup table for player position assignments
    await db.execute('''
      CREATE TABLE game_lineup(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_id TEXT NOT NULL,
        position_id TEXT,
        player_id TEXT NOT NULL,
        is_substitute INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE
      )
    ''');

    // Seed the database with initial players
    await seedTopPlayers(db);
  }

  Future<void> seedTopPlayers([Database? providedDb]) async {
    final db = providedDb ?? await database;
    
    // Check if we already have players
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM players'));
    if (count != null && count > 0) return; // Don't seed if we already have players
    
    final topPlayers = [
      Player(id: const Uuid().v4(), name: 'Erling Haaland', number: 9),
      Player(id: const Uuid().v4(), name: 'Kylian Mbappé', number: 7),
      Player(id: const Uuid().v4(), name: 'Kevin De Bruyne', number: 17),
      Player(id: const Uuid().v4(), name: 'Jude Bellingham', number: 5),
      Player(id: const Uuid().v4(), name: 'Vinicius Jr', number: 20),
      Player(id: const Uuid().v4(), name: 'Rodri', number: 16),
      Player(id: const Uuid().v4(), name: 'Harry Kane', number: 9),
      Player(id: const Uuid().v4(), name: 'Mohamed Salah', number: 11),
      Player(id: const Uuid().v4(), name: 'Bukayo Saka', number: 7),
      Player(id: const Uuid().v4(), name: 'Phil Foden', number: 47),
    ];

    // Insert all players in a transaction
    await db.transaction((txn) async {
      for (final player in topPlayers) {
        await txn.insert(
          'players',
          player.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<Map<String, dynamic>?> getById(String table, String id) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> update(
    String table, 
    Map<String, dynamic> data, 
    String where, 
    List<Object> whereArgs
  ) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, 
    String where, 
    List<Object> whereArgs
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // Player-specific operations for backward compatibility
  Future<int> insertPlayer(Player player) async {
    return await insert('players', player.toMap());
  }

  Future<List<Player>> getAllPlayers() async {
    final maps = await getAll('players');
    return List.generate(maps.length, (i) => Player.fromMap(maps[i]));
  }

  Future<void> updatePlayer(Player player) async {
    await update(
      'players',
      player.toMap(),
      'id = ?',
      [player.id],
    );
  }

  Future<void> deletePlayer(String id) async {
    await delete('players', 'id = ?', [id]);
  }

  Future<String> insertGame(Game game) async {
    final db = await database;
    final uuid = const Uuid().v4();
    final gameMap = game.toMap()..['id'] = uuid;
    
    await db.transaction((txn) async {
      // Insert the game record
      await txn.insert('games', gameMap);
      
      // Insert lineup entries
      for (final entry in game.startingLineup.entries) {
        await txn.insert(
          'game_lineup',
          {
            'game_id': uuid,
            'position_id': entry.key,
            'player_id': entry.value.id,
            'is_substitute': 0,
          },
        );
      }
      
      // Insert substitute entries
      for (final player in game.substitutes) {
        await txn.insert(
          'game_lineup',
          {
            'game_id': uuid,
            'player_id': player.id,
            'is_substitute': 1,
          },
        );
      }
    });
    
    return uuid;
  }
  
  Future<void> deleteGame(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete lineup entries
      await txn.delete(
        'game_lineup',
        where: 'game_id = ?',
        whereArgs: [id],
      );
      
      // Delete the game record
      await txn.delete(
        'games',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> updateGame(Game game) async {
    final db = await database;
    await db.transaction((txn) async {
      // Update the game record
      await txn.update(
        'games',
        game.toMap(),
        where: 'id = ?',
        whereArgs: [game.id],
      );

      // Delete existing lineup entries
      await txn.delete(
        'game_lineup',
        where: 'game_id = ?',
        whereArgs: [game.id],
      );

      // Insert new lineup entries
      for (final entry in game.startingLineup.entries) {
        await txn.insert(
          'game_lineup',
          {
            'game_id': game.id,
            'position_id': entry.key,
            'player_id': entry.value.id,
            'is_substitute': 0,
          },
        );
      }

      // Insert substitute entries
      for (final player in game.substitutes) {
        await txn.insert(
          'game_lineup',
          {
            'game_id': game.id,
            'player_id': player.id,
            'is_substitute': 1,
          },
        );
      }
    });
  }

  Future<List<Game>> getGames() async {
    final db = await database;
    
    // Get all games
    final List<Map<String, dynamic>> games = await db.query('games');
    
    // For each game, get the lineup
    final List<Game> result = [];
    for (final gameMap in games) {
      final gameId = gameMap['id'] as String;
      
      // Get starting lineup
      final startingLineup = await db.query(
        'game_lineup',
        where: 'game_id = ? AND is_substitute = 0',
        whereArgs: [gameId],
      );
      
      // Get substitutes
      final substitutes = await db.query(
        'game_lineup',
        where: 'game_id = ? AND is_substitute = 1',
        whereArgs: [gameId],
      );
      
      // Get player details for each entry
      final Map<String, Player> lineup = {};
      for (final entry in startingLineup) {
        final positionId = entry['position_id'] as String;
        final playerId = entry['player_id'] as String;
        
        final playerData = await db.query(
          'players',
          where: 'id = ?',
          whereArgs: [playerId],
        );
        
        if (playerData.isNotEmpty) {
          lineup[positionId] = Player.fromMap(playerData.first);
        }
      }
      
      final List<Player> subs = [];
      for (final entry in substitutes) {
        final playerId = entry['player_id'] as String;
        
        final playerData = await db.query(
          'players',
          where: 'id = ?',
          whereArgs: [playerId],
        );
        
        if (playerData.isNotEmpty) {
          subs.add(Player.fromMap(playerData.first));
        }
      }
      
      // Create the Game object
      result.add(Game.fromMap({
        ...gameMap,
        'startingLineup': jsonEncode(lineup.map((key, value) => MapEntry(key, value.toMap()))),
        'substitutes': jsonEncode(subs.map((p) => p.toMap()).toList()),
      }));
    }
    
    return result;
  }
}
