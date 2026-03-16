import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/secure_time_service.dart';

import 'logger_service.dart';

enum RewardedAdStatus {
  rewarded,
  dismissed,
  notReady,
  failedToLoad,
  failedToShow,
  alreadyShowing,
}

class RewardedAdResult {
  const RewardedAdResult(this.status);

  final RewardedAdStatus status;

  bool get rewardEarned => status == RewardedAdStatus.rewarded;
}

/// Servicio avanzado de AdMob para Scanner Crush
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  static AdMobService get instance => _instance;
  AdMobService._internal();

  SharedPreferences? _prefs;

  /// En release usamos IDs de producción.
  /// En debug/profile usamos test IDs por seguridad (evita riesgo de baneo).
  static const bool _forceProductionAds = bool.fromEnvironment(
    'USE_PROD_ADS',
    defaultValue: true,
  );

  // IDs de producción Android
  static const String _androidProdBannerAdUnitId = 'ca-app-pub-6436417991123423/1992572008';
  static const String _androidProdInterstitialAdUnitId = 'ca-app-pub-6436417991123423/1801000311';
  static const String _androidProdRewardedAdUnitId = 'ca-app-pub-6436417991123423/1900222602';

  // IDs de producción iOS (opcionales vía --dart-define hasta publicar iOS)
  static const String _iosProdBannerAdUnitId = String.fromEnvironment('IOS_BANNER_AD_UNIT_ID', defaultValue: '');
  static const String _iosProdInterstitialAdUnitId = String.fromEnvironment('IOS_INTERSTITIAL_AD_UNIT_ID', defaultValue: '');
  static const String _iosProdRewardedAdUnitId = String.fromEnvironment('IOS_REWARDED_AD_UNIT_ID', defaultValue: '');

  // IDs de prueba oficiales de Google
  static const String _androidTestBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _iosTestBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';
  static const String _androidTestInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _iosTestInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910';
  static const String _androidTestRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _iosTestRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';

  // Estado de anuncios
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;
  bool _isInitialized = false;
  bool _isRewardedAdLoading = false;
  bool _isRewardedAdShowing = false;
  Completer<void>? _rewardedLoadCompleter;

  // Equilibrio UX vs ingresos
  static const int _interstitialCooldownMinutes = 3;
  static const int _minActionsBeforeInterstitial = 4;
  static const int _maxInterstitialPerDay = 7;

  static const int _rewardedCooldownSeconds = 90;
  static const int _maxRewardedPerDay = 8;

  bool get _useProductionAds => _forceProductionAds;

  // Getters para IDs de anuncios
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _useProductionAds
          ? _androidProdBannerAdUnitId
          : _androidTestBannerAdUnitId;
    } else if (Platform.isIOS) {
      if (_useProductionAds && _iosProdBannerAdUnitId.isNotEmpty) {
        return _iosProdBannerAdUnitId;
      }
      return _iosTestBannerAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _useProductionAds
          ? _androidProdInterstitialAdUnitId
          : _androidTestInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      if (_useProductionAds && _iosProdInterstitialAdUnitId.isNotEmpty) {
        return _iosProdInterstitialAdUnitId;
      }
      return _iosTestInterstitialAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      return _useProductionAds
          ? _androidProdRewardedAdUnitId
          : _androidTestRewardedAdUnitId;
    } else if (Platform.isIOS) {
      if (_useProductionAds && _iosProdRewardedAdUnitId.isNotEmpty) {
        return _iosProdRewardedAdUnitId;
      }
      return _iosTestRewardedAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Inicializar AdMob
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();

      // En desarrollo, marcar emulador como test device explícito.
      if (!_useProductionAds) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: const <String>['EMULATOR']),
        );
      }

      // Inicializar Mobile Ads SDK
      await MobileAds.instance.initialize();
      
      // Precargar anuncios
      await _loadInterstitialAd();
      await _loadRewardedAd();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        LoggerService.info(
          'AdMob initialized successfully (${_useProductionAds ? 'PROD ADS' : 'TEST ADS'})',
          origin: 'admob_service',
        );
      }
    } catch (e) {
      LoggerService.error('Error initializing AdMob: $e', origin: 'AdMobService');
    }
  }

  /// Crear Banner Ad
  BannerAd createBannerAd() {
    _bannerAd?.dispose();
    
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            LoggerService.info('Banner ad loaded', origin: 'admob_service');
          }
        },
        onAdFailedToLoad: (ad, error) {
          LoggerService.warning('Banner ad failed to load: $error', origin: 'AdMobService');
          ad.dispose();
        },
        onAdOpened: (ad) {
          LoggerService.debug('Banner ad opened', origin: 'AdMobService');
          _trackAdEvent('banner_opened');
        },
        onAdClosed: (ad) {
          LoggerService.debug('Banner ad closed', origin: 'AdMobService');
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
            LoggerService.info('Interstitial ad loaded', origin: 'admob_service');
          }

          // Configurar callbacks
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              LoggerService.debug('Interstitial ad showed', origin: 'AdMobService');
              _trackAdEvent('interstitial_showed');
            },
            onAdDismissedFullScreenContent: (ad) {
              LoggerService.debug('Interstitial ad dismissed', origin: 'AdMobService');
              ad.dispose();
              _isInterstitialAdLoaded = false;
              // Precargar el siguiente anuncio
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              LoggerService.error('Interstitial ad failed to show: $error', origin: 'AdMobService');
              ad.dispose();
              _isInterstitialAdLoaded = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          LoggerService.warning('Interstitial ad failed to load: $error', origin: 'AdMobService');
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
    if (!await _canShowInterstitialAd(commit: false)) {
      LoggerService.debug('Interstitial ad blocked by cooldown/daily cap', origin: 'AdMobService');
      return false;
    }

    if (_interstitialAd != null && _isInterstitialAdLoaded) {
      await _canShowInterstitialAd(commit: true);
      await _interstitialAd!.show();
      return true;
    } else {
      LoggerService.debug('Interstitial ad not ready', origin: 'AdMobService');
      // Intentar cargar uno nuevo
      await _loadInterstitialAd();
      return false;
    }
  }

  /// Cargar Anuncio con Recompensa
  Future<void> _loadRewardedAd() async {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      return;
    }
    if (_isRewardedAdLoading) {
      return _rewardedLoadCompleter?.future ?? Future.value();
    }

    _isRewardedAdLoading = true;
    _rewardedLoadCompleter = Completer<void>();

    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          
          if (kDebugMode) {
            LoggerService.info('Rewarded ad loaded', origin: 'admob_service');
          }
          _isRewardedAdLoading = false;
          if (!(_rewardedLoadCompleter?.isCompleted ?? true)) {
            _rewardedLoadCompleter?.complete();
          }

          // Configurar callbacks
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              LoggerService.debug('Rewarded ad showed', origin: 'AdMobService');
              _trackAdEvent('rewarded_showed');
            },
            onAdDismissedFullScreenContent: (ad) {
              LoggerService.debug('Rewarded ad dismissed', origin: 'AdMobService');
              ad.dispose();
              _isRewardedAdLoaded = false;
              // Precargar el siguiente anuncio
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              LoggerService.error('Rewarded ad failed to show: $error', origin: 'AdMobService');
              ad.dispose();
              _isRewardedAdLoaded = false;
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          LoggerService.warning('Rewarded ad failed to load: $error', origin: 'AdMobService');
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          _isRewardedAdLoading = false;
          if (!(_rewardedLoadCompleter?.isCompleted ?? true)) {
            _rewardedLoadCompleter?.complete();
          }
          // Reintentar en 30 segundos
          Future.delayed(const Duration(seconds: 30), () {
            _loadRewardedAd();
          });
        },
      ),
    );
  }

  Future<bool> _ensureRewardedAdReady({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (_rewardedAd != null && _isRewardedAdLoaded) {
      return true;
    }

    await _loadRewardedAd();

    final waitFuture = _rewardedLoadCompleter?.future ?? Future.value();
    try {
      await waitFuture.timeout(timeout);
    } catch (_) {
      LoggerService.warning(
        'Rewarded ad readiness wait timed out',
        origin: 'AdMobService',
      );
    }

    return _rewardedAd != null && _isRewardedAdLoaded;
  }

  Future<RewardedAdResult> showRewardedAdDetailed({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    Function()? onAdDismissed,
  }) async {
    if (_isRewardedAdShowing) {
      LoggerService.debug('Rewarded ad already showing', origin: 'AdMobService');
      return const RewardedAdResult(RewardedAdStatus.alreadyShowing);
    }

    if (!await _canShowRewardedAd(commit: false)) {
      LoggerService.debug('Rewarded ad blocked by cooldown/daily cap', origin: 'AdMobService');
      return const RewardedAdResult(RewardedAdStatus.notReady);
    }

    final ready = await _ensureRewardedAdReady();
    if (!ready || _rewardedAd == null) {
      LoggerService.debug('Rewarded ad not ready after wait', origin: 'AdMobService');
      return const RewardedAdResult(RewardedAdStatus.notReady);
    }

    await _canShowRewardedAd(commit: true);

    _isRewardedAdShowing = true;
    final completer = Completer<RewardedAdResult>();
    var rewardGiven = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        LoggerService.debug('Rewarded ad showed', origin: 'AdMobService');
        _trackAdEvent('rewarded_showed');
      },
      onAdDismissedFullScreenContent: (ad) {
        if (!rewardGiven) {
          onAdDismissed?.call();
        }
        if (!completer.isCompleted) {
          completer.complete(
            RewardedAdResult(
              rewardGiven ? RewardedAdStatus.rewarded : RewardedAdStatus.dismissed,
            ),
          );
        }
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        _isRewardedAdShowing = false;
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        LoggerService.error('Rewarded ad failed to show: $error', origin: 'AdMobService');
        if (!completer.isCompleted) {
          completer.complete(const RewardedAdResult(RewardedAdStatus.failedToShow));
        }
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        _isRewardedAdShowing = false;
        _loadRewardedAd();
      },
    );

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          rewardGiven = true;
          try {
            onUserEarnedReward(ad, reward);
          } catch (e) {
            LoggerService.error('Error in onUserEarnedReward callback: $e', origin: 'AdMobService');
          }
        },
      );
    } catch (e) {
      LoggerService.error('Rewarded ad show threw error: $e', origin: 'AdMobService');
      _isRewardedAdShowing = false;
      _rewardedAd = null;
      _isRewardedAdLoaded = false;
      _loadRewardedAd();
      return const RewardedAdResult(RewardedAdStatus.failedToShow);
    }

    return completer.future;
  }

  /// Mostrar Anuncio con Recompensa
  Future<bool> showRewardedAd({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    Function()? onAdDismissed,
  }) async {
    final result = await showRewardedAdDetailed(
      onUserEarnedReward: onUserEarnedReward,
      onAdDismissed: onAdDismissed,
    );
    return result.rewardEarned;
  }

  /// Verificar si hay anuncios disponibles
  bool get isInterstitialAdReady => _isInterstitialAdLoaded && _interstitialAd != null;
  bool get isRewardedAdReady => _isRewardedAdLoaded && _rewardedAd != null;

  /// Tracking de eventos de anuncios
  Future<void> _trackAdEvent(String eventName) async {
    final today = SecureTimeService.instance.getSecureDate().toIso8601String().split('T')[0];
    final currentCount = _prefs?.getInt('ad_events_${eventName}_$today') ?? 0;
    await _prefs?.setInt('ad_events_${eventName}_$today', currentCount + 1);
  }

  /// Analytics de anuncios
  Future<Map<String, dynamic>> getAdAnalytics() async {
    final today = SecureTimeService.instance.getSecureDate().toIso8601String().split('T')[0];
    
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
    return _canShowInterstitialAd(commit: false);
  }

  /// Incrementar contador de acciones del usuario
  Future<void> trackUserAction() async {
    final today = SecureTimeService.instance.getSecureDate().toIso8601String().split('T')[0];
    final lastActionDate = _prefs?.getString('last_action_date');
    
    if (lastActionDate != today) {
      await _prefs?.setString('last_action_date', today);
      await _prefs?.setInt('user_actions_today', 1);
    } else {
      final currentActions = _prefs?.getInt('user_actions_today') ?? 0;
      await _prefs?.setInt('user_actions_today', currentActions + 1);
    }
  }

  String _todayKey() =>
      SecureTimeService.instance.getSecureDate().toIso8601String().split('T')[0];

  int _getDailyCounter(String baseKey) {
    final key = '${baseKey}_${_todayKey()}';
    return _prefs?.getInt(key) ?? 0;
  }

  Future<void> _incrementDailyCounter(String baseKey) async {
    final key = '${baseKey}_${_todayKey()}';
    final current = _prefs?.getInt(key) ?? 0;
    await _prefs?.setInt(key, current + 1);
  }

  Future<bool> _canShowInterstitialAd({required bool commit}) async {
    final lastShown = _prefs?.getInt('last_interstitial_timestamp') ?? 0;
    final now = SecureTimeService.instance.getSecureTime().millisecondsSinceEpoch;
    final todayActions = _prefs?.getInt('user_actions_today') ?? 0;
    final shownToday = _getDailyCounter('interstitial_shown_count');

    if (todayActions < _minActionsBeforeInterstitial) return false;
    if (shownToday >= _maxInterstitialPerDay) return false;

    const cooldownMs = _interstitialCooldownMinutes * 60 * 1000;
    if (now - lastShown < cooldownMs) return false;

    if (commit) {
      await _prefs?.setInt('last_interstitial_timestamp', now);
      await _incrementDailyCounter('interstitial_shown_count');
    }
    return true;
  }

  Future<bool> _canShowRewardedAd({required bool commit}) async {
    final lastShown = _prefs?.getInt('last_rewarded_timestamp') ?? 0;
    final now = SecureTimeService.instance.getSecureTime().millisecondsSinceEpoch;
    final shownToday = _getDailyCounter('rewarded_shown_count');

    if (shownToday >= _maxRewardedPerDay) return false;

    const cooldownMs = _rewardedCooldownSeconds * 1000;
    if (now - lastShown < cooldownMs) return false;

    if (commit) {
      await _prefs?.setInt('last_rewarded_timestamp', now);
      await _incrementDailyCounter('rewarded_shown_count');
    }
    return true;
  }
}
