import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
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

  // ------------------------------------------------------------
  // Auto-scroll / UI
  // ------------------------------------------------------------
  bool _isAutoScrolling = false;
  bool userScrolling = false;

  int currentWordIndex = -1;
  int currentParagraphIndex = -1;

  Timer? debounceTimer;
  Timer? userScrollTimer;

  bool isCollapsed = false;
  bool isAnimateAppBarText = false;

  bool suppressAutoScroll = false;
  List<ParagraphData> paragraphs = [];

  // paragraph pixel offsets cache (index -> absolute scroll offset)
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

  // ------------------------------
  // Collapse AppBar on Scroll
  // ------------------------------
  void _onCollapseScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels > 40) {
      if (!isCollapsed) {
        isCollapsed = true;
        update();
      }
    } else {
      if (isCollapsed) {
        isCollapsed = false;
        update();
      }
    }
  }

  // ------------------------------------------------------------
  // Initialization
  // ------------------------------------------------------------
  Future<void> initializeApp() async {
    try {
      transcript = await loadRealData();

      // populate paragraphs and paragraph keys
      paragraphs = transcript?.paragraphs ?? [];
      paragraphKeys.clear();
      paragraphKeys.addAll(List.generate(paragraphs.length, (_) => GlobalKey()));

      syncEngine = SyncEngine(transcript!.paragraphs);

      _duration = transcript?.duration ?? 0;
      _audioUrl = transcript?.audioUrl;

      await audioInitialize();

      addListener(onAudioPositionUpdate);
      scrollController.addListener(_onUserScroll);

      // attempt to capture offsets once the UI builds (UI must call this too when layout done)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        captureParagraphOffsets();
      });

      if (!isClosed) update();
    } catch (e) {
      if (!isClosed) {
        hasError = true;
        errorMessage = 'Initialization error: $e';
        update();
      }
    }
  }

  // ------------------------------------------------------------
  // Detect manual user scroll (optimized)
  // ------------------------------------------------------------
  void _onUserScroll() {
    if (_isDisposed) return;
    if (!scrollController.hasClients) return;
    if (_isAutoScrolling) return; // Ignore auto-scroll events

    // mark user is scrolling and reset timer
    userScrolling = true;
    userScrollTimer?.cancel();
    // shorter timer for snappy feel but long enough to avoid conflicts
    userScrollTimer = Timer(const Duration(milliseconds: 900), () {
      userScrolling = false;
      update();
    });
  }

  // ------------------------------------------------------------
  // Audio Position Listener → Highlight Words → Auto-scroll
  // (Option A behavior: only on paragraph change)
  // ------------------------------------------------------------
  void onAudioPositionUpdate() {
    if (_isDisposed) return;
    if (suppressAutoScroll) return;
    if (!scrollController.hasClients) return;

    debounceTimer?.cancel();
    debounceTimer = Timer(const Duration(milliseconds: 16), () {
      final engine = syncEngine;
      if (engine == null) return;

      final newWordIndex = engine.findWordIndexAtTime(position);

      if (newWordIndex < 0) return;

      final pIndex = engine.getParagraphIndex(newWordIndex);

      // ONLY act if paragraph changed (Option A)
      if (pIndex != currentParagraphIndex) {
        // update indices
        currentParagraphIndex = pIndex;
        currentWordIndex = newWordIndex;

        // only auto-scroll if user isn't actively scrolling
        if (!userScrolling && scrollController.hasClients) {
          // try context-based scroll; if not possible, fallback to offset-based
          scrollToParagraph(paragraphKeys[pIndex], alignment: 0.30);
        }

        if (!isClosed) update();
      } else {
        // we still update word highlight index even when paragraph unchanged
        currentWordIndex = newWordIndex;
        if (!isClosed) update();
      }
    });
  }

  // ------------------------------------------------------------
  // Scroll to Paragraph (context-first, multi-frame recovery,
  // fallback to offset-based animateTo using cached offsets)
  // ------------------------------------------------------------
  Future<void> scrollToParagraph(GlobalKey key, {double alignment = 0.40}) async {
    try {
      if (!scrollController.hasClients) return;

      // Avoid multiple overlaps
      if (_isAutoScrolling) return;

      BuildContext? ctx = key.currentContext;

      // Multi-frame recovery: try a few frames if context null
      if (ctx == null) {
        for (int i = 0; i < 6; i++) {
          await Future.delayed(const Duration(milliseconds: 16));
          ctx = key.currentContext;
          if (ctx != null) break;
        }
      }

      _isAutoScrolling = true;

      if (ctx != null) {
        // preferred approach — ensureVisible uses the exact widget
        try {
          await Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic, alignment: alignment);
          // capture offsets after a successful ensureVisible so fallback has data later
          WidgetsBinding.instance.addPostFrameCallback((_) => captureParagraphOffsets());
        } catch (e) {
          debugPrint("ensureVisible failed, will try offset fallback: $e");
          await _scrollToParagraphByOffsetFallback(key, alignment: alignment);
        }
      } else {
        // fallback path when context still null
        await _scrollToParagraphByOffsetFallback(key, alignment: alignment);
      }
    } catch (e) {
      debugPrint("scrollToParagraph ERROR: $e");
    } finally {
      // small delay to avoid immediate re-entry and allow rebuilds
      await Future.delayed(const Duration(milliseconds: 120));
      _isAutoScrolling = false;
    }
  }

  // ------------------------------------------------------------
  // Fallback: compute or use cached offsets and animateTo that offset
  // ------------------------------------------------------------
  Future<void> _scrollToParagraphByOffsetFallback(GlobalKey key, {double alignment = 0.30}) async {
    // Ensure offsets exist (attempt to capture)
    if (paragraphOffsets.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 16));
      captureParagraphOffsets();
      // small pause to let capture run
      await Future.delayed(const Duration(milliseconds: 16));
    }

    // find paragraph index from key
    final pIndex = paragraphKeys.indexOf(key);
    if (pIndex < 0) return;

    final targetOffset = paragraphOffsets[pIndex];
    if (targetOffset == null) {
      // if we don't have an offset, estimate using average paragraph height
      final avg = _estimateAverageParagraphHeight();
      final estimate = (pIndex * avg).clamp(0.0, scrollController.position.maxScrollExtent);
      await scrollController.animateTo(estimate, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
      return;
    }

    // apply a small top padding (so paragraph is not flush to very top)
    final double topPadding = 80.0;
    final scrollTo = (targetOffset - topPadding).clamp(0.0, scrollController.position.maxScrollExtent);

    await scrollController.animateTo(scrollTo, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
  }

  // ------------------------------------------------------------
  // Capture paragraph offsets (call from UI after build, and we call after ensures)
  // ------------------------------------------------------------
  void captureParagraphOffsets() {
    if (!scrollController.hasClients) return;
    paragraphOffsets.clear();

    for (int i = 0; i < paragraphKeys.length; i++) {
      try {
        final ctx = paragraphKeys[i].currentContext;
        if (ctx == null) continue;

        final box = ctx.findRenderObject() as RenderBox?;
        if (box == null) continue;

        // compute absolute offset relative to scrollable
        // localToGlobal returns position on screen; adding scrollController.offset gets absolute scroll offset.
        final dy = box.localToGlobal(Offset.zero).dy + scrollController.offset;
        paragraphOffsets[i] = dy;
      } catch (_) {}
    }
  }

  double _estimateAverageParagraphHeight() {
    if (paragraphOffsets.length >= 2) {
      // use first two offsets as an approximation
      final keys = paragraphOffsets.keys.toList()..sort();
      final d0 = paragraphOffsets[keys.first]!;
      final d1 = paragraphOffsets[keys.length > 1 ? keys[1] : keys.first]!;
      final diff = (d1 - d0).abs();
      if (diff > 0) return diff;
    }
    // fallback reasonable default
    return 200.0;
  }

  // ------------------------------------------------------------
  // Audio Initialization
  // ------------------------------------------------------------
  Future<void> audioInitialize() async {
    if (_isDisposed || _isInitialized) return;

    try {
      _isLoading = true;
      _error = null;
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

  void _handleCompletion() {
    _isPlaying = false;
    _hasPlayedOnce = true;
    _position = _duration;
    _lastDriftCheck = null;
    update();
  }

  // Audio Stream Handlers
  void _onPositionStream(Duration pos) {
    if (_isSeeking || _isDisposed) return;

    final newPos = pos.inMilliseconds.clamp(0, _duration);

    if ((_position - newPos).abs() > 100) {
      _position = newPos;
      _checkDrift();
      update();
    }
  }

  void _onStateStream(PlayerState state) {
    if (_isDisposed) return;

    final wasPlaying = _isPlaying;
    _isPlaying = state == PlayerState.playing;

    if (wasPlaying != _isPlaying) {
      if (!_isPlaying) {
        _lastDriftCheck = null;
      }
      update();
    }
  }

  void _checkDrift() {
    if (!_isPlaying || _isSeeking) return;

    final now = DateTime.now();

    if (_lastDriftCheck != null) {
      final elapsed = now.difference(_lastDriftCheck!);

      // Check drift every 5 seconds
      if (elapsed.inSeconds >= 5) {
        audioPlayer
            .getCurrentPosition()
            .then((actualPosition) {
              if (actualPosition == null || _isDisposed || !_isPlaying) return;

              final actualMs = actualPosition.inMilliseconds.clamp(0, _duration);
              final drift = (actualMs - _position).abs();

              if (drift > 200) {
                _position = actualMs;
                _driftCorrectionCount++;
                update();
              }
            })
            .catchError((_) {});

        _lastDriftCheck = now;
      }
    } else {
      _lastDriftCheck = now;
    }
  }

  // ------------------------------------------------------------
  // Audio Controls
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
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  // ------------------------------------------------------------
  // Seek
  // ------------------------------------------------------------
  Future<void> seek(int positionMs, {bool fromUser = false}) async {
    if (_isDisposed || !_isInitialized || _operationInProgress) return;

    if (fromUser) {
      suppressAutoScroll = true;
      userScrolling = true;
    }

    _operationInProgress = true;
    _isSeeking = true;

    try {
      _position = positionMs.clamp(0, _duration);
      await audioPlayer.seek(Duration(milliseconds: _position));

      await Future.delayed(const Duration(milliseconds: 70));

      _lastDriftCheck = _isPlaying ? DateTime.now() : null;
      update();
    } catch (e) {
      _error = 'Seek error: $e';
      update();
    } finally {
      _isSeeking = false;
      _operationInProgress = false;

      if (fromUser) {
        // allow UI to settle then re-enable auto-scroll and force paragraph scroll
        Future.delayed(const Duration(milliseconds: 120), () async {
          if (_isDisposed) return;

          userScrolling = false;
          suppressAutoScroll = false;
          update();

          // Force paragraph-scroll on user seek end
          forceAutoScrollToCurrentParagraph();
        });
      }
    }
  }

  void forceAutoScrollToCurrentParagraph() {
    if (_isDisposed) return;
    if (!scrollController.hasClients) return;
    if (syncEngine == null) return;

    final pIndex = syncEngine!.findParagraphIndexAtTime(_position);
    if (pIndex < 0 || pIndex >= paragraphKeys.length) return;

    final key = paragraphKeys[pIndex];

    // prefer context-based, fallback inside scrollToParagraph handles other cases
    scrollToParagraph(key, alignment: 0.20);
  }

  Future<void> skipForward() async => await seek(_position + 10000);

  Future<void> skipBackward() async => await seek(_position - 10000);

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
    return '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
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
