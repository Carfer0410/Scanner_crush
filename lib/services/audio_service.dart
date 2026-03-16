import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logger_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  static AudioService get instance => _instance;
  AudioService._internal();

  final AudioPlayer _effectPlayer = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _volume = 0.7;
  bool _isBackgroundMusicPlaying = false;
  bool _wasPlayingBeforePause = false;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get volume => _volume;

  void handleAppLifecycleState(AppLifecycleState state) {
    LoggerService.debug('App lifecycle changed to: $state', origin: 'audio_service');

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        LoggerService.debug('App moved to background', origin: 'audio_service');
        pauseForBackground();
        break;
      case AppLifecycleState.resumed:
        LoggerService.debug('App returned to foreground', origin: 'audio_service');
        resumeFromBackground();
        break;
      case AppLifecycleState.detached:
        LoggerService.debug('App detached - stopping background music', origin: 'audio_service');
        stopBackgroundMusic();
        break;
    }
  }

  Future<void> pauseForBackground() async {
    LoggerService.debug(
      'Handling app pause - playing=$_isBackgroundMusicPlaying, enabled=$_musicEnabled',
      origin: 'audio_service',
    );

    try {
      await _effectPlayer.stop();
    } catch (_) {
      // No interrumpir el flujo por un efecto puntual.
    }

    if (_isBackgroundMusicPlaying && _musicEnabled) {
      _wasPlayingBeforePause = true;
      await _pauseBackgroundMusic();
      LoggerService.debug('Background music paused for background state', origin: 'audio_service');
      return;
    }

    _wasPlayingBeforePause = false;
    LoggerService.debug('No background music needed pausing', origin: 'audio_service');
  }

  Future<void> resumeFromBackground() async {
    LoggerService.debug(
      'Handling app resume - wasPlaying=$_wasPlayingBeforePause, enabled=$_musicEnabled, currentlyPlaying=$_isBackgroundMusicPlaying',
      origin: 'audio_service',
    );

    if (_wasPlayingBeforePause && _musicEnabled) {
      await _resumeBackgroundMusic();
      _wasPlayingBeforePause = false;
      LoggerService.debug('Background music resumed after returning to app', origin: 'audio_service');
      return;
    }

    LoggerService.debug('No background music to resume', origin: 'audio_service');
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _musicEnabled = prefs.getBool('music_enabled') ?? true;
    _volume = prefs.getDouble('volume') ?? 0.7;

    LoggerService.debug(
      'AudioService initializing - Sound: $_soundEnabled, Music: $_musicEnabled, Volume: $_volume',
      origin: 'audio_service',
    );

    await _effectPlayer.setVolume(_volume);
    await _backgroundPlayer.setVolume(_volume * 0.3);

    if (_musicEnabled) {
      LoggerService.debug('Starting background music during initialization...', origin: 'audio_service');
      await startBackgroundMusic();
    } else {
      LoggerService.debug('Music is disabled, not starting background music', origin: 'audio_service');
    }

    LoggerService.debug('AudioService initialization complete', origin: 'audio_service');
  }

  Future<void> playButtonTap() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource('sounds/button_tap.mp3'));
    } catch (_) {}
  }

  Future<void> playHeartbeat() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource('sounds/heartbeat.mp3'));
    } catch (_) {}
  }

  Future<void> playMagicWhoosh() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource('sounds/magic_whoosh.mp3'));
    } catch (_) {}
  }

  Future<void> playCelebration() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource('sounds/celebration.mp3'));
    } catch (_) {}
  }

  Future<void> playLowCompatibility() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource('sounds/gentle_chime.mp3'));
    } catch (_) {}
  }

  Future<void> playTransition() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource('sounds/transition.mp3'));
    } catch (_) {}
  }

  Future<void> startBackgroundMusic() async {
    if (!_musicEnabled) {
      LoggerService.debug('Music disabled, not starting background music', origin: 'audio_service');
      return;
    }

    try {
      if (_isBackgroundMusicPlaying) {
        LoggerService.debug('Background music already playing', origin: 'audio_service');
        return;
      }

      await _backgroundPlayer.stop();
      await _backgroundPlayer.setVolume(_volume * 0.3);
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.setSource(AssetSource('sounds/ambient_love.mp3'));
      await _backgroundPlayer.resume();
      _isBackgroundMusicPlaying = true;

      LoggerService.debug('Background music started successfully', origin: 'audio_service');
    } catch (e) {
      LoggerService.error('Error starting background music: $e', origin: 'AudioService');
      _isBackgroundMusicPlaying = false;
    }
  }

  Future<void> _pauseBackgroundMusic() async {
    try {
      await _backgroundPlayer.pause();
      LoggerService.debug('Background music paused', origin: 'audio_service');
    } catch (e) {
      LoggerService.error('Error pausing background music: $e', origin: 'AudioService');
    }
  }

  Future<void> _resumeBackgroundMusic() async {
    try {
      await _backgroundPlayer.resume();
      LoggerService.debug('Background music resumed', origin: 'audio_service');
    } catch (e) {
      LoggerService.error('Error resuming background music: $e', origin: 'AudioService');
      _isBackgroundMusicPlaying = false;
      await startBackgroundMusic();
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundPlayer.stop();
      _isBackgroundMusicPlaying = false;
      _wasPlayingBeforePause = false;
      LoggerService.debug('Background music stopped completely', origin: 'audio_service');
    } catch (e) {
      LoggerService.error('Error stopping background music: $e', origin: 'AudioService');
      _isBackgroundMusicPlaying = false;
      _wasPlayingBeforePause = false;
    }
  }

  Future<void> resetBackgroundMusic() async {
    try {
      await _backgroundPlayer.stop();
      _isBackgroundMusicPlaying = false;
      _wasPlayingBeforePause = false;
      LoggerService.debug('Background music reset - will start fresh next time', origin: 'audio_service');
    } catch (e) {
      LoggerService.error('Error resetting background music: $e', origin: 'AudioService');
      _isBackgroundMusicPlaying = false;
      _wasPlayingBeforePause = false;
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;

    if (!enabled) {
      await _pauseBackgroundMusic();
      _wasPlayingBeforePause = false;
      LoggerService.debug('Music disabled - paused', origin: 'audio_service');
    } else {
      if (_isBackgroundMusicPlaying) {
        await _resumeBackgroundMusic();
        LoggerService.debug('Music enabled - resumed from previous position', origin: 'audio_service');
      } else {
        await startBackgroundMusic();
        LoggerService.debug('Music enabled - started fresh', origin: 'audio_service');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', enabled);
    LoggerService.debug('Music enabled: $enabled', origin: 'audio_service');
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _effectPlayer.setVolume(volume);
    await _backgroundPlayer.setVolume(volume * 0.3);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', volume);
  }

  Future<void> playCompatibilityResult(int percentage) async {
    if (percentage >= 80) {
      await playCelebration();
    } else if (percentage >= 50) {
      await playHeartbeat();
    } else {
      await playLowCompatibility();
    }
  }

  void dispose() {
    _effectPlayer.dispose();
    _backgroundPlayer.dispose();
  }
}
