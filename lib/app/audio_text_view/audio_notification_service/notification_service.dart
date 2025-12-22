// ============================================================
// 1. Audio Notification Service
// ============================================================

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';

class AudioNotificationService {
  static AudioHandler? _audioHandler;

  // static AudioPlayer? _audioPlayer;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    Get.lazyPut(() => AudioTextController());
    if (_isInitialized) {
      print('AudioNotificationService already initialized');
      return;
    }

    try {
      Get.find<AudioTextController>().audioPlayer = AudioPlayer();

      _audioHandler = await AudioService.init(
        builder: () => AudioPlayerHandler(),
        config: AudioServiceConfig(
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
      rethrow;
    }
  }

  static AudioHandler? get audioHandler => _audioHandler;

  static AudioPlayer? get audioPlayer => Get.find<AudioTextController>().audioPlayer;

  static bool get isInitialized => _isInitialized;
}
// ============================================================
// 2. Audio Player Handler
// ============================================================

class AudioPlayerHandler extends BaseAudioHandler {
  Duration? _currentDuration;

  AudioPlayerHandler() {
    _init();
  }

  void _init() {
    final player = AudioNotificationService.audioPlayer;

    if (player == null) {
      print('AudioPlayer is null in handler');
      return;
    }

    // Listen to player state changes
    player.onPlayerStateChanged.listen((state) {
      final playing = state == PlayerState.playing;
      _updatePlaybackState(playing);
    });

    // Listen to position changes
    player.onPositionChanged.listen((position) {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    });

    // Listen to duration changes
    player.onDurationChanged.listen((duration) {
      _currentDuration = duration;
      final newMediaItem = mediaItem.value?.copyWith(duration: duration);
      if (newMediaItem != null) {
        mediaItem.add(newMediaItem);
      }
      playbackState.add(playbackState.value.copyWith(bufferedPosition: duration));
    });
  }

