import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';
import '../services/monetization_service.dart';
import '../services/theme_service.dart';

/// Pantalla de prueba simplificada para anuncios
class AdsTestScreen extends StatefulWidget {
  const AdsTestScreen({super.key});

  @override
  State<AdsTestScreen> createState() => _AdsTestScreenState();
}

class _AdsTestScreenState extends State<AdsTestScreen> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  String _status = "Lista para probar anuncios";
  final List<String> _testResults = [];

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdMobService.instance.createBannerAd();
    _bannerAd?.load().then((_) {
      if (mounted) {
        setState(() {
          _isBannerLoaded = true;
          _status = "Banner Ad cargado correctamente";
        });
      }
    }).catchError((error) {
      setState(() {
        _status = "Error cargando Banner Ad: $error";
      });
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add("${DateTime.now().toString().substring(11, 19)} - $result");
    });
  }

  Future<void> _testBannerAd() async {
    _addResult("🎯 Testing Banner Ad...");
    if (_bannerAd != null && _isBannerLoaded) {
      _addResult("✅ Banner Ad está funcionando");
    } else {
      _addResult("❌ Banner Ad no está cargado");
    }
  }

  Future<void> _testInterstitialAd() async {
    _addResult("🎯 Testing Interstitial Ad...");
    final isReady = AdMobService.instance.isInterstitialAdReady;
    if (isReady) {
      _addResult("✅ Interstitial Ad disponible");
      final success = await AdMobService.instance.showInterstitialAd();
      _addResult(success ? "✅ Interstitial mostrado" : "❌ Error mostrando Interstitial");
    } else {
      _addResult("⚠️ Interstitial Ad no está listo");
    }
  }

  Future<void> _testRewardedAd() async {
    _addResult("🎯 Testing Rewarded Ad...");
    final success = await MonetizationService.instance.watchAdForExtraScans();
    _addResult(success ? "✅ Rewarded Ad mostrado y recompensa otorgada" : "❌ Error con Rewarded Ad");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prueba de Anuncios',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: ThemeService.instance.primaryColor,
        foregroundColor: Colors.white,
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
            // Status section
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
              child: Column(
                children: [
                  Text(
                    'Estado del Sistema',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeService.instance.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: ThemeService.instance.textColor.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Banner Ad Display
                  if (_bannerAd != null && _isBannerLoaded) ...[
                    Text(
                      '📱 Banner Ad en vivo:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeService.instance.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ThemeService.instance.primaryColor.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  ],
                ],
              ),
            ),

            // Test buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _testBannerAd,
                          icon: const Icon(Icons.web),
                          label: const Text('Test Banner'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _testInterstitialAd,
                          icon: const Icon(Icons.fullscreen),
                          label: const Text('Test Interstitial'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _testRewardedAd,
                      icon: const Icon(Icons.card_giftcard),
                      label: const Text('Test Rewarded Ad'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Results section
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resultados de Pruebas',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ThemeService.instance.textColor,
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: _testResults.isEmpty
                          ? Center(
                              child: Text(
                                'Presiona los botones para probar los anuncios',
                                style: GoogleFonts.poppins(
                                  color: ThemeService.instance.textColor.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              itemCount: _testResults.length,
                              itemBuilder: (context, index) {
                                final result = _testResults[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    result,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: ThemeService.instance.textColor,
                                      height: 1.4,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
