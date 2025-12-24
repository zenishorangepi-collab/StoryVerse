import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:utsav_interview/app/audio_text_view/audio_notification_service/notification_service.dart';
import 'package:utsav_interview/app/audio_text_view/models/book_info_model.dart';
import 'package:utsav_interview/app/audio_text_view/models/bookmark_model.dart';

import 'package:utsav_interview/app/audio_text_view/models/paragrah_data_model.dart';
import 'package:utsav_interview/app/audio_text_view/models/transcript_data_model.dart';
import 'package:utsav_interview/app/audio_text_view/services/sync_enginge_service.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';
import 'package:utsav_interview/app/home_screen/models/recent_listen_model.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/pref.dart';

RxBool isBookListening = false.obs;
RxBool isPlayAudio = false.obs;
// RxString vAuthorName = "".obs;
// RxString vBookName = "".obs;
// RxString vBookImage = "".obs;
// RxString vBookId = "".obs;
Rx<BookInfoModel> bookInfo = BookInfoModel(authorName: '', bookName: '', bookImage: '', bookId: '', textUrl: '', audioUrl: '', summary: "").obs;

class AudioTextController extends GetxController {
  // Models & Data
  NovelsDataModel? novelData;
  TranscriptData? transcript;
  SyncEngine? syncEngine;
  List<ParagraphData> paragraphs = [];
  List<BookmarkModel>? listBookmarks;

  // Controllers & Services
  final TextEditingController addNoteController = TextEditingController();
  AudioPlayer audioPlayer = AudioPlayer();
  AudioPlayerHandler? audioHandler;
  late final ScrollController scrollController;

  // Keys for scroll tracking
  final List<GlobalKey> paragraphKeys = [];
  final List<GlobalKey> wordKeys = [];

  // Book metadata
  String bookNme = "";
  String authorNme = "";
  String bookCoverUrl = "";
  String audioUrl = "";
  String textUrl = "";
  String bookId = "";
  String bookSummary = "";

  // UI State
  bool isHideText = false;
  bool isCollapsed = false;
  bool isScrolling = false;
  bool suppressAutoScroll = false;
  bool hasError = false;
  bool isBookMarkDelete = false;
  String? errorMessage;

  // Audio State
  int currentWordIndex = -1;
  int currentParagraphIndex = -1;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _hasPlayedOnce = false;
  bool _isLoading = false;
  bool _isSeeking = false;
  bool _isDisposed = false;
  bool _operationInProgress = false;
  double _speed = 1.0;
  int _position = 0;
  int _duration = 0;
  String? _audioUrl;
  String? _error;
  int _driftCorrectionCount = 0;

  // Timestamps
  DateTime? _lastDriftCheck;
  DateTime? _lastScrollTime;
  DateTime? _lastPositionSave;

  // Subscriptions
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<void>? _completionSubscription;

  // Speed Options
  double currentSpeed = 1.0;
  int currentIndex = 8;
  final List<double> presetSpeeds = [0.5, 0.75, 1, 1.5, 2];
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

  // Theme Options
  String selectedFonts = CS.vInter;
  Color colorAudioTextBg = AppColors.colorTealDark;
  Color colorAudioTextParagraphBg = AppColors.colorTealDarkBg;
  int iThemeSelect = 0;
  final List listThemeImg = [CS.imgSky, CS.imgFall, CS.imgHighlight, CS.imgClassic];

  // Getters
  bool get isPlaying => _isPlaying;

  int get position => _position;

  double get speed => _speed;

  int get duration => _duration;

  bool get isLoading => _isLoading;

  String? get error => _error;

  int get driftCorrectionCount => _driftCorrectionCount;

  bool get isInitialized => _isInitialized;

