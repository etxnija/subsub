import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subsub/router.dart';
import 'package:subsub/services/database_service.dart';

// Flag to track if we've already reset the database
const String kDbVersionKey = 'db_version';
const int kCurrentDbVersion =
    3; // Match this with the version in database_service.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reset the database to handle schema changes
  final dbService = DatabaseService();
  await dbService.resetDatabase();

  runApp(const ProviderScope(child: App()));
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
