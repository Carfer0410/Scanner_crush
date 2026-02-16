import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/welcome_screen.dart';
import 'screens/splash_screen.dart';

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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print("🚀 Iniciando Scanner Crush...");

    // Initialize AdMob (con manejo de errores)
    try {
      await MobileAds.instance.initialize();
      print("✅ AdMob inicializado");
    } catch (e) {
      print("⚠️ Error en AdMob: $e");
    }

    // Initialize AdMob Service (con manejo de errores)
    try {
      await AdMobService.instance.initialize();
      print("✅ AdMobService inicializado");
    } catch (e) {
      print("⚠️ Error en AdMobService: $e");
    }

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    // Initialize services (SecureTimeService debe ser PRIMERO)
    try {
      await SecureTimeService.instance.initialize();
      print("✅ SecureTimeService inicializado");
    } catch (e) {
      print("⚠️ Error en SecureTimeService: $e");
    }

    await ThemeService.instance.initialize();
    print("✅ ThemeService inicializado");

    await DailyLoveService.instance.initialize();
    print("✅ DailyLoveService inicializado");

    await AudioService.instance.initialize();
    print("✅ AudioService inicializado");

    await LocaleService.instance.initialize();
    print("✅ LocaleService inicializado");

    await StreakService.instance.initialize();
    print("✅ StreakService inicializado");

    // Initialize monetization service
    await MonetizationService.instance.initialize();
    print("✅ MonetizationService inicializado");

    // Initialize purchase service
    await PurchaseService.instance.initialize();
    print("✅ PurchaseService inicializado");

    // Initialize premium services
    await PremiumThemeService.instance.initialize();
    print("✅ PremiumThemeService inicializado");

    await AnalyticsService.instance.initialize();
    print("✅ AnalyticsService inicializado");

    // Check for expired premium theme access and clean up
    await PremiumThemeService.instance.checkAndHandleExpiredPremium();
    print("✅ Premium cleanup completado");

    // Fix any invalid compatibility results from previous versions
    await CrushService.instance.fixInvalidResults();
    print("✅ CrushService fix completado");

    print("🎉 ¡Todos los servicios inicializados correctamente!");
    runApp(const ScannerCrushApp());
  } catch (e) {
    print("❌ Error crítico en inicialización: $e");
    // Fallback: run app anyway
    runApp(const ScannerCrushApp());
  }
}

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
              theme: _buildLightTheme(),
              darkTheme: _buildDarkTheme(),
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

  ThemeData _buildLightTheme() {
    return ThemeData(
      primarySwatch: Colors.pink,
      primaryColor: ThemeService.instance.primaryColor,
      scaffoldBackgroundColor: Colors.transparent,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        bodyLarge: TextStyle(color: ThemeService.instance.textColor),
        bodyMedium: TextStyle(color: ThemeService.instance.textColor),
        titleLarge: TextStyle(color: ThemeService.instance.textColor),
        titleMedium: TextStyle(color: ThemeService.instance.textColor),
        titleSmall: TextStyle(color: ThemeService.instance.textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: ThemeService.instance.primaryColor.withAlpha(77),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeService.instance.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: ThemeService.instance.primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardTheme(
        color: ThemeService.instance.cardColor,
        elevation: 8,
        shadowColor: Colors.black.withAlpha(26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: ThemeService.instance.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: ThemeService.instance.textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: ThemeService.instance.subtitleColor,
          fontSize: 16,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.pink,
      primaryColor: ThemeService.instance.primaryColor,
      scaffoldBackgroundColor: Colors.transparent,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        bodyLarge: TextStyle(color: ThemeService.instance.textColor),
        bodyMedium: TextStyle(color: ThemeService.instance.textColor),
        titleLarge: TextStyle(color: ThemeService.instance.textColor),
        titleMedium: TextStyle(color: ThemeService.instance.textColor),
        titleSmall: TextStyle(color: ThemeService.instance.textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: ThemeService.instance.primaryColor.withAlpha(102),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeService.instance.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: ThemeService.instance.borderColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: ThemeService.instance.primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardTheme(
        color: ThemeService.instance.cardColor,
        elevation: 8,
        shadowColor: Colors.black.withAlpha(77),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: ThemeService.instance.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: ThemeService.instance.textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: ThemeService.instance.subtitleColor,
          fontSize: 16,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return ThemeService.instance.primaryColor;
          }
          return ThemeService.instance.subtitleColor;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return ThemeService.instance.primaryColor.withAlpha(128);
          }
          return ThemeService.instance.borderColor;
        }),
      ),
    );
  }
}