  void _updatePlaybackState(bool playing) {
    playbackState.add(
      PlaybackState(
        controls: [
          // Skip backward 15 seconds
          MediaControl(androidIcon: 'drawable/ic_replay_15', label: 'Rewind 15 seconds', action: MediaAction.rewind),
          // Play/Pause
          playing ? MediaControl.pause : MediaControl.play,
          // Skip forward 15 seconds
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
        // All 3 buttons
        processingState: playing ? AudioProcessingState.ready : AudioProcessingState.idle,
        playing: playing,
        updatePosition: Duration.zero,
        bufferedPosition: _currentDuration ?? Duration.zero,
        speed: 1.0,
        queueIndex: 0,
      ),
    );
  }

  // Load and play audio with title and subtitle
  Future<void> loadAndPlay({required String audioUrl, required String title, required String artist, String? artUri}) async {
    final player = AudioNotificationService.audioPlayer;
    if (player == null) return;

    // Set media item for notification
    mediaItem.add(
      MediaItem(
        id: audioUrl,
        album: 'Phone speaker',
        // Shows as top text in notification
        title: title,
        // Book name
        artist: artist,
        // Author name
        artUri: artUri != null && artUri.isNotEmpty ? Uri.parse(artUri) : null,
        duration: Duration.zero,
      ),
    );

    try {
      if (audioUrl.startsWith('http')) {
        await player.setSourceUrl(audioUrl);
      } else {
        await player.setSource(AssetSource(audioUrl));
      }
      _updatePlaybackState(false);
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  @override
  Future<void> play() async {
    final player = AudioNotificationService.audioPlayer;
    if (player == null) return;

    await player.resume();
    _updatePlaybackState(true);
  }

  @override
  Future<void> pause() async {
    final player = AudioNotificationService.audioPlayer;
    if (player == null) return;

    await player.pause();
    _updatePlaybackState(false);
  }

  @override
  Future<void> stop() async {
    await AudioNotificationService.audioPlayer?.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await AudioNotificationService.audioPlayer?.seek(position);
    playbackState.add(playbackState.value.copyWith(updatePosition: position));
  }

  @override
  Future<void> rewind() async {
    final player = AudioNotificationService.audioPlayer;
    if (player == null) return;

    final current = await player.getCurrentPosition();
    final newPosition = (current ?? Duration.zero) - const Duration(seconds: 15);
    final seekPosition = newPosition.isNegative ? Duration.zero : newPosition;

    await player.seek(seekPosition);
    playbackState.add(playbackState.value.copyWith(updatePosition: seekPosition));
  }

  @override
  Future<void> fastForward() async {
    final player = AudioNotificationService.audioPlayer;
    if (player == null) return;

    final current = await player.getCurrentPosition();
    final newPosition = (current ?? Duration.zero) + const Duration(seconds: 15);

    // Don't seek beyond duration if available
    Duration seekPosition = newPosition;
    if (_currentDuration != null && newPosition > _currentDuration!) {
      seekPosition = _currentDuration!;
    }

    await player.seek(seekPosition);
    playbackState.add(playbackState.value.copyWith(updatePosition: seekPosition));
  }

  @override
  Future<void> setSpeed(double speed) async {
    await AudioNotificationService.audioPlayer?.setPlaybackRate(speed);
    playbackState.add(playbackState.value.copyWith(speed: speed));
  }

  Future<void> dispose() async {
    // Handler cleanup
  }
}

// ============================================================
// 3. Integration in AudioTextController
// ============================================================

// class AudioTextController extends GetxController {
//   AudioPlayerHandler? _audioHandler;
//
//   // ... existing code ...
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeAudioService();
//     // ... rest of your onInit code ...
//   }
//
//   Future<void> _initializeAudioService() async {
//     await AudioNotificationService.initialize();
//     _audioHandler = AudioNotificationService.audioHandler as AudioPlayerHandler?;
//   }
//
//   Future<void> initializeApp() async {
//     try {
//       transcript = await loadRealData();
//       paragraphs = transcript?.paragraphs ?? [];
//
//       // ... existing initialization code ...
//
//       // Setup notification with book info
//       await _setupNotification();
//
//       if (!isClosed) update();
//     } catch (e) {
//       hasError = true;
//       errorMessage = 'Initialization error: $e';
//       update();
//     }
//   }
//
//   Future<void> _setupNotification() async {
//     if (_audioHandler == null) return;
//
//     await _audioHandler!.loadAndPlay(
//       audioUrl: _audioUrl ?? '',
//       title: vBookName.value.isNotEmpty ? vBookName.value : 'A Million to One',
//       artist: vAuthorName.value.isNotEmpty ? vAuthorName.value : 'Alan Mitchell',
//       artUri: vBookImage.value.isNotEmpty ? vBookImage.value : CS.imgBookCover,
//     );
//   }
//
//   void startListening() {
//     isBookListening.value = true;
//     vAuthorName.value = "Alan Mitchell";
//     vBookName.value = "Princess of Amazon";
//     vBookImage.value = CS.imgBookCover;
//     vBookId.value = "";
//
//     bookInfo.value = BookInfoModel(authorName: vAuthorName.value, bookName: vBookName.value, bookImage: vBookImage.value, bookId: vBookId.value);
//
//     saveBookInfo(bookInfo.value);
//     setIsBookListening(true);
//
//     // Update notification
//     _setupNotification();
//
//     update();
//   }
//
//   @override
//   Future<void> play({bool isPositionScrollOnly = false, bool isOnlyPlayAudio = false}) async {
//     if (_isDisposed || !_isInitialized || _operationInProgress) return;
//
//     _operationInProgress = true;
//
//     try {
//       // ... existing play logic ...
//
//       // Play via notification handler
//       await _audioHandler?.play();
//
//       _isPlaying = true;
//       isPlayAudio.value = true;
//       _lastDriftCheck = DateTime.now();
//
//       update();
//     } catch (e) {
//       _error = 'Playback error: $e';
//       update();
//     } finally {
//       _operationInProgress = false;
//     }
//   }
//
//   @override
//   Future<void> pause() async {
//     if (_isDisposed || !_isInitialized || _operationInProgress) return;
//     if (!_isPlaying) return;
//
//     _operationInProgress = true;
//
//     try {
//       await _audioHandler?.pause();
//       await audioPlayer.pause();
//
//       _isPlaying = false;
//       isPlayAudio.value = false;
//       _lastDriftCheck = null;
//
//       update();
//     } catch (e) {
//       _error = 'Pause error: $e';
//       update();
//     } finally {
//       _operationInProgress = false;
//     }
//   }
//
//   Future<void> skipForward() async {
//     await _audioHandler?.skipForward();
//     await seek(_position + 15000);
//   }
//
//   Future<void> skipBackward() async {
//     await _audioHandler?.skipBackward();
//     await seek(_position - 15000);
//   }
//
//   Future<void> stopListening() async {
//     await WidgetsBinding.instance.endOfFrame;
//
//     try {
//       // Stop notification
//       await _audioHandler?.stop();
//
//       isBookListening.value = false;
//       isPlayAudio.value = false;
//
//       await setIsBookListening(false);
//
//       vAuthorName.value = "";
//       vBookName.value = "";
//       vBookImage.value = "";
//       vBookId.value = "";
//
//       bookInfo.value = BookInfoModel(authorName: '', bookName: '', bookImage: '', bookId: '');
//
//       await clearBookInfo();
//       await resetController();
//     } catch (e) {
//       print('Error in stopListening: $e');
//     }
//   }
//
//   @override
//   void onClose() {
//     _audioHandler?.dispose();
//     // ... rest of cleanup ...
//     super.onClose();
//   }
// }

// ============================================================
// 4. Android Manifest Configuration
// ============================================================

/*
Add to android/app/src/main/AndroidManifest.xml inside <application> tag:

<service
    android:name="com.ryanheise.audioservice.AudioService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="true"
    tools:ignore="Instantiatable">
    <intent-filter>
        <action android:name="android.media.browse.MediaBrowserService" />
    </intent-filter>
</service>

<receiver
    android:name="com.ryanheise.audioservice.MediaButtonReceiver"
    android:exported="true"
    tools:ignore="Instantiatable">
    <intent-filter>
        <action android:name="android.intent.action.MEDIA_BUTTON" />
    </intent-filter>
</receiver>

Add permissions:
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
*/

// ============================================================
// 5. Initialize in main.dart
// ============================================================

/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio service
  await AudioNotificationService.initialize();

  // Put controller
  Get.put(AudioTextController(), permanent: true);

  runApp(MyApp());
}
*/
