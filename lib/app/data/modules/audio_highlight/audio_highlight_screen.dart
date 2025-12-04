
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../audio_text_screen/services/sync_enginge_service.dart';
import '../../../audio_text_screen/models/transcript_data_model.dart';
import 'audio_highlight_controller.dart';
import '../../../audio_text_screen/widgets/paragraph_widget.dart';

class AudioHighlighterScreen extends StatefulWidget {
  const AudioHighlighterScreen({super.key});

  @override
  State<AudioHighlighterScreen> createState() => _AudioHighlighterScreenState();
}

class _AudioHighlighterScreenState extends State<AudioHighlighterScreen> {
  TranscriptData? _transcript;
  late final SyncEngine? _syncEngine;
  late final AudioControllerForHighLight _audioController;
  late final ScrollController scrollController;
  final List<GlobalKey> _paragraphKeys = [];

  int _currentWordIndex = -1;
  int _currentParagraphIndex = -1;
  Timer? _debounceTimer;
  bool _userScrolling = false;
  Timer? _userScrollTimer;

  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      _transcript = await _loadRealData();
      _syncEngine = SyncEngine(_transcript!.paragraphs);
      _audioController = AudioControllerForHighLight(
        _transcript?.duration ?? 0,
        _transcript?.audioUrl,
      );
      scrollController = ScrollController();
      for (
        int i = 0;
        i < (_transcript ?? TranscriptData()).paragraphs.length;
        i++
      ) {
        _paragraphKeys.add(GlobalKey());
      }

      await _audioController.initialize();

      _audioController.addListener(_onAudioPositionUpdate);
      scrollController.addListener(_onUserScroll);

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Initialization error: $e';
        });
      }
    }
  }

  void _onUserScroll() {
    if (scrollController.hasClients &&
        scrollController.position.isScrollingNotifier.value) {
      _userScrolling = true;
      _userScrollTimer?.cancel();
      _userScrollTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _userScrolling = false);
        }
      });
    }
  }

  void _onAudioPositionUpdate() {

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 16), () {
      if (_syncEngine == null) return;

      final newWordIndex = _syncEngine.findWordIndexAtTime(
        _audioController.position,
      );

      if (newWordIndex != _currentWordIndex && newWordIndex >= 0) {
        if (mounted) {
          setState(() {
            _currentWordIndex = newWordIndex;
            _currentParagraphIndex = _syncEngine.getParagraphIndex(
              newWordIndex,
            );
          });
        }

        if (!_userScrolling && scrollController.hasClients) {
          _autoScrollToCurrentWord();
        }
      }
    });
  }

  void _autoScrollToCurrentWord() {
    if (_currentParagraphIndex < 0 ||
        _currentParagraphIndex >= _paragraphKeys.length) {
      return;
    }

    try {
      final key = _paragraphKeys[_currentParagraphIndex];
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _userScrollTimer?.cancel();
    _audioController.removeListener(_onAudioPositionUpdate);
    _audioController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: _buildErrorView(),
      );
    }

    if (_transcript == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Text Synchronizer'),
        elevation: 2,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_audioController.isLoading) const LinearProgressIndicator(),
              if (_audioController.error != null)
                Container(
                  color: Colors.red[100],
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _audioController.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(child: _buildTranscriptView()),
              _buildControlPanel(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = null;
                });
                _initializeApp();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranscriptView() {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _transcript!.paragraphs.length,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        final paragraph = _transcript!.paragraphs[index];
        final isCurrentParagraph = index == _currentParagraphIndex;
        final wordIndexInParagraph = isCurrentParagraph && _syncEngine != null
            ? _syncEngine.getWordIndexInParagraph(_currentWordIndex, index)
            : null;

        return ParagraphWidget(
          paragraph: paragraph,
          paragraphIndex: index,
          currentWordIndex: wordIndexInParagraph,
          isCurrentParagraph: isCurrentParagraph,
          onWordTap: (start) => _audioController.seek(start),
          widgetKey: _paragraphKeys[index],
        );
      },
    );
  }

  Widget _buildControlPanel() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  _formatTime(_audioController.position),
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  _formatTime(_audioController.duration),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  iconSize: 32,
                  onPressed: _audioController.skipBackward,
                  tooltip: 'Skip -10s',
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    _audioController.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 48,
                  ),
                  onPressed: _audioController.togglePlayPause,
                  tooltip: _audioController.isPlaying ? 'Pause' : 'Play',
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  iconSize: 32,
                  onPressed: _audioController.skipForward,
                  tooltip: 'Skip +10s',
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<TranscriptData> _loadRealData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/transcript-1.json');
      final jsonData = json.decode(jsonString);

      jsonData['audioUrl'] = 'audio.mp3';

      return TranscriptData.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load transcript: $e');
    }
  }
}
