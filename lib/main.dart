import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/welcome_screen.dart';
import 'screens/splash_screen.dart';

import 'services/logger_service.dart';
import 'services/theme_service.dart';
import 'services/daily_love_service.dart';
import 'services/audio_service.dart';
import 'services/locale_service.dart';
import 'services/streak_service.dart';
import 'services/crush_service.dart';
import 'services/monetization_service.dart';
import 'services/admob_service.dart';
import 'services/purchase_service.dart';
import 'services/premium_theme_service.dart';
import 'services/analytics_service.dart';
import 'services/secure_time_service.dart';
import 'services/receipt_validation_service.dart';
import 'services/scanner_economy_service.dart';
import 'services/global_economy_service.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    LoggerService.info('Iniciando Scanner Crush...', origin: 'main');

    // ── System chrome (no bloquea) ──
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    // ── Fase 1: Servicios críticos (deben ir primero y en orden) ──
    await _initSafe('AdMob SDK', () => MobileAds.instance.initialize());
    await _initSafe('SecureTimeService', () => SecureTimeService.instance.initialize());

    // ── Fase 2: Servicios de UI/UX (pueden correr en paralelo) ──
    await Future.wait([
      _initSafe('ThemeService', () => ThemeService.instance.initialize()),
      _initSafe('LocaleService', () => LocaleService.instance.initialize()),
      _initSafe('DailyLoveService', () => DailyLoveService.instance.initialize()),
      _initSafe('AudioService', () => AudioService.instance.initialize()),
      _initSafe('StreakService', () => StreakService.instance.initialize()),
    ]);

    // ── Fase 3: Monetización (depende de SecureTimeService) ──
    await Future.wait([
      _initSafe('AdMobService', () => AdMobService.instance.initialize()),
      _initSafe('MonetizationService', () => MonetizationService.instance.initialize()),
    ]);

    // ── Fase 4: Servicios secundarios ──
    await Future.wait([
      _initSafe('PurchaseService', () => PurchaseService.instance.initialize()),
      _initSafe('ReceiptValidationService', () => ReceiptValidationService.instance.initialize()),
      _initSafe('PremiumThemeService', () => PremiumThemeService.instance.initialize()),
      _initSafe('AnalyticsService', () => AnalyticsService.instance.initialize()),
      _initSafe('GlobalEconomyService', () => GlobalEconomyService.instance.initialize()),
      _initSafe('ScannerEconomyService', () => ScannerEconomyService.instance.initialize()),
    ]);

    // ── Fase 5: Tareas de mantenimiento (no bloquean el splash) ──
    unawaited(
      Future.wait([
        _initSafe('PremiumCleanup', () => PremiumThemeService.instance.checkAndHandleExpiredPremium()),
        _initSafe('FixInvalidResults', () => CrushService.instance.fixInvalidResults()),
      ]),
    );

    LoggerService.info('Todos los servicios inicializados correctamente', origin: 'main');
  } catch (e, st) {
    LoggerService.error('Error crítico en inicialización', origin: 'main', error: e, stackTrace: st);
  }

  runApp(const ScannerCrushApp());
}

/// Helper que envuelve cada inicialización en un try/catch individual
/// para que un fallo no cancele las demás.
Future<void> _initSafe(String name, Future<void> Function() init) async {
  try {
    await init();
    LoggerService.info('$name inicializado', origin: 'init');
  } catch (e, st) {
    LoggerService.warning('$name falló: $e', origin: 'init', error: e);
    // stack trace en debug
    LoggerService.debug(st.toString(), origin: 'init');
  }
}

/// Fire-and-forget para futures que no deben bloquear el hilo principal.
void unawaited(Future<void> future) {}

class ScannerCrushApp extends StatefulWidget {
  const ScannerCrushApp({super.key});

  @override
  State<ScannerCrushApp> createState() => _ScannerCrushAppState();
}

class _ScannerCrushAppState extends State<ScannerCrushApp> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ThemeService.instance,
        LocaleService.instance,
        StreakService.instance,
      ]),
      builder: (context, child) {
        return Builder(
          builder: (context) {
            final localizations = AppLocalizations.of(context);
            return MaterialApp(
              title: localizations?.appTitleFull ?? 'Crush Scanner',
              debugShowCheckedModeBanner: false,
              showPerformanceOverlay: false,
              showSemanticsDebugger: false,
              locale: LocaleService.instance.currentLocale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: LocaleService.instance.supportedLocales,
              theme: _buildTheme(Brightness.light),
              darkTheme: _buildTheme(Brightness.dark),
              themeMode:
                  ThemeService.instance.isDarkMode
                      ? ThemeMode.dark
                      : ThemeMode.light,
              initialRoute: '/',
              routes: {
                '/': (context) => const SplashScreen(),
                '/welcome': (context) => const WelcomeScreen(),
              },
            );
          },
        );
      },
    );
  }

  /// Genera [ThemeData] unificado para evitar duplicación light/dark.
  ThemeData _buildTheme(Brightness brightness) {
    final ts = ThemeService.instance;
    final isDark = brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark() : ThemeData.light();

    return base.copyWith(
      primaryColor: ts.primaryColor,
      scaffoldBackgroundColor: Colors.transparent,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: base.colorScheme.copyWith(
        primary: ts.primaryColor,
        secondary: ts.secondaryColor,
        surface: ts.surfaceColor,
        brightness: brightness,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        bodyLarge: TextStyle(color: ts.textColor),
        bodyMedium: TextStyle(color: ts.textColor),
        titleLarge: TextStyle(color: ts.textColor),
        titleMedium: TextStyle(color: ts.textColor),
        titleSmall: TextStyle(color: ts.textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: ts.primaryColor.withAlpha(isDark ? 102 : 77),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ts.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: isDark
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: ts.borderColor, width: 1),
              )
            : null,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: ts.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardTheme(
        color: ts.cardColor,
        elevation: 8,
        shadowColor: Colors.black.withAlpha(isDark ? 77 : 26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: ts.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: ts.textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: ts.subtitleColor,
          fontSize: 16,
        ),
      ),
      switchTheme: isDark
          ? SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return ts.primaryColor;
                  }
                  return ts.subtitleColor;
                },
              ),
              trackColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return ts.primaryColor.withAlpha(128);
                  }
                  return ts.borderColor;
                },
              ),
            )
          : null,
    );
  }
}
