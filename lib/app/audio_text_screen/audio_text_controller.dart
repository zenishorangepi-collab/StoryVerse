import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/audio_text_screen/models/transcript_data_model.dart';
import 'package:utsav_interview/app/audio_text_screen/services/sync_enginge_service.dart';
import 'package:utsav_interview/core/common_string.dart';


class AudioTextController extends GetxController{
  final AudioPlayer _player = AudioPlayer();
  TranscriptData? transcript;
  late final SyncEngine? syncEngine;
  late final ScrollController scrollController;
  final List<GlobalKey> paragraphKeys = [];

  int currentWordIndex = -1;
  int currentParagraphIndex = -1;
  Timer? debounceTimer;
  bool userScrolling = false;
  Timer? userScrollTimer;

  bool hasError = false;
  String? errorMessage;
  
  bool _isPlaying = false;
  double _speed = 1.0;
  int _position = 0;
  int _duration=0;
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

  bool get isPlaying => _isPlaying;
  int get position => _position;
  double get speed => _speed;
  int get duration => _duration;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get driftCorrectionCount => _driftCorrectionCount;
  bool get isInitialized => _isInitialized;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<void>? _completionSubscription;

  // AudioTextController(this._duration, [this._audioUrl]);

  var isCollapsed = false;
  bool isAnimateAppBarText = false;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    scrollController = ScrollController();

