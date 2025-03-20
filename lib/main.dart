import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subsub/router.dart';
import 'package:subsub/services/database_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

// Flag to track if we've already reset the database
const String kDbVersionKey = 'db_version';
const int kCurrentDbVersion =
    6; // Match this with the version in database_service.dart

Future<void> main() async {
  // Ensure Flutter is initialized before doing anything else
  WidgetsFlutterBinding.ensureInitialized();

  // Wrap the app initialization in error handling
  try {
    // Reset the database to handle schema changes
    final dbService = DatabaseService();
    await dbService.resetDatabase();

    // Run the app inside a try-catch to catch any startup errors
    runApp(const ProviderScope(child: App()));
  } catch (e, stackTrace) {
    // If there's an error during initialization, show an error screen
    print('Error during app initialization: $e\n$stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to start the app',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Get the database path
                        final databasesPath = await getDatabasesPath();
                        final dbPath = path.join(databasesPath, 'subsub.db');

                        // Delete the database file if it exists
                        if (await databaseExists(dbPath)) {
                          await deleteDatabase(dbPath);
                        }

                        // Clear shared preferences
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();

                        // Exit the app - user needs to restart manually
                        exit(0);
                      } catch (e) {
                        print('Error during recovery: $e');
                      }
                    },
                    child: const Text('Reset App Data'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SubSub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
