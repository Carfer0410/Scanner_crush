import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';

import 'logger_service.dart';
class AudioService with WidgetsBindingObserver {
  static final AudioService _instance = AudioService._internal();
  static AudioService get instance => _instance;
  AudioService._internal();

  final AudioPlayer _effectPlayer = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _volume = 0.7;
  bool _isBackgroundMusicPlaying = false;
  bool _wasPlayingBeforePause = false; // Para recordar si estaba reproduciendo antes de minimizar

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get volume => _volume;

  // Método para manejar cambios en el ciclo de vida de la aplicación
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    LoggerService.debug('App lifecycle changed to: $state', origin: 'audio_service');
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App se minimizó o perdió el foco
        LoggerService.debug('App going to background - paused/inactive', origin: 'audio_service');
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        // App volvió a primer plano
        LoggerService.debug('App returning to foreground - resumed', origin: 'audio_service');
        _handleAppResumed();
        break;
      case AppLifecycleState.detached:
        // App se está cerrando
        LoggerService.debug('App detaching - closing', origin: 'audio_service');
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        // App está oculta pero aún en memoria
        LoggerService.debug('App hidden', origin: 'audio_service');
        _handleAppPaused();
        break;
    }
  }

  // Pausar música cuando se minimiza la app
  void _handleAppPaused() {
    LoggerService.debug('Handling app pause - Current state: playing=$_isBackgroundMusicPlaying, enabled=$_musicEnabled', origin: 'audio_service');
    if (_isBackgroundMusicPlaying && _musicEnabled) {
      _wasPlayingBeforePause = true;
      _pauseBackgroundMusic();
      LoggerService.debug('App paused - Background music paused (wasPlaying set to true)', origin: 'audio_service');
    } else {
      LoggerService.debug('App paused - No music to pause (playing=$_isBackgroundMusicPlaying, enabled=$_musicEnabled)', origin: 'audio_service');
    }
  }

  // Reanudar música cuando se vuelve a la app
  void _handleAppResumed() {
    LoggerService.debug('Handling app resume - wasPlaying=$_wasPlayingBeforePause, enabled=$_musicEnabled, currentlyPlaying=$_isBackgroundMusicPlaying', origin: 'audio_service');
    if (_wasPlayingBeforePause && _musicEnabled) {
      _resumeBackgroundMusic();
      _wasPlayingBeforePause = false;
      LoggerService.debug('App resumed - Background music resumed', origin: 'audio_service');
    } else {
      LoggerService.debug('App resumed - No music to resume (wasPlaying=$_wasPlayingBeforePause, enabled=$_musicEnabled)', origin: 'audio_service');
    }
  }

  // Detener completamente cuando se cierra la app
  void _handleAppDetached() {
    stopBackgroundMusic(); // Aquí sí queremos parar completamente
    LoggerService.debug('App detached - Background music stopped completely', origin: 'audio_service');
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _musicEnabled = prefs.getBool('music_enabled') ?? true;
    _volume = prefs.getDouble('volume') ?? 0.7;

    LoggerService.debug('AudioService initializing - Sound: $_soundEnabled, Music: $_musicEnabled, Volume: $_volume', origin: 'audio_service');

    await _effectPlayer.setVolume(_volume);
    await _backgroundPlayer.setVolume(_volume * 0.3); // Background más suave

    // Registrar observer para detectar cambios en el ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);

    // Iniciar música de fondo si está habilitada
    if (_musicEnabled) {
      LoggerService.debug('Starting background music during initialization...', origin: 'audio_service');
      await startBackgroundMusic();
    } else {
      LoggerService.debug('Music is disabled, not starting background music', origin: 'audio_service');
    }

    LoggerService.debug('AudioService initialization complete', origin: 'audio_service');
  }

  // 🎵 SONIDOS DE EFECTOS
  Future<void> playButtonTap() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource('sounds/button_tap.mp3'));
    } catch (e) {
      // Fallback silencioso - no interrumpir la experiencia
    }
  }

  Future<void> playHeartbeat() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource('sounds/heartbeat.mp3'));
    } catch (e) {
      // Fallback silencioso
    }
  }

  Future<void> playMagicWhoosh() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource('sounds/magic_whoosh.mp3'));
    } catch (e) {
      // Fallback silencioso
    }
  }

  Future<void> playCelebration() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource('sounds/celebration.mp3'));
    } catch (e) {
      // Fallback silencioso
    }
  }

  Future<void> playLowCompatibility() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource('sounds/gentle_chime.mp3'));
    } catch (e) {
      // Fallback silencioso
    }
  }

  Future<void> playTransition() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource('sounds/transition.mp3'));
    } catch (e) {
      // Fallback silencioso
    }
  }

  // 🎼 MÚSICA DE FONDO
  Future<void> startBackgroundMusic() async {
    if (!_musicEnabled) {
      LoggerService.debug('Music disabled, not starting background music', origin: 'audio_service');
      return;
    }

    try {
      // Si ya está sonando, no hacer nada
      if (_isBackgroundMusicPlaying) {
        LoggerService.debug('Background music already playing', origin: 'audio_service');
        return;
      }

      // Configurar el player
      await _backgroundPlayer.stop(); // Limpiar estado anterior
      await _backgroundPlayer.setVolume(_volume * 0.3); // Background más suave
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);

      // Cargar y reproducir
      await _backgroundPlayer.setSource(AssetSource('sounds/ambient_love.mp3'));
      await _backgroundPlayer.resume();
      _isBackgroundMusicPlaying = true;

      LoggerService.debug('Background music started successfully', origin: 'audio_service');
    } catch (e) {
      LoggerService.error('Error starting background music: $e', origin: 'AudioService');
      _isBackgroundMusicPlaying = false;
    }
  }

  // Pausar música de fondo (sin detenerla completamente)
  Future<void> _pauseBackgroundMusic() async {
    try {
      await _backgroundPlayer.pause();
      // NO cambiar _isBackgroundMusicPlaying aquí, para poder reanudar
      LoggerService.debug('Background music paused', origin: 'audio_service');
    } catch (e) {
      LoggerService.error('Error pausing background music: $e', origin: 'AudioService');
    }
  }

  // Reanudar música de fondo
  Future<void> _resumeBackgroundMusic() async {
    try {
      await _backgroundPlayer.resume();
      LoggerService.debug('Background music resumed', origin: 'audio_service');
    } catch (e) {
      LoggerService.error('Error resuming background music: $e', origin: 'AudioService');
      // Si hay error al reanudar, intentar iniciar desde cero
      _isBackgroundMusicPlaying = false;
      await startBackgroundMusic();
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundPlayer.stop();
      _isBackgroundMusicPlaying = false;
      _wasPlayingBeforePause = false; // Reset flag
      LoggerService.debug('Background music stopped completely', origin: 'audio_service');
    } catch (e) {
      LoggerService.error('Error stopping background music: $e', origin: 'AudioService');
      // Asegurar que el estado se actualice incluso si hay error
      _isBackgroundMusicPlaying = false;
      _wasPlayingBeforePause = false;
    }
  }

  // Método para pausar completamente y reiniciar (solo para casos especiales)
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

  // ⚙️ CONFIGURACIONES
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;

    if (!enabled) {
      // Solo pausar, no detener completamente, para que continúe desde donde estaba
      await _pauseBackgroundMusic();
      LoggerService.debug('Music disabled - paused (will resume from same position)', origin: 'audio_service');
    } else {
      // Si había música pausada, reanudarla desde donde estaba
      if (_isBackgroundMusicPlaying) {
        await _resumeBackgroundMusic();
        LoggerService.debug('Music enabled - resumed from previous position', origin: 'audio_service');
      } else {
        // Si no había música, iniciar desde el principio
        await startBackgroundMusic();
        LoggerService.debug('Music enabled - started fresh', origin: 'audio_service');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', enabled);

    LoggerService.debug('Music enabled: $enabled', origin: 'audio_service'); // Debug
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _effectPlayer.setVolume(volume);
    await _backgroundPlayer.setVolume(volume * 0.3);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', volume);
  }

  // 🎯 SONIDOS CONTEXTUALES
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
    WidgetsBinding.instance.removeObserver(this);
    _effectPlayer.dispose();
    _backgroundPlayer.dispose();
  }
}