  bool get showScrollButton => isScrolling && suppressAutoScroll;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAudioService();
      WidgetsBinding.instance.addPostFrameCallback((_) => loadIsBookListening());
      scrollController = ScrollController(initialScrollOffset: -10)..addListener(_onCollapseScroll);
      if (Get.arguments != null) initializeApp();
    });
  }

  // ------------------------------------------------------------
  // Initialization
  // ------------------------------------------------------------
  Future<void> initializeApp() async {
    bool usedCache = false;

    try {
      if (Get.arguments != null) {
        novelData = Get.arguments["novelData"];
      } else {
        bookInfo.value = await loadBookInfo();
      }

      if (Get.arguments != null && novelData != null) {
        audioUrl = novelData?.audioFiles?.first.url ?? "";
        textUrl = novelData?.audioFiles?.first.audioJsonUrl ?? "";
        bookId = novelData?.id ?? "";
        authorNme = novelData?.author?.name ?? "";
        bookNme = novelData?.bookName ?? "";
        bookCoverUrl = novelData?.bookCoverUrl ?? "";
        bookSummary = novelData?.summary ?? "";
      } else {
        audioUrl = bookInfo.value.audioUrl;
        textUrl = bookInfo.value.textUrl;
        bookId = bookInfo.value.bookId;
        authorNme = bookInfo.value.authorName;
        bookNme = bookInfo.value.bookName;
        bookCoverUrl = bookInfo.value.bookImage;
        bookSummary = bookInfo.value.summary;
      }

      print('📌 Book ID: $bookId');
      print('📌 Audio URL: $audioUrl');

      // ✅ Step 1: Try to load from cache first
      TranscriptData? cachedTranscript = getCachedTranscript(bookId);

      if (cachedTranscript != null) {
        print('✅ Using cached transcript');
        transcript = cachedTranscript;
        usedCache = true;
      } else {
        // ✅ Step 2: Load from server if no cache
        print('🌐 Loading transcript from server...');
        transcript = await fetchJsonData(audioUrl: audioUrl, textUrl: textUrl);

        // ✅ Step 3: Cache the transcript and URLs for next time
        if (transcript != null) {
          await cacheTranscript(bookId: bookId, transcript: transcript!);
          await cacheUrls(bookId: bookId, audioUrl: audioUrl, jsonUrl: textUrl);
        }
      }

      paragraphs = transcript?.paragraphs ?? [];

      getBookmark();
      paragraphKeys.clear();
      wordKeys.clear();

      paragraphKeys.addAll(List.generate(paragraphs.length, (_) => GlobalKey()));

      for (final paragraph in paragraphs) {
        final allWords = paragraph.allWords;
        for (int i = 0; i < allWords.length; i++) {
          wordKeys.add(GlobalKey());
        }
      }

      syncEngine = SyncEngine(paragraphs);

      _duration = transcript?.duration ?? 0;
      _audioUrl = transcript?.audioUrl;
      print('📌 JSON URL: $_audioUrl');
      await audioInitialize();

      // Load saved position
      final savedPosition = await loadSavedPosition();
      if (savedPosition > 0 && savedPosition < _duration) {
        _position = savedPosition;
        print('✅ Restoring position to: ${formatTime(savedPosition)}');

        if (syncEngine != null) {
          currentWordIndex = syncEngine!.findWordIndexAtTime(_position);
          currentParagraphIndex = syncEngine!.getParagraphIndex(currentWordIndex);
        }
      }

      saveRecentView(RecentViewModel(id: bookId, title: bookNme, image: bookCoverUrl, summary: bookSummary, length: formatTime(duration)));

      scrollController.addListener(_onUserScroll);
      await _setupNotification();

      if (!isClosed) update();

      print('✅ Initialization completed ${usedCache ? "(from cache)" : "(from server)"}');
    } catch (e, stackTrace) {
      print('❌ Initialization Error: $e');
      print('📍 Stack trace: $stackTrace');

      // ✅ TRY TO RECOVER FROM CACHE
      if (!usedCache) {
        print('🔄 Attempting to recover from cache...');

        try {
          // Try cached transcript
          final cachedTranscript = getCachedTranscript(bookId);

          if (cachedTranscript != null) {
            print('✅ Successfully loaded from cache after error');

            transcript = cachedTranscript;
            paragraphs = transcript?.paragraphs ?? [];

            getBookmark();
            paragraphKeys.clear();
            wordKeys.clear();

            paragraphKeys.addAll(List.generate(paragraphs.length, (_) => GlobalKey()));

            for (final paragraph in paragraphs) {
              final allWords = paragraph.allWords;
              for (int i = 0; i < allWords.length; i++) {
                wordKeys.add(GlobalKey());
              }
            }

            syncEngine = SyncEngine(paragraphs);

            _duration = transcript?.duration ?? 0;

            // Get cached URLs
            final cachedUrls = getCachedUrls(bookId);
            _audioUrl = transcript?.audioUrl ?? cachedUrls['audioUrl'] ?? audioUrl;

            await audioInitialize();

            // Load saved position
            final savedPosition = await loadSavedPosition();
            if (savedPosition > 0 && savedPosition < _duration) {
              _position = savedPosition;

              if (syncEngine != null) {
                currentWordIndex = syncEngine!.findWordIndexAtTime(_position);
                currentParagraphIndex = syncEngine!.getParagraphIndex(currentWordIndex);
              }
            }

            saveRecentView(RecentViewModel(id: bookId, title: bookNme, image: bookCoverUrl, summary: bookSummary, length: formatTime(duration)));

            scrollController.addListener(_onUserScroll);
            await _setupNotification();

            if (!isClosed) update();

            print('✅ Recovery successful - using cached data');
            return; // Exit successfully
          } else {
            print('❌ No cache available for recovery');
          }
        } catch (cacheError) {
          print('❌ Cache recovery failed: $cacheError');
        }
      }

      // ✅ If cache recovery fails, show error
      hasError = true;

      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException') || e.toString().contains('Network')) {
        errorMessage = 'No internet connection. Please check your network and try again.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid data format. Please try again later.';
      } else {
        errorMessage = 'Failed to load content. Please try again.';
      }

      // Preserve URLs even on error
      if (audioUrl.isNotEmpty) {
        _audioUrl = audioUrl;
      }

      update();
    }
  }

  // ============================================================
  // CACHE MANAGEMENT
  // ============================================================

  Future<void> cacheUrls({required String bookId, required String audioUrl, required String jsonUrl}) async {
    await AppPrefs.setString('${CS.keyCachedAudioUrl}_$bookId', audioUrl);
    await AppPrefs.setString('${CS.keyCachedJsonUrl}_$bookId', jsonUrl);
    print('💾 Cached URLs for book: $bookId');
  }

  Map<String, String?> getCachedUrls(String bookId) {
    final audio = AppPrefs.getString('${CS.keyCachedAudioUrl}_$bookId');
    final json = AppPrefs.getString('${CS.keyCachedJsonUrl}_$bookId');
    return {'audioUrl': audio.isEmpty ? null : audio, 'jsonUrl': json.isEmpty ? null : json};
  }

  Future<void> cacheTranscript({required String bookId, required TranscriptData transcript}) async {
    final jsonString = jsonEncode(transcript.toJson());
    await AppPrefs.setString('${CS.keyCachedTranscript}_$bookId', jsonString);
    print('💾 Cached transcript for book: $bookId');
  }

  TranscriptData? getCachedTranscript(String bookId) {
    final jsonString = AppPrefs.getString('${CS.keyCachedTranscript}_$bookId');
    if (jsonString.isEmpty) return null;

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is String) {
        print('⚠️ Old invalid cache detected. Clearing...');
        AppPrefs.remove('${CS.keyCachedTranscript}_$bookId');
        return null;
      }
      return TranscriptData.fromJson(decoded as Map<String, dynamic>);
    } catch (e) {
      print('❌ Error loading cached transcript: $e');
      return null;
    }
  }

  Future<void> clearBookCache(String bookId) async {
    await Future.wait([
      AppPrefs.remove('${CS.keyCachedAudioUrl}_$bookId'),
      AppPrefs.remove('${CS.keyCachedJsonUrl}_$bookId'),
      AppPrefs.remove('${CS.keyCachedTranscript}_$bookId'),
      AppPrefs.remove(CS.keyLastBookId),
      AppPrefs.remove('${CS.keyLastPosition}_$bookId'),
    ]);
  }

  // ============================================================
  // POSITION MANAGEMENT
  // ============================================================

  Future<void> saveCurrentPosition() async {
    if (novelData?.id != null) {
      await AppPrefs.setInt('${CS.keyLastPosition}_${novelData!.id}', _position);
      await AppPrefs.setString(CS.keyLastBookId, novelData!.id!);
      print('Saved position: $_position for book: ${novelData!.id}');
    }
  }

  Future<int> loadSavedPosition() async {
    final novelId = AppPrefs.getString(CS.keyLastBookId);
    if (novelId.isNotEmpty) {
      final position = AppPrefs.getInt('${CS.keyLastPosition}_$novelId');
      print('Loaded position: $position for book: $novelId');
      return position;
    }
    return 0;
  }

  Future<void> clearSavedPosition() async {
    if (novelData?.id != null) {
      await AppPrefs.remove('${CS.keyLastPosition}_${novelData!.id}');
    }
  }

  // ============================================================
  // BackGround Audio Play NOTIFICATION
  // ============================================================

  Future<void> _initializeAudioService() async {
    audioHandler = AudioNotificationService.audioHandler as AudioPlayerHandler?;
    update();
  }

  Future<void> _setupNotification() async {
    if (audioHandler == null) return;
    await audioHandler?.loadAndPlay(audioUrl: audioUrl, title: bookNme, artist: authorNme, artUri: bookCoverUrl);
  }

  // ============================================================
  // BOOK INFO
  // ============================================================
  Future<void> saveBookInfo(BookInfoModel model) async {
    final jsonString = jsonEncode(model.toMap());
    AppPrefs.setString(CS.keyBookInfo, jsonString);
  }

  Future<BookInfoModel> loadBookInfo() async {
    final jsonString = AppPrefs.getString(CS.keyBookInfo);
    if (jsonString.isEmpty) {
      return BookInfoModel(authorName: '', bookName: '', bookImage: '', bookId: '', textUrl: '', audioUrl: '', summary: "");
    }

    try {
      return BookInfoModel.fromMap(jsonDecode(jsonString));
    } catch (e) {
      print('Error loading book info: $e');
      return BookInfoModel(authorName: '', bookName: '', bookImage: '', bookId: '', textUrl: '', audioUrl: '', summary: "");
    }
  }

  Future<void> clearBookInfo() async => await AppPrefs.remove(CS.keyBookInfo);

  Future<void> setIsBookListening(bool value) async => await AppPrefs.setBool(CS.keyIsBookListening, value);

  Future<bool> getIsBookListening() async => await AppPrefs.getBool(CS.keyIsBookListening);

  Future<void> loadIsBookListening() async {
    isBookListening.value = await getIsBookListening();
    bookInfo.value = await loadBookInfo();
  }

  void startListening() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isBookListening.value = true;
      setIsBookListening(true);

      saveBookInfo(
        BookInfoModel(
          authorName: authorNme,
          bookName: bookNme,
          bookImage: bookCoverUrl,
          bookId: bookId,
          textUrl: textUrl,
          audioUrl: audioUrl,
          summary: bookSummary,
        ),
      );

      loadIsBookListening();
      _initializeAudioService();
      _setupNotification();
    });
  }

  // ============================================================
  // BOOKMARK MANAGEMENT
  // ============================================================

  Future<void> addNoteBookmark() async {
    listBookmarks = await getBookmarksPrefs();

    for (var i = 0; i < (listBookmarks?.length ?? 0); i++) {
      if (paragraphs[currentParagraphIndex].id == listBookmarks?[i].id) {
        listBookmarks?[i].note = addNoteController.text;
      }
    }

    await saveBookmarkList(listBookmarks ?? []);
    update();
  }

  Future<void> bookmark() async {
    final paragraphId = paragraphs[currentParagraphIndex].id;
    bool exists = listBookmarks?.any((e) => e.id == paragraphId) ?? false;
    if (exists) return;

    final newItem = BookmarkModel(
      id: paragraphId,
      paragraph: paragraphs[currentParagraphIndex].allWords.map((e) => e.word).join(" "),
      note: "",
      startTime: formatTime(paragraphs[currentParagraphIndex].allWords.first.start),
      endTime: formatTime(paragraphs[currentParagraphIndex].allWords.last.start),
    );

    await saveBookmark(data: newItem);
    paragraphs[currentParagraphIndex].isBookmarked = true;
    update();
  }

  Future<void> getBookmark() async {
    listBookmarks = await getBookmarksPrefs();
    for (var p in paragraphs) {
      p.isBookmarked = listBookmarks?.any((b) => b.id == p.id) ?? false;
    }
    update();
  }

  Future<void> saveBookmark({required BookmarkModel data}) async {
    final list = AppPrefs.getStringList(CS.keyBookmarks);
    list.add(jsonEncode(data.toJson()));
    await AppPrefs.setStringList(CS.keyBookmarks, list);
  }

  Future<List<BookmarkModel>> getBookmarksPrefs() async {
    final list = AppPrefs.getStringList(CS.keyBookmarks);
    return list.map((e) => BookmarkModel.fromJson(jsonDecode(e))).toList();
  }

  Future<void> deleteBookmark(int index) async {
    try {
      isBookMarkDelete = true;
      update();

      listBookmarks?.removeAt(index);
      await saveBookmarkList(listBookmarks ?? []);

      transcript = await fetchJsonData(audioUrl: audioUrl, textUrl: textUrl);
      paragraphs = transcript?.paragraphs ?? [];
      await getBookmark();
    } finally {
      isBookMarkDelete = false;
      update();
    }
  }

  Future<void> saveBookmarkList(List<BookmarkModel> list) async {
    final jsonList = list.map((e) => jsonEncode(e.toJson())).toList();
    await AppPrefs.setStringList(CS.keyBookmarks, jsonList);
  }

  // ============================================================
  // RECENT VIEWS
  // ============================================================

  Future<void> saveRecentView(RecentViewModel book) async {
    List<String> recentList = AppPrefs.getStringList(CS.keyRecentViews);
    List<RecentViewModel> items = recentList.map((item) => RecentViewModel.fromJson(jsonDecode(item))).toList();

    items.removeWhere((e) => e.id == book.id);
    items.insert(0, book);
    if (items.length > 10) items.removeLast();

    AppPrefs.setStringList(CS.keyRecentViews, items.map((e) => jsonEncode(e.toJson())).toList());
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
      // ✅ Save position every 5 seconds
      final now = DateTime.now();
      if (_lastPositionSave == null || now.difference(_lastPositionSave!) > Duration(seconds: 5)) {
        saveCurrentPosition();
        _lastPositionSave = now;
      }
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

  void safeScrollToParagraph(int index) {
    final now = DateTime.now();
    if (_lastScrollTime != null && now.difference(_lastScrollTime!) < const Duration(milliseconds: 120)) {
      return;
    }

    _lastScrollTime = now;

    scrollToCurrentParagraph(index);
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

  // ============================================================
  // PLAYBACK CONTROLS
  // ============================================================

  Future<void> play({bool isPositionScrollOnly = false, bool isOnlyPlayAudio = false}) async {
    if (_isDisposed || !_isInitialized || _operationInProgress) return;

    _operationInProgress = true;

    try {
      if (audioHandler == null) {
        startListening();
        await audioHandler?.play();
      } else {
        await audioHandler?.play();
      }

      if (currentParagraphIndex == -1 && !isOnlyPlayAudio) {
        await scrollController.animateTo(0, duration: Duration(milliseconds: 400), curve: Curves.easeOut);
      }

      if (_position >= _duration - 100) {
        _position = 0;
        _hasPlayedOnce = false;
      }

      if (_position > -1) {
        _operationInProgress = false;
        await seek(_position, isPlay: true);
      }

      if (!_hasPlayedOnce) {
        await audioPlayer.play(UrlSource(_audioUrl!));
        _hasPlayedOnce = true;
      } else {
        await audioPlayer.resume();
      }

      _isPlaying = true;
      isPlayAudio.value = true;
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
    if (_isDisposed || !_isInitialized || _operationInProgress || !_isPlaying) return;

    _operationInProgress = true;

    try {
      _isPlaying = false;
      isPlayAudio.value = false;
      await audioHandler?.pause();
      await audioPlayer.pause();
      _lastDriftCheck = null;
      await saveCurrentPosition();
      update();
    } catch (e) {
      _error = 'Pause error: $e';
      update();
    } finally {
      _operationInProgress = false;
    }
  }

  Future<void> togglePlayPause({bool isOnlyPlayAudio = false}) async {
    if (_isPlaying) {
      await pause();
    } else {
      await play(isOnlyPlayAudio: isOnlyPlayAudio);
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

  Future<void> skipForward() async {
    await audioHandler?.skipToNext();
    await seek(_position + 10000);
  }

  Future<void> skipBackward() async {
    await audioHandler?.skipToPrevious();
    await seek(_position - 10000);
  }

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
      // jsonData['audioUrl'] = 'audio.mp3';

      return TranscriptData.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load transcript: $e');
    }
  }

  Future<TranscriptData> fetchJsonData({String? textUrl, String? audioUrl}) async {
    try {
      final url = Uri.parse(textUrl ?? "");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        jsonData['audioUrl'] = audioUrl ?? "";
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

  Future<void> resetController() async {
    if (_isDisposed) return;

    _isDisposed = true;

    try {
      // 1. Cancel all subscriptions
      await _positionSubscription?.cancel();
      await _stateSubscription?.cancel();
      await _completionSubscription?.cancel();

      _positionSubscription = null;
      _stateSubscription = null;
      _completionSubscription = null;

      // 2. Stop and dispose audio player
      if (audioPlayer.state != PlayerState.disposed) {
        try {
          await audioHandler?.stop();
          await audioHandler?.dispose();
          await audioPlayer.stop();
          await audioPlayer.dispose();
        } catch (e) {
          print('Error disposing audio player: $e');
        }
      }

      // 3. Reset audio state
      _isPlaying = false;
      _speed = 1.0;
      _position = 0;
      _duration = 0;
      _audioUrl = null;
      _isLoading = false;
      _isInitialized = false;
      _hasPlayedOnce = false;
      _error = null;
      _driftCorrectionCount = 0;
      _lastDriftCheck = null;
      _isSeeking = false;
      _operationInProgress = false;

      // 4. Reset word/paragraph tracking
      currentWordIndex = -1;
      currentParagraphIndex = -1;

      // 5. Reset UI state
      isCollapsed = false;
      isScrolling = false;

      suppressAutoScroll = false;
      isHideText = false;
      hasError = false;
      errorMessage = null;
      isBookMarkDelete = false;
      _lastScrollTime = null;

      // 6. Reset speed/theme preferences to defaults
      currentSpeed = 1.0;
      currentIndex = 8;
      selectedFonts = CS.vInter;
      colorAudioTextBg = AppColors.colorTealDark;
      colorAudioTextParagraphBg = AppColors.colorTealDarkBg;
      iThemeSelect = 0;

      // 7. Clear transcript and sync data
      transcript = null;
      syncEngine = null;
      paragraphs.clear();

      // 8. Clear bookmarks
      listBookmarks?.clear();
      addNoteController.clear();

      // 9. Clear all keys
      paragraphKeys.clear();
      wordKeys.clear();

      // 10. Reset scroll controller (don't dispose yet)
      if (scrollController.hasClients) {
        try {
          scrollController.jumpTo(0);
        } catch (e) {
          print('Error resetting scroll: $e');
        }
      }

      // 11. Update UI
      update();
    } catch (e) {
      print('Error in resetController: $e');
    }
  }

  /// Modified stopListening to properly reset everything
  Future<void> stopListening() async {
    await WidgetsBinding.instance.endOfFrame;

    try {
      // ✅ Save current position before stopping
      await saveCurrentPosition();
      // 1. Clear book listening state
      isBookListening.value = false;
      isPlayAudio.value = false;
      await setIsBookListening(false);

      // 2. Clear book info

      bookInfo.value = BookInfoModel(authorName: '', bookName: '', bookImage: '', bookId: '', textUrl: '', audioUrl: '', summary: "");
      await clearBookInfo();
      await clearBookCache(bookId);
      // 3. Reset the entire controller
      await resetController();
    } catch (e) {
      print('Error in stopListening: $e');
    }
  }

  /// Alternative: Delete controller completely from GetX
  Future<void> stopListeningAndDelete() async {
    try {
      // 2. Stop listening and reset
      await stopListening();

      // 3. Delete from GetX
      Get.delete<AudioTextController>(force: true);
      Get.put(AudioTextController(), permanent: true);
    } catch (e) {
      print('Error in stopListeningAndDelete: $e');
    }
  }

  /// Call this when user presses back button
  Future<void> handleBackButton() async {
    try {
      await stopListening();
      Get.back();
    } catch (e) {
      print('Error handling back: $e');
      Get.back(); // Go back anyway
    }
  }

  // ============================================================
  // UPDATE YOUR onClose() METHOD TO THIS:
  // ============================================================
  @override
  void onClose() {
    try {
      scrollController.dispose();
    } catch (e) {
      print('Error disposing scroll controller: $e');
    }
    super.onClose();
  }
}
