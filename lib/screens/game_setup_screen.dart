import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsub/models/game.dart';
import 'package:subsub/models/player.dart';
import 'package:subsub/providers/game_provider.dart';
import 'package:subsub/providers/roster_provider.dart';
import 'package:subsub/screens/field_screen.dart';
import 'package:go_router/go_router.dart';

class GameSetupScreen extends ConsumerStatefulWidget {
  const GameSetupScreen({super.key});

  @override
  ConsumerState<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends ConsumerState<GameSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _opponentController = TextEditingController();
  DateTime _gameDate = DateTime.now();
  final Set<Player> _selectedPlayers = {};
  
  @override
  Widget build(BuildContext context) {
    final allPlayers = ref.watch(rosterProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Game'),
        actions: [
          TextButton(
            onPressed: _selectedPlayers.isEmpty ? null : _proceedToLineup,
            child: const Text('Next'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Game Details Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Game Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _opponentController,
                      decoration: const InputDecoration(
                        labelText: 'Opponent',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter opponent name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Game Date'),
                      subtitle: Text(
                        '${_gameDate.year}-${_gameDate.month.toString().padLeft(2, '0')}-${_gameDate.day.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _gameDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _gameDate = date);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Player Selection Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Players',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_selectedPlayers.length} selected',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...allPlayers.map((player) => CheckboxListTile(
                      title: Text(player.name),
                      subtitle: Text('#${player.number}'),
                      value: _selectedPlayers.contains(player),
                      onChanged: (selected) {
                        setState(() {
                          if (selected ?? false) {
                            _selectedPlayers.add(player);
                          } else {
                            _selectedPlayers.remove(player);
                          }
                        });
                      },
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToLineup() {
    if (!_formKey.currentState!.validate()) return;
    
    // Create a new game with empty lineup
    final game = Game(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // Temporary ID
      date: _gameDate,
      opponent: _opponentController.text,
      startingLineup: {}, // Empty lineup to be filled in the next screen
      substitutes: _selectedPlayers.toList(), // All selected players start as subs
    );
    
    // Navigate to field screen for lineup selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FieldScreen(
          game: game,
          onLineupComplete: (updatedGame) async {
            // Save the game with lineup to database
            try {
              await ref.read(gamesProvider.notifier).addGame(updatedGame);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Game setup complete!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Navigate back to the games list
                Navigator.of(context).popUntil((route) => route.isFirst);
                GoRouter.of(context).go('/games');
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error saving game: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _opponentController.dispose();
    super.dispose();
  }
} 