import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';

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
  bool _wasPlayingBeforePause =
      false; // Para recordar si estaba reproduciendo antes de minimizar

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get volume => _volume;

  // Método para manejar cambios en el ciclo de vida de la aplicación
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print('🔄 App lifecycle changed to: $state');

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App se minimizó o perdió el foco
        print('🔄 App going to background - paused/inactive');
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        // App volvió a primer plano
        print('🔄 App returning to foreground - resumed');
        _handleAppResumed();
        break;
      case AppLifecycleState.detached:
        // App se está cerrando
        print('🔄 App detaching - closing');
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        // App está oculta pero aún en memoria
        print('🔄 App hidden');
        _handleAppPaused();
        break;
    }
  }

  // Pausar música cuando se minimiza la app
  void _handleAppPaused() {
    print(
      '🎵 Handling app pause - Current state: playing=$_isBackgroundMusicPlaying, enabled=$_musicEnabled',
    );
    if (_isBackgroundMusicPlaying && _musicEnabled) {
      _wasPlayingBeforePause = true;
      _pauseBackgroundMusic();
      print('🎵 App paused - Background music paused (wasPlaying set to true)');
    } else {
      print(
        '🎵 App paused - No music to pause (playing=$_isBackgroundMusicPlaying, enabled=$_musicEnabled)',
      );
    }
  }

  // Reanudar música cuando se vuelve a la app
  void _handleAppResumed() {
    print(
      '🎵 Handling app resume - wasPlaying=$_wasPlayingBeforePause, enabled=$_musicEnabled, currentlyPlaying=$_isBackgroundMusicPlaying',
    );
    if (_wasPlayingBeforePause && _musicEnabled) {
      _resumeBackgroundMusic();
      _wasPlayingBeforePause = false;
      print('🎵 App resumed - Background music resumed');
    } else {
      print(
        '🎵 App resumed - No music to resume (wasPlaying=$_wasPlayingBeforePause, enabled=$_musicEnabled)',
      );
    }
  }

  // Detener completamente cuando se cierra la app
  void _handleAppDetached() {
    stopBackgroundMusic(); // Aquí sí queremos parar completamente
    print('🎵 App detached - Background music stopped completely');
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _musicEnabled = prefs.getBool('music_enabled') ?? true;
    _volume = prefs.getDouble('volume') ?? 0.7;

    print(
      '🔧 AudioService initializing - Sound: $_soundEnabled, Music: $_musicEnabled, Volume: $_volume',
    );

    await _effectPlayer.setVolume(_volume);
    await _backgroundPlayer.setVolume(_volume * 0.3); // Background más suave

    // Registrar observer para detectar cambios en el ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);

    // Iniciar música de fondo si está habilitada
    if (_musicEnabled) {
      print('🎵 Starting background music during initialization...');
      await startBackgroundMusic();
    } else {
      print('🎵 Music is disabled, not starting background music');
    }

    print('🔧 AudioService initialization complete');
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
      print('🎵 Music disabled, not starting background music');
      return;
    }

    try {
      // Si ya está sonando, no hacer nada
      if (_isBackgroundMusicPlaying) {
        print('🎵 Background music already playing');
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

      print('🎵 Background music started successfully');
    } catch (e) {
      print('❌ Error starting background music: $e');
      _isBackgroundMusicPlaying = false;
    }
  }

  // Pausar música de fondo (marca estado para correcta reanudación)
  Future<void> _pauseBackgroundMusic() async {
    try {
      await _backgroundPlayer.pause();
      // Actualizar estado para reflejar que la música está pausada
      _isBackgroundMusicPlaying = false;
      print('🎵 Background music paused');
    } catch (e) {
      print('❌ Error pausing background music: $e');
    }
  }

  // Reanudar música de fondo
  Future<void> _resumeBackgroundMusic() async {
    try {
      await _backgroundPlayer.resume();
      print('🎵 Background music resumed');
    } catch (e) {
      print('❌ Error resuming background music: $e');
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
      print('🎵 Background music stopped completely');
    } catch (e) {
      print('❌ Error stopping background music: $e');
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
      print('🎵 Background music reset - will start fresh next time');
    } catch (e) {
      print('❌ Error resetting background music: $e');
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
      // Detener completamente cuando se deshabilita la música de fondo
      await stopBackgroundMusic();
      print('🎵 Music disabled - stopped');
    } else {
      // Si había música pausada, reanudarla desde donde estaba
      if (_isBackgroundMusicPlaying) {
        await _resumeBackgroundMusic();
        print('🎵 Music enabled - resumed from previous position');
      } else {
        // Si no había música, iniciar desde el principio
        await startBackgroundMusic();
        print('🎵 Music enabled - started fresh');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', enabled);

    print('🎵 Music enabled: $enabled'); // Debug
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
