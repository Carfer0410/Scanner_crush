class CrushResult {
  final String userName;
  final String crushName;
  final int percentage;
  final String message;
  final String emoji;
  final DateTime timestamp;
  final bool isCelebrity;

  CrushResult({
    required this.userName,
    required this.crushName,
    required this.percentage,
    required this.message,
    required this.emoji,
    required this.timestamp,
    this.isCelebrity = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'crushName': crushName,
      'percentage': percentage,
      'message': message,
      'emoji': emoji,
      'timestamp': timestamp.toIso8601String(),
      'isCelebrity': isCelebrity,
    };
  }

  factory CrushResult.fromJson(Map<String, dynamic> json) {
    return CrushResult(
      userName: json['userName'],
      crushName: json['crushName'],
      percentage: json['percentage'],
      message: json['message'],
      emoji: json['emoji'],
      timestamp: DateTime.parse(json['timestamp']),
      isCelebrity: json['isCelebrity'] ?? false,
    );
  }

  String get shareText {
    String viralHook;
    String hashtags;

    if (isCelebrity) {
      viralHook =
          percentage >= 80
              ? '🌟 ¡MI CELEBRITY CRUSH ES COMPATIBLE! 🌟'
              : percentage >= 60
              ? '✨ ¡TENGO QUÍMICA CON UNA CELEBRIDAD! ✨'
              : percentage >= 45
              ? '🎭 Mi crush celebrity... interesante 🎭'
              : '😅 Bueno, es una celebridad... 😅';

      hashtags =
          '#CelebrityCrush #EscanerDeCrush #Hollywood #Crush #Amor #Celebridades #Famosos';
    } else {
      viralHook =
          percentage >= 80
              ? '🔥 ¡COMPATIBILIDAD PERFECTA! 🔥'
              : percentage >= 60
              ? '💖 ¡Hay química aquí! 💖'
              : percentage >= 45
              ? '🤔 Interesante... 🤔'
              : '😅 Ups... 😅';

      hashtags = '#EscanerDeCrush #Crush #Amor #Compatibilidad';
    }

    return '$viralHook\n\n'
        '💘 Mi compatibilidad ${isCelebrity ? 'con mi celebrity crush' : 'con mi crush'}:\n'
        '$userName + $crushName = $percentage% $emoji\n\n'
        '$message\n\n'
        '¿Cuál es TU compatibilidad? 👀\n'
        'Descárgalo: Escáner de Crush 💕\n\n'
        '$hashtags';
  }
}
