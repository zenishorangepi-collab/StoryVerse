
// GetX Controller
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioControllerForHighLight extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = false;
  int _position = 0;
  double _speed = 1.0;
  final int _duration;
  final String? _audioUrl;

  bool _isLoading = false;
  bool _isInitialized = false;
  bool _hasPlayedOnce = false;
  String? _error;
  int _driftCorrectionCount = 0;
  DateTime? _lastDriftCheck;
  bool _isSeeking = false;
  bool _isDisposed = false;
  bool _operationInProgress = false;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<void>? _completionSubscription;

  AudioControllerForHighLight(this._duration, [this._audioUrl]);

  bool get isPlaying => _isPlaying;
  int get position => _position;
  double get speed => _speed;
  int get duration => _duration;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get driftCorrectionCount => _driftCorrectionCount;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isDisposed || _isInitialized) return;
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_audioUrl != null) {
        await _player.setReleaseMode(ReleaseMode.stop);
        await _player.setSourceAsset(_audioUrl);
        await _player.setPlaybackRate(_speed);
        _positionSubscription = _player.onPositionChanged.listen((pos) {
          if (!_isSeeking && !_isDisposed) {
            final newPos = pos.inMilliseconds.clamp(0, _duration);
            if ((_position - newPos).abs() > 100) {
              _position = newPos;
              _checkDrift();
              notifyListeners();
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
            }
            notifyListeners();
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
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load audio: $e';
      _isLoading = false;
      _isInitialized = false;
      notifyListeners();
    }
  }

  void _handleCompletion() {
    _isPlaying = false;
    _hasPlayedOnce = true;
    _position = _duration;
    _lastDriftCheck = null;
    notifyListeners();
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
              notifyListeners();
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
      notifyListeners();
    } catch (e) {
      _error = 'Playback error: $e';
      _isPlaying = false;
      _lastDriftCheck = null;
      notifyListeners();
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
      notifyListeners();
    } catch (e) {
      _error = 'Pause error: $e';
      notifyListeners();
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
      notifyListeners();
    } catch (e) {
      _error = 'Seek error: $e';
      notifyListeners();
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
      
      notifyListeners();
    } catch (e) {
      _error = 'Speed change error: $e';
      notifyListeners();
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
    notifyListeners();
    
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
    
    super.dispose();
  }
}