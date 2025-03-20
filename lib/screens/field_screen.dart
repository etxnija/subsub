import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsub/models/game.dart';
import 'package:subsub/models/player.dart';
import 'package:subsub/models/position.dart';
import 'package:subsub/providers/game_provider.dart';

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
      body: _buildField(context),
    );
  }

  Widget _buildField(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const markerSize = 40.0;
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[800],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Stack(
            children: [
              CustomPaint(
                painter: HalfFieldPainter(),
                size: Size(constraints.maxWidth, constraints.maxHeight),
              ),
              ...Position.standardPositions.map((position) {
                return Positioned(
                  left:
                      (position.defaultLocation.dx * constraints.maxWidth) -
                      (markerSize / 2),
                  top:
                      (position.defaultLocation.dy * constraints.maxHeight) -
                      (markerSize / 2),
                  child: _buildPositionMarker(context, position),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPositionMarker(BuildContext context, Position position) {
    const markerSize = 40.0;
    final player = _game?.startingLineup[position.id];

    return Container(
      width: markerSize,
      height: markerSize,
      decoration: BoxDecoration(
        color:
            player != null
                ? _getColorForCategory(position.category)
                : _getColorForCategory(position.category).withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
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
          borderRadius: BorderRadius.circular(markerSize / 2),
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
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${player.number}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
      builder:
          (context) => Container(
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
                      final isCurrentlySelected =
                          currentPlayer?.id == player.id;
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
        return Colors.grey;
    }
  }
}

class HalfFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Center circle (half)
    final centerY = size.height;
    final radius = size.width / 8;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, centerY), radius: radius),
      3.14159, // PI
      3.14159, // PI
      false,
      paint,
    );

    // Penalty area
    final penaltyAreaWidth = size.width * 0.7;
    final penaltyAreaHeight = size.height * 0.25;

    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyAreaWidth) / 2,
        0,
        penaltyAreaWidth,
        penaltyAreaHeight,
      ),
      paint,
    );

    // Goal area
    final goalAreaWidth = size.width * 0.35;
    final goalAreaHeight = size.height * 0.12;

    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalAreaWidth) / 2,
        0,
        goalAreaWidth,
        goalAreaHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
