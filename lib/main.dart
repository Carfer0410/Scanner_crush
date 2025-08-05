import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/welcome_screen.dart';
import 'services/ad_service.dart';
import 'services/theme_service.dart';
import 'services/daily_love_service.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize services
  await AdService.instance.initialize();
  await ThemeService.instance.initialize();
  await DailyLoveService.instance.initialize();
  await AudioService.instance.initialize();
  runApp(const ScannerCrushApp());
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
      listenable: ThemeService.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'Escáner de Crush 💘',
          debugShowCheckedModeBanner: false,
          showPerformanceOverlay: false,
          showSemanticsDebugger: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: ThemeService.instance.isDarkMode 
              ? ThemeMode.dark 
              : ThemeMode.light,
          home: const WelcomeScreen(),
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
          shadowColor: ThemeService.instance.primaryColor.withOpacity(0.3),
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
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: ThemeService.instance.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: TextStyle(color: ThemeService.instance.textColor),
        bodyMedium: TextStyle(color: ThemeService.instance.textColor),
        titleLarge: TextStyle(color: ThemeService.instance.textColor),
        titleMedium: TextStyle(color: ThemeService.instance.textColor),
        titleSmall: TextStyle(color: ThemeService.instance.textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: ThemeService.instance.primaryColor.withOpacity(0.4),
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
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: ThemeService.instance.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
        thumbColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return ThemeService.instance.primaryColor;
            }
            return ThemeService.instance.subtitleColor;
          },
        ),
        trackColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return ThemeService.instance.primaryColor.withOpacity(0.5);
            }
            return ThemeService.instance.borderColor;
          },
        ),
      ),
    );
  }
}
