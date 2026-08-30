import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sequence Memory')),
      body: Center(
        child: CognitiveGameWidget(
          difficulty: GameDifficulty.medium,
          onGameOver: (result) {
            // e.g. save high score, show a snackbar, etc.
          },
        ),
      ),
    );
  }
}

/// Difficulty presets controlling grid size and speed curve.
enum GameDifficulty { easy, medium, hard }

/// Internal game state machine.
enum _GamePhase { idle, showingSequence, awaitingInput, roundSuccess, gameOver }

/// Result payload returned to the host app when a game session ends.
class CognitiveGameResult {
  final int score; // number of correct taps across the whole session
  final int level; // highest sequence length reached
  final Duration timePlayed;

  const CognitiveGameResult({
    required this.score,
    required this.level,
    required this.timePlayed,
  });

  @override
  String toString() =>
      'CognitiveGameResult(score: $score, level: $level, timePlayed: $timePlayed)';
}

/// A self-contained "Sequence Memory" cognitive game widget.
///
/// Drop it anywhere in a widget tree (e.g. inside a [Scaffold], a [Card], a
/// dialog, or a dedicated screen). It manages all of its own state
/// internally and only reports back through the optional callbacks.
class CognitiveGameWidget extends StatefulWidget {
  /// Controls grid size (number of tiles) and speed curve.
  final GameDifficulty difficulty;

  /// Called every time the session ends (player makes a mistake or, if
  /// [maxLevel] is set, the player reaches it).
  final ValueChanged<CognitiveGameResult>? onGameOver;

  /// Called whenever the score changes, useful for live HUDs in a parent
  /// screen (e.g. a persistent top bar showing points).
  final ValueChanged<int>? onScoreUpdate;

  /// Optional cap on sequence length. Null = unlimited (game gets
  /// progressively harder forever).
  final int? maxLevel;

  /// Overall visual size of the game board. The widget is square.
  final double boardSize;

  /// Base tile color palette. Must have at least as many colors as tiles
  /// implied by [difficulty] (4 for easy/medium, 9 for hard). Sensible
  /// defaults are provided.
  final List<Color>? tileColors;

  /// Whether to show the built-in header (title, level, score) above the
  /// board. Set to false if you want to build your own HUD and only embed
  /// the board itself.
  final bool showHeader;

  const CognitiveGameWidget({
    super.key,
    this.difficulty = GameDifficulty.medium,
    this.onGameOver,
    this.onScoreUpdate,
    this.maxLevel,
    this.boardSize = 320,
    this.tileColors,
    this.showHeader = true,
  });

  @override
  State<CognitiveGameWidget> createState() => _CognitiveGameWidgetState();
}

