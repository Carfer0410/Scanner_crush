import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get volume => _volume;
  bool get isBackgroundMusicPlaying => _isBackgroundMusicPlaying;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _musicEnabled = prefs.getBool('music_enabled') ?? true;
    _volume = prefs.getDouble('volume') ?? 0.7;

    await _effectPlayer.setVolume(_volume);
    await _backgroundPlayer.setVolume(_volume * 0.3); // Background más suave

    // Iniciar música de fondo si está habilitada
    if (_musicEnabled) {
      await startBackgroundMusic();
    }

    print(
      '🔧 AudioService initialized - Sound: $_soundEnabled, Music: $_musicEnabled, Volume: $_volume',
    );
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

  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundPlayer.stop();
      _isBackgroundMusicPlaying = false;
      print('🎵 Background music stopped successfully');
    } catch (e) {
      print('❌ Error stopping background music: $e');
      // Asegurar que el estado se actualice incluso si hay error
      _isBackgroundMusicPlaying = false;
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
      await stopBackgroundMusic();
    } else {
      await startBackgroundMusic();
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
    _effectPlayer.dispose();
    _backgroundPlayer.dispose();
  }
}
