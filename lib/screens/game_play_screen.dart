import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsub/models/game.dart';
import 'package:subsub/models/player.dart';
import 'package:subsub/models/position.dart';
import 'package:subsub/providers/game_provider.dart';
import 'dart:async';
import 'dart:ui';

class GamePlayScreen extends ConsumerStatefulWidget {
  final String gameId;
  
  const GamePlayScreen({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  ConsumerState<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends ConsumerState<GamePlayScreen> {
  Game? _game;
  Timer? _gameTimer;
  int _activeSeconds = 0;
  int _activePeriod = 0;
  bool _isPeriodActive = false;
  bool _isDragging = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGame();
    });
  }
  
  Future<void> _loadGame() async {
    final games = ref.read(gamesProvider);
    final game = games.firstWhere((g) => g.id == widget.gameId);
    
    setState(() {
      _game = game;
    });
  }
  
  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
  
  void _startPeriod() {
    if (_game == null || _activePeriod >= _game!.periods.length) return;
    
    final updatedPeriods = List<GamePeriod>.from(_game!.periods);
    updatedPeriods[_activePeriod] = GamePeriod(
      number: updatedPeriods[_activePeriod].number,
      durationMinutes: updatedPeriods[_activePeriod].durationMinutes,
      startTime: DateTime.now(),
      endTime: null,
    );
    
    final updatedGame = _game!.copyWith(
      periods: updatedPeriods,
      status: GameStatus.inProgress,
    );
    
    ref.read(gamesProvider.notifier).updateGame(updatedGame);
    
    setState(() {
      _game = updatedGame;
      _isPeriodActive = true;
      _activeSeconds = 0;
    });
    
    _startTimer();
  }
  
  void _pausePeriod() {
    _gameTimer?.cancel();
    
    if (_game == null || _activePeriod >= _game!.periods.length) return;
    
    setState(() {
      _isPeriodActive = false;
    });
    
    final updatedGame = _game!.copyWith(
      status: GameStatus.paused,
    );
    
    ref.read(gamesProvider.notifier).updateGame(updatedGame);
    
    setState(() {
      _game = updatedGame;
    });
  }
  
