import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:utsav_interview/app/audio_text_view/models/paragrah_data_model.dart';
import 'package:utsav_interview/app/audio_text_view/models/transcript_data_model.dart';
import 'package:utsav_interview/app/audio_text_view/services/sync_enginge_service.dart';
import 'package:utsav_interview/core/common_string.dart';

class AudioTextController extends GetxController {
  // ------------------------------------------------------------
  // Controllers / Services
  // ------------------------------------------------------------
  final TextEditingController addNoteController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();

  TranscriptData? transcript;
  SyncEngine? syncEngine;

  late final ScrollController scrollController;
  final List<GlobalKey> paragraphKeys = [];
  final List<GlobalKey> wordKeys = [];

  List<ParagraphData> paragraphs = [];

  // ------------------------------------------------------------
  // Auto-scroll / UI
  // ------------------------------------------------------------
  bool _isAutoScrolling = false;
  bool userScrolling = false;

  int currentWordIndex = -1;
  int currentParagraphIndex = -1;

  bool isCollapsed = false;
  bool isAnimateAppBarText = false;
  bool suppressAutoScroll = false;

  Timer? debounceTimer;
  Timer? userScrollTimer;

  // paragraph pixel offsets cache
  final Map<int, double> paragraphOffsets = {};

  // ------------------------------------------------------------
  // Audio properties
  // ------------------------------------------------------------
  bool hasError = false;
  String? errorMessage;

  bool _isPlaying = false;
  double _speed = 1.0;

  int _position = 0;
  int _duration = 0;
  String? _audioUrl;

  bool _isLoading = false;
  bool _isInitialized = false;
  bool _hasPlayedOnce = false;
  String? _error;

  int _driftCorrectionCount = 0;
  DateTime? _lastDriftCheck;

  bool _isSeeking = false;
  bool _isDisposed = false;
  bool _operationInProgress = false;

  // ------------------------------------------------------------
  // Player Streams
  // ------------------------------------------------------------
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<void>? _completionSubscription;

  // ------------------------------------------------------------
  // Speed Options
  // ------------------------------------------------------------
  double currentSpeed = 1.0;
  int currentIndex = 8;

  final List<double> presetSpeeds = [0.5, 0.75, 1.0, 1.5, 2.0];

  final List<double> speedSteps = [
    0.25,
    0.30,
    0.40,
    0.50,
    0.60,
    0.70,
    0.80,
    0.90,
    1.0,
    1.1,
    1.2,
    1.3,
    1.4,
    1.5,
    1.6,
    1.7,
    1.8,
    1.9,
    2.0,
    2.1,
    2.2,
    2.3,
    2.4,
    2.5,
    2.6,
    2.7,
    2.8,
    2.9,
    3.0,
  ];

  // ------------------------------------------------------------
  // Getters
  // ------------------------------------------------------------
  bool get isPlaying => _isPlaying;

  int get position => _position;

  double get speed => _speed;

  int get duration => _duration;

  bool get isLoading => _isLoading;

  String? get error => _error;

  int get driftCorrectionCount => _driftCorrectionCount;

  bool get isInitialized => _isInitialized;

