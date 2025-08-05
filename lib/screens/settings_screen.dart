import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/ad_service.dart';
import '../services/crush_service.dart';
import '../services/audio_service.dart';
import 'premium_screen.dart';
import 'history_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: ThemeService.instance.textColor,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Configuración',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeService.instance.textColor,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const SizedBox(height: 20),

                    // Premium status card
                    if (AdService.instance.isPremiumUser)
                      _buildPremiumCard()
                    else
                      _buildUpgradeCard(),

                    const SizedBox(height: 30),

                    // Settings sections
                    _buildSettingsSection(
                      title: 'General',
                      items: [
                        _buildSettingsItem(
                          icon: Icons.history,
                          title: 'Historial de Escaneos',
                          subtitle: 'Ver todos tus escaneos anteriores',
                          onTap: () => _navigateToHistory(),
                        ),
                        _buildSettingsItem(
                          icon:
                              ThemeService.instance.isDarkMode
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                          title:
                              'Tema ${ThemeService.instance.isDarkMode ? "Claro" : "Oscuro"}',
                          subtitle: 'Cambiar el tema de la aplicación',
                          onTap: () => _toggleTheme(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 🎵 NUEVA SECCIÓN DE AUDIO
                    _buildSettingsSection(
                      title: 'Audio',
                      items: [
                        _buildSettingsItem(
                          icon:
                              AudioService.instance.soundEnabled
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                          title: 'Efectos de Sonido',
                          subtitle: 'Sonidos en botones y acciones',
                          onTap: () => _toggleSoundEffects(),
                          trailing: Switch(
                            value: AudioService.instance.soundEnabled,
                            onChanged: (value) => _toggleSoundEffects(),
                            activeColor: ThemeService.instance.primaryColor,
                          ),
                        ),
                        _buildSettingsItem(
                          icon:
                              AudioService.instance.musicEnabled
                                  ? Icons.music_note
                                  : Icons.music_off,
                          title: 'Música de Fondo',
                          subtitle: 'Música ambiente relajante',
                          onTap: () => _toggleBackgroundMusic(),
                          trailing: Switch(
                            value: AudioService.instance.musicEnabled,
                            onChanged: (value) => _toggleBackgroundMusic(),
                            activeColor: ThemeService.instance.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    _buildSettingsSection(
                      title: 'Premium',
                      items: [
                        if (!AdService.instance.isPremiumUser)
                          _buildSettingsItem(
                            icon: Icons.star,
                            title: 'Actualizar a Premium',
                            subtitle: 'Desbloquea todas las funciones',
                            onTap: () => _navigateToPremium(),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'NUEVO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    _buildSettingsSection(
                      title: 'Soporte',
                      items: [
                        _buildSettingsItem(
                          icon: Icons.help_outline,
                          title: 'Ayuda y Preguntas',
                          subtitle: 'Obtén ayuda sobre cómo usar la app',
                          onTap: () => _showHelpDialog(),
                        ),
                        _buildSettingsItem(
                          icon: Icons.info_outline,
                          title: 'Acerca de',
                          subtitle: 'Información sobre la aplicación',
                          onTap: () => _showAboutDialog(),
                        ),
                        _buildSettingsItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacidad',
                          subtitle: 'Política de privacidad y términos',
                          onTap: () => _showPrivacyDialog(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // App version
                    Center(
                      child: Text(
                        'Escáner de Crush v1.0.0\nHecho con 💕 para el amor',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: ThemeService.instance.textColor.withOpacity(
                            0.5,
                          ),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.amber, Colors.orange]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.stars, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Eres Premium!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Disfruta de todas las funciones sin límites',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 200.ms);
  }

  Widget _buildUpgradeCard() {
    return GestureDetector(
      onTap: () => _navigateToPremium(),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ThemeService.instance.primaryColor,
              ThemeService.instance.secondaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ThemeService.instance.primaryColor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.star_border, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actualizar a Premium',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Sin anuncios, escaneos ilimitados y más',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    ).animate().scale(delay: 200.ms);
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 16),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeService.instance.textColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: ThemeService.instance.cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ThemeService.instance.primaryColor.withOpacity(0.1),
        ),
        child: Icon(icon, color: ThemeService.instance.primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ThemeService.instance.textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: ThemeService.instance.textColor.withOpacity(0.7),
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios,
            color: ThemeService.instance.textColor.withOpacity(0.3),
            size: 16,
          ),
      onTap: onTap,
    );
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  void _navigateToPremium() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumScreen()),
    );
  }

  void _toggleTheme() async {
    await ThemeService.instance.toggleTheme();
    setState(() {});
  }

  // 🎵 NUEVOS MÉTODOS DE AUDIO
  void _toggleSoundEffects() async {
    await AudioService.instance.setSoundEnabled(
      !AudioService.instance.soundEnabled,
    );
    setState(() {});

    // Reproducir sonido de prueba si se activó
    if (AudioService.instance.soundEnabled) {
      AudioService.instance.playButtonTap();
    }
  }

  void _toggleBackgroundMusic() async {
    await AudioService.instance.setMusicEnabled(
      !AudioService.instance.musicEnabled,
    );
    setState(() {});
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '💕 Ayuda',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Escáner de Crush es una app divertida que calcula la compatibilidad entre dos personas basándose en sus nombres.\n\n'
              '• Ingresa tu nombre y el de tu crush\n'
              '• Presiona "Escanear Amor"\n'
              '• Descubre tu compatibilidad\n'
              '• Comparte el resultado\n\n'
              '¡Es solo por diversión! 😄',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Entendido',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: ThemeService.instance.primaryColor,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '💘 Acerca de',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Escáner de Crush v1.0.0\n\n'
              'Una aplicación divertida para descubrir la compatibilidad amorosa.\n\n'
              'Desarrollada con Flutter y mucho amor 💕\n\n'
              '© 2024 Escáner de Crush',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cerrar',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: ThemeService.instance.primaryColor,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '🔒 Privacidad',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Tu privacidad es importante para nosotros.\n\n'
              '• Los nombres se almacenan solo localmente\n'
              '• No compartimos información personal\n'
              '• Los resultados son generados aleatoriamente\n'
              '• Puedes borrar tu historial en cualquier momento\n\n'
              'Esta app es solo para entretenimiento.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Entendido',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: ThemeService.instance.primaryColor,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
