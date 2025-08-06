import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/ad_service.dart';
import '../services/audio_service.dart';
import '../services/locale_service.dart';
import '../generated/l10n/app_localizations.dart';
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
                      AppLocalizations.of(context)!.settings,
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
                          title: AppLocalizations.of(context)!.history,
                          subtitle: AppLocalizations.of(context)?.crushHistoryDescription ?? 'Ver todos tus escaneos anteriores',
                          onTap: () => _navigateToHistory(),
                        ),
                        _buildSettingsItem(
                          icon: Icons.language,
                          title: AppLocalizations.of(context)!.language,
                          subtitle: _getCurrentLanguageName(),
                          onTap: () => _showLanguageSelector(),
                        ),
                        _buildSettingsItem(
                          icon:
                              ThemeService.instance.isDarkMode
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                          title: ThemeService.instance.isDarkMode 
                              ? (AppLocalizations.of(context)?.darkMode ?? 'Modo Oscuro').replaceAll('Mode', 'Theme').replaceAll('Modo', 'Tema')
                              : (AppLocalizations.of(context)?.darkMode ?? 'Modo Oscuro').replaceAll('Dark', 'Light').replaceAll('Mode', 'Theme').replaceAll('Modo Oscuro', 'Tema Claro').replaceAll('Oscuro', 'Claro'),
                          subtitle: AppLocalizations.of(context)?.specialThemesDescription ?? 'Cambiar el tema de la aplicación',
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
                          title: AppLocalizations.of(context)!.soundEffects,
                          subtitle: AppLocalizations.of(context)!.soundEffectsSubtitle,
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
                          title: AppLocalizations.of(context)!.backgroundMusic,
                          subtitle: AppLocalizations.of(context)!.backgroundMusicSubtitle,
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
                      title: AppLocalizations.of(context)?.premium ?? 'Premium',
                      items: [
                        if (!AdService.instance.isPremiumUser)
                          _buildSettingsItem(
                            icon: Icons.star,
                            title: AppLocalizations.of(context)?.upgradeSettings ?? 'Actualizar a Premium',
                            subtitle: AppLocalizations.of(context)?.unlockAllFeaturesSettings ?? 'Desbloquea todas las funciones',
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
                      title: (LocaleService.instance.currentLocale.languageCode == 'en') ? 'Support' : 'Soporte',
                      items: [
                        _buildSettingsItem(
                          icon: Icons.help_outline,
                          title: (LocaleService.instance.currentLocale.languageCode == 'en') ? 'Help & Questions' : 'Ayuda y Preguntas',
                          subtitle: (LocaleService.instance.currentLocale.languageCode == 'en') ? 'Get help on how to use the app' : 'Obtén ayuda sobre cómo usar la app',
                          onTap: () => _showHelpDialog(),
                        ),
                        _buildSettingsItem(
                          icon: Icons.info_outline,
                          title: (LocaleService.instance.currentLocale.languageCode == 'en') ? 'About' : 'Acerca de',
                          subtitle: (LocaleService.instance.currentLocale.languageCode == 'en') ? 'Information about the application' : 'Información sobre la aplicación',
                          onTap: () => _showAboutDialog(),
                        ),
                        _buildSettingsItem(
                          icon: Icons.privacy_tip_outlined,
                          title: (LocaleService.instance.currentLocale.languageCode == 'en') ? 'Privacy' : 'Privacidad',
                          subtitle: (LocaleService.instance.currentLocale.languageCode == 'en') ? 'Privacy policy and terms' : 'Política de privacidad y términos',
                          onTap: () => _showPrivacyDialog(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // App version
                    Center(
                      child: Text(
                        (LocaleService.instance.currentLocale.languageCode == 'en') 
                          ? 'Crush Scanner v1.0.0\nMade with 💕 for love'
                          : 'Escáner de Crush v1.0.0\nHecho con 💕 para el amor',
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
            gradient: ThemeService.instance.cardGradient,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: ThemeService.instance.borderColor,
              width: 1,
            ),
            boxShadow: ThemeService.instance.cardShadow,
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
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ThemeService.instance.borderColor.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                ThemeService.instance.primaryColor.withOpacity(0.1),
                ThemeService.instance.secondaryColor.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: ThemeService.instance.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: ThemeService.instance.primaryColor,
            size: 22,
          ),
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
            color: ThemeService.instance.subtitleColor,
            height: 1.3,
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios,
              color: ThemeService.instance.subtitleColor,
              size: 16,
            ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
      ),
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

  String _getCurrentLanguageName() {
    switch (LocaleService.instance.currentLocale.languageCode) {
      case 'es':
        return AppLocalizations.of(context)!.spanish;
      case 'en':
        return AppLocalizations.of(context)!.english;
      default:
        return AppLocalizations.of(context)!.spanish;
    }
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          AppLocalizations.of(context)!.language,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇪🇸'),
              title: Text(AppLocalizations.of(context)!.spanish),
              trailing: LocaleService.instance.currentLocale.languageCode == 'es'
                  ? Icon(Icons.check, color: ThemeService.instance.primaryColor)
                  : null,
              onTap: () {
                LocaleService.instance.setLocale('es');
                Navigator.pop(context);
                setState(() {});
              },
            ),
            ListTile(
              leading: const Text('🇺🇸'),
              title: Text(AppLocalizations.of(context)!.english),
              trailing: LocaleService.instance.currentLocale.languageCode == 'en'
                  ? Icon(Icons.check, color: ThemeService.instance.primaryColor)
                  : null,
              onTap: () {
                LocaleService.instance.setLocale('en');
                Navigator.pop(context);
                setState(() {});
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              (LocaleService.instance.currentLocale.languageCode == 'en') ? '💕 Help' : '💕 Ayuda',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              (LocaleService.instance.currentLocale.languageCode == 'en') 
                ? 'Crush Scanner is a fun app that calculates compatibility between two people based on their names.\n\n'
                  '• Enter your name and your crush\'s name\n'
                  '• Press "Scan Love"\n'
                  '• Discover your compatibility\n'
                  '• Share the result\n\n'
                  'It\'s just for fun! 😄'
                : 'Escáner de Crush es una app divertida que calcula la compatibilidad entre dos personas basándose en sus nombres.\n\n'
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
                  (LocaleService.instance.currentLocale.languageCode == 'en') ? 'Got it' : 'Entendido',
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
              (LocaleService.instance.currentLocale.languageCode == 'en') ? '💘 About' : '💘 Acerca de',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              (LocaleService.instance.currentLocale.languageCode == 'en') 
                ? 'Crush Scanner v1.0.0\n\n'
                  'A fun app to discover love compatibility.\n\n'
                  'Developed with Flutter and lots of love 💕\n\n'
                  '© 2025 Crush Scanner'
                : 'Escáner de Crush v1.0.0\n\n'
                  'Una aplicación divertida para descubrir la compatibilidad amorosa.\n\n'
                  'Desarrollada con Flutter y mucho amor 💕\n\n'
                  '© 2024 Escáner de Crush',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  (LocaleService.instance.currentLocale.languageCode == 'en') ? 'Close' : 'Cerrar',
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
              (LocaleService.instance.currentLocale.languageCode == 'en') ? '🔒 Privacy' : '🔒 Privacidad',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              (LocaleService.instance.currentLocale.languageCode == 'en')
                ? 'Your privacy is important to us.\n\n'
                  '• Names are stored only locally\n'
                  '• We don\'t share personal information\n'
                  '• Results are generated randomly\n'
                  '• You can delete your history anytime\n\n'
                  'This app is for entertainment only.'
                : 'Tu privacidad es importante para nosotros.\n\n'
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
                  (LocaleService.instance.currentLocale.languageCode == 'en') ? 'Got it' : 'Entendido',
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