  // ------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController(initialScrollOffset: -10);
    scrollController.addListener(_onCollapseScroll);
    initializeApp();
  }

  // ------------------------------------------------------------
  // Collapse AppBar on Scroll
  // ------------------------------------------------------------
  void _onCollapseScroll() {
    if (!scrollController.hasClients) return;

    if (scrollController.position.pixels > 40 && !isCollapsed) {
      isCollapsed = true;
      update();
    } else if (scrollController.position.pixels <= 40 && isCollapsed) {
      isCollapsed = false;
      update();
    }
  }

  // ------------------------------------------------------------
  // Initialization
  // ------------------------------------------------------------
  Future<void> initializeApp() async {
    try {
      transcript = await loadRealData();
      paragraphs = transcript?.paragraphs ?? [];

      paragraphKeys.clear();
      wordKeys.clear();

      paragraphKeys.addAll(List.generate(paragraphs.length, (_) => GlobalKey()));

      // Build wordKeys list
      for (final paragraph in paragraphs) {
        for (int i = 0; i < paragraph.words.length; i++) {
          wordKeys.add(GlobalKey());
        }
      }

      syncEngine = SyncEngine(paragraphs);

      _duration = transcript?.duration ?? 0;
      _audioUrl = transcript?.audioUrl;

      await audioInitialize();

      // scrollController.addListener(_onUserScroll);

      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //    captureParagraphOffsets();
      // });

      if (!isClosed) update();
    } catch (e) {
      hasError = true;
      errorMessage = 'Initialization error: $e';
      update();
    }
  }

  // ------------------------------------------------------------
  // Detect manual scroll
  // ------------------------------------------------------------
  // void _onUserScroll() {
  //   if (_isAutoScrolling || !scrollController.hasClients) return;
  //
  //   final direction = scrollController.position.userScrollDirection;
  //
  //   if (direction != ScrollDirection.idle) {
  //     userScrolling = true;
  //     userScrollTimer?.cancel();
  //     print(ScrollDirection.reverse);
  //     userScrollTimer = Timer(Duration(milliseconds: direction == ScrollDirection.reverse ? 200 : 400), () {
  //       userScrolling = false;
  //       update();
  //     });
  //   }
  // }

  // ------------------------------------------------------------
  // Position listener → highlight + auto-scroll
  // ------------------------------------------------------------
  void onAudioPositionUpdate() {
    if (!scrollController.hasClients || suppressAutoScroll || syncEngine == null) return;

    final newIndex = syncEngine!.findWordIndexAtTime(position);
    if (newIndex < 0) return;

    currentWordIndex = newIndex;
    currentParagraphIndex = syncEngine!.getParagraphIndex(newIndex);

    if (!userScrolling && wordKeys.isNotEmpty) {
      scrollToCurrentWord(newIndex);
    }

    update();
  }

  Future<void> scrollToCurrentWord(int index) async {
    if (index < 0 || index >= wordKeys.length) return;
    final key = wordKeys[index];

    if (key.currentContext == null) return;
    try {
      await Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 200), alignment: 0.4, curve: Curves.easeOutCubic);
    } catch (_) {}
  }

  // ------------------------------------------------------------
  // Capture paragraph offsets
  // ------------------------------------------------------------
  // void captureParagraphOffsets() {
  //   if (!scrollController.hasClients) return;
  //
  //   paragraphOffsets.clear();
  //
  //   for (int i = 0; i < paragraphKeys.length; i++) {
  //     final ctx = paragraphKeys[i].currentContext;
  //
  //     if (ctx == null) continue;
  //
  //     final box = ctx.findRenderObject() as RenderBox?;
  //     if (box == null) continue;
  //
  //     final dy = box.localToGlobal(Offset.zero).dy + scrollController.offset;
  //     paragraphOffsets[i] = dy;
  //   }
  // }

  // ------------------------------------------------------------
  // Audio Initialization
  // ------------------------------------------------------------
  Future<void> audioInitialize() async {
    if (_isInitialized || _isDisposed) return;

    try {
      _isLoading = true;
      update();

      if (_audioUrl != null) {
        await audioPlayer.setReleaseMode(ReleaseMode.stop);
        await audioPlayer.setSourceAsset(_audioUrl!);
        await audioPlayer.setPlaybackRate(_speed);

        _positionSubscription = audioPlayer.onPositionChanged.listen(_onPositionStream);
        _stateSubscription = audioPlayer.onPlayerStateChanged.listen(_onStateStream);
        _completionSubscription = audioPlayer.onPlayerComplete.listen((_) => _handleCompletion());

        _isInitialized = true;
      }

      _isLoading = false;
      update();
    } catch (e) {
      _error = 'Failed to load audio: $e';
      _isLoading = false;
      update();
    }
  }

  // ------------------------------------------------------------
  // Audio Stream handlers
  // ------------------------------------------------------------
  void _handleCompletion() {
    _isPlaying = false;
    _hasPlayedOnce = true;
    _position = _duration;
    _lastDriftCheck = null;
    update();
  }

  void _onPositionStream(Duration pos) {
    if (_isSeeking || _isDisposed) return;

    final newPos = pos.inMilliseconds.clamp(0, _duration);

    if ((_position - newPos).abs() > 100) {
      _position = newPos;

      if (!suppressAutoScroll) {
        onAudioPositionUpdate();
      }

      _checkDrift();
      update();
    }
  }

  void _onStateStream(PlayerState state) {
    if (_isDisposed) return;

    final wasPlaying = _isPlaying;
    _isPlaying = state == PlayerState.playing;

    if (wasPlaying != _isPlaying && !_isPlaying) {
      _lastDriftCheck = null;
    }

    update();
  }

  // ------------------------------------------------------------
  // Drift correction
  // ------------------------------------------------------------
  void _checkDrift() {
    if (!_isPlaying || _isSeeking) return;

    final now = DateTime.now();

    if (_lastDriftCheck != null) {
      final elapsed = now.difference(_lastDriftCheck!);

      if (elapsed.inSeconds >= 5) {
        audioPlayer.getCurrentPosition().then((actualPosition) {
          if (actualPosition == null || !_isPlaying || _isDisposed) return;

          final actualMs = actualPosition.inMilliseconds.clamp(0, _duration);

          if ((actualMs - _position).abs() > 200) {
            _position = actualMs;
            _driftCorrectionCount++;
            update();
          }
        });

        _lastDriftCheck = now;
      }
    } else {
      _lastDriftCheck = now;
    }
  }

  // ------------------------------------------------------------
  // Playback Controls
  // ------------------------------------------------------------
  Future<void> play() async {
    if (_isDisposed || !_isInitialized || _operationInProgress) return;
    if (_isPlaying) return;

    _operationInProgress = true;

    try {
      if (_position >= _duration - 100) {
        _position = 0;
        _isSeeking = true;

        await audioPlayer.seek(Duration.zero);

        _isSeeking = false;
        _hasPlayedOnce = false;
      }

      if (!_hasPlayedOnce) {
        await audioPlayer.play(AssetSource(_audioUrl!));
        _hasPlayedOnce = true;
      } else {
        await audioPlayer.resume();
      }

      _isPlaying = true;
      _lastDriftCheck = DateTime.now();

      update();
    } catch (e) {
      _error = 'Playback error: $e';
      update();
    } finally {
      _operationInProgress = false;
    }
  }

  Future<void> pause() async {
    if (_isDisposed || !_isInitialized || _operationInProgress) return;
    if (!_isPlaying) return;

    _operationInProgress = true;

    try {
      await audioPlayer.pause();
      _isPlaying = false;
      _lastDriftCheck = null;
      update();
    } catch (e) {
      _error = 'Pause error: $e';
      update();
    } finally {
      _operationInProgress = false;
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying)
      await pause();
    else
      await play();
  }

  // ------------------------------------------------------------
  // Seek
  // ------------------------------------------------------------
  Future<void> seek(int positionMs) async {
    if (_isDisposed || !_isInitialized || _operationInProgress) return;

    _operationInProgress = true;
    _isSeeking = true;

    suppressAutoScroll = true;

    try {
      _position = positionMs.clamp(0, _duration);

      await audioPlayer.seek(Duration(milliseconds: _position));

      _lastDriftCheck = _isPlaying ? DateTime.now() : null;

      await Future.delayed(const Duration(milliseconds: 100));

      if (syncEngine != null) {
        currentWordIndex = syncEngine!.findWordIndexAtTime(_position);
        currentParagraphIndex = syncEngine!.getParagraphIndex(currentWordIndex);

        if (!userScrolling && wordKeys.isNotEmpty) {
          scrollToCurrentWord(currentWordIndex);
        }
      }

      update();
    } catch (e) {
      _error = 'Seek error: $e';
      update();
    } finally {
      await Future.delayed(const Duration(milliseconds: 50));

      suppressAutoScroll = false;
      _isSeeking = false;
      _operationInProgress = false;

      update();
    }
  }

  Future<void> skipForward() async => seek(_position + 10000);

  Future<void> skipBackward() async => seek(_position - 10000);

  // ------------------------------------------------------------
  // Speed
  // ------------------------------------------------------------
  Future<void> setSpeed(double newSpeed) async {
    if (_isDisposed || !_isInitialized || _operationInProgress) return;

    _operationInProgress = true;

    try {
      final s = newSpeed.clamp(0.5, 2.0);

      if ((_speed - s).abs() < 0.01) {
        _operationInProgress = false;
        return;
      }

      _speed = s;
      await audioPlayer.setPlaybackRate(_speed);

      _lastDriftCheck = _isPlaying ? DateTime.now() : null;
      _driftCorrectionCount = 0;

      update();
    } catch (e) {
      _error = 'Speed change error: $e';
      update();
    } finally {
      _operationInProgress = false;
    }
  }

  // ------------------------------------------------------------
  // Reset Player
  // ------------------------------------------------------------
  Future<void> reset() async {
    if (_isDisposed || !_isInitialized) return;

    await pause();
    await seek(0);

    _error = null;
    _driftCorrectionCount = 0;
    _hasPlayedOnce = false;

    update();
  }

  // ------------------------------------------------------------
  // Utility
  // ------------------------------------------------------------
  String formatTime(int ms) {
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  // ------------------------------------------------------------
  // Load JSON Transcript
  // ------------------------------------------------------------
  Future<TranscriptData> loadRealData() async {
    try {
      final jsonString = await rootBundle.loadString(CS.vJsonTranscript1);
      final jsonData = json.decode(jsonString);

      jsonData['audioUrl'] = 'audio.mp3';

      return TranscriptData.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load transcript: $e');
    }
  }

  // ------------------------------------------------------------
  // Cleanup
  // ------------------------------------------------------------
  @override
  void onClose() {
    _isDisposed = true;

    _positionSubscription?.cancel();
    _stateSubscription?.cancel();
    _completionSubscription?.cancel();

    debounceTimer?.cancel();
    userScrollTimer?.cancel();

    scrollController.dispose();

    audioPlayer.stop();
    audioPlayer.dispose();

    super.onClose();
  }
}
