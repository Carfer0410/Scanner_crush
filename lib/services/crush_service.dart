import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crush_result.dart';
import 'daily_love_service.dart';

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

  final List<String> _celebrityMessages = [
    "¡OMG! Tu compatibilidad con una celebridad es increíble 🌟",
    "Las estrellas de Hollywood aprueban esta combinación ⭐",
    "¡Tu crush celebrity podría ser tu alma gemela! 💫",
    "Hollywood está hablando de esta compatibilidad 🎬",
    "¡Plot twist! Tienes química con una superestrella 🎭",
    "Tu nivel de compatibilidad celebrity es off the charts! 📈",
    "¡Breaking news! Eres compatible con una estrella 📺",
    "El red carpet del amor te está esperando 🌹",
    "¡Paparazzi alert! Tienes una conexión especial 📸",
    "Tu historia de amor podría ser una película de éxito 🍿",
    "¡Award-winning compatibility detected! 🏆",
    "Las revistas de chismes estarían hablando de ustedes 📰",
    "Tu crush celebrity aprueba esta combinación 💕",
    "¡Lights, camera, amor! Tienes potencial de celebrity couple 🎥",
    "El universo celebrity conspira a tu favor ✨",
  ];

  final List<String> _romanticMessages = [
    "¡Tu corazón y el suyo laten al mismo ritmo! 💕",
    "Las estrellas se alinean perfectamente para ustedes ✨",
    "Hay una conexión especial esperando a ser descubierta 🌙",
    "El destino ha tejido sus hilos entre ustedes dos 💫",
    "Sus almas parecen hablar el mismo idioma del amor 💝",
    "La magia del amor está flotando en el aire 🎭",
    "Existe una química innegable entre ustedes 🔥",
    "El universo conspira a favor de su amor 🌟",
    "Sus energías se complementan de manera perfecta 🌸",
    "Hay algo más que amistad esperando florecer 🌺",
    "La compatibilidad entre ustedes es sorprendente 💖",
    "El amor verdadero podría estar más cerca de lo que piensas 💘",
    "Sus corazones vibran en la misma frecuencia 🎵",
    "La atracción entre ustedes es magnética ⚡",
    "El cupido ya tiene sus flechas apuntando hacia ustedes 🏹",
    "Sus caminos están destinados a cruzarse una y otra vez 🛤️",
    "La llama del amor arde con intensidad entre ustedes 🕯️",
    "Existe una conexión cósmica que los une 🌌",
    "El amor está escribiendo su propia historia 📖",
    "Sus corazones hablan un idioma que solo ustedes entienden 💬",
  ];

  final List<String> _mysteriousMessages = [
    "Los secretos del corazón están por revelarse... 🔮",
    "Alguien piensa en ti más de lo que imaginas 👁️",
    "Las señales del universo están tratando de decirte algo 🌠",
    "Hay sentimientos ocultos que pronto saldrán a la luz 🌅",
    "El misterio del amor está a punto de desvelarse 🎭",
    "Fuerzas invisibles están trabajando en su favor 👻",
    "Los susurros del corazón están llegando a ti 🍃",
    "Hay una historia de amor esperando ser contada 📚",
    "Los hilos del destino se están entrelazando 🕸️",
    "Algo mágico está por suceder en el amor 🎪",
    "Las cartas del tarot del amor están mezclándose 🃏",
    "Un secreto romántico está flotando en el aire 💨",
    "La luna llena trae revelaciones del corazón 🌕",
    "Hay miradas que dicen más que mil palabras 👀",
    "El eco de un corazón enamorado resuena cerca 🔊",
    "Algo hermoso está gestándose en silencio 🤫",
    "Las estrellas susurran secretos de amor 🌟",
    "Un mensaje del corazón está esperando ser enviado 💌",
    "La magia del amor está creando conexiones invisibles ✨",
    "Hay una sorpresa romántica en el horizonte 🎁",
  ];

  final List<String> _funMessages = [
    "¡Houston, tenemos una conexión! 🚀",
    "Tu crush-o-metro está por las nubes 📈",
    "¡Alerta de corazones! Peligro de enamoramiento 🚨",
    "El detector de amor está sonando fuertemente 📢",
    "¡Bingo! Has encontrado una coincidencia perfecta 🎯",
    "Tu nivel de compatibilidad está off the charts! 📊",
    "¡Ding ding ding! Tenemos un ganador del amor 🛎️",
    "El GPS del amor te está guiando hacia algo especial 🗺️",
    "¡Jackpot emocional! Has dado en el clavo 🎰",
    "Tu corazón acaba de hacer *match* perfecto 💕",
    "¡Eureka! La fórmula del amor ha sido descifrada 🧪",
    "El termómetro del romance está a punto de explotar 🌡️",
    "¡Breaking news! Se detecta química entre ustedes 📺",
    "Tu radar del amor está captando señales fuertes 📡",
    "¡Plot twist! Tu crush podría estar pensando en ti 🎬",
    "El algoritmo del amor dice que son compatibles 💻",
    "¡Spoiler alert! Hay romance en tu futuro 📱",
    "Tu aplicación de amor acaba de enviar una notificación 📲",
    "¡Achievement unlocked! Has encontrado tu match 🏆",
    "El bluetooth del corazón se ha conectado exitosamente 📶",
  ];

  final List<String> _lowCompatibilityMessages = [
    "A veces las diferencias crean la chispa perfecta ⚡",
    "El amor verdadero supera cualquier porcentaje 💪",
    "Los opuestos se atraen y crean magia 🧲",
    "No todos los grandes amores empiezan con 100% 📈",
    "Dale tiempo al tiempo, el amor crece paso a paso 🌱",
    "La compatibilidad se construye día a día 🏗️",
    "Quizás necesiten conocerse un poco más 🤔",
    "El amor real no siempre sigue las estadísticas 📊",
    "Hay espacio para que crezca algo hermoso 🌻",
    "Los mejores romances empiezan como amistad 👫",
  ];

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

  String _getRandomMessage(int percentage, {bool isCelebrity = false}) {
    final random = Random();

    // Mensajes especiales para celebridades
    if (isCelebrity) {
      return _celebrityMessages[random.nextInt(_celebrityMessages.length)];
    }

    if (percentage >= 80) {
      return _romanticMessages[random.nextInt(_romanticMessages.length)];
    } else if (percentage >= 60) {
      return _mysteriousMessages[random.nextInt(_mysteriousMessages.length)];
    } else if (percentage >= 45) {
      return _funMessages[random.nextInt(_funMessages.length)];
    } else {
      return _lowCompatibilityMessages[random.nextInt(
        _lowCompatibilityMessages.length,
      )];
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

  Future<CrushResult> generateResult(String userName, String crushName) async {
    // Check if we already have a result for this combination
    final existingResult = await getSavedResult(userName, crushName);
    if (existingResult != null) {
      return existingResult;
    }

    // Check if crush is a celebrity
    final isCelebrity = _isCelebrity(crushName);

    // Generate new result
    final percentage = _generateCompatibilityPercentage(userName, crushName);
    final message = _getRandomMessage(percentage, isCelebrity: isCelebrity);
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
