import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showNewGameDialog(context),
          ),
        ],
      ),
      body: const Center(child: Text('Game management coming soon!')),
    );
  }

  Future<void> _showNewGameDialog(BuildContext context) async {
    // TODO: Implement new game dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('New Game'),
            content: const Text('Game creation coming soon!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
