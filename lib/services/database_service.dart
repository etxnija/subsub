import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/player.dart';
import '../models/game.dart';
import '../models/player_time.dart';

final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService(),
);

class DatabaseService {
  static Database? _database;
  static const String databaseName = 'subsub.db';
  static const int _databaseVersion = 6; // Increase version to add periods
  static const String kDbVersionKey = 'db_version';
  static const int kCurrentDbVersion = 6;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<void> resetDatabase() async {
    try {
      // Close any existing database connection
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, databaseName);

      // Get current version from preferences
      final prefs = await SharedPreferences.getInstance();
      final currentVersion = prefs.getInt(kDbVersionKey) ?? 0;

      // Always close and reopen the database in release mode
      if (await databaseExists(path)) {
        _database = await openDatabase(
          path,
          version: kCurrentDbVersion,
          onCreate: _createDatabase,
          onUpgrade: _onUpgrade,
        );
      } else {
        // Create a new database if it doesn't exist
        _database = await openDatabase(
          path,
          version: kCurrentDbVersion,
          onCreate: _createDatabase,
        );

        // Seed initial data
        await seedTopPlayers(_database);

        // Update version in preferences
        await prefs.setInt(kDbVersionKey, kCurrentDbVersion);
      }
    } catch (e, stackTrace) {
      print('Error resetting database: $e\n$stackTrace');
      // Attempt to recover by deleting the database file and trying again
      try {
        if (_database != null) {
          await _database!.close();
          _database = null;
        }

        final databasesPath = await getDatabasesPath();
        final path = join(databasesPath, databaseName);

        if (await databaseExists(path)) {
          await deleteDatabase(path);
        }

        // Create a new database from scratch
        _database = await openDatabase(
          path,
          version: kCurrentDbVersion,
          onCreate: _createDatabase,
        );

        // Seed initial data
        await seedTopPlayers(_database);

        // Reset the version in preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(kDbVersionKey, kCurrentDbVersion);
      } catch (e2) {
        print('Failed to recover database: $e2');
        rethrow; // If recovery fails, let the app show the error screen
      }
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS game_lineup (
          game_id TEXT NOT NULL,
          position_id TEXT NOT NULL,
          player_id TEXT NOT NULL,
          FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE,
          PRIMARY KEY (game_id, position_id)
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE games ADD COLUMN time_tracking TEXT DEFAULT '{}'
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS game_periods (
          game_id TEXT NOT NULL,
          period_number INTEGER NOT NULL,
          start_time TEXT,
          end_time TEXT,
          FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE,
          PRIMARY KEY (game_id, period_number)
        )
      ''');
    }

    if (oldVersion < 5) {
      await db.execute('''
        ALTER TABLE games ADD COLUMN status TEXT DEFAULT 'scheduled'
      ''');
    }

    if (oldVersion < 6) {
      // Update the games table to use proper JSON for time tracking
      await db.execute('''
        ALTER TABLE games ADD COLUMN time_tracking_json TEXT DEFAULT '{}'
      ''');

      // Migrate existing time tracking data
      final games = await db.query('games');
      for (final game in games) {
        final timeTracking = game['time_tracking'] as String? ?? '{}';
        await db.update(
          'games',
          {'time_tracking_json': timeTracking},
          where: 'id = ?',
          whereArgs: [game['id']],
        );
      }

      // Drop the old column
      await db.execute('''
        ALTER TABLE games DROP COLUMN time_tracking
      ''');

      // Rename the new column
      await db.execute('''
        ALTER TABLE games RENAME COLUMN time_tracking_json TO time_tracking
      ''');
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS players (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        number INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS games (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        opponent TEXT NOT NULL,
        startingLineup TEXT NOT NULL DEFAULT '{}',
        substitutes TEXT NOT NULL DEFAULT '[]',
        periods TEXT NOT NULL DEFAULT '[]',
        status TEXT NOT NULL DEFAULT 'setup',
        timeTracking TEXT NOT NULL DEFAULT '{}'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS game_lineup (
        game_id TEXT NOT NULL,
        position_id TEXT NOT NULL,
        player_id TEXT NOT NULL,
        FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE,
        PRIMARY KEY (game_id, position_id)
      )
    ''');

    // Seed the database with initial players
    await seedTopPlayers(db);
  }

