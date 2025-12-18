import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:utsav_interview/app/audio_text_view/models/bookmark_model.dart';

import 'package:utsav_interview/app/audio_text_view/models/paragrah_data_model.dart';
import 'package:utsav_interview/app/audio_text_view/models/transcript_data_model.dart';
import 'package:utsav_interview/app/audio_text_view/services/sync_enginge_service.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/pref.dart';

bool isAudioPlay = false;

class AudioTextController extends GetxController {
  // ------------------------------------------------------------
  // Controllers / Services
  // ------------------------------------------------------------
  final TextEditingController addNoteController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();

  TranscriptData? transcript;
  SyncEngine? syncEngine;

  late final ScrollController scrollController;
  late final ScrollController nestedScrollViewController;
  final List<GlobalKey> paragraphKeys = [];
  final List<GlobalKey> wordKeys = [];

  List<ParagraphData> paragraphs = [];

  bool isHideText = false;

  int currentWordIndex = -1;
  int currentParagraphIndex = -1;

  bool isCollapsed = false;
  bool isScrolling = false;
  bool isAnimateAppBarText = false;
  bool suppressAutoScroll = false;

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
  String selectedFonts = CS.vInter;
  Color colorAudioTextBg = AppColors.colorTealDark;
  Color colorAudioTextParagraphBg = AppColors.colorTealDarkBg;

  final List<double> presetSpeeds = [0.5, 0.75, 1, 1.5, 2];

