// ============================================================
// 1. Audio Notification Service
// ============================================================

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioNotificationService {
  static AudioHandler _audioHandler = AudioPlayerHandler();
  static AudioPlayer audioPlayer = AudioPlayer();

  static Future<void> initialize() async {
    _audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.yourapp.audio',
        androidNotificationChannelName: 'Audio Playback',
        androidNotificationOngoing: true,
        androidShowNotificationBadge: true,
      ),
    );
  }

  static AudioHandler? get audioHandler => _audioHandler;
}

// ============================================================
// 2. Audio Player Handler
// ============================================================

class AudioPlayerHandler extends BaseAudioHandler {
  // final AudioPlayer audioPlayer = AudioPlayer();

  AudioPlayerHandler() {
    _init();
  }

  void _init() {
    // Listen to player state changes

    AudioNotificationService.audioPlayer?.onPlayerStateChanged.listen((state) {
      final playing = state == PlayerState.playing;

      playbackState.add(playbackState.value.copyWith(playing: playing, processingState: playing ? AudioProcessingState.ready : AudioProcessingState.idle));
    });

    AudioNotificationService.audioPlayer?.onPositionChanged.listen((position) {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    });

    // // Listen to position changes
    // _player.positionStream.listen((position) {
    //   playbackState.add(playbackState.value.copyWith(updatePosition: position));
    // });

    AudioNotificationService.audioPlayer?.onDurationChanged.listen((duration) {
      final newMediaItem = mediaItem.value?.copyWith(duration: duration);
      if (newMediaItem != null) {
        mediaItem.add(newMediaItem);
      }
    });

    // Listen to duration changes
    // _player.durationStream.listen((duration) {
    //   final newMediaItem = mediaItem.value?.copyWith(duration: duration);
    //   if (newMediaItem != null) {
    //     mediaItem.add(newMediaItem);
    //   }
    // });
  }

  // Load and play audio
  Future<void> loadAndPlay({required String audioUrl, required String title, required String artist, required String artUri}) async {
    // Set media item for notification
    mediaItem.add(MediaItem(id: audioUrl, title: title, artist: artist, artUri: Uri.parse(artUri), duration: Duration.zero));

    try {
      if (audioUrl.startsWith('http')) {
        await AudioNotificationService.audioPlayer?.play(UrlSource(audioUrl));
      } else {
        await AudioNotificationService.audioPlayer?.play(AssetSource(audioUrl));
      }
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  @override
  Future<void> play() async {
    await AudioNotificationService.audioPlayer?.resume();
  }

  @override
  Future<void> pause() async {
    await AudioNotificationService.audioPlayer?.pause();
  }

  @override
  Future<void> stop() async {
    await AudioNotificationService.audioPlayer?.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await AudioNotificationService.audioPlayer?.seek(position);
  }

  Future<void> skipForward() async {
    final current = await AudioNotificationService.audioPlayer?.getCurrentPosition();
    final newPosition = (current ?? Duration.zero) + const Duration(seconds: 15);

    await AudioNotificationService.audioPlayer?.seek(newPosition);
  }

  Future<void> skipBackward() async {
    final current = await AudioNotificationService.audioPlayer?.getCurrentPosition();
    final newPosition = (current ?? Duration.zero) - const Duration(seconds: 15);

    await AudioNotificationService.audioPlayer?.seek(newPosition.isNegative ? Duration.zero : newPosition);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await AudioNotificationService.audioPlayer?.setPlaybackRate(speed);
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'setSpeed') {
      final speed = extras?['speed'] as double? ?? 1.0;
      await setSpeed(speed);
    }
  }

  Future<void> dispose() async {
    await AudioNotificationService.audioPlayer?.dispose();
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
