

import 'package:utsav_interview/app/audio_text_screen/models/paragrah_data_model.dart';
import 'package:utsav_interview/app/audio_text_screen/models/word_data_model.dart';

class SyncEngine {
  final List<ParagraphData> paragraphs;
  late final List<WordData> _flatWords;
  late final List<int> _paragraphStartIndices;
  late final List<int> _wordStartTimes;

  int _lastSearchIndex = 0; // Cache for temporal locality
  int _searchHits = 0;
  int _searchMisses = 0;

  SyncEngine(this.paragraphs) {
    _buildOptimizedStructure();
  }

  void _buildOptimizedStructure() {
    _flatWords = [];
    _paragraphStartIndices = [0];
    _wordStartTimes = [];

    for (final para in paragraphs) {
      for (final word in para.words) {
        _flatWords.add(word);
        _wordStartTimes.add(word.start);
      }
      _paragraphStartIndices.add(_flatWords.length);
    }
  }

  // O(log n) binary search with interpolation + temporal locality caching
  int findWordIndexAtTime(int timeMs) {
    if (_flatWords.isEmpty) return -1;
    if (timeMs < _wordStartTimes.first) return -1;
    if (timeMs >= _flatWords.last.end) return _flatWords.length - 1;

    // Check cached position first (temporal locality)
    if (_lastSearchIndex >= 0 && _lastSearchIndex < _flatWords.length) {
      if (_flatWords[_lastSearchIndex].containsTime(timeMs)) {
        _searchHits++;
        return _lastSearchIndex;
      }

      // Check neighbors
      if (_lastSearchIndex > 0 &&
          _flatWords[_lastSearchIndex - 1].containsTime(timeMs)) {
        _searchHits++;
        _lastSearchIndex--;
        return _lastSearchIndex;
      }
      if (_lastSearchIndex < _flatWords.length - 1 &&
          _flatWords[_lastSearchIndex + 1].containsTime(timeMs)) {
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
    const maxIterations = 32; // Safety limit

    while (left <= right && iterations < maxIterations) {
      iterations++;

      int mid;
      if (_wordStartTimes[right] != _wordStartTimes[left]) {
        // Interpolation for O(log log n) average case
        final ratio =
            (timeMs - _wordStartTimes[left]) /
            (_wordStartTimes[right] - _wordStartTimes[left]);
        mid = left + (ratio * (right - left)).round();
        mid = mid.clamp(left, right);
      } else {
        mid = (left + right) ~/ 2;
      }

      final word = _flatWords[mid];

      if (word.containsTime(timeMs)) {
        _lastSearchIndex = mid;
        return mid;
      } else if (timeMs < word.start) {
        right = mid - 1;
      } else {
        left = mid + 1;
      }
    }

    // Fallback: Find closest word
    if (left < _flatWords.length) {
      _lastSearchIndex = left;
      return left;
    }

    return -1;
  }

  int getParagraphIndex(int wordIndex) {
    if (wordIndex < 0) return -1;

    for (int i = 0; i < _paragraphStartIndices.length - 1; i++) {
      if (wordIndex >= _paragraphStartIndices[i] &&
          wordIndex < _paragraphStartIndices[i + 1]) {
        return i;
      }
    }
    return paragraphs.length - 1;
  }

  int getWordIndexInParagraph(int globalWordIndex, int paragraphIndex) {
    if (paragraphIndex < 0 ||
        paragraphIndex >= _paragraphStartIndices.length - 1) {
      return -1;
    }
    return globalWordIndex - _paragraphStartIndices[paragraphIndex];
  }

  double get cacheHitRate => (_searchHits + _searchMisses) > 0
      ? _searchHits / (_searchHits + _searchMisses)
      : 0.0;
}
