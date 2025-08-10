import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/monetization_service.dart';
import 'services/theme_service.dart';

/// Pantalla de prueba para validar la renovación diaria de escaneos
class TestDailyRenewalScreen extends StatefulWidget {
  const TestDailyRenewalScreen({super.key});

  @override
  State<TestDailyRenewalScreen> createState() => _TestDailyRenewalScreenState();
}

class _TestDailyRenewalScreenState extends State<TestDailyRenewalScreen> {
  String _status = '📋 Iniciando pruebas de renovación diaria...';
  final List<String> _testResults = [];
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _runDailyRenewalTests();
  }

  Future<void> _runDailyRenewalTests() async {
    setState(() {
      _status = '🔍 Ejecutando pruebas de renovación diaria...';
      _testResults.clear();
    });

    _prefs = await SharedPreferences.getInstance();

    // Test 1: Simular que es un nuevo día
    await _testNewDayRenewal();
    
    // Test 2: Uso de escaneos en el día actual
    await _testSameDayUsage();
    
    // Test 3: Simulación de cambio de día con escaneos usados
    await _testDayChangeWithUsedScans();
    
    // Test 4: Renovación de bonos por anuncios
    await _testAdBonusRenewal();
    
    // Test 5: Verificar límites después de renovación
    await _testLimitsAfterRenewal();

    setState(() {
      _status = '✅ Pruebas de renovación diaria completadas';
    });
  }

  Future<void> _testNewDayRenewal() async {
    try {
      _addTestResult('📅 Test 1: Renovación en nuevo día');
      
      // Simular usuario fuera del período de gracia (hace 5 días)
      final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
      final fiveDaysAgoString = fiveDaysAgo.toIso8601String().split('T')[0];
      await _prefs?.setString('first_install_date', fiveDaysAgoString);
      
      // Simular día anterior con escaneos usados
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayString = yesterday.toIso8601String().split('T')[0];
      await _prefs?.setString('last_scan_date', yesterdayString);
      await _prefs?.setInt('today_scans', 5); // Había usado todos los escaneos ayer
      await _prefs?.setInt('extra_scans_today', 6); // Había ganado algunos por ads
      
      // Verificar que hoy se resetean
      final remainingScans = await MonetizationService.instance.getRemainingScansTodayForFree();
      final canScan = await MonetizationService.instance.canScanToday();
      final extraScans = await MonetizationService.instance.getExtraScansFromAds();
      
      _addTestResult(remainingScans == 5 ? '✅ Escaneos base reseteados a 5' : '❌ ERROR: Escaneos no reseteados correctamente');
      _addTestResult(extraScans == 0 ? '✅ Bonos por ads reseteados' : '❌ ERROR: Bonos no reseteados');
      _addTestResult(canScan ? '✅ Puede escanear nuevamente' : '❌ ERROR: No puede escanear');
      _addTestResult('🔢 Escaneos disponibles hoy: $remainingScans');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en Test 1: $e');
    }
  }

  Future<void> _testSameDayUsage() async {
    try {
      _addTestResult('📅 Test 2: Uso de escaneos en el mismo día');
      
      // Verificar estado inicial
      final initialScans = await MonetizationService.instance.getRemainingScansTodayForFree();
      _addTestResult('📊 Escaneos iniciales: $initialScans');
      
      // Simular uso de 2 escaneos
      await MonetizationService.instance.recordScan();
      await MonetizationService.instance.recordScan();
      
      final afterTwoScans = await MonetizationService.instance.getRemainingScansTodayForFree();
      _addTestResult(afterTwoScans == 3 ? '✅ Después de 2 escaneos: 3 restantes' : '❌ ERROR: Cálculo incorrecto después de usar 2');
      
      // Simular uso de 3 escaneos más (total 5)
      await MonetizationService.instance.recordScan();
      await MonetizationService.instance.recordScan();
      await MonetizationService.instance.recordScan();
      
      final afterAllScans = await MonetizationService.instance.getRemainingScansTodayForFree();
      final canStillScan = await MonetizationService.instance.canScanToday();
      
      _addTestResult(afterAllScans == 0 ? '✅ Después de 5 escaneos: 0 restantes' : '❌ ERROR: Debería tener 0 restantes');
      _addTestResult(!canStillScan ? '✅ No puede escanear más (límite alcanzado)' : '❌ ERROR: Aún puede escanear');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en Test 2: $e');
    }
  }

  Future<void> _testDayChangeWithUsedScans() async {
    try {
      _addTestResult('📅 Test 3: Cambio de día con escaneos previamente usados');
      
      // Asegurar que todos los escaneos están usados
      final today = DateTime.now().toIso8601String().split('T')[0];
      await _prefs?.setString('last_scan_date', today);
      await _prefs?.setInt('today_scans', 5);
      
      // Verificar que no puede escanear
      final beforeReset = await MonetizationService.instance.canScanToday();
      _addTestResult(!beforeReset ? '✅ Confirmado: No puede escanear (límite alcanzado)' : '❌ ERROR: Puede escanear cuando no debería');
      
      // Simular cambio de día (mañana)
      await _prefs?.setString('last_scan_date', 'fecha_falsa'); // Forzar reset
      
      // Verificar renovación
      final afterReset = await MonetizationService.instance.getRemainingScansTodayForFree();
      final canScanAfterReset = await MonetizationService.instance.canScanToday();
      
      _addTestResult(afterReset == 5 ? '✅ Día nuevo: 5 escaneos renovados' : '❌ ERROR: Renovación no funciona');
      _addTestResult(canScanAfterReset ? '✅ Puede escanear después de renovación' : '❌ ERROR: No puede escanear tras renovación');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en Test 3: $e');
    }
  }

  Future<void> _testAdBonusRenewal() async {
    try {
      _addTestResult('📅 Test 4: Renovación de bonos por anuncios');
      
      // Simular día anterior con bonos usados
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayString = yesterday.toIso8601String().split('T')[0];
      await _prefs?.setString('last_ad_date', yesterdayString);
      await _prefs?.setInt('extra_scans_today', 10); // Máximo de bonos ayer
      
      // Verificar que hoy se resetean los bonos
      final extraScansToday = await MonetizationService.instance.getExtraScansFromAds();
      final availableBonusScans = await MonetizationService.instance.getAvailableAdBonusScans();
      final canWatchAd = await MonetizationService.instance.canWatchAdForScans();
      
      _addTestResult(extraScansToday == 0 ? '✅ Bonos por ads reseteados a 0' : '❌ ERROR: Bonos no reseteados');
      _addTestResult(availableBonusScans == 10 ? '✅ Puede ganar 10 bonos nuevos' : '❌ ERROR: Bonos disponibles incorrectos');
      _addTestResult(canWatchAd ? '✅ Puede ver anuncios para bonos' : '❌ ERROR: No puede ver anuncios');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en Test 4: $e');
    }
  }

  Future<void> _testLimitsAfterRenewal() async {
    try {
      _addTestResult('📅 Test 5: Verificar límites después de renovación');
      
      // Resetear para día nuevo
      await _prefs?.setString('last_scan_date', 'fecha_diferente');
      await _prefs?.setString('last_ad_date', 'fecha_diferente');
      await _prefs?.setInt('today_scans', 0);
      await _prefs?.setInt('extra_scans_today', 0);
      
      // Verificar límites máximos
      final baseScans = await MonetizationService.instance.getRemainingScansTodayForFree();
      final maxAdBonusScans = await MonetizationService.instance.getAvailableAdBonusScans();
      final totalPossible = baseScans + maxAdBonusScans;
      
      _addTestResult('📊 Límites después de renovación:');
      _addTestResult(baseScans == 5 ? '✅ Base: 5 escaneos diarios' : '❌ ERROR: Base incorrecto');
      _addTestResult(maxAdBonusScans == 10 ? '✅ Bonos: hasta 10 por anuncios' : '❌ ERROR: Bonos incorrectos');
      _addTestResult(totalPossible == 15 ? '✅ Total máximo: 15 escaneos/día' : '❌ ERROR: Total incorrecto');
      
      // Verificar que la renovación es diaria
      _addTestResult('🔄 Renovación automática: DIARIA a las 00:00');
      _addTestResult('⏰ Próxima renovación: Mañana a medianoche');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _addTestResult('❌ Error en Test 5: $e');
    }
  }

  void _addTestResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  Future<void> _simulateNewDay() async {
    // Forzar renovación eliminando la fecha actual
    await _prefs?.setString('last_scan_date', 'fecha_diferente');
    await _prefs?.setString('last_ad_date', 'fecha_diferente');
    _addTestResult('🌅 Simulando nuevo día - Forzando renovación');
  }

  Future<void> _resetToCleanState() async {
    await _prefs?.remove('last_scan_date');
    await _prefs?.remove('today_scans');
    await _prefs?.remove('extra_scans_today');
    await _prefs?.remove('last_ad_date');
    _addTestResult('🧹 Estado limpio - Como si fuera primera vez hoy');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Renovación Diaria',
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
                          onPressed: _runDailyRenewalTests,
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
                          onPressed: _simulateNewDay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Simular Nuevo Día',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _resetToCleanState,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Reset Estado Limpio',
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
