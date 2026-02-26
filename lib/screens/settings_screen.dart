import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/background_animation_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../models/app_theme.dart';
import '../services/audio_service.dart';
import '../services/locale_service.dart';
import '../services/daily_love_service.dart';
import '../services/streak_service.dart';
import '../services/monetization_service.dart';
import '../services/admob_service.dart';
import '../services/crush_service.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';
import 'premium_screen.dart';
import 'history_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  bool _showBackgroundAnimation = true;
  late final VoidCallback _backgroundListener;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadBackgroundPref();
    // Listen for global changes
    _backgroundListener = () {
      if (mounted) setState(() {
        _showBackgroundAnimation = BackgroundAnimationService.instance.enabled.value;
      });
    };
    BackgroundAnimationService.instance.enabled.addListener(_backgroundListener);
  }

  Future<void> _loadBackgroundPref() async {
    try {
      // Ensure service has loaded value; read from service
      _showBackgroundAnimation = BackgroundAnimationService.instance.enabled.value;
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _toggleBackgroundAnimation(bool value) async {
    await BackgroundAnimationService.instance.setEnabled(value);
  }

  @override
  void dispose() {
    try {
      BackgroundAnimationService.instance.enabled.removeListener(_backgroundListener);
    } catch (_) {}
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() async {
    // Solo cargar banner ads para usuarios no premium
    if (!await MonetizationService.instance.isPremiumAsync()) {
      _bannerAd = AdMobService.instance.createBannerAd();
      _bannerAd?.load().then((_) {
        if (mounted) {
          setState(() {
            _isBannerAdReady = true;
          });
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        showHearts: _showBackgroundAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: ThemeService.instance.cardColor.withOpacity(0.74),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: ThemeService.instance.borderColor.withOpacity(0.9),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: ThemeService.instance.textColor,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.settings,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ThemeService.instance.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 42),
                    ],
                  ),
                ),
              ),

              // Banner Ad for non-premium users
              FutureBuilder<bool>(
                future: MonetizationService.instance.isPremiumAsync(),
                builder: (context, snapshot) {
                  final isPremium = snapshot.data ?? false;
                  if (_bannerAd != null && _isBannerAdReady && !isPremium) {
                    return Container(
                      alignment: Alignment.center,
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: AdWidget(ad: _bannerAd!),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const SizedBox(height: 20),

                    // Premium status card
                    FutureBuilder<bool>(
                      future: MonetizationService.instance.isPremiumAsync(),
                      builder: (context, snapshot) {
                        final isPremium = snapshot.data ?? false;
                        if (isPremium) {
                          return _buildPremiumCard();
                        } else {
                          return _buildUpgradeCard();
                        }
                      },
                    ),

                    const SizedBox(height: 30),

                    // Settings sections
                    _buildSettingsSection(
                      title: AppLocalizations.of(context)!.sectionGeneral,
                      items: [
                        _buildSettingsItem(
                          icon: Icons.history,
                          title: AppLocalizations.of(context)!.history,
                          subtitle: AppLocalizations.of(context)!.settingsHistorySubtitle,
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
                          title:
                              ThemeService.instance.isDarkMode
                                  ? (AppLocalizations.of(context)?.darkMode ??
                                          'Modo Oscuro')
                                      .replaceAll('Mode', 'Theme')
                                      .replaceAll('Modo', 'Tema')
                                  : (AppLocalizations.of(context)?.darkMode ??
                                          'Modo Oscuro')
                                      .replaceAll('Dark', 'Light')
                                      .replaceAll('Mode', 'Theme')
                                      .replaceAll('Modo Oscuro', 'Tema Claro')
                                      .replaceAll('Oscuro', 'Claro'),
                          subtitle: AppLocalizations.of(context)!.changeThemeSubtitle,
                          onTap: () => _toggleTheme(),
                        ),
                        _buildSettingsItem(
                          icon: Icons.blur_on,
                          title: AppLocalizations.of(context)!.backgroundAnimationTitle,
                          subtitle: AppLocalizations.of(context)!.backgroundAnimationSubtitle,
                          onTap: () => _toggleBackgroundAnimation(!_showBackgroundAnimation),
                          trailing: Switch(
                            value: _showBackgroundAnimation,
                            onChanged: (value) => _toggleBackgroundAnimation(value),
                            activeColor: ThemeService.instance.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 🎵 NUEVA SECCIÓN DE AUDIO
                    _buildSettingsSection(
                      title: AppLocalizations.of(context)!.sectionAudio,
                      items: [
                        _buildSettingsItem(
                          icon:
                              AudioService.instance.soundEnabled
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                          title: AppLocalizations.of(context)!.soundEffects,
                          subtitle:
                              AppLocalizations.of(
                                context,
                              )!.soundEffectsSubtitle,
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
                          subtitle:
                              AppLocalizations.of(
                                context,
                              )!.backgroundMusicSubtitle,
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

                        FutureBuilder<bool>(
                          future: MonetizationService.instance.isPremiumAsync(),
                          builder: (context, snapshot) {
                            final isPremium = snapshot.data ?? false;
                            return _buildSettingsSection(
                              title: AppLocalizations.of(context)?.premium ?? 'Premium',
                              items: [
                                if (!isPremium)
                                  _buildSettingsItem(
                                    icon: Icons.star,
                                    title:
                                        AppLocalizations.of(context)?.upgradeSettings ??
                                        AppLocalizations.of(context)?.upgradeSettings ?? 'Actualizar a Premium',
                                    subtitle:
                                        AppLocalizations.of(
                                          context,
                                        )?.unlockAllFeaturesSettings ??
                                        AppLocalizations.of(context)?.unlockAllFeaturesSettings ?? 'Desbloquea todas las funciones',
                                    onTap: () => _navigateToPremium(),
                                    trailing: null,
                                  ),
                              ],
                            );
                          },
                        ),                    const SizedBox(height: 30),

                    // Data section
                    _buildSettingsSection(
                      title: AppLocalizations.of(context)!.sectionData,
                      items: [
                        _buildSettingsItem(
                          icon: Icons.delete_forever,
                          title: AppLocalizations.of(context)!.clearAllData,
                          subtitle: AppLocalizations.of(context)!.clearAllDataSubtitle,
                          onTap: () => _showClearDataDialog(),
                          trailing: Icon(
                            Icons.warning,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    _buildSettingsSection(
                      title: AppLocalizations.of(context)!.support,
                      items: [
                        _buildSettingsItem(
                          icon: Icons.help_outline,
                          title: AppLocalizations.of(context)!.helpAndQuestions,
                          subtitle: AppLocalizations.of(context)!.getHelpOnApp,
                          onTap: () => _showHelpDialog(),
                        ),
                        _buildSettingsItem(
                          icon: Icons.info_outline,
                          title: AppLocalizations.of(context)!.about,
                          subtitle: AppLocalizations.of(context)!.aboutSubtitle,
                          onTap: () => _showAboutDialog(),
                        ),
                        _buildSettingsItem(
                          icon: Icons.privacy_tip_outlined,
                          title: AppLocalizations.of(context)!.privacyTitle,
                          subtitle: AppLocalizations.of(context)!.privacySubtitle,
                          onTap: () => _showPrivacyDialog(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // App version
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.appVersionFooter,
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
        gradient: LinearGradient(colors: [ThemeService.instance.primaryColor, ThemeService.instance.secondaryColor]),
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
          Icon(Icons.stars, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.youArePremium,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.enjoyAllFeatures,
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
    return FutureBuilder<int>(
            future: MonetizationService.instance.getRemainingScansTodayForFree(),
            builder: (context, snapshot) {
              final remainingScans = snapshot.data ?? 0;
              final baseScans = 5; // _dailyFreeScans del MonetizationService
              
              return FutureBuilder<int>(
                future: MonetizationService.instance.getExtraScansFromAds(),
                builder: (context, adSnapshot) {
                  final extraScans = adSnapshot.data ?? 0;
                  return FutureBuilder<int>(
                    future: MonetizationService.instance.getExtraScansFromCoins(),
                    builder: (context, coinSnapshot) {
                      final coinScans = coinSnapshot.data ?? 0;
                      final totalFreeScans = baseScans + extraScans + coinScans;
                      // Calcular los escaneos utilizados hoy
                      final scansUsedToday =
                          (totalFreeScans - remainingScans).clamp(0, totalFreeScans);

              return GestureDetector(
                onTap: () => _navigateToPremium(),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ThemeService.instance.primaryColor.withOpacity(0.9),
                        ThemeService.instance.secondaryColor.withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.diamond, color: Colors.amber, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)?.upgradeToPremium ?? '✨ Upgrade to Premium',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)?.unlockFullPotential ?? 'Unlock the full potential of love!',
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
                      
                      const SizedBox(height: 20),
                      
                      // Scan counter for free users
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.red[300], size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.scansToday(scansUsedToday, totalFreeScans),
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    remainingScans > 0
                                      ? AppLocalizations.of(context)!.scansRemaining(remainingScans)
                                      : AppLocalizations.of(context)!.noScansLeft,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Premium benefits
                      Text(
                        AppLocalizations.of(context)!.premiumBenefits,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ).animate().scale(delay: 200.ms);
                    },
                  );
                },
              );
            },
          );
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
        trailing:
            trailing ??
            Icon(
              Icons.arrow_forward_ios,
              color: ThemeService.instance.subtitleColor,
              size: 16,
            ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

  String _normalizeDialogText(String value) {
    return value.replaceAll(r'\n', '\n').replaceAll('/n', '\n');
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) {
        final isLavender = ThemeService.instance.currentTheme == ThemeType.lavender;
        final textColor = isLavender ? Colors.white : ThemeService.instance.textColor;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            AppLocalizations.of(context)!.language,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: textColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇪🇸'),
                title: Text(
                  AppLocalizations.of(context)!.spanish,
                  style: TextStyle(color: textColor),
                ),
                trailing: LocaleService.instance.currentLocale.languageCode == 'es'
                    ? Icon(
                        Icons.check,
                        color: ThemeService.instance.primaryColor,
                      )
                    : null,
                onTap: () {
                  LocaleService.instance.setLocale('es');
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Text('🇺🇸'),
                title: Text(
                  AppLocalizations.of(context)!.english,
                  style: TextStyle(color: textColor),
                ),
                trailing: LocaleService.instance.currentLocale.languageCode == 'en'
                    ? Icon(
                        Icons.check,
                        color: ThemeService.instance.primaryColor,
                      )
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
        );
      },
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
            backgroundColor: ThemeService.instance.cardColor,
            title: Text(
              AppLocalizations.of(context)!.helpDialogTitle,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: ThemeService.instance.textColor,
              ),
            ),
            content: Text(
              _normalizeDialogText(AppLocalizations.of(context)!.helpDialogContent),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: ThemeService.instance.textColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)!.understood,
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
            backgroundColor: ThemeService.instance.cardColor,
            title: Text(
              AppLocalizations.of(context)!.aboutDialogTitle,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: ThemeService.instance.textColor,
              ),
            ),
            content: Text(
              _normalizeDialogText(AppLocalizations.of(context)!.aboutDialogContent),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: ThemeService.instance.textColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)!.close,
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
            backgroundColor: ThemeService.instance.cardColor,
            title: Text(
              AppLocalizations.of(context)!.privacyDialogTitle,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: ThemeService.instance.textColor,
              ),
            ),
            content: Text(
              _normalizeDialogText(AppLocalizations.of(context)!.privacyDialogContent),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: ThemeService.instance.textColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)!.understood,
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

  // Method to show clear data confirmation dialog
  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context)!.confirmClearDataTitle,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeService.instance.textColor,
              ),
            ),
            content: Text(
              AppLocalizations.of(context)!.confirmClearDataContent,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: ThemeService.instance.textColor.withOpacity(0.7),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _clearAllData(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                ),
                child: Text(
                  AppLocalizations.of(context)!.deleteAll,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // Method to clear all user data
  Future<void> _clearAllData() async {
    try {
      // Close dialog first
      Navigator.pop(context);

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Clear SharedPreferences data
      final prefs = await SharedPreferences.getInstance();

      // Keys to clear (based on all services)
      final keysToRemove = [
        // Streak service keys
        'love_streak',
        'last_used_date',
        'total_scans',
        'best_streak',

        // Daily love service keys
        'total_compatibility', // Agregado para limpiar estadísticas de compatibilidad

        // History keys (assuming they follow a pattern)
        'crush_history',
        'scan_history',

        // Any other statistics keys
        'total_compatibility_scans',
        'total_celebrity_scans',
        'favorite_crush',
        'highest_compatibility',
        'last_scan_date',
      ];

      // Remove all specified keys
      for (String key in keysToRemove) {
        await prefs.remove(key);
      }

      // Also remove any keys that start with common prefixes
      final allKeys = prefs.getKeys();
      final keysToRemoveByPrefix =
          allKeys
              .where(
                (key) =>
                    key.startsWith('scan_') ||
                    key.startsWith('crush_') ||
                    key.startsWith('history_') ||
                    key.startsWith('stat_'),
              )
              .toList();

      for (String key in keysToRemoveByPrefix) {
        await prefs.remove(key);
      }

      // Clear crush history using the dedicated service method
      await CrushService.instance.clearAllHistory();

      // Reinitialize services to reflect the cleared data
      await DailyLoveService.instance.initialize();
      await StreakService.instance
          .resetAllData(); // Usar resetAllData() que incluye notifyListeners()

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.dataDeletedSuccess,
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorDeletingData(e.toString()),
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }
}



