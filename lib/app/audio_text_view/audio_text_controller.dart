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
import 'package:utsav_interview/app/home_screen/home_controller.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';
import 'package:utsav_interview/app/home_screen/models/recent_listen_model.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/pref.dart';

RxBool isBookListening = false.obs;
RxBool isPlayAudio = false.obs;
RxInt isAudioInitCount = 0.obs;

Rx<NovelsDataModel> bookInfo = NovelsDataModel().obs;

class AudioTextController extends GetxController {
  // Models & Data
  NovelsDataModel? novelData = NovelsDataModel();
  TranscriptData? transcript;
  SyncEngine? syncEngine;
  List<ParagraphData> paragraphs = [];
  List<BookmarkModel>? listBookmarks;

  // ✅ CHAPTER MANAGEMENT
  int currentChapterIndex = 0;
  String currentChapterId = "";
  List<AudioFiles> allChapters = [];
  bool isAllChaptersLoaded = false;
  List<ParagraphData> allParagraphs = [];
  List<ParagraphData> uiParagraphs = [];
  List<ParagraphData> syncParagraphs = [];
  late List<int> syncToUiWordIndex;
  late List<int> syncToUiParagraphIndex;

  String get currentAudioUrl => allChapters.isNotEmpty ? (allChapters[currentChapterIndex].url ?? "") : "";

  String get currentTextUrl => allChapters.isNotEmpty ? (allChapters[currentChapterIndex].audioJsonUrl ?? "") : "";

  String get currentChapterTitle => allChapters.isNotEmpty ? (allChapters[currentChapterIndex].name ?? "Chapter ${currentChapterIndex + 1}") : "";

  // Controllers & Services
  final TextEditingController addNoteController = TextEditingController();
  AudioPlayer audioPlayer = AudioPlayer();
  AudioPlayerHandler? audioHandler;
  late final ScrollController scrollController;

  // Keys for scroll tracking

