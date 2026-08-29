// local_audio_player.dart
//
// A drop-in, reusable Flutter widget for playing local MP3 files.
// Works with:
//   - Files on device storage (File path, e.g. from file_picker or path_provider)
//   - Bundled assets (e.g. 'assets/audio/song.mp3')
//
// ─────────────────────────────────────────────────────────────────────────
// SETUP
// ─────────────────────────────────────────────────────────────────────────
// 1. Add the dependency to pubspec.yaml:
//
//      dependencies:
//        audioplayers: ^6.0.0
//
//    Then run: flutter pub get
//
// 2. If you're playing bundled assets, declare them in pubspec.yaml:
//
//      flutter:
//        assets:
//          - assets/audio/
//
// ─────────────────────────────────────────────────────────────────────────
// USAGE
// ─────────────────────────────────────────────────────────────────────────
//
//   // Playing a file from device storage:
//   LocalAudioPlayer(
//     source: LocalAudioSource.file('/storage/emulated/0/Music/song.mp3'),
//   )
//
//   // Playing a bundled asset (path is relative to the "assets/" folder
//   // entry you declared, and should NOT include "assets/" itself):
//   LocalAudioPlayer(
//     source: LocalAudioSource.asset('audio/song.mp3'),
//   )
//
//   // Compact version (just a play/pause icon + tiny progress bar),
//   // handy for embedding inside a ListTile, Card, or chat bubble:
//   LocalAudioPlayer(
//     source: LocalAudioSource.file(path),
//     compact: true,
//   )
//
//   // With callbacks and custom styling:
//   LocalAudioPlayer(
//     source: LocalAudioSource.file(path),
//     autoPlay: false,
//     accentColor: Colors.deepPurple,
//     title: 'Voice memo',
//     onComplete: () => print('done playing'),
//   )
//
// The widget manages its own playback state internally, so you can drop
// multiple instances into a ListView (e.g. one per message/file) and each
// will play independently.
//
// ─────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// Describes where the audio comes from: a local file path or a bundled
/// Flutter asset. Use the named constructors below instead of building
/// this directly.
class LocalAudioSource {
  final Source _source;
  final String label;

  const LocalAudioSource._(this._source, this.label);

  /// A file living on the device's filesystem, e.g.
  /// '/storage/emulated/0/Download/track.mp3' or a path returned by
  /// file_picker / path_provider.
  factory LocalAudioSource.file(String path) {
    return LocalAudioSource._(DeviceFileSource(path), path);
  }

  /// A bundled Flutter asset. Path is relative to your assets folder,
  /// e.g. 'audio/track.mp3' (do not prefix with 'assets/').
  factory LocalAudioSource.asset(String assetPath) {
    return LocalAudioSource._(AssetSource(assetPath), assetPath);
  }
}

/// A self-contained audio player widget for local MP3 playback.
///
/// Drop it anywhere in your widget tree. It owns its own AudioPlayer
/// instance and disposes it automatically, so it's safe to use many
/// instances at once (e.g. in a list of tracks).
class LocalAudioPlayer extends StatefulWidget {
  /// Where the mp3 comes from.
  final LocalAudioSource source;

  /// Optional title shown above the controls (ignored when [compact]).
  final String? title;

  /// Start playing as soon as the widget is built.
  final bool autoPlay;

  /// If true, renders a small single-row layout (icon + slider) suitable
  /// for embedding inside list items. If false, renders a fuller card
  /// with title, time labels, and a bigger play button.
  final bool compact;

  /// Primary color for the play button / active slider track.
  final Color? accentColor;

  /// Called once playback reaches the end of the file.
  final VoidCallback? onComplete;

  /// Called whenever an error occurs while loading/playing.
  final void Function(Object error)? onError;

  const LocalAudioPlayer({
    super.key,
    required this.source,
    this.title,
    this.autoPlay = false,
    this.compact = false,
    this.accentColor,
    this.onComplete,
    this.onError,
  });

  @override
  State<LocalAudioPlayer> createState() => _LocalAudioPlayerState();
}

class _LocalAudioPlayerState extends State<LocalAudioPlayer> {
  late final AudioPlayer _player;

  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _loading = true;
  Object? _loadError;

  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _completeSub;

  bool get _isPlaying => _playerState == PlayerState.playing;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    _durationSub = _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _positionSub = _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _stateSub = _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _playerState = s);
    });
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
          _position = Duration.zero;
        });
      }
      widget.onComplete?.call();
    });

    try {
      await _player.setSource(widget.source._source);
      if (widget.autoPlay) {
        await _player.resume();
      }
    } catch (e) {
      _loadError = e;
      widget.onError?.call(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _togglePlay() async {
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.resume();
      }
    } catch (e) {
      widget.onError?.call(e);
    }
  }

  Future<void> _seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      widget.onError?.call(e);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _stateSub?.cancel();
    _completeSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? Theme.of(context).colorScheme.primary;

    if (_loadError != null) {
      return _ErrorRow(message: 'Could not load audio', compact: widget.compact);
    }

    if (_loading) {
      return SizedBox(
        height: widget.compact ? 32 : 72,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final maxMs = _duration.inMilliseconds.clamp(1, double.maxFinite.toInt()).toDouble();
    final valueMs = _position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();

    if (widget.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            iconSize: 22,
            color: accent,
            icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
            onPressed: _togglePlay,
          ),
          SizedBox(
            width: 140,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                activeTrackColor: accent,
              ),
              child: Slider(
                min: 0,
                max: maxMs,
                value: valueMs,
                onChanged: (v) => _seek(Duration(milliseconds: v.round())),
              ),
            ),
          ),
          Text(_fmt(_position), style: Theme.of(context).textTheme.bodySmall),
        ],
      );
    }

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                IconButton(
                  iconSize: 40,
                  color: accent,
                  icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                  onPressed: _togglePlay,
                ),
                Expanded(
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: accent,
                          thumbColor: accent,
                        ),
                        child: Slider(
                          min: 0,
                          max: maxMs,
                          value: valueMs,
                          onChanged: (v) => _seek(Duration(milliseconds: v.round())),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_fmt(_position), style: Theme.of(context).textTheme.bodySmall),
                            Text(_fmt(_duration), style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final String message;
  final bool compact;
  const _ErrorRow({required this.message, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 4 : 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 6),
          Text(message, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}