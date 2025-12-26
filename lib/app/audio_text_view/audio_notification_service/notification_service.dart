import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioNotificationService {
  static AudioHandler? _audioHandler;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) {
      print('✅ AudioNotificationService already initialized');
      return;
    }

    try {
      _audioHandler = await AudioService.init(
        builder: () => AudioPlayerHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.storyverse.audio',
          androidNotificationChannelName: 'Storyverse Audio',
          androidNotificationOngoing: false,
          androidShowNotificationBadge: true,
          androidStopForegroundOnPause: true,
        ),
      );

      _isInitialized = true;
      print('✅ AudioNotificationService initialized successfully');
    } catch (e) {
      print('❌ Error initializing AudioNotificationService: $e');
      _isInitialized = false;
    }
  }

  static AudioHandler? get audioHandler => _audioHandler;

  static bool get isInitialized => _isInitialized;

  static Future<void> dispose() async {
    await _audioHandler?.stop();
    _audioHandler = null;
    _isInitialized = false;
  }
}

// ============================================================
// Audio Player Handler
// ============================================================

class AudioPlayerHandler extends BaseAudioHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration? _currentDuration;

  AudioPlayerHandler() {
    _init();
  }

  void _init() {
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      final playing = state == PlayerState.playing;
      _updatePlaybackState(playing);
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((position) {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((duration) {
      _currentDuration = duration;
      final newMediaItem = mediaItem.value?.copyWith(duration: duration);
      if (newMediaItem != null) {
        mediaItem.add(newMediaItem);
      }
      playbackState.add(playbackState.value.copyWith(bufferedPosition: duration));
    });

    // Listen to completion
    _audioPlayer.onPlayerComplete.listen((_) {
      _updatePlaybackState(false);
    });
  }

  void _updatePlaybackState(bool playing) {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl(androidIcon: 'drawable/ic_replay_15', label: 'Rewind 15 seconds', action: MediaAction.rewind),
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl(androidIcon: 'drawable/ic_forward_15', label: 'Forward 15 seconds', action: MediaAction.fastForward),
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.rewind,
          MediaAction.fastForward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: playing ? AudioProcessingState.ready : AudioProcessingState.idle,
        playing: playing,
        updatePosition: playbackState.value.updatePosition,
        bufferedPosition: _currentDuration ?? Duration.zero,
        speed: playbackState.value.speed,
        queueIndex: 0,
      ),
    );
  }

  Future<void> loadAndPlay({required String audioUrl, required String title, required String artist, String? artUri}) async {
    try {
      // Set media item for notification
      mediaItem.add(
        MediaItem(id: audioUrl, album: 'Phone speaker', title: title, artist: artist, artUri: artUri != null && artUri.isNotEmpty ? Uri.parse(artUri) : null),
      );

      // Load audio source
      await _audioPlayer.setSourceUrl(audioUrl);
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);

      _updatePlaybackState(false);
      print('✅ Audio loaded in notification service');
    } catch (e) {
      print('❌ Error loading audio: $e');
    }
  }

  AudioPlayer get audioPlayer => _audioPlayer;

  @override
  Future<void> play() async {
    try {
      await _audioPlayer.resume();
      _updatePlaybackState(true);
    } catch (e) {
      print('❌ Play error: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _updatePlaybackState(false);
    } catch (e) {
      print('❌ Pause error: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _updatePlaybackState(false);
      await super.stop();
    } catch (e) {
      print('❌ Stop error: $e');
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    } catch (e) {
      print('❌ Seek error: $e');
    }
  }

  @override
  Future<void> rewind() async {
    final current = await _audioPlayer.getCurrentPosition();
    final newPosition = (current ?? Duration.zero) - const Duration(seconds: 15);
    final seekPosition = newPosition.isNegative ? Duration.zero : newPosition;
    await seek(seekPosition);
  }

  @override
  Future<void> fastForward() async {
    final current = await _audioPlayer.getCurrentPosition();
    final newPosition = (current ?? Duration.zero) + const Duration(seconds: 15);

    Duration seekPosition = newPosition;
    if (_currentDuration != null && newPosition > _currentDuration!) {
      seekPosition = _currentDuration!;
    }
    await seek(seekPosition);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setPlaybackRate(speed);
    playbackState.add(playbackState.value.copyWith(speed: speed));
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