  void _endPeriod() {
    _gameTimer?.cancel();
    
    if (_game == null || _activePeriod >= _game!.periods.length) return;
    
    final updatedPeriods = List<GamePeriod>.from(_game!.periods);
    updatedPeriods[_activePeriod] = GamePeriod(
      number: updatedPeriods[_activePeriod].number,
      durationMinutes: updatedPeriods[_activePeriod].durationMinutes,
      startTime: updatedPeriods[_activePeriod].startTime,
      endTime: DateTime.now(),
    );
    
    final isLastPeriod = _activePeriod == _game!.periods.length - 1;
    final updatedGame = _game!.copyWith(
      periods: updatedPeriods,
      status: isLastPeriod ? GameStatus.completed : GameStatus.setup,
    );
    
    ref.read(gamesProvider.notifier).updateGame(updatedGame);
    
    setState(() {
      _game = updatedGame;
      _isPeriodActive = false;
      if (!isLastPeriod) {
        _activePeriod++;
      }
    });
  }
  
  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _activeSeconds++;
      });
    });
  }
  
  void _handlePlayerSwap(String positionId, Player player) {
    if (_game == null) return;
    
    // Get current player at this position if any
    final currentPlayer = _game!.startingLineup[positionId];
    
    // Make a copy of the lineup and substitutes
    final newLineup = Map<String, Player>.from(_game!.startingLineup);
    final newSubstitutes = List<Player>.from(_game!.substitutes);
    
    // If player is already in another position, remove them from that position
    String? oldPositionId;
    newLineup.forEach((key, value) {
      if (value.id == player.id && key != positionId) {
        oldPositionId = key;
      }
    });
    
    if (oldPositionId != null) {
      // This is a position swap - player is already on the field
      if (currentPlayer != null) {
        // Put current player in old position
        newLineup[oldPositionId!] = currentPlayer;
      } else {
        // Remove player from old position without replacement
        newLineup.remove(oldPositionId);
      }
    } else {
      // Player is coming from substitutes
      newSubstitutes.remove(player);
      
      if (currentPlayer != null) {
        // Current player becomes a substitute
        newSubstitutes.add(currentPlayer);
      }
    }
    
    // Put the new player in the position
    newLineup[positionId] = player;
    
    // Update the game
    final updatedGame = _game!.copyWith(
      startingLineup: newLineup,
      substitutes: newSubstitutes,
    );
    
    ref.read(gamesProvider.notifier).updateGame(updatedGame);
    
    setState(() {
      _game = updatedGame;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_game == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final currentPeriod = _game!.periods.isEmpty ? null : _game!.periods[_activePeriod];
    final periodTimeInSeconds = currentPeriod != null ? currentPeriod.durationMinutes * 60 : 0;
    final isOvertime = _activeSeconds > periodTimeInSeconds;
    final minutes = _activeSeconds ~/ 60;
    final seconds = _activeSeconds % 60;
    final formattedTime = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text('vs. ${_game!.opponent}'),
        actions: [
          if (_isPeriodActive)
            IconButton(
              onPressed: _pausePeriod,
              icon: const Icon(Icons.pause),
              tooltip: 'Pause Game',
            )
          else if (_game!.status == GameStatus.paused)
            IconButton(
              onPressed: _startPeriod,
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Resume Game',
            )
          else if (_activePeriod < _game!.periods.length && 
                  (_activePeriod == 0 || _game!.periods[_activePeriod - 1].isCompleted))
            IconButton(
              onPressed: _startPeriod,
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Start Period',
            ),
        ],
      ),
      body: Column(
        children: [
          // Period status and timer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: Column(
              children: [
                // Period indicators in a more compact row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < _game!.periods.length; i++)
                      _buildCompactPeriodIndicator(i),
                  ],
                ),
                if (currentPeriod != null) ...[
                  // More compact timer display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Period ${currentPeriod.number}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOvertime ? Colors.red.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _isPeriodActive ? formattedTime : 'Not Active',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: !_isPeriodActive ? Colors.grey : (isOvertime ? Colors.red : null),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      if (_isPeriodActive)
                        ElevatedButton(
                          onPressed: _endPeriod,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text('End Period'),
                        )
                      else if (_activePeriod < _game!.periods.length && 
                              (_activePeriod == 0 || _game!.periods[_activePeriod - 1].isCompleted))
                        ElevatedButton(
                          onPressed: _startPeriod,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 36),
                          ),
                          child: Text('Start ${_activePeriod + 1}'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Field with draggable players
          Expanded(
            child: Stack(
              children: [
                // Soccer field background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[800],
                    // Create a simple field pattern with lines
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CustomPaint(
                    painter: SoccerFieldPainter(),
                    size: Size.infinite,
                  ),
                ),
                
                // Position markers for players on the field
                for (final position in Position.standardPositions)
                  _buildPositionTarget(position),
                
                // Bench area for substitutes
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    color: Colors.grey[900]?.withOpacity(0.8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Substitutes',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _game!.substitutes.length,
                            itemBuilder: (context, index) {
                              final player = _game!.substitutes[index];
                              return _buildPlayerDraggable(player, null);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompactPeriodIndicator(int periodIndex) {
    final period = _game!.periods[periodIndex];
    Color color;
    IconData icon;
    
    if (period.isCompleted) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (period.isActive) {
      color = Colors.blue;
      icon = Icons.sports;
    } else if (periodIndex == _activePeriod && 
              (periodIndex == 0 || _game!.periods[periodIndex - 1].isCompleted)) {
      color = Colors.orange;
      icon = Icons.play_circle;
    } else {
      color = Colors.grey;
      icon = Icons.circle_outlined;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          'Period ${period.number}',
          style: TextStyle(
            color: color, 
            fontSize: 12,
            fontWeight: periodIndex == _activePeriod ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPositionTarget(Position position) {
    final player = _game!.startingLineup[position.id];
    
    return Positioned(
      left: MediaQuery.of(context).size.width * position.defaultLocation.dx - 25,
      top: MediaQuery.of(context).size.height * 0.5 * position.defaultLocation.dy - 25,
      child: DragTarget<Player>(
        onWillAccept: (incomingPlayer) => true,
        onAccept: (incomingPlayer) {
          _handlePlayerSwap(position.id, incomingPlayer);
        },
        builder: (context, candidateItems, rejectedItems) {
          return Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getColorForCategory(position.category).withOpacity(
                candidateItems.isNotEmpty ? 0.8 : 0.5
              ),
              border: Border.all(
                color: Colors.white,
                width: candidateItems.isNotEmpty ? 3 : 1,
              ),
            ),
            child: player != null
                ? _buildPlayerDraggable(player, position)
                : Center(
                    child: Text(
                      position.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
  
  Widget _buildPlayerDraggable(Player player, Position? position) {
    return Draggable<Player>(
      data: player,
      onDragStarted: () {
        setState(() {
          _isDragging = true;
        });
      },
      onDragEnd: (_) {
        setState(() {
          _isDragging = false;
        });
      },
      feedback: Material(
        elevation: 4.0,
        shape: const CircleBorder(),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: position != null 
                ? _getColorForCategory(position.category)
                : Colors.grey[700],
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: position != null 
                ? _getColorForCategory(position.category).withOpacity(0.3)
                : Colors.grey[700]?.withOpacity(0.3),
          ),
          child: Center(
            child: position != null
                ? Text(
                    position.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const Icon(Icons.person_off, color: Colors.white54),
          ),
        ),
      ),
      child: position == null
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
          : Center(
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
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

/// Custom painter to draw a simple soccer field
class SoccerFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final width = size.width;
    final height = size.height;
    
    // Center circle
    final centerX = width / 2;
    final centerY = height / 2;
    final centerRadius = width / 10;
    canvas.drawCircle(Offset(centerX, centerY), centerRadius, paint);
    
    // Center line
    canvas.drawLine(
      Offset(0, centerY),
      Offset(width, centerY),
      paint,
    );
    
    // Goal areas
    final goalAreaHeight = height / 6;
    final goalAreaWidth = width / 2;
    
    // Top goal area
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, goalAreaHeight / 2),
        width: goalAreaWidth,
        height: goalAreaHeight,
      ),
      paint,
    );
    
    // Bottom goal area
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, height - goalAreaHeight / 2),
        width: goalAreaWidth,
        height: goalAreaHeight,
      ),
      paint,
    );
    
    // Draw a small goal at each end
    final goalWidth = width / 6;
    final goalHeight = height / 20;
    
    // Top goal
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, 2),
        width: goalWidth,
        height: goalHeight,
      ),
      paint,
    );
    
    // Bottom goal
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, height - 2),
        width: goalWidth,
        height: goalHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 