import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crush_result.dart';
import 'daily_love_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CrushService {
  static final CrushService _instance = CrushService._internal();
  static CrushService get instance => _instance;
  CrushService._internal();

  // Lista de celebridades populares
  final List<String> _celebrities = [
    "Ryan Gosling",
    "Emma Stone",
    "Timothée Chalamet",
    "Zendaya",
    "Tom Holland",
    "Anya Taylor-Joy",
    "Michael B. Jordan",
    "Margot Robbie",
    "Chris Evans",
    "Scarlett Johansson",
    "Ryan Reynolds",
    "Blake Lively",
    "Leonardo DiCaprio",
    "Jennifer Lawrence",
    "Brad Pitt",
    "Emma Watson",
    "Sebastian Stan",
    "Elizabeth Olsen",
    "Oscar Isaac",
    "Florence Pugh",
    "Adam Driver",
    "Saoirse Ronan",
    "Regé-Jean Page",
    "Bridgerton Cast",
    "Harry Styles",
    "Taylor Swift",
    "Dua Lipa",
    "Shawn Mendes",
    "Bad Bunny",
    "Billie Eilish",
    "The Weeknd",
    "Ariana Grande",
    "BTS",
    "Stray Kids",
    "NewJeans",
    "TWICE",
    "BLACKPINK",
    "IU",
    "Pedro Pascal",
    "Oscar Isaac",
    "Michael Cera",
    "Jacob Elordi",
    "Sydney Sweeney",
    "Maddie Ziegler",
    "Noah Centineo",
    "Charles Melton",
  ];

  List<String> get celebrities => _celebrities;

  final List<String> _emojis = [
    "💕",
    "💖",
    "💘",
    "💝",
    "💗",
    "💓",
    "💞",
    "💌",
    "🌹",
    "❤️",
    "🥰",
    "😍",
    "🌟",
    "✨",
    "💫",
    "🦋",
    "🌸",
    "🌺",
    "🍀",
    "🌙",
  ];

  int _generateCompatibilityPercentage(String name1, String name2) {
    // Create a simple "algorithm" based on names to make results consistent
    final combined = (name1 + name2).toLowerCase();
    var hash = 0;
    for (int i = 0; i < combined.length; i++) {
      hash = ((hash << 5) - hash + combined.codeUnitAt(i)) & 0xffffffff;
    }

    // Ensure percentage is between 30-100 for more optimistic results
    final percentage = 30 + (hash.abs() % 71);
    return percentage;
  }

  String _getRandomMessage(int percentage, AppLocalizations localizations, {bool isCelebrity = false}) {
    final random = Random();

    // Mensajes especiales para celebridades
    if (isCelebrity) {
      return _getCelebrityMessage(random.nextInt(15) + 1, localizations);
    }

    if (percentage >= 80) {
      return _getRomanticMessage(random.nextInt(20) + 1, localizations);
    } else if (percentage >= 60) {
      return _getMysteriousMessage(random.nextInt(20) + 1, localizations);
    } else if (percentage >= 45) {
      return _getFunMessage(random.nextInt(20) + 1, localizations);
    } else {
      return _getLowCompatibilityMessage(random.nextInt(10) + 1, localizations);
    }
  }

  String _getCelebrityMessage(int index, AppLocalizations localizations) {
    switch (index) {
      case 1: return localizations.celebrityMessage1;
      case 2: return localizations.celebrityMessage2;
      case 3: return localizations.celebrityMessage3;
      case 4: return localizations.celebrityMessage4;
      case 5: return localizations.celebrityMessage5;
      case 6: return localizations.celebrityMessage6;
      case 7: return localizations.celebrityMessage7;
      case 8: return localizations.celebrityMessage8;
      case 9: return localizations.celebrityMessage9;
      case 10: return localizations.celebrityMessage10;
      case 11: return localizations.celebrityMessage11;
      case 12: return localizations.celebrityMessage12;
      case 13: return localizations.celebrityMessage13;
      case 14: return localizations.celebrityMessage14;
      case 15: return localizations.celebrityMessage15;
      default: return localizations.celebrityMessage1;
    }
  }

  String _getRomanticMessage(int index, AppLocalizations localizations) {
    switch (index) {
      case 1: return localizations.romanticMessage1;
      case 2: return localizations.romanticMessage2;
      case 3: return localizations.romanticMessage3;
      case 4: return localizations.romanticMessage4;
      case 5: return localizations.romanticMessage5;
      case 6: return localizations.romanticMessage6;
      case 7: return localizations.romanticMessage7;
      case 8: return localizations.romanticMessage8;
      case 9: return localizations.romanticMessage9;
      case 10: return localizations.romanticMessage10;
      case 11: return localizations.romanticMessage11;
      case 12: return localizations.romanticMessage12;
      case 13: return localizations.romanticMessage13;
      case 14: return localizations.romanticMessage14;
      case 15: return localizations.romanticMessage15;
      case 16: return localizations.romanticMessage16;
      case 17: return localizations.romanticMessage17;
      case 18: return localizations.romanticMessage18;
      case 19: return localizations.romanticMessage19;
      case 20: return localizations.romanticMessage20;
      default: return localizations.romanticMessage1;
    }
  }

  String _getMysteriousMessage(int index, AppLocalizations localizations) {
    switch (index) {
      case 1: return localizations.mysteriousMessage1;
      case 2: return localizations.mysteriousMessage2;
      case 3: return localizations.mysteriousMessage3;
      case 4: return localizations.mysteriousMessage4;
      case 5: return localizations.mysteriousMessage5;
      case 6: return localizations.mysteriousMessage6;
      case 7: return localizations.mysteriousMessage7;
      case 8: return localizations.mysteriousMessage8;
      case 9: return localizations.mysteriousMessage9;
      case 10: return localizations.mysteriousMessage10;
      case 11: return localizations.mysteriousMessage11;
      case 12: return localizations.mysteriousMessage12;
      case 13: return localizations.mysteriousMessage13;
      case 14: return localizations.mysteriousMessage14;
      case 15: return localizations.mysteriousMessage15;
      case 16: return localizations.mysteriousMessage16;
      case 17: return localizations.mysteriousMessage17;
      case 18: return localizations.mysteriousMessage18;
      case 19: return localizations.mysteriousMessage19;
      case 20: return localizations.mysteriousMessage20;
      default: return localizations.mysteriousMessage1;
    }
  }

  String _getFunMessage(int index, AppLocalizations localizations) {
    switch (index) {
      case 1: return localizations.funMessage1;
      case 2: return localizations.funMessage2;
      case 3: return localizations.funMessage3;
      case 4: return localizations.funMessage4;
      case 5: return localizations.funMessage5;
      case 6: return localizations.funMessage6;
      case 7: return localizations.funMessage7;
      case 8: return localizations.funMessage8;
      case 9: return localizations.funMessage9;
      case 10: return localizations.funMessage10;
      case 11: return localizations.funMessage11;
      case 12: return localizations.funMessage12;
      case 13: return localizations.funMessage13;
      case 14: return localizations.funMessage14;
      case 15: return localizations.funMessage15;
      case 16: return localizations.funMessage16;
      case 17: return localizations.funMessage17;
      case 18: return localizations.funMessage18;
      case 19: return localizations.funMessage19;
      case 20: return localizations.funMessage20;
      default: return localizations.funMessage1;
    }
  }

  String _getLowCompatibilityMessage(int index, AppLocalizations localizations) {
    switch (index) {
      case 1: return localizations.lowCompatibilityMessage1;
      case 2: return localizations.lowCompatibilityMessage2;
      case 3: return localizations.lowCompatibilityMessage3;
      case 4: return localizations.lowCompatibilityMessage4;
      case 5: return localizations.lowCompatibilityMessage5;
      case 6: return localizations.lowCompatibilityMessage6;
      case 7: return localizations.lowCompatibilityMessage7;
      case 8: return localizations.lowCompatibilityMessage8;
      case 9: return localizations.lowCompatibilityMessage9;
      case 10: return localizations.lowCompatibilityMessage10;
      default: return localizations.lowCompatibilityMessage1;
    }
  }

  bool _isCelebrity(String name) {
    return _celebrities.any(
      (celebrity) =>
          celebrity.toLowerCase().contains(name.toLowerCase()) ||
          name.toLowerCase().contains(celebrity.toLowerCase()),
    );
  }

  String _getRandomEmoji() {
    final random = Random();
    return _emojis[random.nextInt(_emojis.length)];
  }

  Future<CrushResult> generateResult(String userName, String crushName, AppLocalizations localizations) async {
    // Check if we already have a result for this combination
    final existingResult = await getSavedResult(userName, crushName);
    if (existingResult != null) {
      return existingResult;
    }

    // Check if crush is a celebrity
    final isCelebrity = _isCelebrity(crushName);

    // Generate new result
    final percentage = _generateCompatibilityPercentage(userName, crushName);
    final message = _getRandomMessage(percentage, localizations, isCelebrity: isCelebrity);
    final emoji = _getRandomEmoji();

    final result = CrushResult(
      userName: userName,
      crushName: crushName,
      percentage: percentage,
      message: message,
      emoji: emoji,
      timestamp: DateTime.now(),
      isCelebrity: isCelebrity,
    );

    // Update statistics
    await DailyLoveService.instance.incrementTotalScans();
    await DailyLoveService.instance.addCompatibilityScore(
      percentage.toDouble(),
    );

    // Save result
    await _saveResult(result);

    return result;
  }

  // Método alternativo para cuando AppLocalizations no está disponible
  Future<CrushResult> generateSimpleResult(String userName, String crushName) async {
    // Check if we already have a result for this combination
    final existingResult = await getSavedResult(userName, crushName);
    if (existingResult != null) {
      return existingResult;
    }

    // Check if crush is a celebrity
    final isCelebrity = _isCelebrity(crushName);

    // Generate new result with default English messages
    final percentage = _generateCompatibilityPercentage(userName, crushName);
    final message = _getSimpleMessage(percentage, isCelebrity: isCelebrity);
    final emoji = _getRandomEmoji();

    final result = CrushResult(
      userName: userName,
      crushName: crushName,
      percentage: percentage,
      message: message,
      emoji: emoji,
      timestamp: DateTime.now(),
      isCelebrity: isCelebrity,
    );

    // Update statistics
    await DailyLoveService.instance.incrementTotalScans();
    await DailyLoveService.instance.addCompatibilityScore(
      percentage.toDouble(),
    );

    // Save result
    await _saveResult(result);

    return result;
  }

  // Método para obtener mensajes simples sin localización
  String _getSimpleMessage(int percentage, {bool isCelebrity = false}) {
    final random = Random();

    if (isCelebrity) {
      final messages = [
        "You have great taste in celebrities! ⭐",
        "This celebrity crush makes perfect sense! 💫",
        "Your celebrity match has potential! 🌟",
        "This is a classic celebrity crush! ✨",
        "You and this star could be perfect together! 🎬",
      ];
      return messages[random.nextInt(messages.length)];
    }

    if (percentage >= 80) {
      final messages = [
        "This could be your perfect match! 💕",
        "The stars are perfectly aligned! ✨",
        "You two are meant to be together! 💖",
        "This is true love material! 💘",
        "Your hearts beat as one! 💓",
      ];
      return messages[random.nextInt(messages.length)];
    } else if (percentage >= 60) {
      final messages = [
        "There's definitely something special here! 💫",
        "The chemistry is undeniable! ⚡",
        "This connection has real potential! 🌟",
        "Your energies complement each other! 💜",
        "Something beautiful could blossom here! 🌸",
      ];
      return messages[random.nextInt(messages.length)];
    } else if (percentage >= 45) {
      final messages = [
        "A fun adventure awaits! 🎉",
        "This could be an interesting journey! 🚀",
        "You bring out each other's playful side! 😄",
        "Great friendship with romantic potential! 💛",
        "Your connection is full of surprises! 🎈",
      ];
      return messages[random.nextInt(messages.length)];
    } else {
      final messages = [
        "Sometimes opposites attract! 🧲",
        "Friendship might be the perfect foundation! 👫",
        "Every connection teaches us something! 📚",
        "The universe has interesting plans! 🌌",
        "Compatibility comes in many forms! 💫",
      ];
      return messages[random.nextInt(messages.length)];
    }
  }

  Future<void> _saveResult(CrushResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        '${result.userName.toLowerCase()}_${result.crushName.toLowerCase()}';
    final jsonString = jsonEncode(result.toJson());
    await prefs.setString('result_$key', jsonString);
  }

  Future<CrushResult?> getSavedResult(String userName, String crushName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${userName.toLowerCase()}_${crushName.toLowerCase()}';
    final jsonString = prefs.getString('result_$key');

    if (jsonString != null) {
      final json = jsonDecode(jsonString);
      return CrushResult.fromJson(json);
    }

    return null;
  }

  Future<List<CrushResult>> getAllSavedResults() async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((key) => key.startsWith('result_')).toList();
    final results = <CrushResult>[];

    for (final key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        results.add(CrushResult.fromJson(json));
      }
    }

    // Sort by timestamp (newest first)
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }
}
