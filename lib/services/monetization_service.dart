import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'admob_service.dart';
import 'secure_time_service.dart';

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
  
  SubscriptionTier _currentTier = SubscriptionTier.free;
  DateTime? _subscriptionExpiry;
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSubscriptionData();
    
    // Siempre inicializar AdMob (necesario para rewarded ads de temas/analytics
    // incluso si el usuario es premium, y para banners de usuarios free)
    await AdMobService.instance.initialize();
  }
  
  Future<void> _loadSubscriptionData() async {
    final tierIndex = _prefs?.getInt('subscription_tier') ?? 0;
    // Seguridad: validar que el índice esté dentro de rango
    if (tierIndex >= 0 && tierIndex < SubscriptionTier.values.length) {
      _currentTier = SubscriptionTier.values[tierIndex];
    } else {
      _currentTier = SubscriptionTier.free;
    }
    
    final expiryString = _prefs?.getString('subscription_expiry');
    if (expiryString != null) {
      _subscriptionExpiry = DateTime.tryParse(expiryString);
    }
    
    // Si tiene tier premium pero NO tiene fecha de expiración, resetear a free
    // (esto previene premium permanente por datos corruptos/residuales)
    if (_currentTier != SubscriptionTier.free && _subscriptionExpiry == null) {
      _currentTier = SubscriptionTier.free;
      await _saveSubscriptionData();
      return;
    }
    
    // Verificar si la suscripción expiró usando tiempo seguro
    if (_subscriptionExpiry != null && SecureTimeService.instance.getSecureTime().isAfter(_subscriptionExpiry!)) {
      _currentTier = SubscriptionTier.free;
      _subscriptionExpiry = null;
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
  
  bool get isPremium => _currentTier == SubscriptionTier.premium || _currentTier == SubscriptionTier.premiumPlus;
  
  /// Verificar acceso premium (async para compatibilidad con código existente)
  Future<bool> isPremiumAsync() async => isPremium;
  
  bool get isPremiumPlus => _currentTier == SubscriptionTier.premiumPlus;
  bool get isFree => _currentTier == SubscriptionTier.free;
  
  // Verificaciones de límites
  Future<bool> canScanToday() async {
    if (isPremium) return true;
    
    final totalScansToday = await _getTotalScansToday();
    final maxAllowed = _dailyFreeScans + await getExtraScansFromAds();
    
    return totalScansToday < maxAllowed;
  }
  
  
  Future<int> _getTotalScansToday() async {
    final today = SecureTimeService.instance.getSecureDate().toIso8601String().split('T')[0];
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
    if (!isPremium) {
      final todayScans = _prefs?.getInt('today_scans') ?? 0;
      await _prefs?.setInt('today_scans', todayScans + 1);
    }
  }
  
  Future<int> getRemainingScansTodayForFree() async {
    if (isPremium) return -1; // Ilimitado
    
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
  

  
  bool canAccessCelebrity(int celebrityIndex) {
    // Para acceso inmediato (sync), verificamos solo premium real
    // Las pantallas deberían usar canAccessCelebrityAsync() para verificar período de gracia
    if (_currentTier == SubscriptionTier.premium || _currentTier == SubscriptionTier.premiumPlus) {
      return true;
    }
    return celebrityIndex < _freeCelebrities;
  }
  
  /// Verificar acceso a celebridad (async)
  Future<bool> canAccessCelebrityAsync(int celebrityIndex) async {
    if (isPremium) return true;
    return celebrityIndex < _freeCelebrities;
  }
  
  Future<bool> canAccessFullHistory() async => isPremium;
  
  Future<bool> canShareToday() async {
    if (isPremium) return true;
    
    final today = SecureTimeService.instance.getSecureDate().toIso8601String().split('T')[0];
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
    if (!isPremium) {
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
        
        // Marcar la fecha del último anuncio visto usando tiempo seguro
        final today = SecureTimeService.instance.getSecureDate().toIso8601String().split('T')[0];
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
    return available >= 1; // Puede ver ad si puede ganar al menos 1 escaneo
  }
  
  Future<int> getExtraScansFromAds() async {
    final today = SecureTimeService.instance.getSecureDate().toIso8601String().split('T')[0];
    final lastAdDate = _prefs?.getString('last_ad_date');
    
    if (lastAdDate != today) {
      await _prefs?.setString('last_ad_date', today);
      await _prefs?.setInt('extra_scans_today', 0);
      return 0;
    }
    
    return _prefs?.getInt('extra_scans_today') ?? 0;
  }
  
  // Suscripciones usando tiempo seguro
  Future<void> upgradeToPremium({int months = 1}) async {
    _currentTier = SubscriptionTier.premium;
    _subscriptionExpiry = SecureTimeService.instance.getSecureTime().add(Duration(days: 30 * months));
    await _saveSubscriptionData();
  }
  
  Future<void> upgradeToPremiumPlus({int months = 1}) async {
    _currentTier = SubscriptionTier.premiumPlus;
    _subscriptionExpiry = SecureTimeService.instance.getSecureTime().add(Duration(days: 30 * months));
    await _saveSubscriptionData();
  }
  
  // Precios
  String getPremiumPrice() => '\$2.99/mes';
  String getPremiumPlusPrice() => '\$4.99/mes';
  
  // Ofertas especiales
  bool hasActivePromotion() {
    // Lógica para promociones especiales
    final now = SecureTimeService.instance.getSecureTime();
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
      'days_remaining': _subscriptionExpiry?.difference(SecureTimeService.instance.getSecureTime()).inDays ?? 0,
      'is_premium_plus': isPremiumPlus,
    };
  }
  
  // Funciones exclusivas Premium Plus
  Future<bool> canAccessAIPredictions() async => 
    _currentTier == SubscriptionTier.premiumPlus;
  Future<bool> canAccessMultipleCrushAnalysis() async => 
    _currentTier == SubscriptionTier.premiumPlus;
  Future<bool> canAccessAdvancedStats() async => 
    _currentTier == SubscriptionTier.premiumPlus;
  Future<bool> canAccessPersonalizedAdvice() async => 
    _currentTier == SubscriptionTier.premiumPlus;
  
  /// Crear banner ad (solo para usuarios gratuitos)
  Widget? createBannerAd() {
    // Para banner, verificamos premium síncrono (sin período de gracia para mantener simplicidad)
    if (_currentTier == SubscriptionTier.premium || _currentTier == SubscriptionTier.premiumPlus) {
      return null;
    }
    
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
