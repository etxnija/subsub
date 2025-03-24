import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsub/models/game.dart';
import 'package:subsub/models/player.dart';
import 'package:subsub/models/position.dart';
import 'package:subsub/providers/game_provider.dart';
import 'package:subsub/widgets/soccer_field_painter.dart';

class FieldScreen extends ConsumerStatefulWidget {
  final Game? game;
  final Function(Game)? onLineupComplete;

  const FieldScreen({super.key, this.game, this.onLineupComplete});

  @override
  ConsumerState<FieldScreen> createState() => _FieldScreenState();
}

class _FieldScreenState extends ConsumerState<FieldScreen> {
  Game? _game;

  @override
  void initState() {
    super.initState();
    _game = widget.game;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _game != null ? 'Select Starting Lineup' : '7v7 Formation (2-3-1)',
        ),
        actions: [
          if (_game != null)
            TextButton(
              onPressed: () {
                // Only enable if we have exactly 7 players selected
                final selectedCount = _game!.startingLineup.length;
                if (selectedCount == 7) {
                  // Update the game state in the provider before calling onLineupComplete
                  ref.read(gamesProvider.notifier).updateGame(_game!);
                  widget.onLineupComplete?.call(_game!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please select exactly 7 players (currently $selectedCount selected)',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Done'),
            )
          else
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                // Clear all positions
              },
              tooltip: 'Clear All Assignments',
            ),
        ],
      ),
      body: Column(
        children: [
          // Field with position markers
          Expanded(
            child: Stack(
              children: [
                // Soccer field background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[800],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CustomPaint(
                    painter: SoccerFieldPainter(),
                    size: Size.infinite,
                  ),
                ),
                // Position markers
                ...Position.standardPositions.map((position) {
                  return Positioned(
                    left: MediaQuery.of(context).size.width * position.defaultLocation.dx - 25,
                    top: MediaQuery.of(context).size.height * 0.5 * position.defaultLocation.dy - 25,
                    child: _buildPositionMarker(context, position),
                  );
                }).toList(),
              ],
            ),
          ),
          // Bench area for substitutes
          Container(
            height: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _game?.substitutes.length ?? 0,
              itemBuilder: (context, index) {
                final player = _game!.substitutes[index];
                return Draggable<Player>(
                  data: player,
                  feedback: Material(
                    elevation: 4.0,
                    shape: const CircleBorder(),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[700],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '#${player.number}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              player.name.split(' ').last,
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '#${player.number}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            player.name.split(' ').last,
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '#${player.number}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          player.name.split(' ').last,
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionMarker(BuildContext context, Position position) {
    final player = _game?.startingLineup[position.id];

    return DragTarget<Player>(
      onWillAccept: (incomingPlayer) => true,
      onAccept: (incomingPlayer) {
        if (incomingPlayer != null) {
          final updatedLineup = Map<String, Player>.from(_game!.startingLineup);
          final updatedSubs = List<Player>.from(_game!.substitutes);
          
          // If there's already a player in this position, move them back to substitutes
          if (player != null) {
            updatedSubs.add(player);
          }
          
          // Remove the dragged player from substitutes and add them to the position
          updatedSubs.remove(incomingPlayer);
          updatedLineup[position.id] = incomingPlayer;
          
          setState(() {
            _game = _game!.copyWith(
              startingLineup: updatedLineup,
              substitutes: updatedSubs,
            );
          });
        }
      },
      builder: (context, candidateItems, rejectedItems) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: player != null
                ? _getColorForCategory(position.category)
                : _getColorForCategory(position.category).withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: candidateItems.isNotEmpty ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showPlayerSelection(context, position),
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          position.abbreviation,
                          style: TextStyle(
                            color: Colors.white.withOpacity(
                              player != null ? 0.7 : 1,
                            ),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        if (player != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            '#${player.number}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            player.name.split(' ').last,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPlayerSelection(BuildContext context, Position position) {
    if (_game == null) return;

    final currentPlayer = _game!.startingLineup[position.id];
    final availablePlayers = [
      ..._game!.substitutes,
      if (currentPlayer != null) currentPlayer,
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getColorForCategory(position.category),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      position.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (currentPlayer != null)
                    TextButton.icon(
                      onPressed: () {
                        final updatedLineup = Map<String, Player>.from(
                          _game!.startingLineup,
                        )..remove(position.id);
                        final updatedSubs = List<Player>.from(
                          _game!.substitutes,
                        )..add(currentPlayer);

                        // Update the state with the new lineup
                        setState(() {
                          _game = _game!.copyWith(
                            startingLineup: updatedLineup,
                            substitutes: updatedSubs,
                          );
                        });

                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.person_remove),
                      label: const Text('Remove Player'),
                    ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: availablePlayers.length,
                itemBuilder: (context, index) {
                  final player = availablePlayers[index];
                  final isCurrentlySelected = currentPlayer?.id == player.id;
                  final isAssignedElsewhere =
                      !isCurrentlySelected &&
                      _game!.startingLineup.values.any(
                        (p) => p.id == player.id,
                      );

                  return ListTile(
                    enabled: !isAssignedElsewhere,
                    selected: isCurrentlySelected,
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        '#${player.number}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    title: Text(player.name),
                    onTap: () {
                      if (isCurrentlySelected) return;

                      final updatedLineup = Map<String, Player>.from(
                        _game!.startingLineup,
                      )..[position.id] = player;
                      final updatedSubs = List<Player>.from(
                        _game!.substitutes,
                      )..remove(player);
                      if (currentPlayer != null) {
                        updatedSubs.add(currentPlayer);
                      }

                      // Update the state with the new lineup
                      setState(() {
                        _game = _game!.copyWith(
                          startingLineup: updatedLineup,
                          substitutes: updatedSubs,
                        );
                      });

                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Goalkeeper':
        return Colors.yellow[700]!;
      case 'Defense':
        return Colors.blue[700]!;
      case 'Midfield':
        return Colors.green[700]!;
      case 'Forward':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}
