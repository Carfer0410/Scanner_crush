import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/theme_service.dart';
import '../services/monetization_service.dart';
import '../screens/premium_screen.dart';

/// Widget promocional sutil para Premium
class SubtlePremiumPromo extends StatelessWidget {
  final String message;
  final String ctaText;
  
  const SubtlePremiumPromo({
    Key? key,
    required this.message,
    this.ctaText = 'Upgrade',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // No mostrar si ya es premium
    if (MonetizationService.instance.isPremium) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeService.instance.primaryColor.withOpacity(0.1),
            ThemeService.instance.secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeService.instance.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ThemeService.instance.primaryColor.withOpacity(0.2),
            ),
            child: Icon(
              Icons.star_border,
              size: 16,
              color: ThemeService.instance.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: ThemeService.instance.textColor.withOpacity(0.8),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _navigateToPremium(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ThemeService.instance.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                ctaText,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPremium(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumScreen()),
    );
  }
}

/// Widget para mostrar beneficios específicos
class PremiumBenefitChip extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isPremiumOnly;

  const PremiumBenefitChip({
    Key? key,
    required this.text,
    required this.icon,
    this.isPremiumOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPremium = MonetizationService.instance.isPremium;
    final canAccess = !isPremiumOnly || isPremium;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: canAccess 
          ? Colors.green.withOpacity(0.1)
          : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: canAccess 
            ? Colors.green.withOpacity(0.3)
            : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            canAccess ? icon : Icons.lock_outline,
            size: 14,
            color: canAccess ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: canAccess ? Colors.green : Colors.grey,
            ),
          ),
          if (!canAccess) ...[
            const SizedBox(width: 4),
            Icon(Icons.star, size: 12, color: Colors.amber),
          ],
        ],
      ),
    );
  }
}

/// Overlay sutil para funciones premium
class PremiumOverlay extends StatelessWidget {
  final Widget child;
  final String featureName;
  final bool showOverlay;

  const PremiumOverlay({
    Key? key,
    required this.child,
    required this.featureName,
    this.showOverlay = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPremium = MonetizationService.instance.isPremium;
    
    if (isPremium || !showOverlay) {
      return child;
    }

    return Stack(
      children: [
        // Contenido borroso
        Opacity(
          opacity: 0.3,
          child: child,
        ),
        
        // Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    featureName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Solo Premium',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
