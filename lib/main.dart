import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'views/roster/roster_screen.dart';

void main() {
  runApp(const ProviderScope(child: SubSubApp()));
}

class SubSubApp extends StatelessWidget {
  const SubSubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubSub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.robotoTextTheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const RosterScreen(),
    );
  }
} 