// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:subsub/main.dart';
import 'package:subsub/models/game.dart';
import 'package:subsub/models/player.dart';
import 'package:subsub/services/database_service.dart';

class MockDatabaseService implements DatabaseService {
  @override
  Future<List<Player>> getAllPlayers() async => [];

  @override
  Future<int> insertPlayer(Player player) async => 1;

  @override
  Future<void> updatePlayer(Player player) async {}

  @override
  Future<void> deletePlayer(String id) async {}

  @override
  Future<Database> get database async => throw UnimplementedError();

  @override
  Future<void> resetDatabase() async {}

  @override
  Future<List<Player>> getPlayersForGame(String gameId) async => [];

  @override
  Future<void> updateGamePlayers(String gameId, List<Player> players) async {}

  @override
  Future<int> delete(
    String table,
    String where,
    List<Object> whereArgs,
  ) async => 1;

  @override
  Future<void> deleteGame(String id) async {}

  @override
  Future<List<Map<String, dynamic>>> getAll(String table) async => [];

  @override
  Future<Map<String, dynamic>?> getById(String table, String id) async => null;

  @override
  Future<Game?> getGame(String id) async => null;

  @override
  Future<List<Game>> getGames() async => [];

  @override
  Future<int> insert(String table, Map<String, dynamic> data) async => 1;

  @override
  Future<void> insertGame(Game game) async {}

  @override
  Future<void> seedTopPlayers([Database? providedDb]) async {}

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List<Object> whereArgs,
  ) async => 1;

  @override
  Future<void> updateGame(Game game) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('App should render games screen', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        databaseServiceProvider.overrideWithValue(MockDatabaseService()),
      ],
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const App()),
    );

    // Verify that we have the games screen title in the AppBar
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Games')),
      findsOneWidget,
    );

    // Verify that we have an add button
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
