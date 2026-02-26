// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get predictionInfoExplanation => 'El porcentaje en la frase es tu compatibilidad promedio real. El número en la esquina es la confianza de la predicción.';

  @override
  String get insightMasterLove => 'Master del Amor';

  @override
  String insightMasterLoveDesc(Object percent) {
    return 'Tu compatibilidad promedio es excepcional ($percent%). ¡Tienes un don natural para el amor!';
  }

  @override
  String get insightGoodRadar => 'Buen Radar Amoroso';

  @override
  String insightGoodRadarDesc(Object percent) {
    return 'Tu compatibilidad promedio es sólida ($percent%). Confías en tus instintos.';
  }

  @override
  String get insightExplorerLove => 'Explorador del Amor';

  @override
  String get insightExplorerLoveDesc => 'Estás explorando diferentes tipos de conexiones. ¡Cada escaneo te acerca más a tu match perfecto!';

  @override
  String get insightCelebrityCrusher => 'Celebrity Crusher';

  @override
  String insightCelebrityCrusherDesc(Object percent) {
    return 'Prefieres las celebridades ($percent% de tus escaneos). ¡Te gustan los estándares altos!';
  }

  @override
  String get insightTrueRomantic => 'Romántico Auténtico';

  @override
  String insightTrueRomanticDesc(Object percent) {
    return 'Prefieres conexiones reales ($percent% de tus escaneos). El amor verdadero te llama.';
  }

  @override
  String get insightExpert => 'Experto en Compatibilidad';

  @override
  String insightExpertDesc(Object scans) {
    return 'Con $scans escaneos, eres todo un experto. Tu experiencia es invaluable.';
  }

  @override
  String get insightDedicatedUser => 'Usuario Dedicado';

  @override
  String insightDedicatedUserDesc(Object scans) {
    return 'Ya llevas $scans escaneos. ¡Tu dedicación al amor es admirable!';
  }

  @override
  String get insightCommittedExplorer => 'Explorador Comprometido';

  @override
  String insightCommittedExplorerDesc(Object scans) {
    return 'Con $scans escaneos, estás construyendo un perfil sólido. ¡Sigue así!';
  }

  @override
  String get insightNewAdventurer => 'Nuevo Aventurero';

  @override
  String get insightNewAdventurerDesc => 'Has comenzado tu viaje de descubrimiento amoroso. ¡Cada escaneo revela algo nuevo!';

  @override
  String get predictionLoveRising => 'Amor en Ascenso';

  @override
  String get predictionLoveRisingDesc => 'Tu compatibilidad ha mejorado últimamente. Las próximas semanas serán prometedoras para el amor.';

  @override
  String get predictionTimeReflection => 'Tiempo de Reflexión';

  @override
  String get predictionTimeReflectionDesc => 'Es un buen momento para reflexionar sobre qué buscas en el amor. La claridad traerá mejores conexiones.';

  @override
  String get predictionStableLove => 'Amor Estable';

  @override
  String get predictionStableLoveDesc => 'Tu compatibilidad se mantiene consistente. Es un buen momento para consolidar conexiones.';

  @override
  String get predictionDiscoveringPattern => 'Descubriendo Tu Patrón';

  @override
  String get predictionDiscoveringPatternDesc => 'Estás construyendo tu perfil amoroso. Cada escaneo nos ayuda a entender mejor tus preferencias.';

  @override
  String get predictionJourneyStart => 'Inicio de Tu Viaje';

  @override
  String get predictionJourneyStartDesc => 'Has comenzado tu exploración amorosa. ¡Sigue escaneando para descubrir patrones fascinantes!';

  @override
  String get predictionPerfectMatchNear => 'Match Perfecto Cerca';

  @override
  String predictionPerfectMatchNearDesc(Object percent) {
    return 'Tu alta compatibilidad promedio ($percent%) sugiere que tu match perfecto está muy cerca. Mantén los ojos abiertos.';
  }

  @override
  String get predictionGoodLovePath => 'Buen Camino Amoroso';

  @override
  String predictionGoodLovePathDesc(Object percent) {
    return 'Tu compatibilidad promedio ($percent%) muestra que tienes buen criterio. Confía en tus instintos.';
  }

  @override
  String get predictionLoveAwaits => 'El Amor Te Espera';

  @override
  String get predictionLoveAwaitsDesc => 'Cada escaneo te acerca más a entender el amor. ¡Sigue explorando y descubriendo tu camino!';

  @override
  String get predictionTimeframeNext2Weeks => 'Próximas 2 semanas';

  @override
  String get predictionTimeframeNextMonth => 'Próximo mes';

  @override
  String get predictionTimeframeNext3Weeks => 'Próximas 3 semanas';

  @override
  String get predictionTimeframeNextWeeks => 'Próximas semanas';

  @override
  String get predictionTimeframeAsYouExplore => 'A medida que explores';

  @override
  String get predictionTimeframeNext3Months => 'Próximos 3 meses';

  @override
  String get predictionTimeframeNext2Months => 'Próximos 2 meses';

  @override
  String get predictionTimeframeLoveJourney => 'En tu viaje amoroso';

  @override
  String get errorGeneratingResult => 'Error al generar resultado. Inténtalo de nuevo.';

  @override
  String get celebrityCrush => 'Celebrity Crush';

  @override
  String helloCelebrity(String userName) {
    return '¡Hola $userName!';
  }

  @override
  String get chooseCelebrityDescription => 'Elige tu celebrity crush y descubre tu compatibilidad';

  @override
  String get searchCelebrity => 'Buscar celebridad...';

  @override
  String get noInsightsYet => 'No hay insights todavía';

  @override
  String get scanMoreForInsights => 'Realiza más escaneos para obtener insights personalizados';

  @override
  String get noPredictionsYet => 'No hay predicciones disponibles';

  @override
  String get scanMoreForPredictions => 'Realiza más escaneos para generar predicciones sobre tu vida amorosa';

  @override
  String get bannerLoaded => 'Banner Ad cargado correctamente';

  @override
  String get bannerLoadError => 'Error cargando Banner Ad:';

  @override
  String get testingBannerAd => '🎯 Probando Banner Ad...';

  @override
  String get bannerAdWorking => '✅ Banner Ad está funcionando';

  @override
  String get bannerAdNotLoaded => '❌ Banner Ad no está cargado';

  @override
  String get testingInterstitialAd => '🎯 Probando Interstitial Ad...';

  @override
  String get interstitialAdAvailable => '✅ Interstitial Ad disponible';

  @override
  String get interstitialShown => '✅ Interstitial mostrado';

  @override
  String get interstitialShowError => '❌ Error mostrando Interstitial';

  @override
  String get interstitialNotReady => '⚠️ Interstitial Ad no está listo';

  @override
  String get testingRewardedAd => '🎯 Probando Rewarded Ad...';

  @override
  String get rewardedAdShown => '✅ Rewarded Ad mostrado y recompensa otorgada';

  @override
  String get rewardedAdError => '❌ Error con Rewarded Ad';

  @override
  String get adsTestTitle => 'Prueba de Anuncios';

  @override
  String get systemStatus => 'Estado del Sistema';

  @override
  String get liveBannerAd => '📱 Banner Ad en vivo:';

  @override
  String get testBanner => 'Test Banner';

  @override
  String get testInterstitial => 'Test Interstitial';

  @override
  String get testRewardedAd => 'Test Rewarded Ad';

  @override
  String get testResults => 'Resultados de Pruebas';

  @override
  String get pressButtonsToTestAds => 'Presiona los botones para probar los anuncios';

  @override
  String get premiumUniverseCard => 'Desbloquea el universo premium: horóscopos personalizados diarios, consejos amorosos, análisis de compatibilidad avanzado, sin anuncios.';

  @override
  String get appTitle => 'Escáner de Crush';

  @override
  String get splashSubtitle => 'Descubre tu destino amoroso';

  @override
  String get splashSlogan => '¡El amor es solo el principio! 💖';

  @override
  String get welcomeTitle => 'Descubre a tu Admirador Secreto';

  @override
  String get welcomeSubtitle => 'Descubre quién está enamorado de ti con nuestro algoritmo avanzado 💕';

  @override
  String get startScan => 'Escaner a tu Crush';

  @override
  String get celebrityScan => 'Escaneo de Celebridades';

  @override
  String get dailyLove => 'Amor Diario';

  @override
  String get settings => 'Configuración';

  @override
  String get history => 'Historial';

  @override
  String get premium => 'Premium';

  @override
  String get yourName => 'Tu nombre';

  @override
  String get enterYourName => 'Ingresa tu nombre';

  @override
  String get crushName => 'Nombre de tu Crush';

  @override
  String get enterCrushName => 'Ingresa el nombre de tu crush';

  @override
  String get scanNow => 'Escanear Ahora';

  @override
  String get scanning => 'Escaneando...';

  @override
  String get analyzing => 'Analizando compatibilidad...';

  @override
  String get calculatingLove => 'Calculando porcentaje de amor...';

  @override
  String get scanComplete => '¡Escaneo Completo!';

  @override
  String get lovePercentage => 'Porcentaje de Amor';

  @override
  String get compatibilityLevel => 'Nivel de Compatibilidad';

  @override
  String get shareResult => 'Compartir Resultado';

  @override
  String get scanAgain => 'Escanear de Nuevo';

  @override
  String get back => 'Atrás';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get soundEffects => 'Efectos de Sonido';

  @override
  String get backgroundMusic => 'Música de Fondo';

  @override
  String get language => 'Idioma';

  @override
  String get volume => 'Volumen';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get noHistory => 'No hay escaneos aún';

  @override
  String get startFirstScan => 'Inicia tu primer escaneo para ver resultados aquí';

  @override
  String get scanHistory => 'Historial de Escaneos';

  @override
  String get deleteHistory => 'Eliminar Historial';

  @override
  String get confirmDelete => 'Confirmar Eliminación';

  @override
  String get deleteHistoryMessage => '¿Estás seguro de que quieres eliminar todo el historial de escaneos? Esta acción no se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get historyDeleted => 'Historial eliminado exitosamente';

  @override
  String get todaysLove => 'Amor de Hoy';

  @override
  String get yourDailyLoveReading => 'Tu Lectura Diaria del Amor';

  @override
  String get loveAdvice => 'Consejo de Amor';

  @override
  String get luckyNumber => 'Número de la Suerte';

  @override
  String get loveCompatibility => 'Compatibilidad Amorosa';

  @override
  String get perfectMatch => '¡Pareja Perfecta! 💖';

  @override
  String get excellentMatch => '¡Excelente Pareja! 💕';

  @override
  String get goodMatch => '¡Buena Pareja! 💓';

  @override
  String get fairMatch => 'Pareja Regular 💙';

  @override
  String get lowMatch => 'Baja Compatibilidad 💔';

  @override
  String get celebrityScanner => 'Escáner de Celebridades';

  @override
  String get whichCelebrityLikesYou => '¿Qué celebridad gusta de ti?';

  @override
  String get selectGender => 'Seleccionar Género';

  @override
  String get male => 'Masculino';

  @override
  String get appTitleFull => 'Escáner de Crush 💘';

  @override
  String get upgrade => 'Mejorar';

  @override
  String get premiumOnly => 'Solo Premium';

  @override
  String remainingScans(Object count) {
    return '¡Te quedan $count escaneos hoy! 💕';
  }

  @override
  String get noScansLeft => '¡Sin escaneos gratis!';

  @override
  String get useWisely => 'Úsalos sabiamente o consigue más abajo 😉';

  @override
  String get moreTomorrow => 'Mañana tendrás 5 escaneos frescos esperándote, o puedes conseguir más ahora:';

  @override
  String get watchShortAd => 'Ver anuncio corto';

  @override
  String get extraScansFree => '+2 escaneos gratis';

  @override
  String get unlimitedScans => 'Escaneos Ilimitados';

  @override
  String get premiumPriceText => 'Premium por \$2.99/mes';

  @override
  String get waitUntilTomorrow => 'Esperar hasta mañana';

  @override
  String get freshScans => '5 escaneos frescos gratis';

  @override
  String get perfectScan => '¡Perfecto, a escanear! 💘';

  @override
  String get limitReachedTitle => '¡Límite alcanzado!';

  @override
  String get limitReachedBody => 'Has usado todos tus escaneos gratuitos de hoy.';

  @override
  String get limitReachedWhatToDo => '¿Qué puedes hacer?';

  @override
  String get watchAd => 'Ver anuncio';

  @override
  String get winExtraScans => 'Gana +2 escaneos más';

  @override
  String get extraScansWon => '¡+2 escaneos ganados!';

  @override
  String get goPremium => 'Hazte Premium';

  @override
  String get wait => 'Esperar';

  @override
  String get moreScansTomorrow => 'Más escaneos mañana';

  @override
  String get close => 'Cerrar';

  @override
  String get female => 'Femenino';

  @override
  String get any => 'Cualquiera';

  @override
  String get findCelebrityMatch => 'Encontrar Pareja Famosa';

  @override
  String get yourCelebrityMatch => 'Tu Pareja Famosa';

  @override
  String get compatibilityScore => 'Puntuación de Compatibilidad';

  @override
  String get whyThisMatch => '¿Por qué esta pareja?';

  @override
  String get upgradeToPremium => 'Actualizar a Premium';

  @override
  String get errorTitle => 'Error';

  @override
  String errorLoadingLoveDay(Object error) {
    return 'No se pudo cargar tu día del amor: $error';
  }

  @override
  String get ok => 'OK';

  @override
  String get freeTrialBannerTitle => '¡Período de Prueba GRATIS!';

  @override
  String get freeTrialBannerDayLeft => '1 DÍA RESTANTE';

  @override
  String freeTrialBannerDaysLeft(Object days) {
    return '$days DÍAS RESTANTES';
  }

  @override
  String get freeTrialBannerUnlimited => '¡Escaneos ilimitados!';

  @override
  String get freeTrialBannerEnjoy => 'Disfruta escaneos de amor ilimitados durante tu prueba';

  @override
  String get limitReached => '¡Límite alcanzado!';

  @override
  String scansRemainingToday(int count) {
    return '$count escaneos restantes hoy';
  }

  @override
  String get watchAdForMore => 'Ver anuncio para +2 más';

  @override
  String get upgradeForUnlimited => 'Has usado todos tus escaneos de hoy. Hazte Premium para escaneos ilimitados.';

  @override
  String get watchAdForScans => 'Ver anuncio (+2 escaneos)';

  @override
  String get noAdsAvailable => 'No hay anuncios disponibles. Intenta más tarde.';

  @override
  String get watchAdOrUpgrade => 'Ve anuncio o upgradea para más';

  @override
  String get dailyStreak => 'Racha Diaria';

  @override
  String get startLoveStreak => '¡Comienza tu racha hoy!';

  @override
  String get best => 'Mejor';

  @override
  String get currentStreak => 'Racha Actual';

  @override
  String get bestStreak => 'Mejor Racha';

  @override
  String get totalScans => 'Escaneos Totales';

  @override
  String get streakStatsTitle => '🔥 Estadísticas de Racha';

  @override
  String get learnAboutStats => 'Aprende sobre las estadísticas';

  @override
  String get streakStatsDialogCurrent => 'Racha Actual';

  @override
  String get streakStatsDialogBest => 'Mejor Racha';

  @override
  String get streakStatsDialogTotal => 'Escaneos Totales';

  @override
  String streakStatsDialogMotivation(Object motivation) {
    return '$motivation';
  }

  @override
  String get streakInfoDialogTitle => '¿Qué significan estas estadísticas?';

  @override
  String get streakInfoCurrentDesc => 'Cuántos días consecutivos has usado la app sin faltar ni un día.';

  @override
  String get streakInfoCurrentExample => 'Ejemplo: Si la usaste ayer y hoy, tu racha actual es de 2 días.';

  @override
  String get streakInfoBestDesc => 'Tu récord personal: la racha más larga que hayas logrado jamás. Siempre es igual o mayor que tu racha actual.';

  @override
  String get streakInfoBestExample => 'Ejemplo: Si tu racha actual son 2 días, tu mejor racha es de al menos 2 días (o mayor si tuviste una racha más larga antes).';

  @override
  String get streakInfoTotalDesc => 'El número total de escaneos de amor que has realizado desde que empezaste a usar la app.';

  @override
  String get streakInfoTotalExample => 'Ejemplo: Cada vez que escaneas la compatibilidad con tu crush, este número aumenta.';

  @override
  String get streakInfoTip => '💡 Consejo: ¡Sigue usando la app a diario para construir tu racha y descubrir tu compatibilidad amorosa!';

  @override
  String get gotIt => '¡Entendido!';

  @override
  String get premiumRequiredTitle => 'Premium Requerido';

  @override
  String get premiumRequiredContent => 'Esta función está disponible solo para usuarios Premium. ¡Actualiza ahora y desbloquea todas las funciones exclusivas!';

  @override
  String get viewPremium => 'Ver Premium';

  @override
  String get unlockAllFeatures => '¡Desbloquea todas las funciones y disfruta la experiencia completa!';

  @override
  String get premiumFeatures => 'Funciones Premium';

  @override
  String get detailedAnalysis => 'Análisis Detallado';

  @override
  String get noAds => 'Sin Anuncios';

  @override
  String get exclusiveContent => 'Contenido Exclusivo';

  @override
  String get advancedCompatibility => 'Compatibilidad Avanzada';

  @override
  String get monthlyPlan => 'Plan Mensual';

  @override
  String get yearlyPlan => 'Plan Anual';

  @override
  String get mostPopular => 'Más Popular';

  @override
  String save(String percentage) {
    return 'Ahorra $percentage%';
  }

  @override
  String get subscribe => 'Suscribirse';

  @override
  String get restorePurchases => 'Restaurar Compras';

  @override
  String get pleaseEnterName => 'Por favor ingresa tu nombre';

  @override
  String get pleaseEnterCrushName => 'Por favor ingresa el nombre de tu crush';

  @override
  String shareMessage(String percentage, String crushName) {
    return '¡Obtuve $percentage% de compatibilidad con $crushName en Escáner de Crush! 💕 Pruébalo tú también: [Enlace de la App]';
  }

  @override
  String get madeWithLove => 'Hecho con 💕 para descubrir el amor';

  @override
  String get regularScanSubtitle => 'Descubre tu compatibilidad con alguien especial';

  @override
  String get celebrityScanSubtitle => 'Tu compatibilidad con las estrellas';

  @override
  String get formInstructions => 'Ingresa tu nombre y el de esa persona especial para descubrir qué dice el corazón sobre su conexión.';

  @override
  String get scanLoveButton => 'Escanear Amor ❤️';

  @override
  String get personalAlgorithm => '✨ Algoritmo Personal ✨';

  @override
  String get algorithmDescription => 'Nuestro algoritmo del amor analiza la compatibilidad entre personas reales, basándose en energías, nombres y conexiones del corazón para revelar secretos románticos.';

  @override
  String get soundEffectsSubtitle => 'Sonidos en botones y acciones';

  @override
  String get backgroundMusicSubtitle => 'Música ambiente relajante';

  @override
  String get upgradeSettings => 'Actualizar a Premium';

  @override
  String get unlockAllFeaturesSettings => 'Desbloquea todas las funciones';

  @override
  String get newBadge => 'NUEVO';

  @override
  String get preparingLoveDay => 'Preparando tu día del amor...';

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get goBack => 'Volver';

  @override
  String get yourLoveUniverse => 'Tu Universo del Amor';

  @override
  String get consecutiveDays => 'Días seguidos';

  @override
  String get average => 'Promedio';

  @override
  String get personalizedTip => 'Consejo Personalizado';

  @override
  String get unlockedAchievements => '🏆 Logros Desbloqueados';

  @override
  String get shareError => 'Error al compartir. Inténtalo de nuevo.';

  @override
  String get result => 'Resultado';

  @override
  String get perfectCompatibility => '¡Compatibilidad Perfecta!';

  @override
  String get greatCompatibility => '¡Gran Compatibilidad!';

  @override
  String get goodCompatibility => 'Buena Compatibilidad';

  @override
  String get share => 'Compartir';

  @override
  String get celebrityCrushTitle => '🌟 Celebrity Crush 🌟';

  @override
  String get celebrityCrushDescription => 'Descubre tu compatibilidad con las estrellas más brillantes de Hollywood y el mundo del entretenimiento';

  @override
  String get chooseMyCommit => 'Elegir Mi Celebrity Crush ✨';

  @override
  String get celebrityMode => '✨ Celebrity Mode ✨';

  @override
  String get celebrityModeDescription => 'Nuestro algoritmo estelar analiza tu nombre y la energía cósmica de las celebridades para revelarte conexiones únicas del mundo del entretenimiento.';

  @override
  String get popularCelebrities => '🎬 Celebridades Populares';

  @override
  String get andManyMore => 'Y muchos más...';

  @override
  String get noHistoryYet => 'Aún no hay historial';

  @override
  String get noHistoryDescription => 'Tus escaneos de compatibilidad aparecerán aquí';

  @override
  String get startScanning => 'Comenzar a Escanear';

  @override
  String errorLoadingHistory(String error) {
    return 'Error al cargar el historial: $error';
  }

  @override
  String get agoTime => 'hace';

  @override
  String get minutes => 'min';

  @override
  String get hours => 'h';

  @override
  String get days => 'días';

  @override
  String get clearHistory => 'Limpiar Historial';

  @override
  String get confirmClearHistory => '¿Estás seguro de que quieres limpiar tu historial?';

  @override
  String get confirmClear => 'Limpiar';

  @override
  String get historyCleared => 'Historial limpiado exitosamente';

  @override
  String get errorClearingHistory => 'Error al limpiar historial';

  @override
  String get errorSharingResult => 'Error al compartir resultado';

  @override
  String get premiumTitle => 'Scanner Crush Premium';

  @override
  String get premiumSubtitle => '¡Desbloquea todo el potencial del amor!';

  @override
  String get noAdsTitle => 'Sin Anuncios';

  @override
  String get noAdsDescription => 'Disfruta de la experiencia completa sin interrupciones';

  @override
  String get unlimitedScansTitle => 'Escaneos Ilimitados';

  @override
  String get unlimitedScansDescription => 'Escanea cuantas veces quieras sin restricciones';

  @override
  String get exclusiveResultsTitle => 'Resultados Exclusivos';

  @override
  String get exclusiveResultsDescription => 'Accede a mensajes y predicciones especiales';

  @override
  String get crushHistoryTitle => 'Historial de Crushes';

  @override
  String get crushHistoryDescription => 'Guarda y revisa todos tus escaneos anteriores';

  @override
  String get specialThemesTitle => 'Temas Especiales';

  @override
  String get specialThemesDescription => 'Personaliza la app con temas únicos y exclusivos';

  @override
  String get premiumSupportTitle => 'Soporte Premium';

  @override
  String get premiumSupportDescription => 'Atención prioritaria y soporte técnico avanzado';

  @override
  String get purchasePremium => 'Obtener Premium - \$2.99/mes';

  @override
  String get welcomeToPremium => '¡Bienvenido a Premium!';

  @override
  String get premiumActivated => 'Tu cuenta Premium ha sido activada exitosamente. ¡Disfruta de todas las características exclusivas!';

  @override
  String get great => '¡Genial!';

  @override
  String get restorePurchasesButton => 'Restaurar Compras';

  @override
  String get processing => 'Procesando...';

  @override
  String get noPreviousPurchases => 'No se encontraron compras anteriores';

  @override
  String get magneticConnection => '💘 Conexión Magnética';

  @override
  String get magneticConnectionMessage => 'Hoy las energías del amor están especialmente fuertes. Es el momento perfecto para descubrir nuevas conexiones.';

  @override
  String get magneticConnectionAdvice => 'Mantén tu corazón abierto a las sorpresas del amor.';

  @override
  String get dayOfRevelations => '✨ Día de Revelaciones';

  @override
  String get dayOfRevelationsMessage => 'Los secretos del corazón están listos para ser revelados. Alguien especial podría confesarte algo importante.';

  @override
  String get dayOfRevelationsAdvice => 'Presta atención a las señales sutiles de quien te rodea.';

  @override
  String get romanceInTheAir => '🌹 Romance en el Aire';

  @override
  String get romanceInTheAirMessage => 'El universo conspira para crear momentos románticos. Tu crush podría estar pensando en ti más de lo que imaginas.';

  @override
  String get romanceInTheAirAdvice => 'Sé valiente y da el primer paso.';

  @override
  String get destinyAligned => '💫 Destino Alineado';

  @override
  String get destinyAlignedMessage => 'Las estrellas se alinean para favorecer encuentros casuales que pueden cambiar tu vida amorosa.';

  @override
  String get destinyAlignedAdvice => 'Sal de tu zona de confort y socializa más.';

  @override
  String get butterfliesInStomach => '🦋 Mariposas en el Estómago';

  @override
  String get butterfliesInStomachMessage => 'Hoy sentirás esas mariposas especiales. Tu intuición amorosa está en su punto más alto.';

  @override
  String get butterfliesInStomachAdvice => 'Confía en tus instintos del corazón.';

  @override
  String get burningPassion => '🔥 Pasión Ardiente';

  @override
  String get burningPassionMessage => 'La energía romántica está al máximo. Es un día perfecto para expresar tus sentimientos.';

  @override
  String get burningPassionAdvice => 'No reprimas tus emociones, déjalas fluir.';

  @override
  String get authenticLove => '💎 Amor Auténtico';

  @override
  String get authenticLoveMessage => 'Hoy puedes reconocer el amor verdadero. Las conexiones superficiales se desvanecen.';

  @override
  String get authenticLoveAdvice => 'Busca la profundidad en tus relaciones.';

  @override
  String personalizedTipStreak(int streak) {
    return '🔥 ¡Increíble racha de $streak días! Tu energía amorosa está en su punto máximo.';
  }

  @override
  String personalizedTipCompatibility(int compatibility) {
    return '⭐ Tu compatibilidad promedio es excelente ($compatibility%). ¡Tienes buen ojo para el amor!';
  }

  @override
  String personalizedTipScans(int scans) {
    return '💡 Con $scans escaneos realizados, tu experiencia amorosa está creciendo. ¡Sigue explorando!';
  }

  @override
  String get personalizedTipGoodCompatibility => '💫 Tu compatibilidad promedio es buena. Confía en tus instintos amorosos.';

  @override
  String get personalizedTipEncouragement => '🌱 Cada escaneo te acerca más a encontrar tu conexión perfecta. ¡No te rindas!';

  @override
  String get fireStreak => '🔥 Racha de Fuego';

  @override
  String fireStreakDescription(int days) {
    return '$days días consecutivos';
  }

  @override
  String get loveExplorer => '🎯 Explorador del Amor';

  @override
  String loveExplorerDescription(int scans) {
    return '$scans escaneos realizados';
  }

  @override
  String get compatibilityMaster => '⭐ Maestro de la Compatibilidad';

  @override
  String compatibilityMasterDescription(int average) {
    return '$average% promedio';
  }

  @override
  String get romanceGuru => '👑 Gurú del Romance';

  @override
  String get romanceGuruDescription => 'Experto en el amor';

  @override
  String get personalScannerTitle => 'Escáner Personal';

  @override
  String get personalCompatibilityTitle => '💕 Tu Compatibilidad Personal 💕';

  @override
  String get resultTitle => 'Resultado';

  @override
  String get thereIsPotential => 'Hay Potencial';

  @override
  String get shareButton => 'Compartir';

  @override
  String get scanAgainButton => 'Escanear Otra Vez';

  @override
  String get celebrityMessage1 => '¡OMG! Tu compatibilidad con una celebridad es increíble 🌟';

  @override
  String get celebrityMessage2 => 'Las estrellas de Hollywood aprueban esta combinación ⭐';

  @override
  String get celebrityMessage3 => '¡Tu crush famoso podría ser tu media naranja! 💫';

  @override
  String get celebrityMessage4 => 'Hollywood está hablando de esta compatibilidad 🎬';

  @override
  String get celebrityMessage5 => '¡Plot twist! Tienes química con una superestrella 🎭';

  @override
  String get celebrityMessage6 => '¡Tu nivel de compatibilidad con celebridades está por las nubes! 📈';

  @override
  String get celebrityMessage7 => '¡Noticia de último momento! Eres compatible con una estrella 📺';

  @override
  String get celebrityMessage8 => 'La alfombra roja del amor te está esperando 🌹';

  @override
  String get celebrityMessage9 => '¡Alerta paparazzi! Tienes una conexión especial 📸';

  @override
  String get celebrityMessage10 => 'Tu historia de amor podría ser una película taquillera 🍿';

  @override
  String get celebrityMessage11 => '¡Compatibilidad ganadora de premios detectada! 🏆';

  @override
  String get celebrityMessage12 => 'Las revistas de chismes estarían hablando de ustedes dos 📰';

  @override
  String get celebrityMessage13 => 'Tu crush famoso aprueba esta combinación 💕';

  @override
  String get celebrityMessage14 => '¡Luces, cámara, amor! Tienes potencial de pareja de famosos 🎥';

  @override
  String get celebrityMessage15 => 'El universo de las celebridades conspira a tu favor ✨';

  @override
  String get romanticMessage1 => '¡Sus corazones laten al ritmo perfecto! 💕';

  @override
  String get romanticMessage2 => 'Las estrellas se alinean perfectamente para ambos ✨';

  @override
  String get romanticMessage3 => 'Hay una conexión especial esperando ser descubierta 🌙';

  @override
  String get romanticMessage4 => 'El destino ha tejido sus hilos entre ustedes dos 💫';

  @override
  String get romanticMessage5 => 'Sus almas parecen hablar el mismo idioma del amor 💝';

  @override
  String get romanticMessage6 => 'La magia del amor está flotando en el aire 🎭';

  @override
  String get romanticMessage7 => 'Hay una química innegable entre ustedes 🔥';

  @override
  String get romanticMessage8 => 'El universo conspira a favor de su amor 🌟';

  @override
  String get romanticMessage9 => 'Sus energías se complementan a la perfección 🌸';

  @override
  String get romanticMessage10 => 'Hay algo más que amistad esperando florecer 🌺';

  @override
  String get romanticMessage11 => 'La compatibilidad entre ustedes es asombrosa 💖';

  @override
  String get romanticMessage12 => 'El amor verdadero podría estar más cerca de lo que piensas 💘';

  @override
  String get romanticMessage13 => 'Sus corazones vibran en la misma frecuencia 🎵';

  @override
  String get romanticMessage14 => 'La atracción entre ustedes es magnética ⚡';

  @override
  String get romanticMessage15 => 'Cupido ya tiene sus flechas dirigidas hacia ustedes 🏹';

  @override
  String get romanticMessage16 => 'Sus caminos están destinados a cruzarse una y otra vez 🛤️';

  @override
  String get romanticMessage17 => 'La llama del amor arde intensamente entre ustedes 🕯️';

  @override
  String get romanticMessage18 => 'Hay una conexión cósmica que los une 🌌';

  @override
  String get romanticMessage19 => 'El amor está escribiendo su propia historia 📖';

  @override
  String get romanticMessage20 => 'Sus corazones hablan un idioma que solo ustedes entienden 💬';

  @override
  String get mysteriousMessage1 => 'Los secretos del corazón están a punto de revelarse... 🔮';

  @override
  String get mysteriousMessage2 => 'Alguien piensa en ti más de lo que imaginas 👁️';

  @override
  String get mysteriousMessage3 => 'Las señales del universo tratan de decirte algo 🌠';

  @override
  String get mysteriousMessage4 => 'Los sentimientos ocultos pronto saldrán a la luz 🌅';

  @override
  String get mysteriousMessage5 => 'El misterio del amor está a punto de desplegarse 🎭';

  @override
  String get mysteriousMessage6 => 'Las fuerzas invisibles están trabajando a tu favor 👻';

  @override
  String get mysteriousMessage7 => 'Los susurros del corazón están llegando a ti 🍃';

  @override
  String get mysteriousMessage8 => 'Hay una historia de amor esperando ser contada 📚';

  @override
  String get mysteriousMessage9 => 'Los hilos del destino se están entrelazando 🕸️';

  @override
  String get mysteriousMessage10 => 'Algo mágico está a punto de suceder en el amor 🎪';

  @override
  String get mysteriousMessage11 => 'Las cartas del tarot del amor se están barajando 🃏';

  @override
  String get mysteriousMessage12 => 'Un secreto romántico está flotando en el aire 💨';

  @override
  String get mysteriousMessage13 => 'La luna llena trae revelaciones del corazón 🌕';

  @override
  String get mysteriousMessage14 => 'Hay miradas que dicen más que mil palabras 👀';

  @override
  String get mysteriousMessage15 => 'El eco de un corazón enamorado resuena cerca 🔊';

  @override
  String get mysteriousMessage16 => 'Algo hermoso se está gestando en silencio 🤫';

  @override
  String get mysteriousMessage17 => 'Las estrellas susurran secretos de amor 🌟';

  @override
  String get mysteriousMessage18 => 'Un mensaje del corazón está esperando ser enviado 💌';

  @override
  String get mysteriousMessage19 => 'La magia del amor está creando conexiones invisibles ✨';

  @override
  String get mysteriousMessage20 => 'Hay una sorpresa romántica en el horizonte 🎁';

  @override
  String get funMessage1 => '¡Houston, tenemos una conexión! 🚀';

  @override
  String get funMessage2 => 'Tu crush-ómetro está por las nubes 📈';

  @override
  String get funMessage3 => '¡Alerta corazón! Peligro de enamorarse 🚨';

  @override
  String get funMessage4 => 'El detector de amor está sonando fuerte 📢';

  @override
  String get funMessage5 => '¡Bingo! Has encontrado una combinación perfecta 🎯';

  @override
  String get funMessage6 => '¡Tu nivel de compatibilidad está fuera de serie! 📊';

  @override
  String get funMessage7 => '¡Ding ding ding! Tenemos un ganador del amor 🛎️';

  @override
  String get funMessage8 => 'El GPS del amor te guía hacia algo especial 🗺️';

  @override
  String get funMessage9 => '¡Jackpot emocional! Has dado en el blanco 🎰';

  @override
  String get funMessage10 => 'Tu corazón acaba de hacer match perfecto 💕';

  @override
  String get funMessage11 => '¡Eureka! La fórmula del amor ha sido descifrada 🧪';

  @override
  String get funMessage12 => 'El termómetro del romance está a punto de explotar 🌡️';

  @override
  String get funMessage13 => '¡Noticia de último momento! Química detectada entre ustedes 📺';

  @override
  String get funMessage14 => 'Tu radar del amor está captando señales fuertes 📡';

  @override
  String get funMessage15 => '¡Plot twist! Tu crush podría estar pensando en ti 🎬';

  @override
  String get funMessage16 => 'El algoritmo del amor dice que son compatibles 💻';

  @override
  String get funMessage17 => '¡Spoiler alert! Hay romance en tu futuro 📱';

  @override
  String get funMessage18 => 'Tu app del amor acaba de enviarte una notificación 📲';

  @override
  String get funMessage19 => '¡Logro desbloqueado! Has encontrado tu match 🏆';

  @override
  String get funMessage20 => 'El bluetooth del corazón se ha conectado con éxito 📶';

  @override
  String get lowCompatibilityMessage1 => 'A veces las diferencias crean la chispa perfecta ⚡';

  @override
  String get lowCompatibilityMessage2 => 'El amor verdadero supera cualquier porcentaje 💪';

  @override
  String get lowCompatibilityMessage3 => 'Los opuestos se atraen y crean magia 🧲';

  @override
  String get lowCompatibilityMessage4 => 'No todos los grandes amores empiezan con 100% 📈';

  @override
  String get lowCompatibilityMessage5 => 'Dale tiempo al tiempo, el amor crece paso a paso 🌱';

  @override
  String get lowCompatibilityMessage6 => 'La compatibilidad se construye día a día 🏗️';

  @override
  String get lowCompatibilityMessage7 => 'Tal vez necesitan conocerse mejor 🤔';

  @override
  String get lowCompatibilityMessage8 => 'El amor real no siempre sigue las estadísticas 📊';

  @override
  String get lowCompatibilityMessage9 => 'Hay espacio para que algo hermoso crezca 🌻';

  @override
  String get lowCompatibilityMessage10 => 'Los mejores romances empiezan como amistad 👫';

  @override
  String get changeAppTheme => 'Cambiar el tema de la aplicación';

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String get darkTheme => 'Tema Oscuro';

  @override
  String get youArePremium => '¡Eres Premium!';

  @override
  String get enjoyAllFeatures => 'Disfruta de todas las funciones sin límites';

  @override
  String purchaseError(String error) {
    return 'Error en la compra: $error';
  }

  @override
  String get storeNotAvailable => 'La tienda no está disponible en este momento. Verifica tu conexión a internet e intenta de nuevo.';

  @override
  String get productNotConfigured => 'El producto no está disponible en este momento. Inténtalo más tarde.';

  @override
  String get purchaseAlreadyInProgress => 'Ya hay una compra en proceso. Espera un momento.';

  @override
  String get purchaseCouldNotStart => 'No se pudo iniciar la compra. Inténtalo de nuevo.';

  @override
  String get purchaseUnexpectedError => 'Ocurrió un error inesperado. Inténtalo más tarde.';

  @override
  String get purchaseStartedCompleteInStore => 'Compra iniciada. Completa el pago en la ventana de la tienda.';

  @override
  String get getFullAccess => 'Obtén acceso completo a todas las funciones especiales';

  @override
  String get specialOffer => 'Oferta Especial';

  @override
  String get cancelAnytime => 'Cancela cuando quieras';

  @override
  String get support => 'Soporte';

  @override
  String get settingsHistorySubtitle => 'Ver todos tus escaneos anteriores';

  @override
  String get changeThemeSubtitle => 'Cambiar el tema de la aplicacion';

  @override
  String get backgroundAnimationTitle => 'Animacion de fondo';

  @override
  String get backgroundAnimationSubtitle => 'Mostrar flores y corazones flotantes';

  @override
  String get helpAndQuestions => 'Ayuda y Preguntas';

  @override
  String get getHelpOnApp => 'Obtén ayuda sobre cómo usar la app';

  @override
  String get helpDialogTitle => '💕 Ayuda';

  @override
  String get helpDialogContent => 'Escaner de Crush es una app divertida que estima compatibilidad con base en nombres.\\n\\n- Ingresa tu nombre y el de tu crush\\n- Toca \\\"Escanear Amor\\\"\\n- Revisa tu resultado de compatibilidad\\n- Comparte tu resultado favorito\\n\\nEsta app es solo para entretenimiento.';

  @override
  String get understood => 'Entendido';

  @override
  String get aboutDialogTitle => '💘 Acerca de';

  @override
  String get aboutDialogContent => 'Escáner de Crush v1.0.0\n\nUna aplicación divertida para descubrir la compatibilidad amorosa.\n\nHecha con amor por Perlaza Studio\n\n© 2026 Escáner de Crush';

  @override
  String get streakTitle => 'Racha Diaria';

  @override
  String daysStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
      zero: '0 días',
    );
    return '$_temp0';
  }

  @override
  String get streakMaintain => '¡No rompas tu racha!';

  @override
  String get streakAtRisk => '¡Racha en riesgo! Escanea ahora para mantenerla 🔥';

  @override
  String get firstScanStreak => '🎉 ¡Bienvenido! ¡Tu aventura de amor comienza ahora!';

  @override
  String get streakBroken => '💔 Racha rota, ¡pero regresaste! Nueva racha iniciada';

  @override
  String newStreakRecord(int days) {
    return '🏆 ¡NUEVO RÉCORD! ¡$days días de racha! ¡Eres imparable!';
  }

  @override
  String streakContinues(int days) {
    return '🔥 ¡La racha continúa! ¡$days días escaneando amor!';
  }

  @override
  String get loveAnalytics => '📊 Love Analytics';

  @override
  String get premiumRequired => '✨ Premium Requerido';

  @override
  String get premiumRequiredMessage => 'Este tema está disponible solo para usuarios Premium. ¡Desbloquea todos los temas y más funciones!';

  @override
  String get analyticsPremium => '🔒 Analytics Premium';

  @override
  String get unlockDeepInsights => 'Desbloquea insights profundos sobre tu vida amorosa con analytics avanzados, predicciones y patrones de compatibilidad.';

  @override
  String get upgradeToPremiumAnalytics => 'Upgrade a Premium';

  @override
  String get analyzingLoveLife => 'Analizando tu vida amorosa...';

  @override
  String get errorLoadingAnalytics => 'Error cargando analytics';

  @override
  String get unknownErrorAnalytics => 'Error desconocido';

  @override
  String get retry => 'Reintentar';

  @override
  String get statisticsTab => 'Estadísticas';

  @override
  String get insightsTab => 'Insights';

  @override
  String get predictionsTab => 'Predicciones';

  @override
  String get totalScansAnalytics => 'Total Escaneos';

  @override
  String get averageAnalytics => 'Promedio';

  @override
  String get bestMatch => 'Mejor Match';

  @override
  String get celebritiesAnalytics => 'Celebridades';

  @override
  String get compatibilityTrend => '📈 Tendencia de Compatibilidad (30 días)';

  @override
  String get notEnoughDataTrends => 'No hay suficientes datos para mostrar tendencias';

  @override
  String get last30Days => 'Últimos 30 días';

  @override
  String get yourBestMatches => '🏆 Tus Mejores Matches';

  @override
  String get celebrity => 'Celebrity';

  @override
  String get personal => 'Personal';

  @override
  String get advancedAnalytics => 'Analytics Avanzados';

  @override
  String get analyticsDescription => 'Gráficos y estadísticas de compatibilidad';

  @override
  String get cloudBackup => 'Backup en la Nube';

  @override
  String get cloudBackupDescription => 'Tus datos seguros y sincronizados';

  @override
  String get perMonth => '/mes';

  @override
  String get monthlyPrice => '\$2.99';

  @override
  String get unlockFullPotential => '¡Desbloquea todo el potencial del amor!';

  @override
  String get purchasesRestoredSuccessfully => 'Compras restauradas exitosamente';

  @override
  String get defaultPrice => '\$2.99/mes';

  @override
  String get themesTitle => '🎨 Temas Premium';

  @override
  String get customizeExperience => 'Personaliza tu experiencia';

  @override
  String get currentTheme => 'Tema Actual';

  @override
  String get active => 'ACTIVO';

  @override
  String themeApplied(String themeName) {
    return 'Tema $themeName aplicado';
  }

  @override
  String get classicThemeName => '💘 Clásico';

  @override
  String get classicThemeDescription => 'El tema original de amor';

  @override
  String get sunsetThemeName => '🌅 Aurora Pastel';

  @override
  String get sunsetThemeDescription => 'Tonos pastel con purpura';

  @override
  String get oceanThemeName => '🌊 Océano';

  @override
  String get oceanThemeDescription => 'Profundos azules marinos';

  @override
  String get forestThemeName => '🌲 Bosque';

  @override
  String get forestThemeDescription => 'Verdes naturales y frescos';

  @override
  String get lavenderThemeName => '💜 Lavanda';

  @override
  String get lavenderThemeDescription => 'Elegantes púrpuras y violetas';

  @override
  String get cosmicThemeName => '🌌 Cósmico';

  @override
  String get cosmicThemeDescription => 'Misterioso espacio profundo';

  @override
  String get cherryThemeName => '🌸 Cerezo';

  @override
  String get cherryThemeDescription => 'Elegante rosa sakura japonés';

  @override
  String get goldenThemeName => '✨ Dorado';

  @override
  String get goldenThemeDescription => 'Lujo y elegancia dorada';

  @override
  String scansToday(int remaining, int total) {
    return 'Escaneos de hoy: $remaining/$total';
  }

  @override
  String scansRemaining(int count) {
    return 'Quedan $count escaneos gratis';
  }

  @override
  String get premiumBenefits => '🚀 Escaneos ilimitados • 🚫 Sin anuncios • ⭐ Contenido exclusivo';

  @override
  String get trialPeriod => '🎉 ¡Período de Prueba!';

  @override
  String unlimitedScansRemaining(int days) {
    return 'Escaneos ILIMITADOS por $days días más';
  }

  @override
  String get premiumAnalytics => 'Analytics Premium';

  @override
  String get analyzeCompatibilityPatterns => 'Analiza tus patrones de compatibilidad';

  @override
  String get premiumThemes => 'Temas Premium';

  @override
  String get customizeWithThemes => 'Personaliza con 8 temas únicos';

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionAudio => 'Audio';

  @override
  String get sectionData => 'Datos';

  @override
  String get clearAllData => 'Eliminar Todos los Datos';

  @override
  String get clearAllDataSubtitle => 'Eliminar estadísticas, historial y rachas';

  @override
  String get aboutSubtitle => 'Información sobre la aplicación';

  @override
  String get privacyTitle => 'Privacidad';

  @override
  String get privacySubtitle => 'Política de privacidad y términos';

  @override
  String get privacyDialogTitle => '🔒 Privacidad';

  @override
  String get privacyDialogContent => 'Tu privacidad es importante para nosotros.\n\n• Los nombres se almacenan solo localmente\n• No compartimos información personal\n• Los resultados son generados aleatoriamente\n• Puedes borrar tu historial en cualquier momento\n\nEsta app es solo para entretenimiento.';

  @override
  String get confirmClearDataTitle => '¿Eliminar Todos los Datos?';

  @override
  String get confirmClearDataContent => '¿Estás seguro de que quieres eliminar todas tus estadísticas, historial y rachas? Esta acción no se puede deshacer.';

  @override
  String get deleteAll => 'Eliminar Todo';

  @override
  String get dataDeletedSuccess => 'Todos los datos han sido eliminados exitosamente';

  @override
  String errorDeletingData(Object error) {
    return 'Error al eliminar datos: $error';
  }

  @override
  String get appVersionFooter => 'Escáner de Crush v1.0.0\nHecho con 💕 para el amor';

  @override
  String get welcomeNewUserTitle => '🎉 ¡Bienvenido Usuario Nuevo!';

  @override
  String get enjoyUnlimitedTrialScans => '¡Disfruta escaneos ilimitados en tu prueba!';

  @override
  String get unlimitedScansActive => 'Escaneos Ilimitados Activos';

  @override
  String trialDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count días de prueba',
      one: 'Queda 1 día de prueba',
    );
    return '$_temp0';
  }

  @override
  String get trialEndingToday => 'Prueba termina hoy';

  @override
  String get upgradeToPremiumPromo => 'Upgrade a Premium';

  @override
  String get watchAdToUnlockInsights => 'Ver anuncio para desbloquear';

  @override
  String get watchAdToUnlockPredictions => 'Ver anuncio para desbloquear';

  @override
  String get insightsLockedDescription => 'Descubre patrones únicos sobre tu vida amorosa. Mira un breve anuncio o hazte Premium para acceso ilimitado.';

  @override
  String get predictionsLockedDescription => 'Obtén predicciones personalizadas sobre tu futuro amoroso. Mira un breve anuncio o hazte Premium para acceso ilimitado.';

  @override
  String get adNotAvailable => 'Anuncio no disponible en este momento';

  @override
  String get orGetPremium => 'o hazte Premium';

  @override
  String get insightsUnlocked => '✨ Insights desbloqueados';

  @override
  String get predictionsUnlocked => '✨ Predicciones desbloqueadas';

  @override
  String coinsClaimedMessage(int count) {
    return '+$count coins reclamadas.';
  }

  @override
  String scanPackBoughtMessage(int scans, int cost) {
    return 'Ganaste +$scans escaneos por $cost coins.';
  }

  @override
  String notEnoughCoinsCurrentPackMessage(int cost) {
    return 'No tienes suficientes coins. El pack actual cuesta $cost.';
  }

  @override
  String notEnoughCoinsThisPackMessage(int cost) {
    return 'No tienes suficientes coins. Este pack cuesta $cost.';
  }

  @override
  String get dailyPackLimitReachedMessage => 'Limite diario de packs alcanzado. Vuelve manana.';

  @override
  String get dailyPackLimitReachedTryTomorrowMessage => 'Limite diario de packs alcanzado. Intenta manana.';

  @override
  String get premiumUnlimitedScansMessage => 'Premium ya tiene escaneos ilimitados.';

  @override
  String coinsEarnedMessage(int count) {
    return '+$count coins ganadas.';
  }

  @override
  String coinsWonMessage(int count) {
    return '+$count coins ganadas';
  }

  @override
  String get noAdAvailableNowMessage => 'No hay anuncio disponible ahora.';

  @override
  String get loadingRetentionRewards => 'Cargando recompensas de retencion...';

  @override
  String get retentionPanelUnavailable => 'Panel de retencion no disponible. Toca para reintentar.';

  @override
  String get dailyRetentionRewardsTitle => 'Recompensas de retencion diaria';

  @override
  String coinsLabel(int count) {
    return 'Coins: $count';
  }

  @override
  String streakDaysLabel(int days) {
    return 'Racha: ${days}d';
  }

  @override
  String get premiumScannerEconomyNotice => 'Premium activo: escaneos ilimitados, sin anuncios y progreso de coins acelerado. Usa tus coins en ventajas del Torneo.';

  @override
  String scanPackButtonLabel(int scans, int cost, int remaining) {
    return '+$scans escaneos (${cost}c) - $remaining disponibles';
  }

  @override
  String get scanPackExhaustedToday => 'Packs de escaneo agotados hoy';

  @override
  String adCoinsButtonLabel(int count) {
    return 'Anuncio +${count}c';
  }

  @override
  String get dailyMissionsTitle => 'Misiones diarias';

  @override
  String get claimedLabel => 'Reclamada';

  @override
  String get retentionRewardsTitle => 'Recompensas de retencion';

  @override
  String get youGotPlusTwoScansMessage => 'Ganaste +2 escaneos.';

  @override
  String get useCoinsLabel => 'Usar coins';

  @override
  String get plusTwoScansWithCoins => '+2 escaneos con coins';

  @override
  String get useCoinsPackPlusTwoScans => 'Usar coins (pack +2 escaneos)';

  @override
  String get watchAdPlusTwoScans => 'Ver anuncio (+2 escaneos)';

  @override
  String get tournamentFunnelTodayTitle => '🎯 Funnel de Torneo (Hoy)';

  @override
  String get funnelStartsLabel => 'Inicios';

  @override
  String get funnelCompletionsLabel => 'Completados';

  @override
  String get funnelCompletionRateLabel => 'Tasa de finalizacion';

  @override
  String get funnelTicketAdsLabel => 'Anuncios de ticket';

  @override
  String get funnelReviveAdsLabel => 'Anuncios de revive';

  @override
  String get funnelReviveCoinsLabel => 'Revive con coins';

  @override
  String get funnelShopBuysLabel => 'Compras en tienda';

  @override
  String get loveIntelligenceStudio => 'Estudio de Inteligencia del Amor';

  @override
  String get tournament16UnlimitedTitle => 'Torneos de 16 Ilimitados';

  @override
  String get tournament16UnlimitedDescription => 'Juega torneos epicos de 16 jugadores todos los dias sin limites';

  @override
  String get tournamentTitle => '🏆 Torneo del Amor';

  @override
  String get tournamentWelcomeSubtitle => '¡Enfrenta a tus crushes en un torneo épico!';

  @override
  String get tournamentDescription => 'Ingresa los nombres de tus crushes y descubre quién es tu match definitivo en un torneo de eliminación';

  @override
  String get tournamentYourName => 'Tu Nombre';

  @override
  String get tournamentYourNameHint => 'Escribe tu nombre...';

  @override
  String get tournamentSelectFormat => 'Formato del Torneo';

  @override
  String get tournamentParticipants => 'Participantes';

  @override
  String get tournamentCrush => 'Crush';

  @override
  String get tournamentAddCelebrity => '⭐ Celebridad';

  @override
  String get tournamentFillAll => '✨ Llenar';

  @override
  String get tournamentStart => '¡Iniciar Torneo!';

  @override
  String get tournamentEnterYourName => 'Por favor ingresa tu nombre';

  @override
  String get tournamentFillAllNames => 'Debes llenar todos los nombres';

  @override
  String get tournamentNoDuplicates => 'No puedes tener nombres duplicados';

  @override
  String get tournament16PremiumOnly => 'El formato de 16 participantes es exclusivo para usuarios Premium. ¡Actualiza para desbloquear torneos épicos!';

  @override
  String get tournamentBracket => 'Bracket del Torneo';

  @override
  String get tournamentMatchesPlayed => 'Partidas jugadas';

  @override
  String get tournamentNextMatch => '¡Siguiente Duelo!';

  @override
  String get tournamentExitTitle => '¿Abandonar Torneo?';

  @override
  String get tournamentExitMessage => '¿Estás seguro de que quieres salir? Tu progreso se perderá.';

  @override
  String get tournamentExit => 'Salir';

  @override
  String get tournamentReviveTitle => '💫 Revivir Crush';

  @override
  String get tournamentReviveDescription => 'Mira un anuncio para dar una segunda oportunidad a un crush eliminado';

  @override
  String get tournamentRevived => '¡ha vuelto al torneo!';

  @override
  String get tournamentComplete => '¡Torneo Completado!';

  @override
  String get tournamentResultSubtitle => 'Aquí están los resultados de tu torneo del amor';

  @override
  String get tournamentShare => 'Compartir Resultados';

  @override
  String get tournamentPlayAgain => 'Jugar de Nuevo';

  @override
  String get tournamentSummary => 'Resumen del Torneo';

  @override
  String get tournamentTotalMatches => 'Total de duelos';

  @override
  String get tournamentParticipantsCount => 'Participantes';

  @override
  String get tournamentRoundsPlayed => 'Rondas jugadas';

  @override
  String get tournamentFinalMatch => '🏆 Duelo Final';
}