  final List listThemeImg = [CS.imgSky, CS.imgFall, CS.imgHighlight, CS.imgClassic];
  int iThemeSelect = 0;

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
    updateAudioBoolean(true);
    scrollController = ScrollController(initialScrollOffset: -10);
    scrollController.addListener(_onCollapseScroll);
    initializeApp();
  }

  updateAudioBoolean(bool value) {
    isAudioPlay = value;
  }

  Future<void> saveBookmark({required BookmarkModel data}) async {
    final list = AppPrefs.getStringList(CS.keyBookmarks);

    list.add(jsonEncode(data.toJson()));

    await AppPrefs.setStringList(CS.keyBookmarks, list);
  }

  // ------------------------------------------------------------
  // Initialization
  // ------------------------------------------------------------
  Future<void> initializeApp() async {
    try {
      transcript = await fetchJsonData();
      paragraphs = transcript?.paragraphs ?? [];

      paragraphKeys.clear();
      wordKeys.clear();

      // keep original behaviour: generate paragraph keys
      paragraphKeys.addAll(List.generate(paragraphs.length, (_) => GlobalKey()));

      // Build wordKeys list (preserve original logic)
      for (final paragraph in paragraphs) {
        for (int i = 0; i < paragraph.words.length; i++) {
          wordKeys.add(GlobalKey());
        }
      }

      syncEngine = SyncEngine(paragraphs);

      _duration = transcript?.duration ?? 0;
      _audioUrl = transcript?.audioUrl;

      await audioInitialize();

      // Preserve user scroll listener addition
      scrollController.addListener(_onUserScroll);

      // Retained comment from original code (disabled post-frame capture)
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

  bookmark() {
    for (var element in paragraphs) {
      if (element.id == paragraphs[currentParagraphIndex].id) {
        element.isBookmarked = true;
      }
    }
    update();
  }

  // ------------------------------------------------------------
  // Collapse AppBar on Scroll
  // ------------------------------------------------------------
  void _onCollapseScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.isScrollingNotifier.value) {
      isScrolling = true;
      suppressAutoScroll = true;

      // If you need collapse logic
      isCollapsed = scrollController.offset > 60;

      update(["scrollButton"]); // update only button
    }
    final px = scrollController.position.pixels;
    if (px > 40 && !isCollapsed) {
      isCollapsed = true;
      update();
    } else if (px <= 40 && isCollapsed) {
      isCollapsed = false;

      update();
    }
  }

  bool get showScrollButton => isScrolling && suppressAutoScroll;

  // ------------------------------------------------------------
  // Detect manual scroll
  // ------------------------------------------------------------
  void _onUserScroll() {
    if (!scrollController.hasClients) return;

    // capture original behaviour: userScrollDirection used to decide debounce
    final direction = scrollController.position.userScrollDirection;

    if (direction != ScrollDirection.idle) {
      suppressAutoScroll = true;
      update();
    } else {
      suppressAutoScroll = false;
      update();
    }
  }

  // ------------------------------------------------------------
  // Position listener → highlight + auto-scroll
  // ------------------------------------------------------------
  void onAudioPositionUpdate() {
    if (!scrollController.hasClients || suppressAutoScroll || syncEngine == null) return;

    final newIndex = syncEngine!.findWordIndexAtTime(position);
    if (newIndex < 0) return;

    currentWordIndex = newIndex;
    currentParagraphIndex = syncEngine!.getParagraphIndex(newIndex);

    if (newIndex != -1) {
      scrollToCurrentWord(newIndex);
    }

    update();
  }

  Future<void> scrollToCurrentWord(int index) async {
    if (index < 0 || index >= wordKeys.length) return;
    final key = wordKeys[index];

    // quick check: if context is not ready, wait a short time and recheck
    if (key.currentContext == null) {
      await Future.delayed(const Duration(milliseconds: 40));
      if (key.currentContext == null) return;
    }

    try {
      await Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 200), alignment: 0.4, curve: Curves.easeOutCubic);
    } catch (_) {
      // swallow errors as original
    }
  }

  void scrollToCurrentParagraph(int index) {
    if (scrollController.hasClients == false) return;
    if (index < 0 || index >= paragraphKeys.length) return;

    final key = paragraphKeys[index];
    final context = key.currentContext;

    if (context != null) {
      // Paragraph built → safe to compute offset and animate
      final box = context.findRenderObject() as RenderBox;
      final offset = box.localToGlobal(Offset.zero).dy;

      scrollController.animateTo(
        scrollController.offset, // Adjust padding as original
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      // Offscreen paragraph → fallback estimation
      _scrollToIndexFallback(index);
    }
  }

  void _scrollToIndexFallback(int index) {
    // Estimate height per paragraph or store heights dynamically
    const double estimatedParagraphHeight = 180.0;
    final position = index * estimatedParagraphHeight;

    scrollController.animateTo(position, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

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
        await audioPlayer.setSourceUrl(_audioUrl!);
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
  Future<void> play({bool isPositionScrollOnly = false}) async {
    if (_isDisposed || !_isInitialized || _operationInProgress) return;
    // if (_isPlaying) return;

    _operationInProgress = true;

    try {
      // ⭐ NEW: If no paragraph is active → scroll to top
      if (currentParagraphIndex == -1) {
        await scrollController.animateTo(0, duration: Duration(milliseconds: 400), curve: Curves.easeOut);
      }

      // If audio ended → reset position
      if (_position >= _duration - 100) {
        _position = 0;
        _hasPlayedOnce = false;
      }

      // IMPORTANT → seek logic (your original)
      if (_position > -1) {
        _operationInProgress = false;
        await seek(_position, isPlay: true);
      }

      // First-time play
      if (!_hasPlayedOnce) {
        await audioPlayer.play(UrlSource(_audioUrl!));
        _hasPlayedOnce = true;
      }
      // Resume
      else {
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
  Future<void> seek(int positionMs, {bool isPlay = false}) async {
    if (_isDisposed || !_isInitialized || _operationInProgress) return;

    _operationInProgress = true;
    _isSeeking = true;

    // suppressAutoScroll = true;

    try {
      _position = positionMs.clamp(0, _duration);

      await audioPlayer.seek(Duration(milliseconds: _position));

      _lastDriftCheck = _isPlaying ? DateTime.now() : null;

      await Future.delayed(const Duration(milliseconds: 100));

      if (syncEngine != null) {
        currentWordIndex = syncEngine!.findWordIndexAtTime(_position);
        currentParagraphIndex = syncEngine!.getParagraphIndex(currentWordIndex);

        if (wordKeys.isNotEmpty) {
          if (isPlay) {
            safeScrollToParagraph(currentParagraphIndex);
          } else {
            scrollToCurrentWord(currentWordIndex);
          }
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

  DateTime? _lastScrollTime;

  void safeScrollToParagraph(int index) {
    final now = DateTime.now();
    if (_lastScrollTime != null && now.difference(_lastScrollTime!) < const Duration(milliseconds: 120)) {
      return;
    }

    _lastScrollTime = now;

    scrollToCurrentParagraph(index);
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

      // preserve original assignment
      jsonData['audioUrl'] = 'audio.mp3';

      return TranscriptData.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load transcript: $e');
    }
  }

  Future<TranscriptData> fetchJsonData() async {
    try {
      final url = Uri.parse(
        'https://firebasestorage.googleapis.com/v0/b/storyverse-db8a5.firebasestorage.app/o/books%2Fjson%2F4VGE6wTtMokWjiCFeXIE%2Ftranscript.json?alt=media&token=1a134233-33af-4f87-b174-4b7fa82c7ae4',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        jsonData['audioUrl'] =
            'https://firebasestorage.googleapis.com/v0/b/storyverse-db8a5.firebasestorage.app/o/books%2Faudios%2F4VGE6wTtMokWjiCFeXIE%2FElevenLabs_2025-12-16T10_40_39_Ariana%20Grande_ivc_sp100_s50_sb75_se0_b_m2.mp3?alt=media&token=b83843c6-f124-450d-b731-ed336adf8cdf';

        return TranscriptData.fromJson(jsonData);
      } else {
        print('Failed to fetch. Status: ${response.statusCode}');
        throw Exception('Failed to fetch. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
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

    // safe dispose of scrollController
    try {
      scrollController.dispose();
    } catch (_) {}

    audioPlayer.stop();
    audioPlayer.dispose();

    super.onClose();
  }
}
