import 'dart:math' as math;
import 'package:utsav_interview/app/audio_text_view/models/paragrah_data_model.dart';
import 'package:utsav_interview/app/audio_text_view/models/word_data_model.dart';

class SyncEngine {
  final List<ParagraphData> paragraphs;
  late final List<WordData> _flatWords;
  late final List<int> _paragraphStartIndices;
  late final List<int> _wordStartTimes;
  late final List<int> _paragraphStartTimes;
  late final List<int> _paragraphEndTimes;

  int _lastSearchIndex = 0; // Cache for temporal locality
  int _searchHits = 0;
  int _searchMisses = 0;

  /// Speed factor: 1.0 = normal, 0.5 = half-speed, 2.0 = double speed, etc.
  double speed = 1.0;

  SyncEngine(this.paragraphs) {
    _buildOptimizedStructure();
  }

  void _buildOptimizedStructure() {
    _flatWords = [];
    _paragraphStartIndices = [0];
    _wordStartTimes = [];

    _paragraphStartTimes = [];
    _paragraphEndTimes = [];

    for (final para in paragraphs) {
      if (para.words.isNotEmpty) {
        _paragraphStartTimes.add(para.words.first.start);
        _paragraphEndTimes.add(para.words.last.end);
      } else {
        _paragraphStartTimes.add(0);
        _paragraphEndTimes.add(0);
      }

      for (final word in para.words) {
        _flatWords.add(word);
        _wordStartTimes.add(word.start);
      }

      _paragraphStartIndices.add(_flatWords.length);
    }
  }

  int findParagraphIndexAtTime(int timeMs) {
    if (_paragraphStartTimes.isEmpty) return -1;

    // Adjust time by speed (same as word logic)
    final adjustedTime = (timeMs * speed).toInt();

    for (int i = 0; i < _paragraphStartTimes.length; i++) {
      if (adjustedTime >= _paragraphStartTimes[i] && adjustedTime <= _paragraphEndTimes[i]) {
        return i;
      }
    }

    return -1;
  }

  // void _buildOptimizedStructure() {
  //   _flatWords = [];
  //   _paragraphStartIndices = [0];
  //   _wordStartTimes = [];
  //
  //   for (final para in paragraphs) {
  //     for (final word in para.words) {
  //       _flatWords.add(word);
  //       _wordStartTimes.add(word.start);
  //     }
  //     _paragraphStartIndices.add(_flatWords.length);
  //   }
  // }

  /// Public setter to change playback speed used for time -> word mapping.
  void setSpeed(double newSpeed) {
    if (newSpeed <= 0) return;
    speed = newSpeed;
    // Reset cache so we don't incorrectly match old index at new speed
    _lastSearchIndex = math.max(0, math.min(_lastSearchIndex, _flatWords.length - 1));
  }

  /// Finds the word index corresponding to the given audio time (milliseconds).
  /// Applies the current speed factor so time is scaled correctly.
  int findWordIndexAtTime(int timeMs) {
    if (_flatWords.isEmpty) return -1;

    // adjust time by speed: if playing faster, a given audio position maps to later transcript time
    final adjustedTime = (timeMs * speed).toInt();

    if (adjustedTime < _wordStartTimes.first) return -1;
    if (adjustedTime >= _flatWords.last.end) return _flatWords.length - 1;

    // Check cached position first (temporal locality)
    if (_lastSearchIndex >= 0 && _lastSearchIndex < _flatWords.length) {
      if (_flatWords[_lastSearchIndex].containsTime(adjustedTime)) {
        _searchHits++;
        return _lastSearchIndex;
      }

      // Check neighbors
      if (_lastSearchIndex > 0 && _flatWords[_lastSearchIndex - 1].containsTime(adjustedTime)) {
        _searchHits++;
        _lastSearchIndex--;
        return _lastSearchIndex;
      }
      if (_lastSearchIndex < _flatWords.length - 1 && _flatWords[_lastSearchIndex + 1].containsTime(adjustedTime)) {
        _searchHits++;
        _lastSearchIndex++;
        return _lastSearchIndex;
      }
    }

    _searchMisses++;

    // Binary search with interpolation
    int left = 0;
    int right = _flatWords.length - 1;
    int iterations = 0;
    const maxIterations = 64; // slightly larger safety limit

    while (left <= right && iterations < maxIterations) {
      iterations++;

      int mid;
      if (_wordStartTimes[right] != _wordStartTimes[left]) {
        // Interpolation estimate
        final ratio = (adjustedTime - _wordStartTimes[left]) / (_wordStartTimes[right] - _wordStartTimes[left]);
        mid = left + (ratio * (right - left)).round();
        mid = mid.clamp(left, right);
      } else {
        mid = (left + right) ~/ 2;
      }

      final word = _flatWords[mid];

      if (word.containsTime(adjustedTime)) {
        _lastSearchIndex = mid;
        return mid;
      } else if (adjustedTime < word.start) {
        right = mid - 1;
      } else {
        left = mid + 1;
      }
    }

    // Fallback: nearest candidate
    if (left < _flatWords.length) {
      _lastSearchIndex = left;
      return left;
    }

    return -1;
  }

  int getParagraphIndex(int wordIndex) {
    if (wordIndex < 0) return -1;

    for (int i = 0; i < _paragraphStartIndices.length - 1; i++) {
      if (wordIndex >= _paragraphStartIndices[i] && wordIndex < _paragraphStartIndices[i + 1]) {
        return i;
      }
    }
    return paragraphs.length - 1;
  }

  int getWordIndexInParagraph(int globalWordIndex, int paragraphIndex) {
    if (paragraphIndex < 0 || paragraphIndex >= _paragraphStartIndices.length - 1) {
      return -1;
    }
    return globalWordIndex - _paragraphStartIndices[paragraphIndex];
  }

  double get cacheHitRate => (_searchHits + _searchMisses) > 0 ? _searchHits / (_searchHits + _searchMisses) : 0.0;
}
