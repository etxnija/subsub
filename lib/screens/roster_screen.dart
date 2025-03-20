import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsub/models/player.dart';
import 'package:subsub/providers/roster_provider.dart';

class RosterScreen extends ConsumerWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(rosterProvider);

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
      body: ListView.builder(
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.lightGreen,
              child: Text(player.number.toString()),
            ),
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
                  onPressed: () => _deletePlayer(context, ref, player),
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

    return showDialog<void>(
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
                    final player = Player(
                      name: nameController.text,
                      number: int.parse(numberController.text),
                    );
                    ref.read(rosterProvider.notifier).addPlayer(player);
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

    return showDialog<void>(
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
                    final updatedPlayer = Player(
                      id: player.id,
                      name: nameController.text,
                      number: int.parse(numberController.text),
                    );
                    ref
                        .read(rosterProvider.notifier)
                        .updatePlayer(updatedPlayer);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _deletePlayer(
    BuildContext context,
    WidgetRef ref,
    Player player,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Player'),
            content: Text('Are you sure you want to delete ${player.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      ref.read(rosterProvider.notifier).deletePlayer(player);
    }
  }
}
