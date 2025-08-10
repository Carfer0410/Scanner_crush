import 'package:flutter/material.dart';
import 'services/theme_service.dart';
import 'models/app_theme.dart';

class TestColorSystemScreen extends StatefulWidget {
  const TestColorSystemScreen({super.key});

  @override
  State<TestColorSystemScreen> createState() => _TestColorSystemScreenState();
}

class _TestColorSystemScreenState extends State<TestColorSystemScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: ThemeService.instance.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: ThemeService.instance.iconColor,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Test del Sistema de Colores',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ThemeService.instance.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Current theme info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: ThemeService.instance.cardGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: ThemeService.instance.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tema Actual: ${ThemeService.instance.currentAppTheme.name}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ThemeService.instance.currentAppTheme.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeService.instance.subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Es tema oscuro: ${ThemeService.instance.isInherentlyDarkTheme() ? "Sí" : "No"}',
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                      Text(
                        'Modo oscuro activado: ${ThemeService.instance.isDarkMode ? "Sí" : "No"}',
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Color samples
                Text(
                  'Ejemplos de Colores',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeService.instance.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _colorSample('Texto Principal', ThemeService.instance.textColor),
                      _colorSample('Texto Secundario', ThemeService.instance.subtitleColor),
                      _colorSample('Color Primario', ThemeService.instance.primaryColor),
                      _colorSample('Color Secundario', ThemeService.instance.secondaryColor),
                      _colorSample('Color de Ícono', ThemeService.instance.iconColor),
                      _colorSample('Color de Borde', ThemeService.instance.borderColor),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Theme switcher
                Text(
                  'Cambiar Tema para Probar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeService.instance.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ThemeType.values.map((themeType) {
                    final theme = AppTheme.getThemeByType(themeType);
                    final isSelected = ThemeService.instance.currentTheme == themeType;
                    
                    return GestureDetector(
                      onTap: () {
                        ThemeService.instance.changeTheme(themeType);
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? ThemeService.instance.primaryColor
                            : ThemeService.instance.cardColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: ThemeService.instance.borderColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          theme.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected 
                              ? Colors.white
                              : ThemeService.instance.textColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _colorSample(String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: ThemeService.instance.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
            style: TextStyle(
              fontSize: 12,
              color: color.computeLuminance() > 0.5 ? Colors.black54 : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