    scrollController.addListener(() {

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
    });
    initializeApp();
  }



  Future<void> initializeApp() async {
    try {
      transcript = await loadRealData();
      syncEngine = SyncEngine(transcript!.paragraphs);
      _duration=transcript?.duration??0;
      _audioUrl=transcript?.audioUrl;


      for (
      int i = 0;
      i < (transcript ?? TranscriptData()).paragraphs.length;
      i++
      ) {
        paragraphKeys.add(GlobalKey());
      }

      await initialize();

      addListener(_onAudioPositionUpdate);
      scrollController.addListener(_onUserScroll);

      if (!isClosed) update();
    } catch (e) {
      if (!isClosed)  {

          hasError = true;
          errorMessage = 'Initialization error: $e';
     update();
      }
    }
  }
  void _onUserScroll() {
    if (scrollController.hasClients &&
        scrollController.position.isScrollingNotifier.value) {
      userScrolling = true;
      userScrollTimer?.cancel();
      userScrollTimer = Timer(const Duration(seconds: 3), () {
        if (!isClosed)  {
           userScrolling = false;
           update();
        }
      });
    }
  }

  void _onAudioPositionUpdate() {
    debounceTimer?.cancel();
    debounceTimer = Timer(const Duration(milliseconds: 16), () {
      final engine = syncEngine; // local variable promotes correctly
      if (engine == null) return;

      final newWordIndex = engine.findWordIndexAtTime(position);

      if (newWordIndex != currentWordIndex && newWordIndex >= 0) {
        if (!isClosed) {
          currentWordIndex = newWordIndex;
          currentParagraphIndex = engine.getParagraphIndex(newWordIndex);
          update();
        }

        if (!userScrolling && scrollController.hasClients) {
          _autoScrollToCurrentWord();
        }
      }
    });
  }


  void _autoScrollToCurrentWord() {
    if (currentParagraphIndex < 0 ||
        currentParagraphIndex >= paragraphKeys.length) {
      return;
    }

    try {
      final key = paragraphKeys[currentParagraphIndex];
      final context = key.currentContext;

      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null && scrollController.hasClients) {
          final position = renderBox.localToGlobal(Offset.zero);
          final viewportHeight = scrollController.position.viewportDimension;
          final currentScroll = scrollController.offset;

          final targetScroll =
              currentScroll + position.dy - (viewportHeight * 0.4);

          final relativePosition = position.dy / viewportHeight;

          if (relativePosition < 0.3 || relativePosition > 0.7) {
            scrollController.animateTo(
              targetScroll.clamp(
                0.0,
                scrollController.position.maxScrollExtent,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      }

    } catch (e) {
      debugPrint('Auto-scroll error: $e');
    }
  }
  Future<void> initialize() async {
    if (_isDisposed || _isInitialized) return;

    try {
      _isLoading = true;
      _error = null;
      update();

      if (_audioUrl != null) {
        await _player.setReleaseMode(ReleaseMode.stop);
        await _player.setSourceAsset(_audioUrl??"");
        await _player.setPlaybackRate(_speed);
        _positionSubscription = _player.onPositionChanged.listen((pos) {
          if (!_isSeeking && !_isDisposed) {
            final newPos = pos.inMilliseconds.clamp(0, _duration);
            if ((_position - newPos).abs() > 100) {
              _position = newPos;
              _checkDrift();
              update();
            }
          }

        });

        _stateSubscription = _player.onPlayerStateChanged.listen((state) {
          if (_isDisposed) return;

          final wasPlaying = _isPlaying;
          _isPlaying = state == PlayerState.playing;

          if (wasPlaying != _isPlaying) {
            if (!_isPlaying) {
              _lastDriftCheck = null;
              update();
            }
          }

        });
        _completionSubscription = _player.onPlayerComplete.listen((_) {
          if (!_isDisposed) {
            _handleCompletion();
          }
        });

        _isInitialized = true;
      }

      _isLoading = false;
      update();
    } catch (e) {
      _error = 'Failed to load audio: $e';
      _isLoading = false;
      _isInitialized = false;
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

  void _checkDrift() {
    if (!_isPlaying || _isSeeking) return;

    final now = DateTime.now();
    if (_lastDriftCheck != null) {
      final elapsed = now.difference(_lastDriftCheck!);
      if (elapsed.inSeconds >= 5) {
        _player.getCurrentPosition().then((actualPosition) {
          if (actualPosition != null && !_isDisposed && _isPlaying) {
            final actualMs = actualPosition.inMilliseconds.clamp(0, _duration);
            final drift = (actualMs - _position).abs();
            if (drift > 200) {
              _position = actualMs;
              _driftCorrectionCount++;
              update();
            }
          }
        }).catchError((e) {
        });
        _lastDriftCheck = now;
      }
    } else {
      _lastDriftCheck = now;
    }
  }

  Future<void> play() async {
    if (_isDisposed || !_isInitialized || _operationInProgress) return;
    if (_isPlaying) return;

    _operationInProgress = true;
    try {
      _error = null;
      if (_position >= _duration - 100) {
        _position = 0;
        _isSeeking = true;
        await _player.seek(Duration.zero);
        _isSeeking = false;
        _hasPlayedOnce = false;
      }
      if (!_hasPlayedOnce) {
        await _player.play(AssetSource(_audioUrl!));
        _hasPlayedOnce = true;
      } else {
        await _player.resume();
      }

      _isPlaying = true;
      _lastDriftCheck = DateTime.now();
      update();
    } catch (e) {
      _error = 'Playback error: $e';
      _isPlaying = false;
      _lastDriftCheck = null;
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
      await _player.pause();
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
    if (_operationInProgress) return;
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(int positionMs) async {
    if (_isDisposed || !_isInitialized || _operationInProgress) return;

    _operationInProgress = true;
    _isSeeking = true;

    try {
      _position = positionMs.clamp(0, _duration);
      await _player.seek(Duration(milliseconds: _position));
      _lastDriftCheck = _isPlaying ? DateTime.now() : null;
      await Future.delayed(const Duration(milliseconds: 50));
      update();
    } catch (e) {
      _error = 'Seek error: $e';
      update();
    } finally {
      _isSeeking = false;
      _operationInProgress = false;
    }
  }

  Future<void> skipForward() async => await seek(_position + 10000);
  Future<void> skipBackward() async => await seek(_position - 10000);

  Future<void> setSpeed(double newSpeed) async {
    if (_isDisposed || !_isInitialized || _operationInProgress) return;

    _operationInProgress = true;
    try {
      final clampedSpeed = newSpeed.clamp(0.5, 2.0);
      if ((_speed - clampedSpeed).abs() < 0.01) {
        _operationInProgress = false;
        return;
      }
      _speed = clampedSpeed;
      await _player.setPlaybackRate(_speed);
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

  Future<void> reset() async {
    if (_isDisposed || !_isInitialized) return;

    await pause();
    await seek(0);
    _error = null;
    _driftCorrectionCount = 0;
    _hasPlayedOnce = false;
    update();

  }

  String formatTime(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

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
  @override
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    _positionSubscription?.cancel();
    _stateSubscription?.cancel();
    _completionSubscription?.cancel();
    _player.stop();
    _player.dispose();


      debounceTimer?.cancel();
      userScrollTimer?.cancel();
      removeListener(_onAudioPositionUpdate);
      scrollController.dispose();
      super.dispose();

    super.dispose();
  }
}