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
  Future<void> deletePlayer(int id) async {}

  @override
  Future<Database> get database async => throw UnimplementedError();

  // Implement other methods as needed
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('App should render roster screen', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        databaseServiceProvider.overrideWithValue(MockDatabaseService()),
      ],
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const SubSubApp()),
    );

    // Verify that we have the roster screen title
    expect(find.text('Team Roster'), findsOneWidget);

    // Verify that we have an add button
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
