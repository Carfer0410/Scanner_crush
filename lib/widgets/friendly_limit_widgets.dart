import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/theme_service.dart';

/// Widget para mostrar límites de forma amigable
class FriendlyLimitDialog extends StatelessWidget {
  final int remainingScans;
  final VoidCallback? onWatchAd;
  final VoidCallback? onUpgrade;
  
  const FriendlyLimitDialog({
    Key? key,
    required this.remainingScans,
    this.onWatchAd,
    this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.pink.shade50],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono amigable
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.shade100,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 40,
                color: Colors.orange.shade600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Título amigable
            Text(
        remainingScans > 0
          ? (AppLocalizations.of(context)?.remainingScans(remainingScans) ?? '¡Te quedan $remainingScans escaneos hoy! 💕')
          : (AppLocalizations.of(context)?.noScansLeft ?? '¡Has explorado mucho amor hoy! 🌟'),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeService.instance.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Mensaje motivacional
            Text(
              remainingScans > 0
                  ? (AppLocalizations.of(context)?.useWisely ?? 'Úsalos sabiamente o consigue más abajo 😉')
                  : (AppLocalizations.of(context)?.moreTomorrow ?? 'Mañana tendrás 5 escaneos frescos esperándote, o puedes conseguir más ahora:'),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: ThemeService.instance.subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Opciones no agresivas
            if (remainingScans == 0) ...[
              // Opción 1: Ver anuncio
              _buildOption(
                icon: Icons.play_circle_outline,
                title: AppLocalizations.of(context)?.watchShortAd ?? 'Ver anuncio corto',
                subtitle: AppLocalizations.of(context)?.extraScansFree ?? '+2 escaneos gratis',
                color: Colors.green,
                onTap: onWatchAd,
              ),
              
              const SizedBox(height: 12),
              
              // Opción 2: Premium
              _buildOption(
                icon: Icons.star_border,
                title: AppLocalizations.of(context)?.unlimitedScans ?? 'Escaneos ilimitados',
                subtitle: AppLocalizations.of(context)?.premiumPriceText ?? 'Premium por \$2.99/mes',
                color: Colors.purple,
                onTap: onUpgrade,
              ),
              
              const SizedBox(height: 12),
              
              // Opción 3: Esperar
              _buildOption(
                icon: Icons.schedule,
                title: AppLocalizations.of(context)?.waitUntilTomorrow ?? 'Esperar hasta mañana',
                subtitle: AppLocalizations.of(context)?.freshScans ?? '5 escaneos frescos gratis',
                color: Colors.blue,
                onTap: () => Navigator.pop(context),
              ),
            ],
            
            if (remainingScans > 0)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)?.perfectScan ?? '¡Perfecto, a escanear! 💘',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: ThemeService.instance.primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: ThemeService.instance.textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: ThemeService.instance.subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar contador de escaneos restantes
class ScanCounterWidget extends StatelessWidget {
  final int remainingScans;
  final bool isPremium;
  
  const ScanCounterWidget({
    Key? key,
    required this.remainingScans,
    required this.isPremium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si es premium O tiene escaneos ilimitados (-1), mostrar ILIMITADO
    if (isPremium || remainingScans == -1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.amber, Colors.orange]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.all_inclusive, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                AppLocalizations.of(context)?.unlimitedScans.toUpperCase() ?? 'ESCANEOS ILIMITADOS',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    
    // Para usuarios gratuitos con escaneos limitados
    final displayCount = remainingScans.clamp(0, 999); // Asegurar que no sea negativo
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getCounterColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getCounterColor().withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, color: _getCounterColor(), size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$displayCount',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getCounterColor(),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getCounterColor() {
    if (remainingScans == -1) return Colors.amber; // Ilimitado
    if (remainingScans >= 3) return Colors.green;
    if (remainingScans >= 1) return Colors.orange;
    return Colors.red;
  }
}
