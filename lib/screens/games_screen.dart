import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:subsub/models/game.dart';
import 'package:subsub/providers/game_provider.dart';
import 'package:subsub/screens/game_setup_screen.dart';

class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(gamesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GameSetupScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: games.isEmpty
          ? const Center(
              child: Text('No games yet. Add a game to get started.'),
            )
          : ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final playerCount = game.startingLineup.length + game.substitutes.length;
                final isGameReady = game.startingLineup.length >= 7;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    game.opponent,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat.yMMMMd().format(game.date),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            _buildGameStatusBadge(context, game),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text('$playerCount players'),
                              backgroundColor: Colors.grey[200],
                            ),
                            Chip(
                              label: Text('${game.startingLineup.length}/7 starters'),
                              backgroundColor: isGameReady 
                                ? Colors.green[100] 
                                : Colors.orange[100],
                            ),
                            if (game.periods.isNotEmpty)
                              Chip(
                                label: Text('${game.periods.length} periods'),
                                backgroundColor: Colors.blue[100],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                // Navigation to edit lineup will be added later
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: isGameReady ? () {
                                context.push('/games/play/${game.id}');
                              } : null,
                              icon: const Icon(Icons.sports),
                              label: const Text('Play'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
  
  Widget _buildGameStatusBadge(BuildContext context, Game game) {
    Color color;
    String text;
    IconData icon;
    
    switch (game.status) {
      case GameStatus.setup:
        color = Colors.grey;
        text = 'Setup';
        icon = Icons.settings;
        break;
      case GameStatus.inProgress:
        color = Colors.green;
        text = 'In Progress';
        icon = Icons.play_arrow;
        break;
      case GameStatus.paused:
        color = Colors.orange;
        text = 'Paused';
        icon = Icons.pause;
        break;
      case GameStatus.completed:
        color = Colors.blue;
        text = 'Completed';
        icon = Icons.check_circle;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 