import 'package:flutter/material.dart';
import 'services/audio_service.dart';
import 'services/theme_service.dart';

class TestAudioScreen extends StatefulWidget {
  const TestAudioScreen({super.key});

  @override
  State<TestAudioScreen> createState() => _TestAudioScreenState();
}

class _TestAudioScreenState extends State<TestAudioScreen> with WidgetsBindingObserver {
  final AudioService _audioService = AudioService.instance;
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Audio & Lifecycle'),
        backgroundColor: ThemeService.instance.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: ThemeService.instance.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Estado del ciclo de vida
                  _buildInfoCard(
                    title: '📱 Estado del Ciclo de Vida',
                    children: [
                      Text(
                        'Estado actual: ${_lastLifecycleState ?? 'resumed'}',
                        style: TextStyle(
                          color: ThemeService.instance.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '💡 Minimiza la app para probar la pausa automática de música',
                        style: TextStyle(
                          color: ThemeService.instance.subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Estado del audio
                  _buildInfoCard(
                    title: '🎵 Estado del Audio',
                    children: [
                      _buildStatusRow('Sound Enabled', _audioService.soundEnabled),
                      _buildStatusRow('Music Enabled', _audioService.musicEnabled),
                      _buildStatusRow('Music Playing', _audioService.isBackgroundMusicPlaying),
                      _buildStatusRow('Was Playing Before Pause', _audioService.wasPlayingBeforePause),
                      Text(
                        'Volume: ${_audioService.volume.toStringAsFixed(2)}',
                        style: TextStyle(color: ThemeService.instance.textColor),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Controles de música
                  _buildControlSection(
                    title: '🎼 Controles de Música de Fondo',
                    children: [
                      _buildControlButton(
                        'Iniciar Música de Fondo',
                        Icons.play_arrow,
                        () async {
                          await _audioService.startBackgroundMusic();
                          setState(() {});
                        },
                      ),

                      _buildControlButton(
                        'Detener Música de Fondo',
                        Icons.stop,
                        () async {
                          await _audioService.stopBackgroundMusic();
                          setState(() {});
                        },
                      ),

                      _buildControlButton(
                        'Toggle Música: ${_audioService.musicEnabled ? 'ON' : 'OFF'}',
                        _audioService.musicEnabled ? Icons.music_note : Icons.music_off,
                        () async {
                          await _audioService.setMusicEnabled(!_audioService.musicEnabled);
                          setState(() {});
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Efectos de sonido
                  _buildControlSection(
                    title: '🔊 Efectos de Sonido',
                    children: [
                      _buildControlButton(
                        'Heartbeat',
                        Icons.favorite,
                        () => _audioService.playHeartbeat(),
                      ),

                      _buildControlButton(
                        'Celebration',
                        Icons.celebration,
                        () => _audioService.playCelebration(),
                      ),

                      _buildControlButton(
                        'Magic Whoosh',
                        Icons.auto_awesome,
                        () => _audioService.playMagicWhoosh(),
                      ),

                      _buildControlButton(
                        'Button Tap',
                        Icons.touch_app,
                        () => _audioService.playButtonTap(),
                      ),

                      _buildControlButton(
                        'Transition',
                        Icons.swap_horiz,
                        () => _audioService.playTransition(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Instrucciones
                  _buildInfoCard(
                    title: '📝 Instrucciones de Prueba',
                    children: [
                      Text(
                        '1. Activa la música de fondo',
                        style: TextStyle(color: ThemeService.instance.textColor),
                      ),
                      Text(
                        '2. Minimiza la aplicación (botón home)',
                        style: TextStyle(color: ThemeService.instance.textColor),
                      ),
                      Text(
                        '3. La música se pausará automáticamente',
                        style: TextStyle(color: ThemeService.instance.textColor),
                      ),
                      Text(
                        '4. Vuelve a la app, la música se reanudará',
                        style: TextStyle(color: ThemeService.instance.textColor),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '✨ Esto evita interrumpir otras actividades del usuario',
                        style: TextStyle(
                          color: ThemeService.instance.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: ThemeService.instance.cardGradient,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: ThemeService.instance.borderColor,
          width: 1,
        ),
        boxShadow: ThemeService.instance.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeService.instance.textColor,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildControlSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeService.instance.textColor,
          ),
        ),
        const SizedBox(height: 16),
        ...children.map((child) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: child,
        )),
      ],
    );
  }

  Widget _buildControlButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeService.instance.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(color: ThemeService.instance.textColor),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: value ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value ? 'YES' : 'NO',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
