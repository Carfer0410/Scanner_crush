import 'package:flutter/material.dart';
import 'services/audio_service.dart';

class TestAudioScreen extends StatefulWidget {
  const TestAudioScreen({super.key});

  @override
  State<TestAudioScreen> createState() => _TestAudioScreenState();
}

class _TestAudioScreenState extends State<TestAudioScreen> {
  final AudioService _audioService = AudioService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Audio'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Estado actual
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text('Estado Actual:'),
                  Text('Sound Enabled: ${_audioService.soundEnabled}'),
                  Text('Music Enabled: ${_audioService.musicEnabled}'),
                  Text(
                    'Music Playing: ${_audioService.isBackgroundMusicPlaying}',
                  ),
                  Text('Volume: ${_audioService.volume.toStringAsFixed(2)}'),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Controles de música
            ElevatedButton(
              onPressed: () async {
                await _audioService.startBackgroundMusic();
                setState(() {});
              },
              child: const Text('Start Background Music'),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                await _audioService.stopBackgroundMusic();
                setState(() {});
              },
              child: const Text('Stop Background Music'),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                await _audioService.setMusicEnabled(
                  !_audioService.musicEnabled,
                );
                setState(() {});
              },
              child: Text(
                'Toggle Music: ${_audioService.musicEnabled ? 'ON' : 'OFF'}',
              ),
            ),
            const SizedBox(height: 30),

            // Efectos de sonido
            ElevatedButton(
              onPressed: () => _audioService.playHeartbeat(),
              child: const Text('Play Heartbeat'),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => _audioService.playCelebration(),
              child: const Text('Play Celebration'),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => _audioService.playMagicWhoosh(),
              child: const Text('Play Magic Whoosh'),
            ),
          ],
        ),
      ),
    );
  }
}
