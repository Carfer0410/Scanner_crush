import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/ad_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = false;

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.block,
      'title': 'Sin Anuncios',
      'description': 'Disfruta de la experiencia completa sin interrupciones',
    },
    {
      'icon': Icons.all_inclusive,
      'title': 'Escaneos Ilimitados',
      'description': 'Escanea cuantas veces quieras sin restricciones',
    },
    {
      'icon': Icons.star,
      'title': 'Resultados Exclusivos',
      'description': 'Accede a mensajes y predicciones especiales',
    },
    {
      'icon': Icons.favorite_border,
      'title': 'Historial de Crushes',
      'description': 'Guarda y revisa todos tus escaneos anteriores',
    },
    {
      'icon': Icons.palette,
      'title': 'Temas Especiales',
      'description': 'Personaliza la app con temas únicos y exclusivos',
    },
    {
      'icon': Icons.support_agent,
      'title': 'Soporte Premium',
      'description': 'Atención prioritaria y soporte técnico avanzado',
    },
  ];

  Future<void> _purchasePremium() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate purchase process
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, implement actual in-app purchase logic here
      // For now, we'll just simulate a successful purchase
      await AdService.instance.setPremiumUser(true);

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 50),
                    const SizedBox(height: 16),
                    Text(
                      '¡Bienvenido a Premium!',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  'Ahora puedes disfrutar de todas las funciones premium sin límites.',
                  style: GoogleFonts.poppins(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(
                        context,
                        true,
                      ); // Return to previous screen with success
                    },
                    child: Text(
                      'Comenzar',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: ThemeService.instance.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en la compra: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _restorePurchases() async {
    // In a real app, implement restore purchases logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se encontraron compras anteriores'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: ThemeService.instance.textColor,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Premium',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeService.instance.textColor,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Premium crown icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(Icons.stars, color: Colors.white, size: 50),
                      ).animate().scale(delay: 200.ms, duration: 800.ms),

                      const SizedBox(height: 30),

                      Text(
                        'Desbloquea el Poder\ndel Amor Premium',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ThemeService.instance.textColor,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 16),

                      Text(
                        'Obtén acceso completo a todas las funciones especiales',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: ThemeService.instance.textColor.withOpacity(
                            0.7,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 600.ms),

                      const SizedBox(height: 40),

                      // Features list
                      ..._features.asMap().entries.map((entry) {
                        final index = entry.key;
                        final feature = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: ThemeService.instance.cardColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ThemeService.instance.primaryColor
                                      .withOpacity(0.2),
                                ),
                                child: Icon(
                                  feature['icon'],
                                  color: ThemeService.instance.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      feature['title'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeService.instance.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      feature['description'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: ThemeService.instance.textColor
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().slideX(
                          delay: Duration(milliseconds: 800 + (index * 100)),
                          duration: 600.ms,
                        );
                      }).toList(),

                      const SizedBox(height: 40),

                      // Price card
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple, Colors.deepPurple],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Oferta Especial',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$2.99',
                                  style: GoogleFonts.poppins(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '/mes',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cancela cuando quieras',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ).animate().scale(delay: 1.2.seconds),

                      const SizedBox(height: 30),

                      // Purchase button
                      GradientButton(
                        text: _isLoading ? 'Procesando...' : 'Obtener Premium',
                        icon: Icons.credit_card,
                        backgroundColor: Colors.amber,
                        onPressed: _purchasePremium,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 16),

                      // Restore purchases link
                      TextButton(
                        onPressed: _restorePurchases,
                        child: Text(
                          'Restaurar compras',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: ThemeService.instance.textColor.withOpacity(
                              0.6,
                            ),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
