import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/player.dart';
import '../../providers/roster_provider.dart';

class RosterScreen extends ConsumerWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roster = ref.watch(rosterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Roster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPlayerDialog(context, ref),
          ),
        ],
      ),
      body: roster.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Players Yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add players to your team',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: roster.length,
              itemBuilder: (context, index) {
                final player = roster[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(player.number.toString())),
                  title: Text(player.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditPlayerDialog(context, ref, player),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed:
                            () => _showDeleteConfirmation(context, ref, player),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showAddPlayerDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final numberController = TextEditingController();

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Player'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  textCapitalization: TextCapitalization.words,
                ),
                TextField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: 'Number'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      numberController.text.isNotEmpty) {
                    ref
                        .read(rosterProvider.notifier)
                        .addPlayer(
                          nameController.text,
                          int.parse(numberController.text),
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  Future<void> _showEditPlayerDialog(
    BuildContext context,
    WidgetRef ref,
    Player player,
  ) async {
    final nameController = TextEditingController(text: player.name);
    final numberController = TextEditingController(
      text: player.number.toString(),
    );

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Player'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  textCapitalization: TextCapitalization.words,
                ),
                TextField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: 'Number'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      numberController.text.isNotEmpty) {
                    ref
                        .read(rosterProvider.notifier)
                        .updatePlayer(
                          Player(
                            id: player.id,
                            name: nameController.text,
                            number: int.parse(numberController.text),
                          ),
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Player player,
  ) {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Player'),
            content: Text('Are you sure you want to delete ${player.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(rosterProvider.notifier).deletePlayer(player.id);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
