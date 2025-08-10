import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/monetization_service.dart';
import 'services/theme_service.dart';
import 'test_daily_renewal_screen.dart';

/// Pantalla de prueba para validar el período de gracia de 3 días
class TestGracePeriodScreen extends StatefulWidget {
  const TestGracePeriodScreen({super.key});

  @override
  State<TestGracePeriodScreen> createState() => _TestGracePeriodScreenState();
}

class _TestGracePeriodScreenState extends State<TestGracePeriodScreen> {
  String _status = '📋 Iniciando pruebas del período de gracia...';
  final List<String> _testResults = [];
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _runGracePeriodTests();
  }

  Future<void> _runGracePeriodTests() async {
    setState(() {
      _status = '🔍 Ejecutando pruebas del período de gracia...';
      _testResults.clear();
    });

    _prefs = await SharedPreferences.getInstance();

    // Test 1: Usuario completamente nuevo
    await _testNewUserScenario();
    
    // Test 2: Usuario en día 1
    await _testDay1Scenario();
    
    // Test 3: Usuario en día 2
    await _testDay2Scenario();
    
    // Test 4: Usuario en día 3
    await _testDay3Scenario();
    
    // Test 5: Usuario después del día 3 (límites normales)
    await _testPostGraceScenario();
    
    // Test 6: Verificar integración con anuncios
    await _testAdIntegration();

    setState(() {
      _status = '✅ Pruebas del período de gracia completadas';
    });
  }

  Future<void> _testNewUserScenario() async {
    try {
      _addTestResult('📱 Test 1: Usuario completamente nuevo');
      
      // Limpiar datos para simular usuario nuevo
      await _prefs?.remove('first_install_date');
      await _prefs?.remove('today_scans');
      await _prefs?.remove('last_scan_date');
      
      // Verificar que es nuevo usuario
      final isNewUser = await MonetizationService.instance.isNewUser();
      final daysRemaining = await MonetizationService.instance.getGracePeriodDaysRemaining();
      final canScan = await MonetizationService.instance.canScanToday();
      final remainingScans = await MonetizationService.instance.getRemainingScansTodayForFree();
      
      _addTestResult(isNewUser ? '✅ Detectado como nuevo usuario' : '❌ NO detectado como nuevo usuario');
      _addTestResult('📅 Días de gracia restantes: $daysRemaining');
      _addTestResult(canScan ? '✅ Puede escanear (ilimitado)' : '❌ NO puede escanear');
      _addTestResult('🔢 Escaneos restantes: ${remainingScans == -1 ? "ILIMITADOS" : remainingScans}');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en Test 1: $e');
    }
  }

  Future<void> _testDay1Scenario() async {
    try {
      _addTestResult('📱 Test 2: Usuario día 1 (ayer se instaló)');
      
      // Simular instalación ayer
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayString = yesterday.toIso8601String().split('T')[0];
      await _prefs?.setString('first_install_date', yesterdayString);
      
      final isNewUser = await MonetizationService.instance.isNewUser();
      final daysRemaining = await MonetizationService.instance.getGracePeriodDaysRemaining();
      final canScan = await MonetizationService.instance.canScanToday();
      final remainingScans = await MonetizationService.instance.getRemainingScansTodayForFree();
      
      _addTestResult(isNewUser ? '✅ Aún en período de gracia' : '❌ Ya NO está en período de gracia');
      _addTestResult('📅 Días de gracia restantes: $daysRemaining');
      _addTestResult(canScan ? '✅ Puede escanear (ilimitado)' : '❌ NO puede escanear');
      _addTestResult('🔢 Escaneos restantes: ${remainingScans == -1 ? "ILIMITADOS" : remainingScans}');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en Test 2: $e');
    }
  }

  Future<void> _testDay2Scenario() async {
    try {
      _addTestResult('📱 Test 3: Usuario día 2 (hace 2 días se instaló)');
      
      // Simular instalación hace 2 días
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final twoDaysAgoString = twoDaysAgo.toIso8601String().split('T')[0];
      await _prefs?.setString('first_install_date', twoDaysAgoString);
      
      final isNewUser = await MonetizationService.instance.isNewUser();
      final daysRemaining = await MonetizationService.instance.getGracePeriodDaysRemaining();
      final canScan = await MonetizationService.instance.canScanToday();
      final remainingScans = await MonetizationService.instance.getRemainingScansTodayForFree();
      
      _addTestResult(isNewUser ? '✅ Último día de gracia' : '❌ Ya NO está en período de gracia');
      _addTestResult('📅 Días de gracia restantes: $daysRemaining');
      _addTestResult(canScan ? '✅ Puede escanear (ilimitado)' : '❌ NO puede escanear');
      _addTestResult('🔢 Escaneos restantes: ${remainingScans == -1 ? "ILIMITADOS" : remainingScans}');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en Test 3: $e');
    }
  }

  Future<void> _testDay3Scenario() async {
    try {
      _addTestResult('📱 Test 4: Usuario día 3 (hace 3 días - límite)');
      
      // Simular instalación hace exactamente 3 días
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final threeDaysAgoString = threeDaysAgo.toIso8601String().split('T')[0];
      await _prefs?.setString('first_install_date', threeDaysAgoString);
      
      final isNewUser = await MonetizationService.instance.isNewUser();
      final daysRemaining = await MonetizationService.instance.getGracePeriodDaysRemaining();
      final canScan = await MonetizationService.instance.canScanToday();
      final remainingScans = await MonetizationService.instance.getRemainingScansTodayForFree();
      
      _addTestResult(isNewUser ? '❌ ERROR: Aún detectado como nuevo' : '✅ Ya NO está en período de gracia');
      _addTestResult('📅 Días de gracia restantes: $daysRemaining');
      _addTestResult(canScan ? '⚠️ Puede escanear (límites normales)' : '❌ NO puede escanear');
      _addTestResult('🔢 Escaneos restantes: ${remainingScans == -1 ? "ILIMITADOS" : remainingScans}');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en Test 4: $e');
    }
  }

  Future<void> _testPostGraceScenario() async {
    try {
      _addTestResult('📱 Test 5: Usuario después de gracia (hace 4+ días)');
      
      // Simular instalación hace 4 días (después del período de gracia)
      final fourDaysAgo = DateTime.now().subtract(const Duration(days: 4));
      final fourDaysAgoString = fourDaysAgo.toIso8601String().split('T')[0];
      await _prefs?.setString('first_install_date', fourDaysAgoString);
      
      // Resetear escaneos para simular día nuevo
      await _prefs?.remove('today_scans');
      await _prefs?.remove('last_scan_date');
      
      final isNewUser = await MonetizationService.instance.isNewUser();
      final daysRemaining = await MonetizationService.instance.getGracePeriodDaysRemaining();
      final canScan = await MonetizationService.instance.canScanToday();
      final remainingScans = await MonetizationService.instance.getRemainingScansTodayForFree();
      final canWatchAd = await MonetizationService.instance.canWatchAdForScans();
      
      _addTestResult(isNewUser ? '❌ ERROR: Aún detectado como nuevo' : '✅ Usuario regular (sin gracia)');
      _addTestResult('📅 Días de gracia restantes: $daysRemaining');
      _addTestResult(canScan ? '✅ Puede escanear (límites normales)' : '❌ NO puede escanear');
      _addTestResult('🔢 Escaneos restantes: $remainingScans (máximo 5 base)');
      _addTestResult(canWatchAd ? '✅ Puede ver ads para más escaneos' : '❌ NO puede ver ads');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en Test 5: $e');
    }
  }

  Future<void> _testAdIntegration() async {
    try {
      _addTestResult('📱 Test 6: Integración con sistema de anuncios');
      
      // Simular usuario fuera del período de gracia
      final fourDaysAgo = DateTime.now().subtract(const Duration(days: 4));
      final fourDaysAgoString = fourDaysAgo.toIso8601String().split('T')[0];
      await _prefs?.setString('first_install_date', fourDaysAgoString);
      
      // Simular que ya usó todos los escaneos gratuitos
      final today = DateTime.now().toIso8601String().split('T')[0];
      await _prefs?.setString('last_scan_date', today);
      await _prefs?.setInt('today_scans', 5); // Máximo de escaneos base
      
      final canScan = await MonetizationService.instance.canScanToday();
      final remainingScans = await MonetizationService.instance.getRemainingScansTodayForFree();
      final canWatchAd = await MonetizationService.instance.canWatchAdForScans();
      final availableAdBonus = await MonetizationService.instance.getAvailableAdBonusScans();
      
      _addTestResult(canScan ? '⚠️ ERROR: Puede escanear sin límites' : '✅ NO puede escanear (límites agotados)');
      _addTestResult('🔢 Escaneos restantes: $remainingScans');
      _addTestResult(canWatchAd ? '✅ Puede ver ads para más escaneos' : '❌ NO puede ver ads');
      _addTestResult('🎁 Escaneos bonus disponibles por ads: $availableAdBonus');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en Test 6: $e');
    }
  }

  void _addTestResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  Future<void> _resetUserData() async {
    await _prefs?.remove('first_install_date');
    await _prefs?.remove('today_scans');
    await _prefs?.remove('last_scan_date');
    await _prefs?.remove('extra_scans_today');
    await _prefs?.remove('last_ad_date');
    
    _addTestResult('🔄 Datos de usuario reseteados - Simula instalación nueva');
  }

  Future<void> _simulateDay(int daysAgo) async {
    final targetDate = DateTime.now().subtract(Duration(days: daysAgo));
    final targetDateString = targetDate.toIso8601String().split('T')[0];
    await _prefs?.setString('first_install_date', targetDateString);
    
    _addTestResult('⏰ Simulando instalación hace $daysAgo días');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Período de Gracia',
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

            // Botones de control
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _runGracePeriodTests,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeService.instance.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Ejecutar Tests',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _resetUserData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Reset Usuario',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _simulateDay(1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text('Día 1', style: GoogleFonts.poppins(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _simulateDay(2),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text('Día 2', style: GoogleFonts.poppins(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _simulateDay(3),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text('Día 3+', style: GoogleFonts.poppins(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TestDailyRenewalScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Test Renovación Diaria',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
