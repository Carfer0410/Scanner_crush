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

  // Lista expandida de 500+ celebridades trending 2025 🌟
  final List<String> _celebrities = [
    // 🎬 HOLLYWOOD A-LIST
    "Ryan Gosling", "Emma Stone", "Timothée Chalamet", "Zendaya", "Tom Holland",
    "Anya Taylor-Joy", "Michael B. Jordan", "Margot Robbie", "Chris Evans", "Scarlett Johansson",
    "Ryan Reynolds", "Blake Lively", "Leonardo DiCaprio", "Jennifer Lawrence", "Brad Pitt",
    "Emma Watson", "Sebastian Stan", "Elizabeth Olsen", "Oscar Isaac", "Florence Pugh",
    "Adam Driver", "Saoirse Ronan", "Regé-Jean Page", "Pedro Pascal", "Jacob Elordi",
    "Sydney Sweeney", "Noah Centineo", "Charles Melton", "Maddie Ziegler", "Glen Powell",
    
    // 🔥 NUEVAS GENERACIONES 2025
    "Jenna Ortega", "Anya Chalotra", "Hunter Schafer", "Barbie Ferreira", "Alexa Demie",
    "Storm Reid", "Kaitlyn Dever", "Thomasin McKenzie", "Millicent Simmonds", "Julia Garner",
    "Rachel Zegler", "Halle Bailey", "Yara Shahidi", "Lana Condor", "Anna Cathcart",
    "Madison Beer", "Dixie D'Amelio", "Addison Rae", "Emma Chamberlain", "James Charles",
    "Noah Beck", "Bryce Hall", "Chase Hudson", "Anthony Reeves", "Payton Moormeier",
    
    // 🎵 MÚSICA GLOBAL
    "Harry Styles", "Taylor Swift", "Dua Lipa", "Olivia Rodrigo", "Billie Eilish",
    "The Weeknd", "Ariana Grande", "Post Malone", "Travis Scott", "Drake",
    "Shawn Mendes", "Justin Bieber", "Ed Sheeran", "Bruno Mars", "The Chainsmokers",
    "Camila Cabello", "Selena Gomez", "Doja Cat", "Megan Thee Stallion", "Cardi B",
    "SZA", "Halsey", "Lorde", "Charli XCX", "Troye Sivan", "Lana Del Rey",
    
    // 🇰🇷 K-POP SUPERSTARS
    "BTS", "RM", "Jin", "Suga", "J-Hope", "Jimin", "V", "Jungkook",
    "BLACKPINK", "Jennie", "Jisoo", "Rosé", "Lisa", "TWICE", "Nayeon", "Jeongyeon",
    "Momo", "Sana", "Jihyo", "Mina", "Dahyun", "Chaeyoung", "Tzuyu",
    "Stray Kids", "Bang Chan", "Lee Know", "Changbin", "Hyunjin", "Han", "Felix", "Seungmin", "I.N",
    "NewJeans", "Minji", "Hanni", "Danielle", "Haerin", "Hyein",
    "aespa", "Karina", "Giselle", "Winter", "Ningning", "IU", "Taeyeon", "IVE",
    "ITZY", "LE SSERAFIM", "(G)I-DLE", "Red Velvet", "MAMAMOO", "SEVENTEEN",
    "ENHYPEN", "TXT", "ATEEZ", "ITZY", "Yeji", "Lia", "Ryujin", "Chaeryeong", "Yuna",
    
    // 🇪🇸 LATINOAMÉRICA
    "Bad Bunny", "Karol G", "Rosalía", "Aitana", "Ana Mena", "Lola Índigo",
    "C. Tangana", "Rauw Alejandro", "Maluma", "J Balvin", "Ozuna", "Anuel AA",
    "Daddy Yankee", "Nicky Jam", "Don Omar", "Wisin", "Yandel", "Farruko",
    "Becky G", "Natti Natasha", "Tini", "María Becerra", "Emilia", "Cazzu",
    "Paulo Londra", "Duki", "Bizarrap", "Peso Pluma", "Feid", "Ryan Castro",
    
    // 🎭 NETFLIX & STREAMING STARS
    "Noah Centineo", "Lana Condor", "Ross Butler", "Anna Cathcart", "Jordan Fisher",
    "Chase Stokes", "Madelyn Cline", "Rudy Pankow", "Madison Bailey", "Jonathan Daviss",
    "Austin Butler", "Jacob Elordi", "Alexa Demie", "Sydney Sweeney", "Hunter Schafer",
    "Zendaya", "Tom Holland", "Millie Bobby Brown", "Finn Wolfhard", "Gaten Matarazzo",
    "Caleb McLaughlin", "Sadie Sink", "Maya Hawke", "Joe Keery", "Natalia Dyer",
    "Charlie Heaton", "Dacre Montgomery", "Penn Badgley", "Victoria Pedretti",
    "Dylan Minnette", "Katherine Langford", "Ross Lynch", "13 Reasons Why Cast",
    
    // 🦸‍♂️ MARVEL & DC
    "Tom Holland", "Zendaya", "Jacob Batalon", "Tony Revolori", "Marisa Tomei",
    "Chris Evans", "Scarlett Johansson", "Mark Ruffalo", "Chris Hemsworth", "Jeremy Renner",
    "Paul Rudd", "Evangeline Lilly", "Brie Larson", "Tessa Thompson", "Lupita Nyong'o",
    "Chadwick Boseman", "Michael B. Jordan", "Letitia Wright", "Danai Gurira",
    "Robert Downey Jr.", "Gwyneth Paltrow", "Don Cheadle", "Anthony Mackie", "Sebastian Stan",
    "Elizabeth Olsen", "Paul Bettany", "Kathryn Hahn", "Evan Peters", "Kat Dennings",
    
    // 🎪 TIKTOKERS & INFLUENCERS
    "Charli D'Amelio", "Dixie D'Amelio", "Addison Rae", "Bella Poarch", "Loren Gray",
    "Baby Ariel", "Zach King", "David Dobrik", "Emma Chamberlain", "James Charles",
    "Jeffree Star", "Nikocado Avocado", "MrBeast", "PewDiePie", "Markiplier",
    "Jacksepticeye", "DanTDM", "VanossGaming", "Ninja", "Pokimane", "Valkyrae",
    "Corpse Husband", "Dream", "GeorgeNotFound", "Sapnap", "TommyInnit", "Tubbo",
    
    // 🏃‍♂️ DEPORTISTAS
    "Cristiano Ronaldo", "Lionel Messi", "Neymar Jr", "Kylian Mbappé", "Erling Haaland",
    "Vinicius Jr", "Pedri", "Gavi", "Jude Bellingham", "Marcus Rashford",
    "LeBron James", "Stephen Curry", "Kevin Durant", "Giannis Antetokounmpo", "Luka Dončić",
    "Jayson Tatum", "Zion Williamson", "Ja Morant", "Trae Young", "Anthony Edwards",
    "Serena Williams", "Naomi Osaka", "Emma Raducanu", "Coco Gauff", "Iga Świątek",
    
    // 🎨 MODELOS & FASHION
    "Gigi Hadid", "Bella Hadid", "Kendall Jenner", "Hailey Bieber", "Emily Ratajkowski",
    "Cara Delevingne", "Kaia Gerber", "Paloma Elsesser", "Ashley Graham", "Winnie Harlow",
    "Joan Smalls", "Liu Wen", "Adut Akech", "Kiki Willems", "Vittoria Ceretti",
    "Barbara Palvin", "Taylor Hill", "Romee Strijd", "Jasmine Tookes", "Sara Sampaio",
    
    // 🔥 RISING STARS 2025
    "Anya Taylor-Joy", "Thomasin McKenzie", "Millicent Simmonds", "Darby Camp", "Julia Butters",
    "McKenna Grace", "Marsai Martin", "Storm Reid", "Yara Shahidi", "Rowan Blanchard",
    "Jenna Davis", "Annie LeBlanc", "Mackenzie Ziegler", "JoJo Siwa", "Millie Bobby Brown",
    "Sadie Sink", "Maya Hawke", "Priah Ferguson", "Gaten Matarazzo", "Caleb McLaughlin",
    
    // 🌟 HOLLYWOOD LEGENDS (STILL HOT)
    "Will Smith", "Johnny Depp", "Tom Cruise", "Keanu Reeves", "Hugh Jackman",
    "Robert Downey Jr.", "Chris Pratt", "Mark Wahlberg", "Dwayne Johnson", "Jason Momoa",
    "Henry Cavill", "Chris Pine", "Ryan Gosling", "Jake Gyllenhaal", "Michael Fassbender",
    "Angelina Jolie", "Jennifer Aniston", "Scarlett Johansson", "Charlize Theron", "Nicole Kidman",
    
    // 🎵 REGGAETON & URBANO
    "Bad Bunny", "J Balvin", "Maluma", "Ozuna", "Anuel AA", "Farruko", "Nicky Jam",
    "Daddy Yankee", "Don Omar", "Wisin", "Yandel", "Arcángel", "De La Ghetto",
    "Rauw Alejandro", "Myke Towers", "Jhay Cortez", "Sech", "Lunay", "Lyanno",
    "Cazzu", "Karol G", "Natti Natasha", "Becky G", "Rosalía", "Aitana",
    
    // 🇧🇷 BRAZIL STARS
    "Anitta", "Pabllo Vittar", "Luísa Sonza", "IZA", "Pocah", "Lexa", "MC Rebecca",
    "Bruna Marquezine", "Marina Ruy Barbosa", "Giovanna Ewbank", "Sabrina Sato",
    "Grazi Massafera", "Paolla Oliveira", "Isis Valverde", "Camila Queiroz",
    
    // 🇮🇳 BOLLYWOOD
    "Priyanka Chopra", "Deepika Padukone", "Alia Bhatt", "Katrina Kaif", "Anushka Sharma",
    "Kareena Kapoor", "Sonam Kapoor", "Jacqueline Fernandez", "Shraddha Kapoor",
    "Ranveer Singh", "Ranbir Kapoor", "Shahid Kapoor", "Varun Dhawan", "Sidharth Malhotra",
    
    // 🇬🇧 BRITISH STARS
    "Daniel Radcliffe", "Emma Watson", "Rupert Grint", "Tom Felton", "Bonnie Wright",
    "Benedict Cumberbatch", "Tom Hiddleston", "Eddie Redmayne", "Dev Patel", "John Boyega",
    "Daisy Ridley", "Felicity Jones", "Keira Knightley", "Kate Winslet", "Helena Bonham Carter",
    
    // 🇫🇷 FRENCH CINEMA
    "Léa Seydoux", "Marion Cotillard", "Adèle Exarchopoulos", "Virginie Efira", "Charlotte Gainsbourg",
    "Omar Sy", "Jean Dujardin", "Gaspard Ulliel", "Pierre Niney", "Romain Duris",
    
    // 🎮 GAMING & ESPORTS
    "Ninja", "Pokimane", "Valkyrae", "Corpse Husband", "Dream", "GeorgeNotFound",
    "Sapnap", "TommyInnit", "Tubbo", "Wilbur Soot", "Philza", "Technoblade",
    "PewDiePie", "Markiplier", "Jacksepticeye", "VanossGaming", "DanTDM", "CaptainSparklez",
    
    // 🌈 LGBTQ+ ICONS
    "Troye Sivan", "Lil Nas X", "Sam Smith", "Janelle Monáe", "Frank Ocean",
    "Tyler, The Creator", "Kevin Abstract", "Hayley Kiyoko", "King Princess", "Clairo",
    "Phoebe Bridgers", "Julien Baker", "Lucy Dacus", "boygenius", "MUNA",
    
    // 🔥 VIRAL SENSATIONS 2025
    "Ice Spice", "Central Cee", "Gayle", "Steve Lacy", "Daniel Caesar", "Summer Walker",
    "Giveon", "Brent Faiyaz", "Kali Uchis", "Rex Orange County", "Boy Pablo", "Cuco",
    "Omar Apollo", "Arlo Parks", "Beabadoobee", "Girl in Red", "Conan Gray", "Declan McKenna",
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
    // Use absolute value and proper modulo to prevent overflow
    final positiveHash = hash.abs();
    final percentage = 30 + (positiveHash % 71); // 71 = 100 - 30 + 1

    // Additional safety check to ensure we're in valid range
    return percentage.clamp(30, 100);
  }

  String _getRandomMessage(
    int percentage,
    AppLocalizations localizations, {
    bool isCelebrity = false,
  }) {
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
      case 1:
        return localizations.celebrityMessage1;
      case 2:
        return localizations.celebrityMessage2;
      case 3:
        return localizations.celebrityMessage3;
      case 4:
        return localizations.celebrityMessage4;
      case 5:
        return localizations.celebrityMessage5;
      case 6:
        return localizations.celebrityMessage6;
      case 7:
        return localizations.celebrityMessage7;
      case 8:
        return localizations.celebrityMessage8;
      case 9:
        return localizations.celebrityMessage9;
      case 10:
        return localizations.celebrityMessage10;
      case 11:
        return localizations.celebrityMessage11;
      case 12:
        return localizations.celebrityMessage12;
      case 13:
        return localizations.celebrityMessage13;
      case 14:
        return localizations.celebrityMessage14;
      case 15:
        return localizations.celebrityMessage15;
      default:
        return localizations.celebrityMessage1;
    }
  }

  String _getRomanticMessage(int index, AppLocalizations localizations) {
    switch (index) {
      case 1:
        return localizations.romanticMessage1;
      case 2:
        return localizations.romanticMessage2;
      case 3:
        return localizations.romanticMessage3;
      case 4:
        return localizations.romanticMessage4;
      case 5:
        return localizations.romanticMessage5;
      case 6:
        return localizations.romanticMessage6;
      case 7:
        return localizations.romanticMessage7;
      case 8:
        return localizations.romanticMessage8;
      case 9:
        return localizations.romanticMessage9;
      case 10:
        return localizations.romanticMessage10;
      case 11:
        return localizations.romanticMessage11;
      case 12:
        return localizations.romanticMessage12;
      case 13:
        return localizations.romanticMessage13;
      case 14:
        return localizations.romanticMessage14;
      case 15:
        return localizations.romanticMessage15;
      case 16:
        return localizations.romanticMessage16;
      case 17:
        return localizations.romanticMessage17;
      case 18:
        return localizations.romanticMessage18;
      case 19:
        return localizations.romanticMessage19;
      case 20:
        return localizations.romanticMessage20;
      default:
        return localizations.romanticMessage1;
    }
  }

  String _getMysteriousMessage(int index, AppLocalizations localizations) {
    switch (index) {
      case 1:
        return localizations.mysteriousMessage1;
      case 2:
        return localizations.mysteriousMessage2;
      case 3:
        return localizations.mysteriousMessage3;
      case 4:
        return localizations.mysteriousMessage4;
      case 5:
        return localizations.mysteriousMessage5;
      case 6:
        return localizations.mysteriousMessage6;
      case 7:
        return localizations.mysteriousMessage7;
      case 8:
        return localizations.mysteriousMessage8;
      case 9:
        return localizations.mysteriousMessage9;
      case 10:
        return localizations.mysteriousMessage10;
      case 11:
        return localizations.mysteriousMessage11;
      case 12:
        return localizations.mysteriousMessage12;
      case 13:
        return localizations.mysteriousMessage13;
      case 14:
        return localizations.mysteriousMessage14;
      case 15:
        return localizations.mysteriousMessage15;
      case 16:
        return localizations.mysteriousMessage16;
      case 17:
        return localizations.mysteriousMessage17;
      case 18:
        return localizations.mysteriousMessage18;
      case 19:
        return localizations.mysteriousMessage19;
      case 20:
        return localizations.mysteriousMessage20;
      default:
        return localizations.mysteriousMessage1;
    }
  }

  String _getFunMessage(int index, AppLocalizations localizations) {
    switch (index) {
      case 1:
        return localizations.funMessage1;
      case 2:
        return localizations.funMessage2;
      case 3:
        return localizations.funMessage3;
      case 4:
        return localizations.funMessage4;
      case 5:
        return localizations.funMessage5;
      case 6:
        return localizations.funMessage6;
      case 7:
        return localizations.funMessage7;
      case 8:
        return localizations.funMessage8;
      case 9:
        return localizations.funMessage9;
      case 10:
        return localizations.funMessage10;
      case 11:
        return localizations.funMessage11;
      case 12:
        return localizations.funMessage12;
      case 13:
        return localizations.funMessage13;
      case 14:
        return localizations.funMessage14;
      case 15:
        return localizations.funMessage15;
      case 16:
        return localizations.funMessage16;
      case 17:
        return localizations.funMessage17;
      case 18:
        return localizations.funMessage18;
      case 19:
        return localizations.funMessage19;
      case 20:
        return localizations.funMessage20;
      default:
        return localizations.funMessage1;
    }
  }

  String _getLowCompatibilityMessage(
    int index,
    AppLocalizations localizations,
  ) {
    switch (index) {
      case 1:
        return localizations.lowCompatibilityMessage1;
      case 2:
        return localizations.lowCompatibilityMessage2;
      case 3:
        return localizations.lowCompatibilityMessage3;
      case 4:
        return localizations.lowCompatibilityMessage4;
      case 5:
        return localizations.lowCompatibilityMessage5;
      case 6:
        return localizations.lowCompatibilityMessage6;
      case 7:
        return localizations.lowCompatibilityMessage7;
      case 8:
        return localizations.lowCompatibilityMessage8;
      case 9:
        return localizations.lowCompatibilityMessage9;
      case 10:
        return localizations.lowCompatibilityMessage10;
      default:
        return localizations.lowCompatibilityMessage1;
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

  Future<CrushResult> generateResult(
    String userName,
    String crushName,
    AppLocalizations localizations,
  ) async {
    // Check if we already have a result for this combination
    final existingResult = await getSavedResult(userName, crushName);
    if (existingResult != null) {
      return existingResult;
    }

    // Check if crush is a celebrity
    final isCelebrity = _isCelebrity(crushName);

    // Generate new result
    final percentage = _generateCompatibilityPercentage(userName, crushName);
    final message = _getRandomMessage(
      percentage,
      localizations,
      isCelebrity: isCelebrity,
    );
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
  Future<CrushResult> generateSimpleResult(
    String userName,
    String crushName,
  ) async {
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
        try {
          final json = jsonDecode(jsonString);
          var result = CrushResult.fromJson(json);

          // Fix any invalid percentages (outside 30-100 range)
          if (result.percentage < 30 || result.percentage > 100) {
            // Recalculate with fixed algorithm
            final correctedPercentage = _generateCompatibilityPercentage(
              result.userName,
              result.crushName,
            );

            // Create corrected result
            result = CrushResult(
              userName: result.userName,
              crushName: result.crushName,
              percentage: correctedPercentage,
              message: result.message,
              emoji: result.emoji,
              timestamp: result.timestamp,
              isCelebrity: result.isCelebrity,
            );

            // Save corrected result
            await _saveResult(result);
          }

          results.add(result);
        } catch (e) {
          // Skip corrupted results
          continue;
        }
      }
    }

    // Sort by timestamp (newest first)
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }

  /// Clean up any invalid results with percentages outside valid range
  /// Limpiar resultados inválidos con porcentajes fuera del rango válido
  Future<void> fixInvalidResults() async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((key) => key.startsWith('result_')).toList();

    for (final key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        try {
          final json = jsonDecode(jsonString);
          final result = CrushResult.fromJson(json);

          // Check if percentage is invalid
          if (result.percentage < 30 || result.percentage > 100) {
            // Recalculate with fixed algorithm
            final correctedPercentage = _generateCompatibilityPercentage(
              result.userName,
              result.crushName,
            );

            // Create corrected result
            final correctedResult = CrushResult(
              userName: result.userName,
              crushName: result.crushName,
              percentage: correctedPercentage,
              message: result.message,
              emoji: result.emoji,
              timestamp: result.timestamp,
              isCelebrity: result.isCelebrity,
            );

            // Save corrected result
            await _saveResult(correctedResult);
          }
        } catch (e) {
          // Remove corrupted results
          await prefs.remove(key);
        }
      }
    }
  }
}
