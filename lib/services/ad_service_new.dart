import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  static AdService get instance => _instance;
  AdService._internal();

  bool _isPremiumUser = false;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremiumUser = prefs.getBool('premium_user') ?? false;
  }

  bool get isPremiumUser => _isPremiumUser;

  Future<bool> showInterstitialAd() async {
    if (_isPremiumUser) {
      return true; // Allow action without ad for premium users
    }

    // Placeholder: simulate ad showing
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  Future<void> setPremiumUser(bool isPremium) async {
    _isPremiumUser = isPremium;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('premium_user', isPremium);
  }

  Widget createBannerAd() {
    if (_isPremiumUser) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 60,
      color: Colors.grey[200],
      child: const Center(
        child: Text('Ad Space', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  void dispose() {
    // Placeholder for cleanup
  }
}
