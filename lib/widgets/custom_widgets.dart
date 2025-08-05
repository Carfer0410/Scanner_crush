import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/theme_service.dart';

class AnimatedBackground extends StatelessWidget {
  final Widget child;
  final bool showHearts;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.showHearts = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: ThemeService.instance.backgroundGradient,
      ),
      child: Stack(children: [if (showHearts) const FloatingHearts(), child]),
    );
  }
}

class FloatingHearts extends StatelessWidget {
  const FloatingHearts({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(8, (index) {
        return Positioned(
          left: (index * 50.0) % MediaQuery.of(context).size.width,
          top: (index * 80.0) % MediaQuery.of(context).size.height,
          child: _buildFloatingHeart(index),
        );
      }),
    );
  }

  Widget _buildFloatingHeart(int index) {
    final hearts = ['💕', '💖', '💘', '💝', '💗', '💓', '💞', '🌹'];
    final heart = hearts[index % hearts.length];

    return Text(heart, style: const TextStyle(fontSize: 20))
        .animate(onPlay: (controller) => controller.repeat())
        .moveY(
          begin: 0,
          end: -100,
          duration: Duration(seconds: 3 + (index % 3)),
          curve: Curves.easeInOut,
        )
        .fadeIn(duration: 1.seconds)
        .fadeOut(delay: Duration(seconds: 2 + (index % 2)));
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              backgroundColor != null
                  ? [backgroundColor!, backgroundColor!.withOpacity(0.8)]
                  : [
                    ThemeService.instance.primaryColor,
                    ThemeService.instance.secondaryColor,
                  ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: ThemeService.instance.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Icon(icon ?? Icons.favorite, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    ).animate().scale(delay: 300.ms, duration: 600.ms);
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final bool isRequired;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: ThemeService.instance.textColor, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: ThemeService.instance.textColor.withOpacity(0.6),
          ),
          prefixIcon: Icon(icon, color: ThemeService.instance.primaryColor),
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
        validator:
            isRequired
                ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                }
                : null,
      ),
    ).animate().slideX(delay: 200.ms, duration: 600.ms);
  }
}

class ResultCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onTap;

  const ResultCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeService.instance.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeService.instance.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: ThemeService.instance.textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms);
  }
}
