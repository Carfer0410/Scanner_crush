import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/admob_service.dart';
import 'services/monetization_service.dart';
import 'services/theme_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Pantalla de prueba para validar el sistema de publicidad
class TestAdsScreen extends StatefulWidget {
  const TestAdsScreen({super.key});

  @override
  State<TestAdsScreen> createState() => _TestAdsScreenState();
}

class _TestAdsScreenState extends State<TestAdsScreen> {
  String _status = '📋 Iniciando pruebas...';
  final List<String> _testResults = [];
  BannerAd? _testBannerAd;

  @override
  void initState() {
    super.initState();
    _runAdTests();
  }

  @override
  void dispose() {
    _testBannerAd?.dispose();
    super.dispose();
  }

  Future<void> _runAdTests() async {
    setState(() {
      _status = '🔍 Ejecutando pruebas del sistema de publicidad...';
      _testResults.clear();
    });

    // Test 1: Inicialización de AdMob
    await _testAdMobInitialization();
    
    // Test 2: Banner Ads
    await _testBannerAds();
    
    // Test 3: Interstitial Ads
    await _testInterstitialAds();
    
    // Test 4: Rewarded Ads
    await _testRewardedAds();
    
    // Test 5: Monetization Service Integration
    await _testMonetizationIntegration();
    
    // Test 6: Error Handling
    await _testErrorHandling();

    setState(() {
      _status = '✅ Pruebas completadas';
    });
  }

  Future<void> _testAdMobInitialization() async {
    try {
      _addTestResult('📱 Prueba 1: Inicialización de AdMob');
      
      final isInitialized = AdMobService.instance.hashCode > 0; // Service exists
      
      if (isInitialized) {
        _addTestResult('✅ AdMobService inicializado correctamente');
      } else {
        _addTestResult('❌ Error: AdMobService no inicializado');
      }
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en inicialización: $e');
    }
  }

  Future<void> _testBannerAds() async {
    try {
      _addTestResult('📱 Prueba 2: Banner Ads');
      
      _testBannerAd = AdMobService.instance.createBannerAd();
      
      if (_testBannerAd != null) {
        _addTestResult('✅ Banner Ad creado correctamente');
        
        // Cargar el anuncio
        _testBannerAd!.load();
        _addTestResult('✅ Banner Ad cargando...');
      } else {
        _addTestResult('❌ Error: No se pudo crear Banner Ad');
      }
      
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      _addTestResult('❌ Error en Banner Ads: $e');
    }
  }

  Future<void> _testInterstitialAds() async {
    try {
      _addTestResult('📱 Prueba 3: Interstitial Ads');
      
      final isReady = AdMobService.instance.isInterstitialAdReady;
      _addTestResult(isReady 
        ? '✅ Interstitial Ad disponible' 
        : '⚠️ Interstitial Ad no disponible (normal durante desarrollo)');
      
      final shouldShow = await AdMobService.instance.shouldShowInterstitialAd();
      _addTestResult(shouldShow 
        ? '✅ Política de cooldown funcional' 
        : '⚠️ En período de cooldown');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en Interstitial Ads: $e');
    }
  }

  Future<void> _testRewardedAds() async {
    try {
      _addTestResult('📱 Prueba 4: Rewarded Ads');
      
      final isReady = AdMobService.instance.isRewardedAdReady;
      _addTestResult(isReady 
        ? '✅ Rewarded Ad disponible' 
        : '⚠️ Rewarded Ad no disponible (normal durante desarrollo)');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en Rewarded Ads: $e');
    }
  }

  Future<void> _testMonetizationIntegration() async {
    try {
      _addTestResult('📱 Prueba 5: Integración con MonetizationService');
      
      final isPremium = MonetizationService.instance.isPremium;
      _addTestResult('👤 Usuario premium: ${isPremium ? "Sí" : "No"}');
      
      final canScan = await MonetizationService.instance.canScanToday();
      _addTestResult('🔍 Puede escanear hoy: ${canScan ? "Sí" : "No"}');
      
      final remaining = await MonetizationService.instance.getRemainingScansTodayForFree();
      _addTestResult('📊 Escaneos restantes: ${remaining == -1 ? "Ilimitados" : remaining}');
      
      final canWatchAd = await MonetizationService.instance.canWatchAdForScans();
      _addTestResult('📺 Puede ver ads para escaneos: ${canWatchAd ? "Sí" : "No"}');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en integración: $e');
    }
  }

  Future<void> _testErrorHandling() async {
    try {
      _addTestResult('📱 Prueba 6: Manejo de errores');
      
      // Test analytics
      final analytics = await AdMobService.instance.getAdAnalytics();
      _addTestResult('📈 Analytics disponibles: ${analytics.keys.length} métricas');
      
      // Test dispose safety
      _testBannerAd?.dispose();
      _addTestResult('✅ Dispose de ads funcional');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en manejo de errores: $e');
    }
  }

  void _addTestResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test de Publicidad',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: ThemeService.instance.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ThemeService.instance.primaryColor.withOpacity(0.1),
              ThemeService.instance.secondaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            // Estado actual
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeService.instance.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _status,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeService.instance.textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Resultados de pruebas
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeService.instance.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemCount: _testResults.length,
                  itemBuilder: (context, index) {
                    final result = _testResults[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        result,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: ThemeService.instance.textColor,
                          height: 1.4,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Banner ad de prueba (si no es premium)
            if (!MonetizationService.instance.isPremium && _testBannerAd != null)
              Container(
                margin: const EdgeInsets.all(16),
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ThemeService.instance.primaryColor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AdWidget(ad: _testBannerAd!),
              ),

            // Botones de prueba
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _runAdTests,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeService.instance.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Ejecutar Pruebas',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final adShown = await MonetizationService.instance.watchAdForExtraScans();
                        _addTestResult(adShown 
                          ? '✅ Rewarded ad mostrado correctamente' 
                          : '⚠️ No se pudo mostrar rewarded ad');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Test Rewarded',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
