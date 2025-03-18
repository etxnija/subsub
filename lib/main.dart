import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subsub/router.dart';
import 'package:subsub/services/database_service.dart';

// Flag to track if we've already reset the database
const String kDbVersionKey = 'db_version';
const int kCurrentDbVersion = 3; // Match this with the version in database_service.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if we need to reset the database
  final prefs = await SharedPreferences.getInstance();
  final storedVersion = prefs.getInt(kDbVersionKey) ?? 0;
  
  if (storedVersion < kCurrentDbVersion) {
    // Reset database for schema changes
    final dbService = DatabaseService();
    await dbService.resetDatabase();
    
    // Update stored version
    await prefs.setInt(kDbVersionKey, kCurrentDbVersion);
  }
  
  runApp(const ProviderScope(child: SubSubApp()));
}

class SubSubApp extends ConsumerWidget {
  const SubSubApp({super.key});

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