  List<GlobalKey> paragraphKeys = [];
  List<GlobalKey> wordKeys = [];

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
  Timer? _scrollEndTimer;
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
  bool audioLoading = false;
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
  double lastScrollOffset = 0.0;
  Timer? _scrollSaveTimer;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onCollapseScroll);
    scrollController.addListener(_onScrollPositionChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAudioService();
      loadIsBookListening();

      if (Get.arguments != null) initializeApp();
    });
  }

  void restoreScrollPosition() {
    if (!scrollController.hasClients) {
      // Retry after a short delay if not ready
      Future.delayed(const Duration(milliseconds: 100), () {
        restoreScrollPosition();
      });
      return;
    }

    if (lastScrollOffset > 0) {
      final maxScroll = scrollController.position.maxScrollExtent;
      final safeOffset = lastScrollOffset.clamp(0.0, maxScroll);

      scrollController.jumpTo(safeOffset);
      print('✅ Restored scroll position: $safeOffset');
    }
  }

  void _onScrollPositionChanged() {
    if (!scrollController.hasClients) return;
    if (!suppressAutoScroll) {
      lastScrollOffset = scrollController.offset;

      // Debounce saving to avoid too many writes
      _scrollSaveTimer?.cancel();
      _scrollSaveTimer = Timer(const Duration(milliseconds: 500), () {
        _saveScrollPosition();
      });
    }
  }

  // void scrollToSavedPosition() {
  //   if (scrollController.hasClients) {
  //     scrollController.jumpTo(lastScrollOffset);
  //   }
  // }

  Future<void> _saveScrollPosition() async {
    if (bookId.isEmpty) return;

    try {
      await AppPrefs.setDouble('${CS.keyScrollPosition}$bookId', lastScrollOffset);
      print('💾 Saved scroll position: $lastScrollOffset for book: $bookId');
    } catch (e) {
      print('❌ Error saving scroll position: $e');
    }
  }

  // ✅ NEW: Load scroll position from preferences
  Future<double> _loadScrollPosition() async {
    if (bookId.isEmpty) return 0.0;

    try {
      final position = AppPrefs.getDouble('${CS.keyScrollPosition}$bookId');
      print('📖 Loaded scroll position: $position for book: $bookId');
      return position;
    } catch (e) {
      print('❌ Error loading scroll position: $e');
      return 0.0;
    }
  }

  // ------------------------------------------------------------
  // Initialization
  // ------------------------------------------------------------
  Future<void> initializeApp() async {
    bool usedCache = false;
    lastScrollOffset = await _loadScrollPosition();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      restoreScrollPosition();
    });
    try {
      if (Get.arguments != null) {
        novelData = Get.arguments["novelData"];
      } else {
        bookInfo.value = await loadBookInfo();
      }

      if (Get.arguments != null && novelData != null) {
        allChapters = novelData?.audioFiles ?? [];
        bookId = novelData?.id ?? "";
        authorNme = novelData?.author?.name ?? "";
        bookNme = novelData?.bookName ?? "";
        bookCoverUrl = novelData?.bookCoverUrl ?? "";
        bookSummary = novelData?.summary ?? "";
        await saveRecentView(novelData!);
      } else {
        allChapters = bookInfo.value.audioFiles ?? [];
        bookId = bookInfo.value.id ?? "";
        authorNme = bookInfo.value.author?.name ?? "";
        bookNme = bookInfo.value.bookName ?? "";
        bookCoverUrl = bookInfo.value.bookCoverUrl ?? "";
        bookSummary = bookInfo.value.summary ?? "";
        await saveRecentView(bookInfo.value);
      }
      audioLoading = true;
      await loadAllChapterTextOnce();

      final savedData = await loadSavedChapterAndPosition();
      currentChapterIndex = savedData['chapterIndex'] ?? 0;

      await loadAudioForChapter(currentChapterIndex);
      _position = savedData['position'] ?? 0;

      audioLoading = false;
      await audioInitialize();

      scrollController.addListener(_onUserScroll);
      await _setupNotification();
      onAudioPositionUpdate();
      if (!isClosed) update();

      print('✅ Initialization completed ${usedCache ? "(from cache)" : "(from server)"}');
    } catch (e, stackTrace) {
      hasError = true;

      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException') || e.toString().contains('Network')) {
        errorMessage = 'No internet connection. Please check your network and try again.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid data format. Please try again later.';
      } else {
        errorMessage = 'Failed to load content. Please try again.';
      }

      update();
    }
  }

  void startListening() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      lastScrollOffset = await _loadScrollPosition();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        restoreScrollPosition();
      });
      isBookListening.value = true;
      setIsBookListening(true);

      if (novelData != null) {
        await saveBookInfo(novelData!);
      } else {
        await saveBookInfo(bookInfo.value);
      }
      // if (_position > -1) {
      //   _operationInProgress = false;
      //   await seek(_position, isPlay: true);
      // }
      loadIsBookListening();

      await _initializeAudioService();
      // await _setupNotification();
    });
  }

  Future<void> scrollToPosition(int positionMs) async {
    if (!scrollController.hasClients || syncEngine == null) return;

    try {
      // Find word and paragraph at this position
      final syncWord = syncEngine!.findWordIndexAtTime(positionMs);
      if (syncWord < 0) return;

      final syncPara = syncEngine!.getParagraphIndex(syncWord);

      // Map to UI indices
      if (syncPara >= syncToUiParagraphIndex.length) return;

      currentParagraphIndex = syncToUiParagraphIndex[syncPara];
      currentWordIndex = syncToUiWordIndex[syncWord];

      print('📍 Scrolling to position: $positionMs ms');
      print('   Word index: $currentWordIndex, Paragraph: $currentParagraphIndex');

      // Disable auto-scroll temporarily
      suppressAutoScroll = true;

      // Quick validation - reduced wait time
      if (wordKeys.isEmpty || currentWordIndex >= wordKeys.length) {
        await Future.delayed(const Duration(milliseconds: 100));

        // If still not ready, use paragraph fallback
        if (wordKeys.isEmpty || currentWordIndex >= wordKeys.length) {
          await _scrollToParagraphFallback(currentParagraphIndex);
          await Future.delayed(const Duration(milliseconds: 300));
          suppressAutoScroll = false;
          update();
          return;
        }
      }

      // Scroll to the word
      final key = wordKeys[currentWordIndex];

      // Single quick context check instead of polling
      if (key.currentContext != null) {
        await Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 300), // Reduced from 400ms
          alignment: 0.4,
          curve: Curves.easeOutCubic,
        );
        print('✅ Scrolled to word successfully');
      } else {
        // Immediate fallback if context not available
        await _scrollToParagraphFallback(currentParagraphIndex);
      }

      // Re-enable auto-scroll after shorter delay
      await Future.delayed(const Duration(milliseconds: 400)); // Reduced from 600ms
      suppressAutoScroll = false;

      update();
    } catch (e) {
      print('❌ Error scrolling to position: $e');
      suppressAutoScroll = false;
    }
  }

  // ✅ ADD THIS HELPER METHOD - Fallback scroll to paragraph
  Future<void> _scrollToParagraphFallback(int paragraphIndex) async {
    if (!scrollController.hasClients) return;

    if (paragraphIndex >= 0 && paragraphIndex < paragraphKeys.length) {
      final paraKey = paragraphKeys[paragraphIndex];

      int attempts = 0;
      while (paraKey.currentContext == null && attempts < 20) {
        await Future.delayed(const Duration(milliseconds: 50));
        attempts++;
      }

      if (paraKey.currentContext != null) {
        await Scrollable.ensureVisible(paraKey.currentContext!, duration: const Duration(milliseconds: 400), alignment: 0.4, curve: Curves.easeOutCubic);
        print('✅ Scrolled to paragraph (fallback)');
      } else {
        // Last resort: calculate approximate offset
        const double avgParagraphHeight = 180.0;
        final offset = paragraphIndex * avgParagraphHeight;

        await scrollController.animateTo(
          offset.clamp(0.0, scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
        print('✅ Scrolled to calculated offset (last resort)');
      }
    }
  }

  // ✅ NEW: Load chapter transcript
  Future<void> loadAllChapterTextOnce() async {
    if (isAllChaptersLoaded) return;

    allParagraphs.clear();

    for (int i = 0; i < allChapters.length; i++) {
      final chapter = allChapters[i];

      TranscriptData data;

      final cached = getCachedTranscript(bookId, chapter.id ?? "");
      if (cached != null) {
        data = cached;
      } else {
        data = await fetchJsonData(textUrl: chapter.audioJsonUrl, audioUrl: chapter.url);
        await cacheTranscript(bookId: bookId, chapterId: chapter.id ?? "", transcript: data);
      }

      for (final p in data.paragraphs ?? []) {
        p.chapterId = chapter.id ?? "";
        p.chapterIndex = i;
        allParagraphs.add(p);
      }
    }
    uiParagraphs = allParagraphs;
    await getBookmark();

    buildUiKeysOnce(); // UI only
    // _updateSyncForCurrentChapter(); // audio only

    isAllChaptersLoaded = true;
    update();
  }

  void _updateSyncForCurrentChapter({bool resetIndices = true}) {
    syncParagraphs = allParagraphs.where((p) => p.chapterIndex == currentChapterIndex).toList();

    syncEngine = SyncEngine(syncParagraphs);

    _buildSyncIndexMap();
    _buildSyncWordIndexMap();

    // ✅ FIX: Initialize indices to prevent late initialization errors
    if (resetIndices) {
      currentWordIndex = -1;
      currentParagraphIndex = -1;
    }
  }

  void _buildSyncIndexMap() {
    syncToUiParagraphIndex = [];

    for (int i = 0; i < uiParagraphs.length; i++) {
      if (uiParagraphs[i].chapterIndex == currentChapterIndex) {
        syncToUiParagraphIndex.add(i);
      }
    }
  }

  void _buildSyncWordIndexMap() {
    syncToUiWordIndex = [];

    for (int p = 0; p < uiParagraphs.length; p++) {
      if (uiParagraphs[p].chapterIndex == currentChapterIndex) {
        for (int w = 0; w < uiParagraphs[p].allWords.length; w++) {
          syncToUiWordIndex.add(_getGlobalWordIndex(p, w));
        }
      }
    }
  }

  int _getGlobalWordIndex(int paragraphIndex, int wordIndex) {
    int count = 0;
    for (int i = 0; i < paragraphIndex; i++) {
      count += uiParagraphs[i].allWords.length;
    }
    return count + wordIndex;
  }

  // void _updateParagraphsForCurrentChapter() {
  //   syncParagraphs = allParagraphs.where((p) => p.chapterIndex == currentChapterIndex).toList();
  //
  //   syncEngine = SyncEngine(syncParagraphs);
  //
  //   _buildSyncIndexMap();
  //   _buildSyncWordIndexMap();
  //
  //   currentWordIndex = -1;
  //   currentParagraphIndex = -1;
  // }

  Future<void> loadAudioForChapter(int index) async {
    currentChapterIndex = index;
    currentChapterId = allChapters[index].id ?? "";

    _audioUrl = allChapters[index].url;

    await audioPlayer.stop();
    await audioPlayer.setSourceUrl(_audioUrl!);

    final d = await audioPlayer.getDuration();
    _duration = d?.inMilliseconds ?? 0;

    _updateSyncForCurrentChapter();
    await Future.delayed(const Duration(milliseconds: 50));
    update();
  }

  void buildUiKeysOnce() {
    paragraphKeys.clear();
    wordKeys.clear();

    for (final paragraph in uiParagraphs) {
      paragraphKeys.add(GlobalKey());

      for (final _ in paragraph.allWords) {
        wordKeys.add(GlobalKey());
      }
    }
  }

  // ✅ NEW: Switch to next/previous chapter
  Future<void> switchChapter(int newChapterIndex) async {
    if (newChapterIndex < 0 || newChapterIndex >= allChapters.length) return;
    audioLoading = true;
    await pause();
    await saveCurrentPosition();
    await _saveScrollPosition();

    _position = 0;
    currentWordIndex = -1;
    currentParagraphIndex = -1;

    // Load the new chapter's audio and paragraphs
    await loadAudioForChapter(newChapterIndex);

    // if (scrollController.hasClients) {
    //   scrollController.jumpTo(0);
    // }
    audioLoading = false;
    update();
  }

  Future<void> nextChapter() async {
    if (currentChapterIndex < allChapters.length - 1) {
      await switchChapter(currentChapterIndex + 1);
    }
  }

  Future<void> previousChapter() async {
    if (currentChapterIndex > 0) {
      await switchChapter(currentChapterIndex - 1);
    }
  }

  // ============================================================
  // CACHE MANAGEMENT (Chapter-wise)
  // ============================================================

  Future<void> cacheTranscript({required String bookId, required String chapterId, required TranscriptData transcript}) async {
    final jsonString = jsonEncode(transcript.toJson());
    await AppPrefs.setString('${CS.keyCachedTranscript}_${bookId}_$chapterId', jsonString);
    print('💾 Cached transcript for book: $bookId, chapter: $chapterId');
  }

  TranscriptData? getCachedTranscript(String bookId, String chapterId) {
    final jsonString = AppPrefs.getString('${CS.keyCachedTranscript}_${bookId}_$chapterId');
    if (jsonString.isEmpty) return null;

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is String) {
        print('⚠️ Old invalid cache detected. Clearing...');
        AppPrefs.remove('${CS.keyCachedTranscript}_${bookId}_$chapterId');
        return null;
      }
      return TranscriptData.fromJson(decoded as Map<String, dynamic>);
    } catch (e) {
      print('❌ Error loading cached transcript: $e');
      return null;
    }
  }

  Future<void> clearBookCache(String bookId) async {
    // Clear all chapter caches
    for (var chapter in allChapters) {
      await AppPrefs.remove('${CS.keyCachedTranscript}_${bookId}_${chapter.id}');
    }
    await AppPrefs.remove('${CS.keyLastPosition}_$bookId');
    await AppPrefs.remove('${CS.keyLastChapter}_$bookId');
    await AppPrefs.remove(CS.keyLastBookId);
  }

  // ============================================================
  // POSITION MANAGEMENT (Chapter-wise)
  // ============================================================

  Future<void> saveCurrentPosition() async {
    if (bookId.isNotEmpty) {
      final data = jsonEncode({'chapterIndex': currentChapterIndex, 'chapterId': currentChapterId, 'position': _position});
      await AppPrefs.setString('${CS.keyLastPosition}_$bookId', data);
      print('💾 Saved position: $_position for chapter: $currentChapterIndex');
    }
  }

  Future<Map<String, dynamic>> loadSavedChapterAndPosition() async {
    if (bookId.isEmpty) {
      return {'chapterIndex': 0, 'chapterId': '', 'position': 0};
    }

    final jsonString = AppPrefs.getString('${CS.keyLastPosition}_$bookId');

    if (jsonString.isEmpty) {
      return {'chapterIndex': 0, 'chapterId': '', 'position': 0};
    }

    try {
      final data = jsonDecode(jsonString);

      final chapterIndex = data['chapterIndex'] is int ? data['chapterIndex'] : int.tryParse('${data['chapterIndex']}') ?? 0;

      final position = data['position'] is int ? data['position'] : int.tryParse('${data['position']}') ?? 0;

      return {'chapterIndex': chapterIndex, 'chapterId': data['chapterId'] ?? '', 'position': position};
    } catch (e) {
      debugPrint('❌ Error loading saved position: $e');
      return {'chapterIndex': 0, 'chapterId': '', 'position': 0};
    }
  }

  Future<void> clearSavedPosition() async {
    if (bookId.isNotEmpty) {
      await AppPrefs.remove('${CS.keyLastPosition}_$bookId');
    }
  }

  // ============================================================
  // BOOKMARK MANAGEMENT (Chapter-wise)
  // ============================================================

  Future<void> addNoteBookmark() async {
    listBookmarks = await getBookmarksPrefs();

    for (var i = 0; i < (listBookmarks?.length ?? 0); i++) {
      final p = uiParagraphs[currentParagraphIndex];

      if (p.id == listBookmarks?[i].id && listBookmarks?[i].chapterId == p.chapterId) {
        listBookmarks?[i].note = addNoteController.text;
      }
    }

    await saveBookmarkList(listBookmarks ?? []);
    update();
  }

  Future<void> bookmark() async {
    if (currentParagraphIndex < 0 || currentParagraphIndex >= uiParagraphs.length) {
      return;
    }

    final paragraph = uiParagraphs[currentParagraphIndex];
    final paragraphId = paragraph.id;

    final exists = listBookmarks?.any((e) => e.id == paragraphId && e.chapterId == paragraph.chapterId) ?? false;

    if (exists) return;

    final newItem = BookmarkModel(
      id: paragraph.id,
      bookId: bookId,
      chapterId: paragraph.chapterId!,
      chapterIndex: paragraph.chapterIndex!,
      chapterTitle: allChapters[paragraph.chapterIndex!].name ?? '',
      paragraph: paragraph.allWords.map((e) => e.word).join(' '),
      note: '',
      startTime: formatTime(paragraph.allWords.first.start),
      endTime: formatTime(paragraph.allWords.last.start),
    );

    await saveBookmark(data: newItem);

    // update UI state
    paragraph.isBookmarked = true;
    update();
  }

  Future<void> getBookmark() async {
    final all = await getBookmarksPrefs();

    // 🔥 filter by book
    listBookmarks = all.where((b) => b.bookId == bookId).toList();

    for (final p in uiParagraphs) {
      p.isBookmarked = listBookmarks?.any((b) => b.id == p.id && b.chapterId == p.chapterId && b.bookId == bookId) ?? false;
    }

    update();
  }

  Future<void> saveBookmark({required BookmarkModel data}) async {
    final list = AppPrefs.getStringList(CS.keyBookmarks);

    final exists = list.any((e) {
      final m = jsonDecode(e);
      return m['id'] == data.id && m['chapterId'] == data.chapterId && m['bookId'] == data.bookId;
    });

    if (!exists) {
      list.add(jsonEncode(data.toJson()));
      await AppPrefs.setStringList(CS.keyBookmarks, list);
    }
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

      final all = await getBookmarksPrefs();

      final filtered = all.where((b) => b.bookId != bookId).toList()..addAll(listBookmarks ?? []);

      await saveBookmarkList(filtered);

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

  // ✅ NEW: Navigate to bookmark
  Future<void> navigateToBookmark(BookmarkModel bookmark) async {
    if (bookmark.chapterIndex != currentChapterIndex) {
      await switchChapter(bookmark.chapterIndex ?? 0);
    }

    // Parse time string to milliseconds
    final timeMs = _parseTimeToMs(bookmark.startTime ?? "00:00");
    await seek(timeMs);
  }

  int _parseTimeToMs(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;

    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = int.tryParse(parts[1]) ?? 0;
    return (minutes * 60 + seconds) * 1000;
  }

  // ============================================================
  // BackGround Audio Play NOTIFICATION
  // ============================================================

  Future<void> _initializeAudioService() async {
    if (!AudioNotificationService.isInitialized) {
      await AudioNotificationService.initialize();
    }

    // Safe type casting with proper type check
    final handler = AudioNotificationService.audioHandler;
    if (handler is AudioPlayerHandler) {
      audioHandler = handler;
      print('✅ Audio handler ready: ${audioHandler != null}');
    } else {
      audioHandler = null;
      print('⚠️ Audio handler is not AudioPlayerHandler type');
    }
    update();
  }

  Future<void> _setupNotification() async {
    if (audioHandler == null) {
      print('⚠️ Cannot setup notification: audioHandler is null');
      return;
    }
    audioHandler!.connectPlayer(audioPlayer);
    await audioHandler?.loadAndPlay(audioUrl: currentAudioUrl, title: "$bookNme - $currentChapterTitle", artist: authorNme, artUri: bookCoverUrl);
  }

  // ============================================================
  // BOOK INFO
  // ============================================================

  Future<void> saveBookInfo(NovelsDataModel model) async {
    final jsonString = jsonEncode(model.toJson());
    await AppPrefs.setString(CS.keyBookInfo, jsonString);
  }

  Future<NovelsDataModel> loadBookInfo() async {
    final jsonString = AppPrefs.getString(CS.keyBookInfo);
    if (jsonString.isEmpty) return NovelsDataModel();

    try {
      return NovelsDataModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      print('Error loading book info: $e');
      return NovelsDataModel();
    }
  }

  Future<void> clearBookInfo() async => await AppPrefs.remove(CS.keyBookInfo);

  Future<void> setIsBookListening(bool value) async => await AppPrefs.setBool(CS.keyIsBookListening, value);

  Future<bool> getIsBookListening() async => await AppPrefs.getBool(CS.keyIsBookListening);

  Future<void> loadIsBookListening() async {
    isBookListening.value = await getIsBookListening();
    bookInfo.value = await loadBookInfo();
  }

  // ============================================================
  // RECENT VIEWS
  // ============================================================

  Future<void> saveRecentView(NovelsDataModel book) async {
    List<String> recentList = AppPrefs.getStringList(CS.keyRecentViews);
    List<NovelsDataModel> items = recentList.map((item) => NovelsDataModel.fromJson(jsonDecode(item))).toList();

    items.removeWhere((e) => e.id == book.id);
    items.insert(0, book);
    if (items.length > 10) items.removeLast();

    AppPrefs.setStringList(CS.keyRecentViews, items.map((e) => jsonEncode(e.toJson())).toList());
  }

  Future<void> removeRecentViewByBookId(String bookId) async {
    if (bookId.isEmpty) return;

    final List<String> recentList = AppPrefs.getStringList(CS.keyRecentViews) ?? [];

    recentList.removeWhere((item) {
      try {
        final map = jsonDecode(item);
        return map['id'] == bookId;
      } catch (_) {
        return false;
      }
    });

    await AppPrefs.setStringList(CS.keyRecentViews, recentList);
  }

  // ------------------------------------------------------------
  // Collapse AppBar on Scroll
  // ------------------------------------------------------------

  void _onCollapseScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.isScrollingNotifier.value) {
      isScrolling = true;
      // suppressAutoScroll = true;
      isCollapsed = scrollController.offset > 60;
      update(["scrollButton"]);
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

    final direction = scrollController.position.userScrollDirection;

    if (direction != ScrollDirection.idle) {
      suppressAutoScroll = true;
      update();
    } else {
      suppressAutoScroll = false;
      update();
    }
  }

  // void _onUserScroll() {
  //   if (!scrollController.hasClients) return;
  //
  //   // User is scrolling
  //   suppressAutoScroll = true;
  //   update();
  //
  //   // Detect scroll stop
  //   _scrollEndTimer?.cancel();
  //   _scrollEndTimer = Timer(const Duration(milliseconds: 250), () {
  //     suppressAutoScroll = false;
  //     update();
  //   });
  // }

  // ------------------------------------------------------------
  // Position listener → highlight + auto-scroll
  // ------------------------------------------------------------

  // void onAudioPositionUpdate() {
  //   if (!scrollController.hasClients || suppressAutoScroll || syncEngine == null) return;
  //
  //   final newIndex = syncEngine!.findWordIndexAtTime(position);
  //   if (newIndex < 0) return;
  //
  //   currentWordIndex = newIndex;
  //   currentParagraphIndex = syncEngine!.getParagraphIndex(newIndex);
  //
  //   if (newIndex != -1) {
  //     scrollToCurrentWord(newIndex);
  //   }
  //
  //   update();
  // }

  void onAudioPositionUpdate() {
    if (!scrollController.hasClients || suppressAutoScroll || syncEngine == null) return;

    final syncWordIndex = syncEngine!.findWordIndexAtTime(position);
    if (syncWordIndex < 0) return;

    final syncPara = syncEngine!.getParagraphIndex(syncWordIndex);

    // ✅ FIX: Add bounds checking to prevent crashes
    if (syncWordIndex >= syncToUiWordIndex.length || syncPara >= syncToUiParagraphIndex.length) {
      return;
    }

    final uiWord = syncToUiWordIndex[syncWordIndex];
    final uiPara = syncToUiParagraphIndex[syncPara];

    if (uiWord == currentWordIndex) return;

    currentWordIndex = uiWord;
    currentParagraphIndex = uiPara;

    scrollToCurrentWord(uiWord);
    update();
  }

  Future<void> scrollToCurrentWord(int index) async {
    if (index < 0 || index >= wordKeys.length) return;
    final key = wordKeys[index];

    if (key.currentContext == null) {
      await Future.delayed(const Duration(milliseconds: 40));
      if (key.currentContext == null) return;
    }

    try {
      await Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 200), alignment: 0.4, curve: Curves.easeOutCubic);
    } catch (_) {}
  }

  void scrollToCurrentParagraph(int index) {
    if (scrollController.hasClients == false) return;
    if (index < 0 || index >= paragraphKeys.length) return;

    final key = paragraphKeys[index];
    final context = key.currentContext;

    if (context != null) {
      // ✅ FIX: Use ensureVisible instead of animating to current position
      Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 350), alignment: 0.25, curve: Curves.easeInOut);
    } else {
      _scrollToIndexFallback(index);
    }
  }

  // void scrollToCurrentParagraph(int index) {
  //   if (!scrollController.hasClients) return;
  //   if (index < 0 || index >= paragraphKeys.length) return;
  //
  //   final context = paragraphKeys[index].currentContext;
  //   if (context == null) return;
  //
  //   Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 300), alignment: 0.15, curve: Curves.easeOut);
  // }

  void _scrollToIndexFallback(int index) {
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

        _positionSubscription?.cancel();
        _stateSubscription?.cancel();
        _completionSubscription?.cancel();

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

  void _handleCompletion() async {
    _isPlaying = false;
    _hasPlayedOnce = true;
    _position = _duration;
    _lastDriftCheck = null;

    if (currentChapterIndex < allChapters.length - 1) {
      await switchChapter(currentChapterIndex + 1);
      await audioInitialize();
      await play(isOnlyPlayAudio: true);
    }

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
    isPlayAudio.value = _isPlaying;

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
    // if (isOnlyPlayAudio && isAudioInitCount.value == 0) {
    //   initializeApp();
    // }
    isAudioInitCount++;
    if (_isDisposed || !_isInitialized || _operationInProgress) return;

    _operationInProgress = true;
    audioLoading = true;

    try {
      if (audioHandler == null) {
        startListening();
      }
      // await audioHandler?.play();

      // if (currentParagraphIndex == -1 && !isOnlyPlayAudio) {
      //   await scrollController.animateTo(0, duration: Duration(milliseconds: 400), curve: Curves.easeOut);
      // }

      if (_position >= _duration - 100) {
        _position = 0;
        _hasPlayedOnce = false;
      }

      if (_position > -1) {
        _operationInProgress = false;
        restoreScrollPosition();
        // await seek(_position, isPlay: true);
      }

      if (!isPositionScrollOnly) {
        if (!_hasPlayedOnce) {
          await audioPlayer.play(UrlSource(_audioUrl!));
          _hasPlayedOnce = true;
        } else {
          await audioPlayer.resume();
        }
      }
      _isPlaying = true;
      isPlayAudio.value = true;
      _lastDriftCheck = DateTime.now();

      update();
    } catch (e) {
      _error = 'Playback error: $e';
      update();
    } finally {
      audioLoading = false;
      _operationInProgress = false;
    }
  }

  Future<void> pause() async {
    if (_isDisposed || !_isInitialized || _operationInProgress || !_isPlaying) return;

    _operationInProgress = true;

    try {
      _isPlaying = false;
      isPlayAudio.value = false;
      // await audioHandler?.pause();
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

  Future<void> seekToWord({required ParagraphData paragraph, required int wordIndexInParagraph, required int positionMs}) async {
    if (paragraph.chapterIndex == null) return;

    // 🔁 Switch chapter if needed
    if (paragraph.chapterIndex != currentChapterIndex) {
      audioLoading = true;
      await switchChapter(paragraph.chapterIndex!);
      await Future.delayed(const Duration(milliseconds: 120));

      // 🛡️ Safety
      if (wordIndexInParagraph < 0 || wordIndexInParagraph >= paragraph.allWords.length) {
        return;
      }

      final startMs = paragraph.allWords[wordIndexInParagraph].start;
      await seek(startMs);
      audioLoading = false;
    } else {
      await seek(positionMs);
    }
  }

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
        final syncWord = syncEngine!.findWordIndexAtTime(_position);
        if (syncWord < 0) {
          _isSeeking = false;
          _operationInProgress = false;
          suppressAutoScroll = false;
          update();
          return;
        }

        final syncPara = syncEngine!.getParagraphIndex(syncWord);

        // ✅ FIX: Add bounds checking to prevent crashes
        if (syncPara >= syncToUiParagraphIndex.length || syncWord >= syncToUiWordIndex.length) {
          _isSeeking = false;
          _operationInProgress = false;
          suppressAutoScroll = false;
          update();
          return;
        }

        currentParagraphIndex = syncToUiParagraphIndex[syncPara];
        currentWordIndex = syncToUiWordIndex[syncWord];
        // currentWordIndex = _syncWordToUiWordIndex(syncWord);

        if (wordKeys.isNotEmpty) {
          if (isPlay) {
            // await scrollToPosition(_position);
            safeScrollToParagraph(currentParagraphIndex);
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              scrollToCurrentWord(currentWordIndex);
              // onAudioPositionUpdate();
            });
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
    // await audioHandler?.skipToNext();
    await seek(_position + 10000);
  }

  Future<void> skipBackward() async {
    // await audioHandler?.skipToPrevious();
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

      scrollController.removeListener(_onUserScroll);
      scrollController.removeListener(_onCollapseScroll);
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
      isAudioInitCount.value = 0;
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
      uiParagraphs.clear();
      allParagraphs.clear();

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
      await saveCurrentPosition();
      isBookListening.value = false;
      isPlayAudio.value = false;
      await setIsBookListening(false);

      bookInfo.value = NovelsDataModel();
      await clearBookInfo();
      await resetController();
    } catch (e) {
      print('Error in stopListening: $e');
    }
  }

  /// Alternative: Delete controller completely from GetX
  Future<void> stopListeningAndDelete() async {
    try {
      listRecents.removeWhere((element) => element.id == bookId);
      await removeRecentViewByBookId(bookId);
      // 2. Stop listening and reset
      await stopListening();

      // 3. Delete from GetX
      if (Get.isRegistered<AudioTextController>()) {
        await Get.delete<AudioTextController>(force: true);
        Get.put(AudioTextController(), permanent: true);
      }
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
      _scrollSaveTimer?.cancel();
      _saveScrollPosition();
      // scrollController.dispose();
    } catch (e) {
      print('Error disposing scroll controller: $e');
    }
    super.onClose();
  }
}