  Future<void> seedTopPlayers([Database? providedDb]) async {
    final db = providedDb ?? await database;

    // Check if we already have players
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM players'),
    );
    if (count != null && count > 0)
      return; // Don't seed if we already have players

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
    List<Object> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String where, List<Object> whereArgs) async {
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
    await update('players', player.toMap(), 'id = ?', [player.id]);
  }

  Future<void> deletePlayer(String id) async {
    await delete('players', 'id = ?', [id]);
  }

  Future<void> insertGame(Game game) async {
    final db = await database;
    await db.transaction((txn) async {
      // Convert complex types to JSON strings
      final lineupJson = jsonEncode(
        game.startingLineup.map((key, value) => MapEntry(key, value.toMap())),
      );

      final substitutesJson = jsonEncode(
        game.substitutes.map((p) => p.toMap()).toList(),
      );
      final periodsJson = jsonEncode(
        game.periods.map((p) => p.toMap()).toList(),
      );
      final timeTrackingJson = jsonEncode(game.timeTracking.toMap());

      await txn.insert('games', {
        'id': game.id,
        'date': game.date.toIso8601String(),
        'opponent': game.opponent,
        'startingLineup': lineupJson,
        'substitutes': substitutesJson,
        'periods': periodsJson,
        'status': game.status.toString(),
        'timeTracking': timeTrackingJson,
      });

      // Insert lineup entries
      for (final entry in game.startingLineup.entries) {
        await txn.insert('game_lineup', {
          'game_id': game.id,
          'position_id': entry.key,
          'player_id': entry.value.id,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<void> deleteGame(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete lineup entries
      await txn.delete('game_lineup', where: 'game_id = ?', whereArgs: [id]);

      // Delete the game record
      await txn.delete('games', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> updateGame(Game game) async {
    final db = await database;
    await db.transaction((txn) async {
      // Convert complex types to JSON strings
      final lineupJson = jsonEncode(
        game.startingLineup.map((key, value) => MapEntry(key, value.toMap())),
      );

      final substitutesJson = jsonEncode(
        game.substitutes.map((p) => p.toMap()).toList(),
      );
      final periodsJson = jsonEncode(
        game.periods.map((p) => p.toMap()).toList(),
      );
      final timeTrackingJson = jsonEncode(game.timeTracking.toMap());

      await txn.update(
        'games',
        {
          'date': game.date.toIso8601String(),
          'opponent': game.opponent,
          'startingLineup': lineupJson,
          'substitutes': substitutesJson,
          'periods': periodsJson,
          'status': game.status.toString(),
          'timeTracking': timeTrackingJson,
        },
        where: 'id = ?',
        whereArgs: [game.id],
      );

      // Update game lineup
      await txn.delete(
        'game_lineup',
        where: 'game_id = ?',
        whereArgs: [game.id],
      );
      for (final entry in game.startingLineup.entries) {
        await txn.insert('game_lineup', {
          'game_id': game.id,
          'position_id': entry.key,
          'player_id': entry.value.id,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<Game?> getGame(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'games',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;

    // Parse JSON strings back to complex types
    final lineupJson =
        jsonDecode(map['startingLineup'] as String) as Map<String, dynamic>;
    final lineup = lineupJson.map(
      (key, value) =>
          MapEntry(key, Player.fromMap(value as Map<String, dynamic>)),
    );

    final substitutesJson =
        jsonDecode(map['substitutes'] as String) as List<dynamic>;
    final substitutes =
        substitutesJson
            .map((item) => Player.fromMap(item as Map<String, dynamic>))
            .toList();

    final periodsJson = jsonDecode(map['periods'] as String) as List<dynamic>;
    final periods =
        periodsJson
            .map((item) => GamePeriod.fromMap(item as Map<String, dynamic>))
            .toList();

    final timeTrackingJson =
        jsonDecode(map['timeTracking'] as String) as Map<String, dynamic>;
    final timeTracking = GameTimeTracking.fromMap(timeTrackingJson);

    return Game(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      opponent: map['opponent'] as String,
      startingLineup: lineup,
      substitutes: substitutes,
      periods: periods,
      status: GameStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => GameStatus.setup,
      ),
      timeTracking: timeTracking,
    );
  }

  Future<List<Game>> getGames() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('games');

    return maps.map((map) {
      try {
        // Parse JSON strings back to complex types with null safety
        final lineupJson =
            map['startingLineup'] != null
                ? jsonDecode(map['startingLineup'] as String)
                    as Map<String, dynamic>
                : <String, dynamic>{};
        final lineup = lineupJson.map(
          (key, value) =>
              MapEntry(key, Player.fromMap(value as Map<String, dynamic>)),
        );

        final substitutesJson =
            map['substitutes'] != null
                ? jsonDecode(map['substitutes'] as String) as List<dynamic>
                : <dynamic>[];
        final substitutes =
            substitutesJson
                .map((item) => Player.fromMap(item as Map<String, dynamic>))
                .toList();

        final periodsJson =
            map['periods'] != null
                ? jsonDecode(map['periods'] as String) as List<dynamic>
                : <dynamic>[];
        final periods =
            periodsJson
                .map((item) => GamePeriod.fromMap(item as Map<String, dynamic>))
                .toList();

        final timeTrackingJson =
            map['timeTracking'] != null
                ? jsonDecode(map['timeTracking'] as String)
                    as Map<String, dynamic>
                : <String, dynamic>{};
        final timeTracking = GameTimeTracking.fromMap(timeTrackingJson);

        return Game(
          id: map['id'] as String,
          date: DateTime.parse(map['date'] as String),
          opponent: map['opponent'] as String,
          startingLineup: lineup,
          substitutes: substitutes,
          periods: periods,
          status: GameStatus.values.firstWhere(
            (e) => e.toString() == map['status'],
            orElse: () => GameStatus.setup,
          ),
          timeTracking: timeTracking,
        );
      } catch (e) {
        print('Error parsing game data: $e');
        print('Raw data: ${map['startingLineup']}');
        // Return a default game object with empty data
        return Game(
          id: map['id'] as String,
          date: DateTime.parse(map['date'] as String),
          opponent: map['opponent'] as String,
          startingLineup: {},
          substitutes: [],
          periods: [],
          status: GameStatus.setup,
          timeTracking: GameTimeTracking(),
        );
      }
    }).toList();
  }
}
