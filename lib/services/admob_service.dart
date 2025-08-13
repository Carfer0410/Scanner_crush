import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio avanzado de AdMob para Scanner Crush
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  static AdMobService get instance => _instance;
  AdMobService._internal();

  SharedPreferences? _prefs;
  
  // IDs de PRUEBA - SEGUROS para desarrollo y testing
  // CAMBIAR a IDs reales SOLO después de publicar la app en Play Store
  // REALES para cuando publiques: Banner=ca-app-pub-6436417991123423/1992572008, Interstitial=ca-app-pub-6436417991123423/1801000311, Rewarded=ca-app-pub-6436417991123423/1900222602
  static const String _androidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID - SEGURO
  static const String _iosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716'; // Test ID - SEGURO
  static const String _androidInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID - SEGURO
  static const String _iosInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910'; // Test ID - SEGURO
  static const String _androidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID - SEGURO
  static const String _iosRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313'; // Test ID - SEGURO

  // Estado de anuncios
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;
  bool _isInitialized = false;

  // Getters para IDs de anuncios
  String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return _androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return _iosBannerAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _androidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return _iosInterstitialAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      return _androidRewardedAdUnitId;
    } else if (Platform.isIOS) {
      return _iosRewardedAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Inicializar AdMob
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Inicializar Mobile Ads SDK
      await MobileAds.instance.initialize();
      
      // Precargar anuncios
      await _loadInterstitialAd();
      await _loadRewardedAd();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('✅ AdMob initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing AdMob: $e');
      }
    }
  }

  /// Crear Banner Ad
  BannerAd createBannerAd() {
    _bannerAd?.dispose();
    
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('✅ Banner ad loaded');
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print('❌ Banner ad failed to load: $error');
          }
          ad.dispose();
        },
        onAdOpened: (ad) {
          if (kDebugMode) {
            print('📱 Banner ad opened');
          }
          _trackAdEvent('banner_opened');
        },
        onAdClosed: (ad) {
          if (kDebugMode) {
            print('📱 Banner ad closed');
          }
        },
      ),
    );

    return _bannerAd!;
  }

  /// Cargar Anuncio Intersticial
  Future<void> _loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          
          if (kDebugMode) {
            print('✅ Interstitial ad loaded');
          }

          // Configurar callbacks
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('📱 Interstitial ad showed');
              }
              _trackAdEvent('interstitial_showed');
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('📱 Interstitial ad dismissed');
              }
              ad.dispose();
              _isInterstitialAdLoaded = false;
              // Precargar el siguiente anuncio
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                print('❌ Interstitial ad failed to show: $error');
              }
              ad.dispose();
              _isInterstitialAdLoaded = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('❌ Interstitial ad failed to load: $error');
          }
          _isInterstitialAdLoaded = false;
          // Reintentar en 30 segundos
          Future.delayed(const Duration(seconds: 30), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  /// Mostrar Anuncio Intersticial
  Future<bool> showInterstitialAd() async {
    if (_interstitialAd != null && _isInterstitialAdLoaded) {
      await _interstitialAd!.show();
      return true;
    } else {
      if (kDebugMode) {
        print('⚠️ Interstitial ad not ready');
      }
      // Intentar cargar uno nuevo
      await _loadInterstitialAd();
      return false;
    }
  }

  /// Cargar Anuncio con Recompensa
  Future<void> _loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          
          if (kDebugMode) {
            print('✅ Rewarded ad loaded');
          }

          // Configurar callbacks
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('📱 Rewarded ad showed');
              }
              _trackAdEvent('rewarded_showed');
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('📱 Rewarded ad dismissed');
              }
              ad.dispose();
              _isRewardedAdLoaded = false;
              // Precargar el siguiente anuncio
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                print('❌ Rewarded ad failed to show: $error');
              }
              ad.dispose();
              _isRewardedAdLoaded = false;
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('❌ Rewarded ad failed to load: $error');
          }
          _isRewardedAdLoaded = false;
          // Reintentar en 30 segundos
          Future.delayed(const Duration(seconds: 30), () {
            _loadRewardedAd();
          });
        },
      ),
    );
  }

  /// Mostrar Anuncio con Recompensa
  Future<bool> showRewardedAd({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    Function()? onAdDismissed,
  }) async {
    if (_rewardedAd != null && _isRewardedAdLoaded) {
      await _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
      
      // Configurar callback para cuando se cierre
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          onAdDismissed?.call();
          ad.dispose();
          _isRewardedAdLoaded = false;
          _loadRewardedAd();
        },
      );
      
      return true;
    } else {
      if (kDebugMode) {
        print('⚠️ Rewarded ad not ready');
      }
      // Intentar cargar uno nuevo
      await _loadRewardedAd();
      return false;
    }
  }

  /// Verificar si hay anuncios disponibles
  bool get isInterstitialAdReady => _isInterstitialAdLoaded && _interstitialAd != null;
  bool get isRewardedAdReady => _isRewardedAdLoaded && _rewardedAd != null;

  /// Tracking de eventos de anuncios
  Future<void> _trackAdEvent(String eventName) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final currentCount = _prefs?.getInt('ad_events_$eventName\_$today') ?? 0;
    await _prefs?.setInt('ad_events_$eventName\_$today', currentCount + 1);
  }

  /// Analytics de anuncios
  Future<Map<String, dynamic>> getAdAnalytics() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    return {
      'banner_opened': _prefs?.getInt('ad_events_banner_opened_$today') ?? 0,
      'interstitial_showed': _prefs?.getInt('ad_events_interstitial_showed_$today') ?? 0,
      'rewarded_showed': _prefs?.getInt('ad_events_rewarded_showed_$today') ?? 0,
      'interstitial_ready': isInterstitialAdReady,
      'rewarded_ready': isRewardedAdReady,
    };
  }

  /// Liberar recursos
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }

  /// Verificar si debe mostrar anuncios (para usuarios no premium)
  bool shouldShowAds() {
    // Esta lógica se integrará con MonetizationService
    return true;
  }

  /// Configurar frecuencia de anuncios intersticiales (más inteligente)
  Future<bool> shouldShowInterstitialAd() async {
    final lastShown = _prefs?.getInt('last_interstitial_timestamp') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const cooldownMinutes = 2; // Reducido a 2 minutos para mejor monetización
    
    // También considerar número de acciones del usuario
    final todayActions = _prefs?.getInt('user_actions_today') ?? 0;
    
    if (now - lastShown > (cooldownMinutes * 60 * 1000) && todayActions >= 3) {
      await _prefs?.setInt('last_interstitial_timestamp', now);
      return true;
    }
    
    return false;
  }

  /// Incrementar contador de acciones del usuario
  Future<void> trackUserAction() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastActionDate = _prefs?.getString('last_action_date');
    
    if (lastActionDate != today) {
      await _prefs?.setString('last_action_date', today);
      await _prefs?.setInt('user_actions_today', 1);
    } else {
      final currentActions = _prefs?.getInt('user_actions_today') ?? 0;
      await _prefs?.setInt('user_actions_today', currentActions + 1);
    }
  }
}
