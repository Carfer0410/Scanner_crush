import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'admob_service.dart';

// Tipos de suscripción
enum SubscriptionTier { free, premium, premiumPlus }

/// Servicio avanzado de monetización para Scanner Crush
class MonetizationService {
  static final MonetizationService _instance = MonetizationService._internal();
  static MonetizationService get instance => _instance;
  MonetizationService._internal();

  SharedPreferences? _prefs;
  
  // Límites para usuarios gratuitos - AJUSTADOS PARA MEJOR UX
  static const int _dailyFreeScans = 5; // Aumentado de 3 a 5
  static const int _freeCelebrities = 50;
  static const int _dailyFreeShares = 3;
  static const int _maxAdBonusScans = 10; // Máximo de escaneos bonus por ads
  static const int _newUserGracePeriod = 3; // Días sin límites para nuevos usuarios
  
  SubscriptionTier _currentTier = SubscriptionTier.free;
  DateTime? _subscriptionExpiry;
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSubscriptionData();
    
    // Inicializar AdMob si no es premium
    if (isFree) {
      await AdMobService.instance.initialize();
    }
  }
  
  Future<void> _loadSubscriptionData() async {
    final tierIndex = _prefs?.getInt('subscription_tier') ?? 0;
    _currentTier = SubscriptionTier.values[tierIndex];
    
    final expiryString = _prefs?.getString('subscription_expiry');
    if (expiryString != null) {
      _subscriptionExpiry = DateTime.parse(expiryString);
    }
    
    // Verificar si la suscripción expiró
    if (_subscriptionExpiry != null && DateTime.now().isAfter(_subscriptionExpiry!)) {
      _currentTier = SubscriptionTier.free;
      await _saveSubscriptionData();
    }
  }
  
  Future<void> _saveSubscriptionData() async {
    await _prefs?.setInt('subscription_tier', _currentTier.index);
    if (_subscriptionExpiry != null) {
      await _prefs?.setString('subscription_expiry', _subscriptionExpiry!.toIso8601String());
    }
  }
  
  // Getters
  SubscriptionTier get currentTier => _currentTier;
  bool get isPremium => _currentTier != SubscriptionTier.free;
  bool get isPremiumPlus => _currentTier == SubscriptionTier.premiumPlus;
  bool get isFree => _currentTier == SubscriptionTier.free;
  
  // Verificaciones de límites
  Future<bool> canScanToday() async {
    if (isPremium) return true;
    
    // Verificar período de gracia para nuevos usuarios
    if (await _isInGracePeriod()) return true;
    
    final totalScansToday = await _getTotalScansToday();
    final maxAllowed = _dailyFreeScans + await getExtraScansFromAds();
    
    return totalScansToday < maxAllowed;
  }
  
  Future<bool> _isInGracePeriod() async {
    final firstInstallDate = _prefs?.getString('first_install_date');
    if (firstInstallDate == null) {
      // Primera vez, marcar fecha de instalación
      final today = DateTime.now().toIso8601String().split('T')[0];
      await _prefs?.setString('first_install_date', today);
      return true;
    }
    
    final install = DateTime.parse(firstInstallDate);
    final daysSinceInstall = DateTime.now().difference(install).inDays;
    return daysSinceInstall < _newUserGracePeriod;
  }
  
  Future<int> _getTotalScansToday() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastScanDate = _prefs?.getString('last_scan_date');
    
    if (lastScanDate != today) {
      // Nuevo día, resetear contador
      await _prefs?.setString('last_scan_date', today);
      await _prefs?.setInt('today_scans', 0);
      return 0;
    }
    
    return _prefs?.getInt('today_scans') ?? 0;
  }
  
  Future<void> recordScan() async {
    if (isFree) {
      final todayScans = _prefs?.getInt('today_scans') ?? 0;
      await _prefs?.setInt('today_scans', todayScans + 1);
    }
  }
  
  Future<int> getRemainingScansTodayForFree() async {
    if (isPremium) return -1; // Ilimitado
    
    // Verificar período de gracia
    if (await _isInGracePeriod()) return -1; // Ilimitado durante gracia
    
    final totalScansUsed = await _getTotalScansToday();
    final baseScans = _dailyFreeScans;
    final extraScans = await getExtraScansFromAds();
    final totalAvailable = baseScans + extraScans;
    
    return (totalAvailable - totalScansUsed).clamp(0, totalAvailable);
  }
  
  Future<int> getAvailableAdBonusScans() async {
    if (isPremium) return 0;
    
    final extraScans = await getExtraScansFromAds();
    return (_maxAdBonusScans - extraScans).clamp(0, _maxAdBonusScans);
  }
  
  Future<bool> isNewUser() async {
    return await _isInGracePeriod();
  }
  
  Future<int> getGracePeriodDaysRemaining() async {
    final firstInstallDate = _prefs?.getString('first_install_date');
    if (firstInstallDate == null) return _newUserGracePeriod;
    
    final install = DateTime.parse(firstInstallDate);
    final daysSinceInstall = DateTime.now().difference(install).inDays;
    return (_newUserGracePeriod - daysSinceInstall).clamp(0, _newUserGracePeriod);
  }
  
  bool canAccessCelebrity(int celebrityIndex) {
    if (isPremium) return true;
    return celebrityIndex < _freeCelebrities;
  }
  
  bool canAccessFullHistory() {
    return isPremium;
  }
  
  Future<bool> canShareToday() async {
    if (isPremium) return true;
    
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastShareDate = _prefs?.getString('last_share_date');
    final todayShares = _prefs?.getInt('today_shares') ?? 0;
    
    if (lastShareDate != today) {
      // Nuevo día, resetear contador
      await _prefs?.setString('last_share_date', today);
      await _prefs?.setInt('today_shares', 0);
      return true;
    }
    
    return todayShares < _dailyFreeShares;
  }
  
  Future<void> recordShare() async {
    if (isFree) {
      final todayShares = _prefs?.getInt('today_shares') ?? 0;
      await _prefs?.setInt('today_shares', todayShares + 1);
    }
  }
  
  // Manejo de anuncios con recompensa
  Future<bool> watchAdForExtraScans() async {
    if (isPremium) return false;
    
    final currentExtra = await getExtraScansFromAds();
    if (currentExtra >= _maxAdBonusScans) return false; // Ya llegó al máximo
    
    // Mostrar anuncio con recompensa real
    final adShown = await AdMobService.instance.showRewardedAd(
      onUserEarnedReward: (ad, reward) async {
        // Agregar 2 escaneos adicionales por ver anuncio
        final newExtra = (currentExtra + 2).clamp(0, _maxAdBonusScans);
        await _prefs?.setInt('extra_scans_today', newExtra);
        
        // Marcar la fecha del último anuncio visto
        final today = DateTime.now().toIso8601String().split('T')[0];
        await _prefs?.setString('last_ad_date', today);
      },
    );
    
    return adShown;
  }
  
  Future<bool> showInterstitialAd() async {
    if (isPremium) return true; // Premium no ve anuncios
    
    final shouldShow = await AdMobService.instance.shouldShowInterstitialAd();
    if (!shouldShow) return true; // Cooldown activo, permitir acción
    
    return await AdMobService.instance.showInterstitialAd();
  }
  
  Future<bool> canWatchAdForScans() async {
    if (isPremium) return false; // Premium no necesita ads
    final available = await getAvailableAdBonusScans();
    return available >= 2; // Puede ver ad si puede ganar al menos 2 escaneos
  }
  
  Future<int> getExtraScansFromAds() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastAdDate = _prefs?.getString('last_ad_date');
    
    if (lastAdDate != today) {
      await _prefs?.setString('last_ad_date', today);
      await _prefs?.setInt('extra_scans_today', 0);
      return 0;
    }
    
    return _prefs?.getInt('extra_scans_today') ?? 0;
  }
  
  // Suscripciones
  Future<void> upgradeToPremium({int months = 1}) async {
    _currentTier = SubscriptionTier.premium;
    _subscriptionExpiry = DateTime.now().add(Duration(days: 30 * months));
    await _saveSubscriptionData();
  }
  
  Future<void> upgradeToPremiumPlus({int months = 1}) async {
    _currentTier = SubscriptionTier.premiumPlus;
    _subscriptionExpiry = DateTime.now().add(Duration(days: 30 * months));
    await _saveSubscriptionData();
  }
  
  // Precios
  String getPremiumPrice() => '\$2.99/mes';
  String getPremiumPlusPrice() => '\$4.99/mes';
  
  // Ofertas especiales
  bool hasActivePromotion() {
    // Lógica para promociones especiales
    final now = DateTime.now();
    // Ejemplo: Promoción de San Valentín
    if (now.month == 2 && now.day >= 10 && now.day <= 16) {
      return true;
    }
    return false;
  }
  
  String getPromotionDiscount() {
    if (hasActivePromotion()) {
      return '50% OFF';
    }
    return '';
  }
  
  // Analytics premium
  Map<String, dynamic> getPremiumAnalytics() {
    if (!isPremium) return {};
    
    return {
      'subscription_tier': _currentTier.toString(),
      'days_remaining': _subscriptionExpiry?.difference(DateTime.now()).inDays ?? 0,
      'is_premium_plus': isPremiumPlus,
    };
  }
  
  // Funciones exclusivas Premium Plus
  bool canAccessAIPredictions() => isPremiumPlus;
  bool canAccessMultipleCrushAnalysis() => isPremiumPlus;
  bool canAccessAdvancedStats() => isPremiumPlus;
  bool canAccessPersonalizedAdvice() => isPremiumPlus;
  
  /// Crear banner ad (solo para usuarios gratuitos)
  Widget? createBannerAd() {
    if (isPremium) return null;
    
    final bannerAd = AdMobService.instance.createBannerAd();
    bannerAd.load();
    
    return Container(
      width: double.infinity,
      height: 60,
      child: AdWidget(ad: bannerAd),
    );
  }
}

/// Widget para mostrar límites y promociones
class MonetizationBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final VoidCallback? onTap;
  
  const MonetizationBadge({
    Key? key,
    required this.text,
    this.color,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color ?? Colors.orange,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (color ?? Colors.orange).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