class _CognitiveGameWidgetState extends State<CognitiveGameWidget>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  final List<int> _sequence = [];
  int _playerStep = 0; // index into _sequence the player must tap next
  int _highlightedTile = -1; // tile currently flashing during playback
  int _score = 0;
  int _level = 0;
  _GamePhase _phase = _GamePhase.idle;
  DateTime? _startTime;
  Timer? _playbackTimer;

  int get _tileCount {
    switch (widget.difficulty) {
      case GameDifficulty.easy:
        return 4;
      case GameDifficulty.medium:
        return 6;
      case GameDifficulty.hard:
        return 9;
    }
  }

  int get _gridColumns => _tileCount <= 4 ? 2 : 3;

  Duration get _flashDuration {
    // Speeds up slightly as the level increases, with a sane floor.
    final base = switch (widget.difficulty) {
      GameDifficulty.easy => 650,
      GameDifficulty.medium => 500,
      GameDifficulty.hard => 420,
    };
    final ms = max(180, base - (_level * 12));
    return Duration(milliseconds: ms);
  }

  List<Color> get _colors {
    if (widget.tileColors != null && widget.tileColors!.length >= _tileCount) {
      return widget.tileColors!;
    }
    const palette = [
      Color(0xFFEF5350), // red
      Color(0xFF42A5F5), // blue
      Color(0xFF66BB6A), // green
      Color(0xFFFFCA28), // amber
      Color(0xFFAB47BC), // purple
      Color(0xFF26C6DA), // cyan
      Color(0xFFFF7043), // deep orange
      Color(0xFF8D6E63), // brown
      Color(0xFF78909C), // blue grey
    ];
    return palette;
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _sequence.clear();
      _score = 0;
      _level = 0;
      _playerStep = 0;
      _startTime = DateTime.now();
      _phase = _GamePhase.idle;
    });
    widget.onScoreUpdate?.call(_score);
    _nextRound();
  }

  void _nextRound() {
    _sequence.add(_random.nextInt(_tileCount));
    _level = _sequence.length;
    _playerStep = 0;
    setState(() => _phase = _GamePhase.showingSequence);
    _playbackFrom(0);
  }

  void _playbackFrom(int index) {
    if (index >= _sequence.length) {
      setState(() {
        _highlightedTile = -1;
        _phase = _GamePhase.awaitingInput;
      });
      return;
    }
    setState(() => _highlightedTile = _sequence[index]);
    _playbackTimer = Timer(_flashDuration, () {
      if (!mounted) return;
      setState(() => _highlightedTile = -1);
      _playbackTimer = Timer(Duration(milliseconds: _flashDuration.inMilliseconds ~/ 3), () {
        if (!mounted) return;
        _playbackFrom(index + 1);
      });
    });
  }

  void _onTileTap(int tileIndex) {
    if (_phase != _GamePhase.awaitingInput) return;

    final expected = _sequence[_playerStep];
    if (tileIndex != expected) {
      _endGame();
      return;
    }

    setState(() {
      _score += 1;
      _highlightedTile = tileIndex;
    });
    widget.onScoreUpdate?.call(_score);

    Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() => _highlightedTile = -1);
      _playerStep += 1;

      if (_playerStep == _sequence.length) {
        // Round complete.
        if (widget.maxLevel != null && _level >= widget.maxLevel!) {
          _endGame(reachedCap: true);
          return;
        }
        setState(() => _phase = _GamePhase.roundSuccess);
        Timer(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          _nextRound();
        });
      }
    });
  }

  void _endGame({bool reachedCap = false}) {
    _playbackTimer?.cancel();
    setState(() => _phase = _GamePhase.gameOver);
    final played = _startTime == null
        ? Duration.zero
        : DateTime.now().difference(_startTime!);
    widget.onGameOver?.call(
      CognitiveGameResult(score: _score, level: _level, timePlayed: played),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showHeader) _buildHeader(context),
        const SizedBox(height: 16),
        SizedBox(
          width: widget.boardSize,
          height: widget.boardSize,
          child: _buildBoard(),
        ),
        const SizedBox(height: 20),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'Sequence Memory',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatChip(label: 'Level', value: '$_level'),
            const SizedBox(width: 12),
            _StatChip(label: 'Score', value: '$_score'),
          ],
        ),
      ],
    );
  }

  Widget _buildBoard() {
    if (_phase == _GamePhase.idle) {
      return _buildOverlay(
        icon: Icons.psychology_alt_outlined,
        title: 'Ready to train your memory?',
        subtitle: 'Watch the pattern, then repeat it back.',
        buttonLabel: 'Start',
        onPressed: _startGame,
      );
    }
    if (_phase == _GamePhase.gameOver) {
      return _buildOverlay(
        icon: Icons.replay_circle_filled_outlined,
        title: 'Game over',
        subtitle: 'Score: $_score  •  Level reached: $_level',
        buttonLabel: 'Play again',
        onPressed: _startGame,
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _tileCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridColumns,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final baseColor = _colors[index % _colors.length];
        final isLit = _highlightedTile == index;
        final tappable = _phase == _GamePhase.awaitingInput;
        return GestureDetector(
          onTap: tappable ? () => _onTileTap(index) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: isLit ? baseColor : baseColor.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isLit
                  ? [
                      BoxShadow(
                        color: baseColor.withValues(alpha: 0.7),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
              border: Border.all(
                color: baseColor.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverlay({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    String status;
    switch (_phase) {
      case _GamePhase.idle:
        status = '';
        break;
      case _GamePhase.showingSequence:
        status = 'Watch closely…';
        break;
      case _GamePhase.awaitingInput:
        status = 'Your turn — repeat the pattern';
        break;
      case _GamePhase.roundSuccess:
        status = 'Nice! Next round…';
        break;
      case _GamePhase.gameOver:
        status = '';
        break;
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        status,
        key: ValueKey(status),
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
