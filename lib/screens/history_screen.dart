import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/crush_service.dart';
import '../services/locale_service.dart';
import '../models/crush_result.dart';
import '../generated/l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<CrushResult> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final results = await CrushService.instance.getAllSavedResults();
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorLoadingHistory(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${AppLocalizations.of(context)!.agoTime} ${difference.inMinutes} ${AppLocalizations.of(context)!.minutes}';
      }
      return '${AppLocalizations.of(context)!.agoTime} ${difference.inHours}${AppLocalizations.of(context)!.hours}';
    } else if (difference.inDays < 7) {
      return '${AppLocalizations.of(context)!.agoTime} ${difference.inDays} ${AppLocalizations.of(context)!.days}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 80) {
      return const Color(0xFF4CAF50); // Green - Perfect compatibility
    } else if (percentage >= 60) {
      return const Color(0xFFFF9800); // Orange - Great compatibility
    } else if (percentage >= 40) {
      return const Color(0xFF2196F3); // Blue - Good compatibility (better visibility)
    } else {
      return const Color(0xFFE91E63); // Pink - There is potential
    }
  }

  Future<void> _shareResult(CrushResult result) async {
    try {
      await Share.share(result.shareText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorSharingResult),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService.instance,
      builder: (context, child) {
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
                          AppLocalizations.of(context)!.history,
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
                    child: _isLoading
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ThemeService.instance.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Cargando historial...',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: ThemeService.instance.textColor.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _results.isEmpty
                            ? _buildEmptyState()
                            : _buildHistoryList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ThemeService.instance.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.history,
              color: ThemeService.instance.primaryColor,
              size: 50,
            ),
          ).animate().scale(delay: 200.ms),

          const SizedBox(height: 30),

          Text(
            AppLocalizations.of(context)!.noHistoryYet,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ThemeService.instance.textColor,
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 16),

          Text(
            AppLocalizations.of(context)!.noHistoryDescription,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: ThemeService.instance.subtitleColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 600.ms),

          const SizedBox(height: 40),

          GradientButton(
            text: AppLocalizations.of(context)!.startScanning,
            icon: Icons.favorite,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return _buildHistoryCard(result, index);
      },
    );
  }

  Widget _buildHistoryCard(CrushResult result, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: ThemeService.instance.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeService.instance.borderColor,
          width: 1,
        ),
        boxShadow: ThemeService.instance.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header with names and percentage
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${result.userName} + ${result.crushName}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(result.timestamp),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: ThemeService.instance.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getPercentageColor(result.percentage),
                    boxShadow: [
                      BoxShadow(
                        color: _getPercentageColor(result.percentage).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${result.percentage}%',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          result.emoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeService.instance.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThemeService.instance.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Text(
                result.message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: ThemeService.instance.textColor,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _shareResult(result),
                icon: const Icon(Icons.share, size: 18),
                label: Text(
                  AppLocalizations.of(context)?.share ?? 'Compartir',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeService.instance.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideX(
          delay: Duration(milliseconds: index * 100),
          duration: 600.ms,
        );
  }
}
