import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/theme_service.dart';
import '../services/audio_service.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool showHearts;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.showHearts = true,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: ThemeService.instance.backgroundGradient,
          ),
          child: Stack(
            children: [
              if (widget.showHearts) const FloatingHearts(),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class FloatingHearts extends StatefulWidget {
  const FloatingHearts({super.key});

  @override
  State<FloatingHearts> createState() => _FloatingHeartsState();
}

class _FloatingHeartsState extends State<FloatingHearts>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final int _heartCount = 12; // Más corazones para mayor dinamismo

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _animations = [];

    for (int i = 0; i < _heartCount; i++) {
      final controller = AnimationController(
        duration: Duration(seconds: 4 + (i % 3)), // Duraciones variadas
        vsync: this,
      );

      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

      _controllers.add(controller);
      _animations.add(animation);

      // Iniciar animaciones con delays aleatorios
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) {
          controller.repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, child) {
        return Stack(
          children: List.generate(_heartCount, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Positioned(
                  left: _getHorizontalPosition(index, _animations[index].value),
                  top: _getVerticalPosition(index, _animations[index].value),
                  child: Transform.rotate(
                    angle:
                        _animations[index].value *
                        2 *
                        math.pi /
                        4, // Rotación suave
                    child: Transform.scale(
                      scale: _getScale(index, _animations[index].value),
                      child: _buildEnhancedHeart(index),
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }

  double _getHorizontalPosition(int index, double progress) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseX = (index * 60.0) % screenWidth;
    final wave =
        math.sin(progress * 2 * math.pi + index) * 30; // Movimiento ondulante
    return (baseX + wave).clamp(0.0, screenWidth - 30);
  }

  double _getVerticalPosition(int index, double progress) {
    final screenHeight = MediaQuery.of(context).size.height;
    final startY = screenHeight + 50;
    final endY = -50.0;
    final currentY = startY + (endY - startY) * progress;

    // Añadir movimiento de rebote suave
    final bounce = math.sin(progress * math.pi) * 20;
    return currentY + bounce;
  }

  double _getScale(int index, double progress) {
    // Escala que varía durante la animación para efecto de "respiración"
    final baseScale = 0.8 + (index % 3) * 0.1; // Tamaños base variados
    final breathe = math.sin(progress * 4 * math.pi) * 0.2;
    return baseScale + breathe;
  }

  Widget _buildEnhancedHeart(int index) {
    // Más variedad de emojis románticos
    final hearts = [
      '💕',
      '💖',
      '💘',
      '💝',
      '💗',
      '💓',
      '💞',
      '🌹',
      '✨',
      '💫',
      '🌟',
      '💐',
      '🦋',
      '🌸',
      '💮',
      '🌺',
    ];
    final heart = hearts[index % hearts.length];

    // Tamaños variados para más dinamismo
    final sizes = [16.0, 18.0, 20.0, 22.0];
    final size = sizes[index % sizes.length];

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ThemeService.instance.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        heart,
        style: TextStyle(
          fontSize: size,
          shadows: [
            Shadow(
              color: ThemeService.instance.secondaryColor.withOpacity(0.8), 
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
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
        gradient: backgroundColor != null
            ? LinearGradient(
                colors: [backgroundColor!, backgroundColor!.withOpacity(0.8)],
              )
            : ThemeService.instance.primaryGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: ThemeService.instance.buttonShadow,
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading
            ? null
            : () {
                // 🎵 Reproducir sonido al presionar botón
                AudioService.instance.playButtonTap();
                onPressed();
              },
        icon: isLoading
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
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
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
        boxShadow: ThemeService.instance.cardShadow,
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          color: ThemeService.instance.textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: ThemeService.instance.subtitleColor,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            icon,
            color: ThemeService.instance.primaryColor,
            size: 24,
          ),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: ThemeService.instance.errorColor,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: ThemeService.instance.errorColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: isRequired
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
          gradient: ThemeService.instance.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ThemeService.instance.borderColor,
            width: 1,
          ),
          boxShadow: ThemeService.instance.cardShadow,
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
                color: ThemeService.instance.subtitleColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms);
  }
}

// 🎊 NUEVO: Widget de celebración con confetti
class CelebrationExplosion extends StatefulWidget {
  final bool isActive;
  final int intensity; // 1-3 para diferentes niveles de celebración

  const CelebrationExplosion({
    super.key,
    required this.isActive,
    this.intensity = 2,
  });

  @override
  State<CelebrationExplosion> createState() => _CelebrationExplosionState();
}

class _CelebrationExplosionState extends State<CelebrationExplosion>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final int _particleCount = 20;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controllers = [];
    _animations = [];

    for (int i = 0; i < _particleCount; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 1500 + (i % 500)),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

      _controllers.add(controller);
      _animations.add(animation);
    }
  }

  @override
  void didUpdateWidget(CelebrationExplosion oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _startExplosion();
    }
  }

  void _startExplosion() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) {
          _controllers[i].forward().then((_) {
            if (mounted) {
              _controllers[i].reset();
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    return Stack(
      children: List.generate(_particleCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Positioned(
              left: _getParticleX(index, _animations[index].value),
              top: _getParticleY(index, _animations[index].value),
              child: Transform.rotate(
                angle: _animations[index].value * 4 * math.pi,
                child: Transform.scale(
                  scale: _getParticleScale(index, _animations[index].value),
                  child: _buildParticle(index),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  double _getParticleX(int index, double progress) {
    final screenWidth = MediaQuery.of(context).size.width;
    final centerX = screenWidth / 2;
    final angle = (index / _particleCount) * 2 * math.pi;
    final distance = progress * (100 + (index % 50));
    return centerX + math.cos(angle) * distance;
  }

  double _getParticleY(int index, double progress) {
    final screenHeight = MediaQuery.of(context).size.height;
    final centerY = screenHeight / 2;
    final angle = (index / _particleCount) * 2 * math.pi;
    final distance = progress * (100 + (index % 50));
    final gravity = progress * progress * 200; // Efecto de gravedad
    return centerY + math.sin(angle) * distance + gravity;
  }

  double _getParticleScale(int index, double progress) {
    final maxScale = 0.3 + (widget.intensity * 0.2);
    return maxScale * (1.0 - progress); // Se desvanece mientras se aleja
  }

  Widget _buildParticle(int index) {
    final particles = ['🎊', '🎉', '✨', '💫', '🌟', '💖', '💕', '🎈'];
    final particle = particles[index % particles.length];

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(particle, style: const TextStyle(fontSize: 16)),
    );
  }
}
