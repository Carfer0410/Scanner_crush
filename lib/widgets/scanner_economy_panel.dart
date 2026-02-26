import 'package:flutter/material.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/monetization_service.dart';
import '../services/scanner_economy_service.dart';
import '../services/theme_service.dart';

class ScannerEconomyPanel extends StatefulWidget {
  final VoidCallback? onChanged;

  const ScannerEconomyPanel({super.key, this.onChanged});

  @override
  State<ScannerEconomyPanel> createState() => _ScannerEconomyPanelState();
}

class _ScannerEconomyPanelState extends State<ScannerEconomyPanel> {
  ScannerEconomySnapshot? _snapshot;
  List<ScanDailyMission> _missions = const [];
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final snapshot = await ScannerEconomyService.instance.getSnapshot();
      final missions = await ScannerEconomyService.instance.getDailyMissions();
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _missions = missions;
        _loading = false;
        _loadError = null;
      });
      widget.onChanged?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'load_error';
      });
    }
  }

  Future<void> _claimMission(ScanDailyMission mission) async {
    final reward = await ScannerEconomyService.instance.claimMission(mission.id);
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    if (reward > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.coinsClaimedMessage(reward)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 6),
        ),
      );
      await _reload();
    }
  }

  Future<void> _buyScanPack() async {
    final costBefore = await ScannerEconomyService.instance.getCurrentScanPackCost();
    final result = await ScannerEconomyService.instance.buyExtraScansWithCoins();
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;

    String message;
    Color color;
    switch (result) {
      case ScannerCoinSpendResult.success:
        message = loc.scanPackBoughtMessage(
          ScannerEconomyService.instance.scanPackScans,
          costBefore,
        );
        color = Colors.green;
        break;
      case ScannerCoinSpendResult.insufficientCoins:
        message = loc.notEnoughCoinsCurrentPackMessage(costBefore);
        color = Colors.orange;
        break;
      case ScannerCoinSpendResult.dailyLimitReached:
        message = loc.dailyPackLimitReachedMessage;
        color = Colors.orange;
        break;
      case ScannerCoinSpendResult.premiumNotNeeded:
        message = loc.premiumUnlimitedScansMessage;
        color = Colors.blue;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 6),
      ),
    );
    await _reload();
  }

  Future<void> _watchCoinsAd() async {
    final ok = await ScannerEconomyService.instance.watchAdForCoins();
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? loc.coinsEarnedMessage(ScannerEconomyService.instance.coinAdReward)
              : loc.noAdAvailableNowMessage,
        ),
        backgroundColor: ok ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 6),
      ),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (_loading) {
      return _buildShell(
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                loc.loadingRetentionRewards,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: ThemeService.instance.subtitleColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_loadError != null || _snapshot == null) {
      return _buildShell(
        child: Row(
          children: [
            Expanded(
              child: Text(
                loc.retentionPanelUnavailable,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: ThemeService.instance.subtitleColor,
                ),
              ),
            ),
            TextButton(onPressed: _reload, child: Text(loc.retry)),
          ],
        ),
      );
    }

    final snapshot = _snapshot!;
    final isPremium = MonetizationService.instance.isPremium;
    final canShowAd = !isPremium &&
        snapshot.adCoinClaimsToday < ScannerEconomyService.instance.maxCoinAdsPerDay;

    return _buildShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, size: 16, color: Colors.green),
              const SizedBox(width: 6),
              Text(
                loc.dailyRetentionRewardsTitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ThemeService.instance.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.toll, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                loc.coinsLabel(snapshot.coins),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: ThemeService.instance.textColor,
                ),
              ),
              const Spacer(),
              Text(
                loc.streakDaysLabel(snapshot.streakDays),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: ThemeService.instance.subtitleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isPremium)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.amber.withOpacity(0.12),
                border: Border.all(color: Colors.amber.withOpacity(0.35)),
              ),
              child: Text(
                loc.premiumScannerEconomyNotice,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ThemeService.instance.textColor,
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final useColumn = constraints.maxWidth < 420;
                final packButton = OutlinedButton.icon(
                  onPressed:
                      snapshot.remainingScanPackBuys > 0 ? _buyScanPack : null,
                  icon: const Icon(Icons.bolt, size: 15),
                  label: Text(
                    snapshot.remainingScanPackBuys > 0
                        ? loc.scanPackButtonLabel(
                            ScannerEconomyService.instance.scanPackScans,
                            snapshot.nextScanPackCost,
                            snapshot.remainingScanPackBuys,
                          )
                        : loc.scanPackExhaustedToday,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11.5),
                  ),
                );

                final adButton = OutlinedButton.icon(
                  onPressed: _watchCoinsAd,
                  icon: const Icon(Icons.play_circle, size: 15),
                  label: Text(
                    loc.adCoinsButtonLabel(
                      ScannerEconomyService.instance.coinAdReward,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11.5),
                  ),
                );

                if (useColumn) {
                  return Column(
                    children: [
                      SizedBox(width: double.infinity, child: packButton),
                      if (canShowAd) ...[
                        const SizedBox(height: 8),
                        SizedBox(width: double.infinity, child: adButton),
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: packButton),
                    if (canShowAd) ...[
                      const SizedBox(width: 8),
                      Expanded(child: adButton),
                    ],
                  ],
                );
              },
            ),
          if (_missions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              loc.dailyMissionsTitle,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ThemeService.instance.textColor,
              ),
            ),
            const SizedBox(height: 6),
            ..._missions.map((m) {
              final isEn = Localizations.localeOf(context).languageCode == 'en';
              final title = isEn ? m.titleEn : m.titleEs;
              final actionEnabled = m.completed && !m.claimed;

              return Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: ThemeService.instance.surfaceColor.withOpacity(0.35),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$title (${m.progress}/${m.target})',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: actionEnabled ? () => _claimMission(m) : null,
                      child: Text(m.claimed ? loc.claimedLabel : '+${m.rewardCoins}c'),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildShell({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeService.instance.cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeService.instance.borderColor),
      ),
      child: child,
    );
  }
}

