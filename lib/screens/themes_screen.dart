import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/theme_service.dart';
import '../services/monetization_service.dart';
import '../services/premium_theme_service.dart';
import '../services/audio_service.dart';
import '../services/admob_service.dart';
import '../models/app_theme.dart';
import 'premium_screen.dart';

class ThemesScreen extends StatefulWidget {
  const ThemesScreen({super.key});

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    _loadBannerAd();
  }

  void _loadBannerAd() async {
    // Cargar banner solo para usuarios no premium (incluyendo período de gracia)
    if (!await MonetizationService.instance.isPremiumWithGrace()) {
      _bannerAd = AdMobService.instance.createBannerAd();
      _bannerAd!.load();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  String _getThemeName(BuildContext context, ThemeType themeType) {
    switch (themeType) {
      case ThemeType.classic:
        return AppLocalizations.of(context)?.classicThemeName ?? '💘 Clásico';
      case ThemeType.sunset:
        return AppLocalizations.of(context)?.sunsetThemeName ?? '� Aurora Pastel';
      case ThemeType.ocean:
        return AppLocalizations.of(context)?.oceanThemeName ?? '🌊 Océano';
      case ThemeType.forest:
        return AppLocalizations.of(context)?.forestThemeName ?? '🌲 Bosque';
      case ThemeType.lavender:
        return AppLocalizations.of(context)?.lavenderThemeName ?? '💜 Lavanda';
      case ThemeType.cosmic:
        return AppLocalizations.of(context)?.cosmicThemeName ?? '🌌 Cósmico';
      case ThemeType.cherry:
        return AppLocalizations.of(context)?.cherryThemeName ?? '🌸 Cerezo';
      case ThemeType.golden:
        return AppLocalizations.of(context)?.goldenThemeName ?? '✨ Dorado';
    }
  }

  String _getThemeDescription(BuildContext context, ThemeType themeType) {
    switch (themeType) {
      case ThemeType.classic:
        return AppLocalizations.of(context)?.classicThemeDescription ?? 'El tema original de amor';
      case ThemeType.sunset:
        return AppLocalizations.of(context)?.sunsetThemeDescription ?? 'Degradé moderno de violeta, rosa y azul';
      case ThemeType.ocean:
        return AppLocalizations.of(context)?.oceanThemeDescription ?? 'Profundos azules marinos';
      case ThemeType.forest:
        return AppLocalizations.of(context)?.forestThemeDescription ?? 'Verdes naturales y frescos';
      case ThemeType.lavender:
        return AppLocalizations.of(context)?.lavenderThemeDescription ?? 'Elegantes púrpuras y violetas';
      case ThemeType.cosmic:
        return AppLocalizations.of(context)?.cosmicThemeDescription ?? 'Misterioso espacio profundo';
      case ThemeType.cherry:
        return AppLocalizations.of(context)?.cherryThemeDescription ?? 'Elegante rosa sakura japonés';
      case ThemeType.golden:
        return AppLocalizations.of(context)?.goldenThemeDescription ?? 'Lujo y elegancia dorada';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: ThemeService.instance.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Themes Grid
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildThemesGrid(),
                ),
              ),
              
              // Banner ad para usuarios no premium (incluyendo período de gracia)
              FutureBuilder<bool>(
                future: MonetizationService.instance.isPremiumWithGrace(),
                builder: (context, snapshot) {
                  final isPremiumWithGrace = snapshot.data ?? false;
                  if (_bannerAd != null && !isPremiumWithGrace) {
                    return Container(
                      width: double.infinity,
                      height: 60,
                      margin: const EdgeInsets.only(top: 8),
                      child: AdWidget(ad: _bannerAd!),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  AudioService.instance.playButtonTap();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ThemeService.instance.cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: ThemeService.instance.cardShadow,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: ThemeService.instance.iconColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.themesTitle ?? '🎨 Temas Premium',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ThemeService.instance.textColor,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)?.customizeExperience ?? 'Personaliza tu experiencia',
                      style: TextStyle(
                        fontSize: 16,
                        color: ThemeService.instance.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Current theme indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeService.instance.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: ThemeService.instance.cardShadow,
            ),
            child: Row(
              children: [
                Icon(
                  ThemeService.instance.currentAppTheme.icon,
                  color: ThemeService.instance.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.currentTheme ?? 'Tema Actual',
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeService.instance.subtitleColor,
                        ),
                      ),
                      Text(
                        _getThemeName(context, ThemeService.instance.currentAppTheme.type),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: ThemeService.instance.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesGrid() {
    return ValueListenableBuilder<int>(
      valueListenable: PremiumThemeService.instance.tempAccessNotifier,
      builder: (context, _, __) {
        return ValueListenableBuilder<String>(
          valueListenable: ThemeService.instance.themeNotifier,
          builder: (context, currentTheme, _) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: AppTheme.availableThemes.length,
              itemBuilder: (context, index) {
                final theme = AppTheme.availableThemes[index];
                final isSelected = theme.type.name == currentTheme;
                final hasTemporaryAccess = PremiumThemeService.instance.hasTemporaryAccessToTheme(theme.type.name);
                return FutureBuilder<bool>(
                  future: MonetizationService.instance.isPremiumWithGrace(),
                  builder: (context, snapshot) {
                    final isPremiumWithGrace = snapshot.data ?? false;
                    // Permitir seleccionar el tema premium si tiene acceso temporal válido
                    final canUse = !theme.isPremium || isPremiumWithGrace || hasTemporaryAccess;
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200 + (index * 100)),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: _buildThemeCard(theme, isSelected, canUse, hasTemporaryAccess),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildThemeCard(AppTheme theme, bool isSelected, bool canUse, bool hasTemporaryAccess) {
    return GestureDetector(
      onTap: () => _onThemeSelected(theme, canUse, hasTemporaryAccess),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeService.instance.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected 
            ? [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : ThemeService.instance.cardShadow,
          border: isSelected 
            ? Border.all(
                color: theme.primaryColor,
                width: 2,
              )
            : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // Theme preview
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: theme.backgroundGradient,
                ),
                child: Stack(
                  children: [
                    // Preview elements
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              theme.icon,
                              color: theme.primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Preview',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Preview button
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    
                    // Premium indicator
                    if (theme.isPremium)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'PREMIUM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                    // Selected indicator
                    if (isSelected)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check,
                            color: theme.primaryColor,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Theme info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getThemeName(context, theme.type),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeService.instance.textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getThemeDescription(context, theme.type),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ThemeService.instance.subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Action button
                        if (!canUse)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (!isSelected)
                          Icon(
                            Icons.radio_button_unchecked,
                            color: ThemeService.instance.subtitleColor,
                          )
                        else
                          Icon(
                            Icons.check_circle,
                            color: theme.primaryColor,
                          ),
                      ],
                    ),
                    
                    // Color palette preview
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildColorDot(theme.primaryColor),
                        const SizedBox(width: 8),
                        _buildColorDot(theme.secondaryColor),
                        const SizedBox(width: 8),
                        _buildColorDot(theme.accentColor),
                        const Spacer(),
                        if (isSelected)
                          Text(
                            AppLocalizations.of(context)?.active ?? 'ACTIVO',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
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

  Widget _buildColorDot(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  void _onThemeSelected(AppTheme theme, bool canUse, bool hasTemporaryAccess) async {
    AudioService.instance.playButtonTap();
    
    final isPremiumWithGrace = await MonetizationService.instance.isPremiumWithGrace();

    // Permitir seleccionar el tema premium si tiene acceso temporal válido
    final hasTempAccess = PremiumThemeService.instance.hasTemporaryAccessToTheme(theme.type.name);
    final canSelect = !theme.isPremium || isPremiumWithGrace || hasTempAccess;

    if (!canSelect) {
      // Si es un tema premium y no tiene acceso, mostrar opción de ver anuncio
      if (theme.isPremium && !isPremiumWithGrace) {
        _showPremiumOrAdOptions(theme);
      } else {
        _showPremiumRequired();
      }
      return;
    }

    if (theme.type.name != ThemeService.instance.themeNotifier.value) {
      // Cambio inmediato de tema y UI reactiva
      ThemeService.instance.changeTheme(theme.type);
      setState(() {}); // Refresca la pantalla para el check

      // Tracking de acción del usuario para anuncios inteligentes
      await AdMobService.instance.trackUserAction();

      // Mostrar intersticial ocasionalmente para usuarios no premium (sin período de gracia)
      if (!isPremiumWithGrace && !hasTempAccess) {
        final shouldShow = await AdMobService.instance.shouldShowInterstitialAd();
        if (shouldShow) {
          await MonetizationService.instance.showInterstitialAd();
        }
      }

      // Show success message después del cambio visual
      String message = 'Tema ${_getThemeName(context, theme.type)} aplicado';
      if (hasTempAccess && theme.isPremium) {
        final hoursRemaining = PremiumThemeService.instance.getTemporaryHoursRemainingForTheme(theme.type.name);
        message += ' (Acceso temporal: ${hoursRemaining}h restantes)';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: theme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showPremiumOrAdOptions(AppTheme theme) {
    bool isProcessing = false;
    void refreshParent() => setState(() {});
    bool hasTempAccess = PremiumThemeService.instance.hasTemporaryAccessToTheme(theme.type.name);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: ThemeService.instance.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '🎨 Tema Premium',
            style: TextStyle(
              color: ThemeService.instance.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Este tema requiere acceso premium. Puedes:',
                style: TextStyle(
                  color: ThemeService.instance.subtitleColor,
                ),
              ),
              const SizedBox(height: 16),
              // Opción 1: Ver anuncio para acceso temporal
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.tv, color: Colors.orange, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      '📺 Ver Anuncio',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      PremiumThemeService.instance.hasTemporaryAccessToTheme(theme.type.name)
                          ? 'Ya tienes acceso temporal activo a este tema.'
                          : 'Acceso por 24 horas SOLO a este tema',
                      style: TextStyle(
                        color: ThemeService.instance.subtitleColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Opción 2: Comprar premium
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeService.instance.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeService.instance.primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.star, color: ThemeService.instance.primaryColor, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      '⭐ Premium',
                      style: TextStyle(
                        color: ThemeService.instance.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Acceso permanente',
                      style: TextStyle(
                        color: ThemeService.instance.subtitleColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: ThemeService.instance.subtitleColor,
                ),
              ),
            ),
            TextButton(
              onPressed: PremiumThemeService.instance.hasTemporaryAccessToTheme(theme.type.name) || isProcessing
                  ? null
                  : () async {
                      setStateDialog(() => isProcessing = true);
                      final adShown = await AdMobService.instance.showRewardedAd(
                        onUserEarnedReward: (ad, reward) async {
                          if (!PremiumThemeService.instance.hasTemporaryAccessToTheme(theme.type.name)) {
                            await PremiumThemeService.instance.grantTemporaryAccessToTheme(theme.type.name);
                          }
                        },
                      );
                      setStateDialog(() => isProcessing = false);
                      if (adShown) {
                        Navigator.pop(context);
                        refreshParent(); // Refresca la lista de temas inmediatamente
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('¡Acceso temporal a este tema otorgado por 24 horas! 🎉'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
              child: Text(
                '📺 Ver Anuncio',
                style: TextStyle(color: Colors.orange),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeService.instance.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('⭐ Premium'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeService.instance.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          AppLocalizations.of(context)?.premiumRequired ?? '✨ Premium Requerido',
          style: TextStyle(
            color: ThemeService.instance.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)?.premiumRequiredMessage ?? 'Este tema está disponible solo para usuarios Premium. ¡Desbloquea todos los temas y más funciones!',
          style: TextStyle(
            color: ThemeService.instance.subtitleColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)?.cancel ?? 'Cancelar',
              style: TextStyle(
                color: ThemeService.instance.subtitleColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PremiumScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeService.instance.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(AppLocalizations.of(context)?.viewPremium ?? 'Ver Premium'),
          ),
        ],
      ),
    );
  }
}
