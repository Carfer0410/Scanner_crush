// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get predictionInfoExplanation => 'The percentage in the phrase is your real average compatibility. The number in the corner is the confidence of the prediction.';

  @override
  String get insightMasterLove => 'Master of Love';

  @override
  String insightMasterLoveDesc(Object percent) {
    return 'Your average compatibility is exceptional ($percent%). You have a natural gift for love!';
  }

  @override
  String get insightGoodRadar => 'Good Love Radar';

  @override
  String insightGoodRadarDesc(Object percent) {
    return 'Your average compatibility is solid ($percent%). You trust your instincts.';
  }

  @override
  String get insightExplorerLove => 'Love Explorer';

  @override
  String get insightExplorerLoveDesc => 'You are exploring different types of connections. Every scan brings you closer to your perfect match!';

  @override
  String get insightCelebrityCrusher => 'Celebrity Crusher';

  @override
  String insightCelebrityCrusherDesc(Object percent) {
    return 'You prefer celebrities ($percent% of your scans). You like high standards!';
  }

  @override
  String get insightTrueRomantic => 'True Romantic';

  @override
  String insightTrueRomanticDesc(Object percent) {
    return 'You prefer real connections ($percent% of your scans). True love calls you.';
  }

  @override
  String get insightExpert => 'Compatibility Expert';

  @override
  String insightExpertDesc(Object scans) {
    return 'With $scans scans, you are an expert. Your experience is invaluable.';
  }

  @override
  String get insightDedicatedUser => 'Dedicated User';

  @override
  String insightDedicatedUserDesc(Object scans) {
    return 'You already have $scans scans. Your dedication to love is admirable!';
  }

  @override
  String get insightCommittedExplorer => 'Committed Explorer';

  @override
  String insightCommittedExplorerDesc(Object scans) {
    return 'With $scans scans, you are building a solid profile. Keep it up!';
  }

  @override
  String get insightNewAdventurer => 'New Adventurer';

  @override
  String get insightNewAdventurerDesc => 'You have started your journey of love discovery. Every scan reveals something new!';

  @override
  String get predictionLoveRising => 'Love Rising';

  @override
  String get predictionLoveRisingDesc => 'Your compatibility has improved lately. The coming weeks will be promising for love.';

  @override
  String get predictionTimeReflection => 'Time for Reflection';

  @override
  String get predictionTimeReflectionDesc => 'It\'s a good time to reflect on what you seek in love. Clarity will bring better connections.';

  @override
  String get predictionStableLove => 'Stable Love';

  @override
  String get predictionStableLoveDesc => 'Your compatibility remains consistent. It\'s a good time to consolidate connections.';

  @override
  String get predictionDiscoveringPattern => 'Discovering Your Pattern';

  @override
  String get predictionDiscoveringPatternDesc => 'You are building your love profile. Each scan helps us better understand your preferences.';

  @override
  String get predictionJourneyStart => 'Start of Your Journey';

  @override
  String get predictionJourneyStartDesc => 'You have started your love exploration. Keep scanning to discover fascinating patterns!';

  @override
  String get predictionPerfectMatchNear => 'Perfect Match Near';

  @override
  String predictionPerfectMatchNearDesc(Object percent) {
    return 'Your high average compatibility ($percent%) suggests your perfect match is very close. Keep your eyes open.';
  }

  @override
  String get predictionGoodLovePath => 'Good Love Path';

  @override
  String predictionGoodLovePathDesc(Object percent) {
    return 'Your average compatibility ($percent%) shows you have good judgment. Trust your instincts.';
  }

  @override
  String get predictionLoveAwaits => 'Love Awaits You';

  @override
  String get predictionLoveAwaitsDesc => 'Each scan brings you closer to understanding love. Keep exploring and discovering your path!';

  @override
  String get predictionTimeframeNext2Weeks => 'Next 2 weeks';

  @override
  String get predictionTimeframeNextMonth => 'Next month';

  @override
  String get predictionTimeframeNext3Weeks => 'Next 3 weeks';

  @override
  String get predictionTimeframeNextWeeks => 'Next weeks';

  @override
  String get predictionTimeframeAsYouExplore => 'As you explore';

  @override
  String get predictionTimeframeNext3Months => 'Next 3 months';

  @override
  String get predictionTimeframeNext2Months => 'Next 2 months';

  @override
  String get predictionTimeframeLoveJourney => 'On your love journey';

  @override
  String get errorGeneratingResult => 'Error generating result. Please try again.';

  @override
  String get celebrityCrush => 'Celebrity Crush';

  @override
  String helloCelebrity(String userName) {
    return 'Hello $userName!';
  }

  @override
  String get chooseCelebrityDescription => 'Choose your celebrity crush and discover your compatibility';

  @override
  String get searchCelebrity => 'Search celebrity...';

  @override
  String get noInsightsYet => 'No insights yet';

  @override
  String get scanMoreForInsights => 'Scan more to get personalized insights';

  @override
  String get noPredictionsYet => 'No predictions available';

  @override
  String get scanMoreForPredictions => 'Scan more to generate predictions about your love life';

  @override
  String get bannerLoaded => 'Banner Ad loaded successfully';

  @override
  String get bannerLoadError => 'Error loading Banner Ad:';

  @override
  String get testingBannerAd => '🎯 Testing Banner Ad...';

  @override
  String get bannerAdWorking => '✅ Banner Ad is working';

  @override
  String get bannerAdNotLoaded => '❌ Banner Ad is not loaded';

  @override
  String get testingInterstitialAd => '🎯 Testing Interstitial Ad...';

  @override
  String get interstitialAdAvailable => '✅ Interstitial Ad available';

  @override
  String get interstitialShown => '✅ Interstitial shown';

  @override
  String get interstitialShowError => '❌ Error showing Interstitial';

  @override
  String get interstitialNotReady => '⚠️ Interstitial Ad is not ready';

  @override
  String get testingRewardedAd => '🎯 Testing Rewarded Ad...';

  @override
  String get rewardedAdShown => '✅ Rewarded Ad shown and reward granted';

  @override
  String get rewardedAdError => '❌ Error with Rewarded Ad';

  @override
  String get adsTestTitle => 'Ads Test';

  @override
  String get systemStatus => 'System Status';

  @override
  String get liveBannerAd => '📱 Live Banner Ad:';

  @override
  String get testBanner => 'Test Banner';

  @override
  String get testInterstitial => 'Test Interstitial';

  @override
  String get testRewardedAd => 'Test Rewarded Ad';

  @override
  String get testResults => 'Test Results';

  @override
  String get pressButtonsToTestAds => 'Press the buttons to test the ads';

  @override
  String get premiumUniverseCard => 'Unlock the premium universe: daily personalized horoscopes, love advice, advanced compatibility analysis, no ads.';

  @override
  String get appTitle => 'Crush Scanner 💘';

  @override
  String get splashSubtitle => 'Discover your love destiny';

  @override
  String get splashSlogan => 'Love is just the beginning! 💖';

  @override
  String get welcomeTitle => 'Discover Your Secret Admirer';

  @override
  String get welcomeSubtitle => 'Find out who has a crush on you with our advanced algorithm 💕';

  @override
  String get startScan => 'Start Scan';

  @override
  String get celebrityScan => 'Celebrity Scan';

  @override
  String get dailyLove => 'Daily Love';

  @override
  String get settings => 'Settings';

  @override
  String get history => 'History';

  @override
  String get premium => 'Premium';

  @override
  String get yourName => 'Your name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get crushName => 'Crush\'s Name';

  @override
  String get enterCrushName => 'Enter your crush\'s name';

  @override
  String get scanNow => 'Scan Now';

  @override
  String get scanning => 'Scanning...';

  @override
  String get analyzing => 'Analyzing compatibility...';

  @override
  String get calculatingLove => 'Calculating love percentage...';

  @override
  String get scanComplete => 'Scan Complete!';

  @override
  String get lovePercentage => 'Love Percentage';

  @override
  String get compatibilityLevel => 'Compatibility Level';

  @override
  String get shareResult => 'Share Result';

  @override
  String get scanAgain => 'Scan Again';

  @override
  String get back => 'Back';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get backgroundMusic => 'Background Music';

  @override
  String get language => 'Language';

  @override
  String get volume => 'Volume';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get noHistory => 'No scans yet';

  @override
  String get startFirstScan => 'Start your first scan to see results here';

  @override
  String get scanHistory => 'Scan History';

  @override
  String get deleteHistory => 'Delete History';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleteHistoryMessage => 'Are you sure you want to delete all scan history? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get historyDeleted => 'History deleted successfully';

  @override
  String get todaysLove => 'Today\'s Love';

  @override
  String get yourDailyLoveReading => 'Your Daily Love Reading';

  @override
  String get loveAdvice => 'Love Advice';

  @override
  String get luckyNumber => 'Lucky Number';

  @override
  String get loveCompatibility => 'Love Compatibility';

  @override
  String get perfectMatch => 'Perfect Match! 💖';

  @override
  String get excellentMatch => 'Excellent Match! 💕';

  @override
  String get goodMatch => 'Good Match! 💓';

  @override
  String get fairMatch => 'Fair Match 💙';

  @override
  String get lowMatch => 'Low Match 💔';

  @override
  String get celebrityScanner => 'Celebrity Scanner';

  @override
  String get whichCelebrityLikesYou => 'Which celebrity likes you?';

  @override
  String get selectGender => 'Select Gender';

  @override
  String get male => 'Male';

  @override
  String get appTitleFull => 'Crush Scanner 💘';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get premiumOnly => 'Premium Only';

  @override
  String remainingScans(Object count) {
    return 'You have $count scans left today! 💕';
  }

  @override
  String get noScansLeft => 'No scans left! Watch ads for more';

  @override
  String get useWisely => 'Use them wisely or get more below 😉';

  @override
  String get moreTomorrow => 'Tomorrow you\'ll have 5 fresh scans waiting, or you can get more now:';

  @override
  String get watchShortAd => 'Watch short ad';

  @override
  String get extraScansFree => '+2 free scans';

  @override
  String get unlimitedScans => 'Unlimited Scans';

  @override
  String get premiumPriceText => 'Premium for \$2.99/month';

  @override
  String get waitUntilTomorrow => 'Wait until tomorrow';

  @override
  String get freshScans => '5 fresh scans free';

  @override
  String get perfectScan => 'Perfect, let\'s scan! 💘';

  @override
  String get limitReachedTitle => 'Limit reached!';

  @override
  String get limitReachedBody => 'You have used all your free scans for today.';

  @override
  String get limitReachedWhatToDo => 'What can you do?';

  @override
  String get watchAd => 'Watch ad';

  @override
  String get winExtraScans => 'Win +2 extra scans';

  @override
  String get extraScansWon => '+2 extra scans won!';

  @override
  String get goPremium => 'Go Premium';

  @override
  String get wait => 'Wait';

  @override
  String get moreScansTomorrow => 'More scans tomorrow';

  @override
  String get close => 'Close';

  @override
  String get female => 'Female';

  @override
  String get any => 'Any';

  @override
  String get findCelebrityMatch => 'Find Celebrity Match';

  @override
  String get yourCelebrityMatch => 'Your Celebrity Match';

  @override
  String get compatibilityScore => 'Compatibility Score';

  @override
  String get whyThisMatch => 'Why this match?';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get errorTitle => 'Error';

  @override
  String errorLoadingLoveDay(Object error) {
    return 'Could not load your love day: $error';
  }

  @override
  String get ok => 'OK';

  @override
  String get freeTrialBannerTitle => 'FREE Trial Period!';

  @override
  String get freeTrialBannerDayLeft => '1 DAY LEFT';

  @override
  String freeTrialBannerDaysLeft(Object days) {
    return '$days DAYS LEFT';
  }

  @override
  String get freeTrialBannerUnlimited => 'Unlimited scans!';

  @override
  String get freeTrialBannerEnjoy => 'Enjoy unlimited love scans during your trial';

  @override
  String get limitReached => 'Limit reached!';

  @override
  String scansRemainingToday(int count) {
    return '$count scans remaining today';
  }

  @override
  String get watchAdForMore => 'Watch ad for +2 more';

  @override
  String get upgradeForUnlimited => 'You\'ve used all your scans today. Upgrade to Premium for unlimited scans.';

  @override
  String get watchAdForScans => 'Watch ad (+2 scans)';

  @override
  String get noAdsAvailable => 'No ads available. Try again later.';

  @override
  String get watchAdOrUpgrade => 'Watch ad or upgrade for more';

  @override
  String get dailyStreak => 'Daily Streak';

  @override
  String get startLoveStreak => 'Start your love streak today!';

  @override
  String get best => 'Best';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get bestStreak => 'Best Streak';

  @override
  String get totalScans => 'Total Scans';

  @override
  String get streakStatsTitle => '🔥 Streak Stats';

  @override
  String get learnAboutStats => 'Learn about stats';

  @override
  String get streakStatsDialogCurrent => 'Current Streak';

  @override
  String get streakStatsDialogBest => 'Best Streak';

  @override
  String get streakStatsDialogTotal => 'Total Scans';

  @override
  String streakStatsDialogMotivation(Object motivation) {
    return '$motivation';
  }

  @override
  String get streakInfoDialogTitle => 'What do these stats mean?';

  @override
  String get streakInfoCurrentDesc => 'How many consecutive days you\'ve used the app without missing a day.';

  @override
  String get streakInfoCurrentExample => 'Example: If you used it yesterday and today, your current streak is 2 days.';

  @override
  String get streakInfoBestDesc => 'Your personal record - the longest streak you\'ve ever achieved. It\'s always equal or greater than your current streak.';

  @override
  String get streakInfoBestExample => 'Example: If your current streak is 2 days, your best streak is at least 2 days (or higher if you had a longer streak before).';

  @override
  String get streakInfoTotalDesc => 'The total number of love scans you\'ve performed since you started using the app.';

  @override
  String get streakInfoTotalExample => 'Example: Every time you scan your crush compatibility, this number goes up.';

  @override
  String get streakInfoTip => '💡 Tip: Keep using the app daily to build your streak and discover your love compatibility!';

  @override
  String get gotIt => 'Got it!';

  @override
  String get premiumRequiredTitle => 'Premium Required';

  @override
  String get premiumRequiredContent => 'This feature is available only for Premium users. Upgrade now and unlock all exclusive features!';

  @override
  String get viewPremium => 'View Premium';

  @override
  String get unlockAllFeatures => 'Unlock all features and enjoy the full experience!';

  @override
  String get premiumFeatures => 'Premium Features';

  @override
  String get detailedAnalysis => 'Detailed Analysis';

  @override
  String get noAds => 'No Ads';

  @override
  String get exclusiveContent => 'Exclusive Content';

  @override
  String get advancedCompatibility => 'Advanced Compatibility';

  @override
  String get monthlyPlan => 'Monthly Plan';

  @override
  String get yearlyPlan => 'Yearly Plan';

  @override
  String get mostPopular => 'Most Popular';

  @override
  String save(String percentage) {
    return 'Save';
  }

  @override
  String get subscribe => 'Subscribe';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get pleaseEnterCrushName => 'Please enter your crush\'s name';

  @override
  String shareMessage(String percentage, String crushName) {
    return 'I got $percentage% compatibility with $crushName on Crush Scanner! 💕 Try it yourself: [App Link]';
  }

  @override
  String get madeWithLove => 'Made with 💕 to discover love';

  @override
  String get regularScanSubtitle => 'Discover your compatibility with someone special';

  @override
  String get celebrityScanSubtitle => 'Your compatibility with the stars';

  @override
  String get formInstructions => 'Enter your name and that of that special person to discover what the heart says about your connection';

  @override
  String get scanLoveButton => 'Scan Love ❤️';

  @override
  String get personalAlgorithm => '✨ Personal Algorithm ✨';

  @override
  String get algorithmDescription => 'Our love algorithm analyzes compatibility between real people, based on energies, names and heart connections to reveal romantic secrets.';

  @override
  String get soundEffectsSubtitle => 'Sounds on buttons and actions';

  @override
  String get backgroundMusicSubtitle => 'Relaxing ambient music';

  @override
  String get upgradeSettings => 'Upgrade to Premium';

  @override
  String get unlockAllFeaturesSettings => 'Unlock all features';

  @override
  String get newBadge => 'NEW';

  @override
  String get preparingLoveDay => 'Preparing your love day...';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get goBack => 'Go Back';

  @override
  String get yourLoveUniverse => 'Your Love Universe';

  @override
  String get consecutiveDays => 'Consecutive days';

  @override
  String get average => 'Average';

  @override
  String get personalizedTip => 'Personalized Tip';

  @override
  String get unlockedAchievements => '🏆 Unlocked Achievements';

  @override
  String get shareError => 'Error sharing. Please try again.';

  @override
  String get result => 'Result';

  @override
  String get perfectCompatibility => 'Perfect Compatibility!';

  @override
  String get greatCompatibility => 'Great Compatibility!';

  @override
  String get goodCompatibility => 'Good Compatibility';

  @override
  String get share => 'Share';

  @override
  String get celebrityCrushTitle => '🌟 Celebrity Crush 🌟';

  @override
  String get celebrityCrushDescription => 'Discover your compatibility with the brightest stars of Hollywood and the entertainment world';

  @override
  String get chooseMyCommit => 'Choose My Celebrity Crush ✨';

  @override
  String get celebrityMode => '✨ Celebrity Mode ✨';

  @override
  String get celebrityModeDescription => 'Our stellar algorithm analyzes your name and the cosmic energy of celebrities to reveal unique connections from the entertainment world.';

  @override
  String get popularCelebrities => '🎬 Popular Celebrities';

  @override
  String get andManyMore => 'And many more...';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get noHistoryDescription => 'Your compatibility scans will appear here';

  @override
  String get startScanning => 'Start Scanning';

  @override
  String errorLoadingHistory(String error) {
    return 'Error loading history: $error';
  }

  @override
  String get agoTime => 'ago';

  @override
  String get minutes => 'min';

  @override
  String get hours => 'h';

  @override
  String get days => 'days';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get confirmClearHistory => 'Are you sure you want to clear your history?';

  @override
  String get confirmClear => 'Clear';

  @override
  String get historyCleared => 'History cleared successfully';

  @override
  String get errorClearingHistory => 'Error clearing history';

  @override
  String get errorSharingResult => 'Error sharing result';

  @override
  String get premiumTitle => 'Scanner Crush Premium';

  @override
  String get premiumSubtitle => 'Unlock the full potential of love!';

  @override
  String get noAdsTitle => 'No Ads';

  @override
  String get noAdsDescription => 'Enjoy the complete experience without interruptions';

  @override
  String get unlimitedScansTitle => 'Unlimited Scans';

  @override
  String get unlimitedScansDescription => 'Scan as much as you want without restrictions';

  @override
  String get exclusiveResultsTitle => 'Exclusive Results';

  @override
  String get exclusiveResultsDescription => 'Access special messages and predictions';

  @override
  String get crushHistoryTitle => 'Crush History';

  @override
  String get crushHistoryDescription => 'Save and review all your previous scans';

  @override
  String get specialThemesTitle => 'Special Themes';

  @override
  String get specialThemesDescription => 'Customize the app with unique and exclusive themes';

  @override
  String get premiumSupportTitle => 'Premium Support';

  @override
  String get premiumSupportDescription => 'Priority attention and advanced technical support';

  @override
  String get purchasePremium => 'Subscribe Now';

  @override
  String get welcomeToPremium => 'Welcome to Premium!';

  @override
  String get premiumActivated => 'Your Premium account has been successfully activated. Enjoy all the exclusive features!';

  @override
  String get great => 'Great!';

  @override
  String get restorePurchasesButton => 'Restore Purchases';

  @override
  String get processing => 'Processing...';

  @override
  String get noPreviousPurchases => 'No previous purchases found';

  @override
  String get magneticConnection => '💘 Magnetic Connection';

  @override
  String get magneticConnectionMessage => 'Today love energies are especially strong. It\'s the perfect time to discover new connections.';

  @override
  String get magneticConnectionAdvice => 'Keep your heart open to love\'s surprises.';

  @override
  String get dayOfRevelations => '✨ Day of Revelations';

  @override
  String get dayOfRevelationsMessage => 'Heart secrets are ready to be revealed. Someone special might confess something important to you.';

  @override
  String get dayOfRevelationsAdvice => 'Pay attention to subtle signs from those around you.';

  @override
  String get romanceInTheAir => '🌹 Romance in the Air';

  @override
  String get romanceInTheAirMessage => 'The universe conspires to create romantic moments. Your crush might be thinking about you more than you imagine.';

  @override
  String get romanceInTheAirAdvice => 'Be brave and take the first step.';

  @override
  String get destinyAligned => '💫 Destiny Aligned';

  @override
  String get destinyAlignedMessage => 'The stars align to favor casual encounters that can change your love life.';

  @override
  String get destinyAlignedAdvice => 'Step out of your comfort zone and socialize more.';

  @override
  String get butterfliesInStomach => '🦋 Butterflies in Your Stomach';

  @override
  String get butterfliesInStomachMessage => 'Today you\'ll feel those special butterflies. Your love intuition is at its highest point.';

  @override
  String get butterfliesInStomachAdvice => 'Trust your heart\'s instincts.';

  @override
  String get burningPassion => '🔥 Burning Passion';

  @override
  String get burningPassionMessage => 'Romantic energy is at its maximum. It\'s a perfect day to express your feelings.';

  @override
  String get burningPassionAdvice => 'Don\'t repress your emotions, let them flow.';

  @override
  String get authenticLove => '💎 Authentic Love';

  @override
  String get authenticLoveMessage => 'Today you can recognize true love. Superficial connections fade away.';

  @override
  String get authenticLoveAdvice => 'Seek depth in your relationships.';

  @override
  String personalizedTipStreak(int streak) {
    return '🔥 Incredible $streak-day streak! Your love energy is at its peak.';
  }

  @override
  String personalizedTipCompatibility(int compatibility) {
    return '⭐ Your average compatibility is excellent ($compatibility%). You have a good eye for love!';
  }

  @override
  String personalizedTipScans(int scans) {
    return '💡 With $scans scans completed, your love experience is growing. Keep exploring!';
  }

  @override
  String get personalizedTipGoodCompatibility => '💫 Your average compatibility is good. Trust your love instincts.';

  @override
  String get personalizedTipEncouragement => '🌱 Each scan brings you closer to finding your perfect connection. Don\'t give up!';

  @override
  String get fireStreak => '🔥 Fire Streak';

  @override
  String fireStreakDescription(int days) {
    return '$days consecutive days';
  }

  @override
  String get loveExplorer => '🎯 Love Explorer';

  @override
  String loveExplorerDescription(int scans) {
    return '$scans scans completed';
  }

  @override
  String get compatibilityMaster => '⭐ Compatibility Master';

  @override
  String compatibilityMasterDescription(int average) {
    return '$average% average';
  }

  @override
  String get romanceGuru => '👑 Romance Guru';

  @override
  String get romanceGuruDescription => 'Love expert';

  @override
  String get personalScannerTitle => 'Personal Scanner';

  @override
  String get personalCompatibilityTitle => '💕 Your Personal Compatibility 💕';

  @override
  String get resultTitle => 'Result';

  @override
  String get thereIsPotential => 'There Is Potential';

  @override
  String get shareButton => 'Share';

  @override
  String get scanAgainButton => 'Scan Again';

  @override
  String get celebrityMessage1 => 'OMG! Your compatibility with a celebrity is incredible 🌟';

  @override
  String get celebrityMessage2 => 'Hollywood stars approve this combination ⭐';

  @override
  String get celebrityMessage3 => 'Your celebrity crush could be your soulmate! 💫';

  @override
  String get celebrityMessage4 => 'Hollywood is talking about this compatibility 🎬';

  @override
  String get celebrityMessage5 => 'Plot twist! You have chemistry with a superstar 🎭';

  @override
  String get celebrityMessage6 => 'Your celebrity compatibility level is off the charts! 📈';

  @override
  String get celebrityMessage7 => 'Breaking news! You\'re compatible with a star 📺';

  @override
  String get celebrityMessage8 => 'Love\'s red carpet is waiting for you 🌹';

  @override
  String get celebrityMessage9 => 'Paparazzi alert! You have a special connection 📸';

  @override
  String get celebrityMessage10 => 'Your love story could be a blockbuster movie 🍿';

  @override
  String get celebrityMessage11 => 'Award-winning compatibility detected! 🏆';

  @override
  String get celebrityMessage12 => 'Gossip magazines would be talking about you two 📰';

  @override
  String get celebrityMessage13 => 'Your celebrity crush approves this combination 💕';

  @override
  String get celebrityMessage14 => 'Lights, camera, love! You have celebrity couple potential 🎥';

  @override
  String get celebrityMessage15 => 'The celebrity universe conspires in your favor ✨';

  @override
  String get romanticMessage1 => 'Your hearts beat in perfect rhythm! 💕';

  @override
  String get romanticMessage2 => 'The stars align perfectly for you both ✨';

  @override
  String get romanticMessage3 => 'There\'s a special connection waiting to be discovered 🌙';

  @override
  String get romanticMessage4 => 'Destiny has woven its threads between you two 💫';

  @override
  String get romanticMessage5 => 'Your souls seem to speak love\'s same language 💝';

  @override
  String get romanticMessage6 => 'Love\'s magic is floating in the air 🎭';

  @override
  String get romanticMessage7 => 'There\'s undeniable chemistry between you 🔥';

  @override
  String get romanticMessage8 => 'The universe conspires in favor of your love 🌟';

  @override
  String get romanticMessage9 => 'Your energies complement each other perfectly 🌸';

  @override
  String get romanticMessage10 => 'There\'s more than friendship waiting to bloom 🌺';

  @override
  String get romanticMessage11 => 'The compatibility between you is amazing 💖';

  @override
  String get romanticMessage12 => 'True love might be closer than you think 💘';

  @override
  String get romanticMessage13 => 'Your hearts vibrate on the same frequency 🎵';

  @override
  String get romanticMessage14 => 'The attraction between you is magnetic ⚡';

  @override
  String get romanticMessage15 => 'Cupid already has his arrows aimed at you 🏹';

  @override
  String get romanticMessage16 => 'Your paths are destined to cross again and again 🛤️';

  @override
  String get romanticMessage17 => 'Love\'s flame burns intensely between you 🕯️';

  @override
  String get romanticMessage18 => 'There\'s a cosmic connection that binds you 🌌';

  @override
  String get romanticMessage19 => 'Love is writing its own story 📖';

  @override
  String get romanticMessage20 => 'Your hearts speak a language only you understand 💬';

  @override
  String get mysteriousMessage1 => 'Heart\'s secrets are about to be revealed... 🔮';

  @override
  String get mysteriousMessage2 => 'Someone thinks of you more than you imagine 👁️';

  @override
  String get mysteriousMessage3 => 'Universe\'s signals are trying to tell you something 🌠';

  @override
  String get mysteriousMessage4 => 'Hidden feelings will soon come to light 🌅';

  @override
  String get mysteriousMessage5 => 'Love\'s mystery is about to unfold 🎭';

  @override
  String get mysteriousMessage6 => 'Invisible forces are working in your favor 👻';

  @override
  String get mysteriousMessage7 => 'Heart\'s whispers are reaching you 🍃';

  @override
  String get mysteriousMessage8 => 'There\'s a love story waiting to be told 📚';

  @override
  String get mysteriousMessage9 => 'Destiny\'s threads are intertwining 🕸️';

  @override
  String get mysteriousMessage10 => 'Something magical is about to happen in love 🎪';

  @override
  String get mysteriousMessage11 => 'Love\'s tarot cards are shuffling 🃏';

  @override
  String get mysteriousMessage12 => 'A romantic secret is floating in the air 💨';

  @override
  String get mysteriousMessage13 => 'The full moon brings heart revelations 🌕';

  @override
  String get mysteriousMessage14 => 'There are glances that say more than a thousand words 👀';

  @override
  String get mysteriousMessage15 => 'A loving heart\'s echo resonates nearby 🔊';

  @override
  String get mysteriousMessage16 => 'Something beautiful is brewing in silence 🤫';

  @override
  String get mysteriousMessage17 => 'Stars whisper love secrets 🌟';

  @override
  String get mysteriousMessage18 => 'A heart message is waiting to be sent 💌';

  @override
  String get mysteriousMessage19 => 'Love\'s magic is creating invisible connections ✨';

  @override
  String get mysteriousMessage20 => 'There\'s a romantic surprise on the horizon 🎁';

  @override
  String get funMessage1 => 'Houston, we have a connection! 🚀';

  @override
  String get funMessage2 => 'Your crush-o-meter is through the roof 📈';

  @override
  String get funMessage3 => 'Heart alert! Danger of falling in love 🚨';

  @override
  String get funMessage4 => 'The love detector is ringing loudly 📢';

  @override
  String get funMessage5 => 'Bingo! You\'ve found a perfect match 🎯';

  @override
  String get funMessage6 => 'Your compatibility level is off the charts! 📊';

  @override
  String get funMessage7 => 'Ding ding ding! We have a love winner 🛎️';

  @override
  String get funMessage8 => 'Love\'s GPS is guiding you to something special 🗺️';

  @override
  String get funMessage9 => 'Emotional jackpot! You\'ve hit the bullseye 🎰';

  @override
  String get funMessage10 => 'Your heart just made a perfect match 💕';

  @override
  String get funMessage11 => 'Eureka! Love\'s formula has been deciphered 🧪';

  @override
  String get funMessage12 => 'The romance thermometer is about to explode 🌡️';

  @override
  String get funMessage13 => 'Breaking news! Chemistry detected between you 📺';

  @override
  String get funMessage14 => 'Your love radar is picking up strong signals 📡';

  @override
  String get funMessage15 => 'Plot twist! Your crush might be thinking of you 🎬';

  @override
  String get funMessage16 => 'Love\'s algorithm says you\'re compatible 💻';

  @override
  String get funMessage17 => 'Spoiler alert! There\'s romance in your future 📱';

  @override
  String get funMessage18 => 'Your love app just sent a notification 📲';

  @override
  String get funMessage19 => 'Achievement unlocked! You\'ve found your match 🏆';

  @override
  String get funMessage20 => 'Heart\'s bluetooth has connected successfully 📶';

  @override
  String get lowCompatibilityMessage1 => 'Sometimes differences create the perfect spark ⚡';

  @override
  String get lowCompatibilityMessage2 => 'True love overcomes any percentage 💪';

  @override
  String get lowCompatibilityMessage3 => 'Opposites attract and create magic 🧲';

  @override
  String get lowCompatibilityMessage4 => 'Not all great loves start with 100% 📈';

  @override
  String get lowCompatibilityMessage5 => 'Give time to time, love grows step by step 🌱';

  @override
  String get lowCompatibilityMessage6 => 'Compatibility is built day by day 🏗️';

  @override
  String get lowCompatibilityMessage7 => 'Maybe you need to get to know each other better 🤔';

  @override
  String get lowCompatibilityMessage8 => 'Real love doesn\'t always follow statistics 📊';

  @override
  String get lowCompatibilityMessage9 => 'There\'s room for something beautiful to grow 🌻';

  @override
  String get lowCompatibilityMessage10 => 'The best romances start as friendship 👫';

  @override
  String get changeAppTheme => 'Change the app theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get youArePremium => 'You are Premium!';

  @override
  String get enjoyAllFeatures => 'Enjoy all features without limits';

  @override
  String purchaseError(String error) {
    return 'Purchase error: $error';
  }

  @override
  String get storeNotAvailable => 'The store is not available right now. Check your internet connection and try again.';

  @override
  String get productNotConfigured => 'This product is not available right now. Please try again later.';

  @override
  String get purchaseAlreadyInProgress => 'A purchase is already in progress. Please wait a moment.';

  @override
  String get purchaseCouldNotStart => 'Could not start the purchase. Please try again.';

  @override
  String get purchaseUnexpectedError => 'An unexpected error occurred. Please try again later.';

  @override
  String get purchaseStartedCompleteInStore => 'Purchase started. Complete the payment in the store window.';

  @override
  String get getFullAccess => 'Get full access to all special features';

  @override
  String get specialOffer => 'Special Offer';

  @override
  String get cancelAnytime => 'Cancel anytime';

  @override
  String get support => 'Support';

  @override
  String get settingsHistorySubtitle => 'View all your previous scans';

  @override
  String get changeThemeSubtitle => 'Change the app theme';

  @override
  String get backgroundAnimationTitle => 'Background Animation';

  @override
  String get backgroundAnimationSubtitle => 'Show floating flowers and hearts';

  @override
  String get helpAndQuestions => 'Help & Questions';

  @override
  String get getHelpOnApp => 'Get help on how to use the app';

  @override
  String get helpDialogTitle => '💕 Help';

  @override
  String get helpDialogContent => 'Crush Scanner is a fun app that estimates compatibility based on names.\\n\\n- Enter your name and your crush\'s name\\n- Tap \\\"Scan Love\\\"\\n- Check your compatibility result\\n- Share your favorite result\\n\\nThis app is for entertainment purposes.';

  @override
  String get understood => 'Got it';

  @override
  String get aboutDialogTitle => '💘 About';

  @override
  String get aboutDialogContent => 'Crush Scanner v1.0.0\n\nA fun app to discover love compatibility.\n\nMade with love by Perlaza Studio\n\n© 2026 Crush Scanner';

  @override
  String get streakTitle => 'Daily Streak';

  @override
  String daysStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: '0 days',
    );
    return '$_temp0';
  }

  @override
  String get streakMaintain => 'Don\'t break your streak!';

  @override
  String get streakAtRisk => 'Streak at risk! Scan now to maintain it 🔥';

  @override
  String get firstScanStreak => '🎉 Welcome! Your love journey begins now!';

  @override
  String get streakBroken => '💔 Streak broken, but you\'re back! New streak started';

  @override
  String newStreakRecord(int days) {
    return '🏆 NEW RECORD! $days days streak! You\'re unstoppable!';
  }

  @override
  String streakContinues(int days) {
    return '🔥 Streak continues! $days days of love scanning!';
  }

  @override
  String get loveAnalytics => '📊 Love Analytics';

  @override
  String get premiumRequired => '✨ Premium Required';

  @override
  String get premiumRequiredMessage => 'This theme is available only for Premium users. Unlock all themes and more features!';

  @override
  String get analyticsPremium => '🔒 Analytics Premium';

  @override
  String get unlockDeepInsights => 'Unlock deep insights about your love life with advanced analytics, predictions and compatibility patterns.';

  @override
  String get upgradeToPremiumAnalytics => 'Upgrade to Premium';

  @override
  String get analyzingLoveLife => 'Analyzing your love life...';

  @override
  String get errorLoadingAnalytics => 'Error loading analytics';

  @override
  String get unknownErrorAnalytics => 'Unknown error';

  @override
  String get retry => 'Retry';

  @override
  String get statisticsTab => 'Statistics';

  @override
  String get insightsTab => 'Insights';

  @override
  String get predictionsTab => 'Predictions';

  @override
  String get totalScansAnalytics => 'Total Scans';

  @override
  String get averageAnalytics => 'Average';

  @override
  String get bestMatch => 'Best Match';

  @override
  String get celebritiesAnalytics => 'Celebrities';

  @override
  String get compatibilityTrend => '📈 Compatibility Trend (30 days)';

  @override
  String get notEnoughDataTrends => 'Not enough data to show trends';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get yourBestMatches => '🏆 Your Best Matches';

  @override
  String get celebrity => 'Celebrity';

  @override
  String get personal => 'Personal';

  @override
  String get advancedAnalytics => 'Advanced Analytics';

  @override
  String get analyticsDescription => 'Compatibility charts and statistics';

  @override
  String get cloudBackup => 'Cloud Backup';

  @override
  String get cloudBackupDescription => 'Your data safe and synchronized';

  @override
  String get perMonth => '/month';

  @override
  String get perYear => '/year';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get bestValue => 'Best Value';

  @override
  String get choosePlan => 'Choose your plan';

  @override
  String get premiumPlanTitle => 'Premium';

  @override
  String get premiumPlusPlanTitle => 'Premium Plus';

  @override
  String get premiumPlusDescription => 'Everything in Premium + Unlimited 16-player tournaments, advanced analytics and exclusive Plus themes';

  @override
  String get subscribeTo => 'Subscribe';

  @override
  String get selectedPlan => 'Selected plan';

  @override
  String get monthlyPrice => '\$2.99';

  @override
  String get unlockFullPotential => 'Unlock the full potential of love!';

  @override
  String get purchasesRestoredSuccessfully => 'Purchases restored successfully';

  @override
  String get defaultPrice => '\$2.99/month';

  @override
  String get themesTitle => '🎨 Premium Themes';

  @override
  String get customizeExperience => 'Customize your experience';

  @override
  String get currentTheme => 'Current Theme';

  @override
  String get active => 'ACTIVE';

  @override
  String themeApplied(String themeName) {
    return 'Theme $themeName applied';
  }

  @override
  String get classicThemeName => '💘 Classic';

  @override
  String get classicThemeDescription => 'The original love theme';

  @override
  String get sunsetThemeName => '🌅 Sunset';

  @override
  String get sunsetThemeDescription => 'Warm golden and orange tones';

  @override
  String get oceanThemeName => '🌊 Ocean';

  @override
  String get oceanThemeDescription => 'Deep marine blues';

  @override
  String get forestThemeName => '🌲 Forest';

  @override
  String get forestThemeDescription => 'Natural and fresh greens';

  @override
  String get lavenderThemeName => '💜 Lavender';

  @override
  String get lavenderThemeDescription => 'Elegant purples and violets';

  @override
  String get cosmicThemeName => '🌌 Cosmic';

  @override
  String get cosmicThemeDescription => 'Mysterious deep space';

  @override
  String get cherryThemeName => '🌸 Cherry';

  @override
  String get cherryThemeDescription => 'Elegant Japanese sakura pink';

  @override
  String get goldenThemeName => '✨ Golden';

  @override
  String get goldenThemeDescription => 'Luxury and golden elegance';

  @override
  String scansToday(int remaining, int total) {
    return 'Today\'s scans: $remaining/$total';
  }

  @override
  String scansRemaining(int count) {
    return '$count free scans remaining';
  }

  @override
  String get premiumBenefits => '🚀 Unlimited scans • 🚫 No ads • ⭐ Exclusive content';

  @override
  String get trialPeriod => '🎉 Trial Period!';

  @override
  String unlimitedScansRemaining(int days) {
    return 'UNLIMITED scans for $days more days';
  }

  @override
  String get premiumAnalytics => 'Premium Analytics';

  @override
  String get analyzeCompatibilityPatterns => 'Analyze your compatibility patterns';

  @override
  String get premiumThemes => 'Premium Themes';

  @override
  String get customizeWithThemes => 'Customize with 8 unique themes';

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionAudio => 'Audio';

  @override
  String get sectionData => 'Data';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearAllDataSubtitle => 'Delete statistics, history and streaks';

  @override
  String get aboutSubtitle => 'Information about the application';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacySubtitle => 'View our privacy policy';

  @override
  String get privacyDialogTitle => '🔒 Privacy Policy';

  @override
  String get privacyDialogContent => 'Your privacy is important to us.\n\n• Names are stored only locally\n• We don\'t share personal information\n• Results are generated randomly\n• You can delete your history anytime\n\nThis app is for entertainment only.';

  @override
  String get viewFullPolicy => 'View full policy';

  @override
  String get confirmClearDataTitle => 'Clear All Data?';

  @override
  String get confirmClearDataContent => 'Are you sure you want to delete all your statistics, history, and streaks? This action cannot be undone.';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get dataDeletedSuccess => 'All data has been successfully deleted';

  @override
  String errorDeletingData(Object error) {
    return 'Error deleting data: $error';
  }

  @override
  String get appVersionFooter => 'Crush Scanner v1.0.0\nMade with 💕 for love';

  @override
  String get welcomeNewUserTitle => '🎉 Welcome New User!';

  @override
  String get enjoyUnlimitedTrialScans => 'Enjoy unlimited scans during your trial!';

  @override
  String get unlimitedScansActive => 'Unlimited Scans Active';

  @override
  String trialDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days remaining in trial',
      one: '1 day remaining in trial',
    );
    return '$_temp0';
  }

  @override
  String get trialEndingToday => 'Trial ending today';

  @override
  String get upgradeToPremiumPromo => 'Upgrade to Premium';

  @override
  String get watchAdToUnlockInsights => 'Watch ad to unlock';

  @override
  String get watchAdToUnlockPredictions => 'Watch ad to unlock';

  @override
  String get insightsLockedDescription => 'Discover unique patterns about your love life. Watch a short ad or go Premium for unlimited access.';

  @override
  String get predictionsLockedDescription => 'Get personalized predictions about your love future. Watch a short ad or go Premium for unlimited access.';

  @override
  String get adNotAvailable => 'Ad not available right now';

  @override
  String get orGetPremium => 'or go Premium';

  @override
  String get insightsUnlocked => '✨ Insights unlocked';

  @override
  String get predictionsUnlocked => '✨ Predictions unlocked';

  @override
  String coinsClaimedMessage(int count) {
    return '+$count coins claimed.';
  }

  @override
  String scanPackBoughtMessage(int scans, int cost) {
    return 'You got +$scans scans for $cost coins.';
  }

  @override
  String notEnoughCoinsCurrentPackMessage(int cost) {
    return 'Not enough coins. Current pack costs $cost.';
  }

  @override
  String notEnoughCoinsThisPackMessage(int cost) {
    return 'Not enough coins. This pack costs $cost.';
  }

  @override
  String get dailyPackLimitReachedMessage => 'Daily pack limit reached. Come back tomorrow.';

  @override
  String get dailyPackLimitReachedTryTomorrowMessage => 'Daily pack limit reached. Try again tomorrow.';

  @override
  String get premiumUnlimitedScansMessage => 'Premium already has unlimited scans.';

  @override
  String coinsEarnedMessage(int count) {
    return '+$count coins earned.';
  }

  @override
  String coinsWonMessage(int count) {
    return '+$count coins earned';
  }

  @override
  String get noAdAvailableNowMessage => 'No ad available now.';

  @override
  String get loadingRetentionRewards => 'Loading retention rewards...';

  @override
  String get retentionPanelUnavailable => 'Retention panel unavailable. Tap to retry.';

  @override
  String get dailyRetentionRewardsTitle => 'Daily retention rewards';

  @override
  String coinsLabel(int count) {
    return 'Coins: $count';
  }

  @override
  String streakDaysLabel(int days) {
    return 'Streak: ${days}d';
  }

  @override
  String get premiumScannerEconomyNotice => 'Premium active: unlimited scans, no ads, faster coin progression. Use coins for Tournament perks.';

  @override
  String scanPackButtonLabel(int scans, int cost, int remaining) {
    return '+$scans scans (${cost}c) - $remaining left';
  }

  @override
  String get scanPackExhaustedToday => 'Scan packs exhausted today';

  @override
  String adCoinsButtonLabel(int count) {
    return 'Ad +${count}c';
  }

  @override
  String get dailyMissionsTitle => 'Daily missions';

  @override
  String get claimedLabel => 'Claimed';

  @override
  String get retentionRewardsTitle => 'Retention rewards';

  @override
  String get youGotPlusTwoScansMessage => 'You got +2 scans.';

  @override
  String get useCoinsLabel => 'Use coins';

  @override
  String get plusTwoScansWithCoins => '+2 scans with coins';

  @override
  String get useCoinsPackPlusTwoScans => 'Use coins (pack +2 scans)';

  @override
  String get watchAdPlusTwoScans => 'Watch ad (+2 scans)';

  @override
  String get tournamentFunnelTodayTitle => '🎯 Tournament Funnel (Today)';

  @override
  String get funnelStartsLabel => 'Starts';

  @override
  String get funnelCompletionsLabel => 'Completions';

  @override
  String get funnelCompletionRateLabel => 'Completion Rate';

  @override
  String get funnelTicketAdsLabel => 'Ticket Ads';

  @override
  String get funnelReviveAdsLabel => 'Revive Ads';

  @override
  String get funnelReviveCoinsLabel => 'Revive Coins';

  @override
  String get funnelShopBuysLabel => 'Shop Buys';

  @override
  String get loveIntelligenceStudio => 'Love Intelligence Studio';

  @override
  String get tournament16UnlimitedTitle => 'Unlimited 16-Player Tournaments';

  @override
  String get tournament16UnlimitedDescription => 'Play epic 16-player tournaments every day with no limits';

  @override
  String get tournamentTitle => '🏆 Love Tournament';

  @override
  String get tournamentWelcomeSubtitle => 'Pit your crushes against each other in an epic tournament!';

  @override
  String get tournamentDescription => 'Enter your crushes\' names and discover who is your ultimate match in an elimination tournament';

  @override
  String get tournamentYourName => 'Your Name';

  @override
  String get tournamentYourNameHint => 'Enter your name...';

  @override
  String get tournamentSelectFormat => 'Tournament Format';

  @override
  String get tournamentParticipants => 'Participants';

  @override
  String get tournamentCrush => 'Crush';

  @override
  String get tournamentAddCelebrity => '⭐ Celebrity';

  @override
  String get tournamentFillAll => '✨ Fill';

  @override
  String get tournamentStart => 'Start Tournament!';

  @override
  String get tournamentEnterYourName => 'Please enter your name';

  @override
  String get tournamentFillAllNames => 'You must fill in all names';

  @override
  String get tournamentNoDuplicates => 'You can\'t have duplicate names';

  @override
  String get tournament16PremiumOnly => 'The 16-participant format is exclusive to Premium users. Upgrade to unlock epic tournaments!';

  @override
  String get tournamentBracket => 'Tournament Bracket';

  @override
  String get tournamentMatchesPlayed => 'Matches played';

  @override
  String get tournamentNextMatch => 'Next Match!';

  @override
  String get tournamentExitTitle => 'Leave Tournament?';

  @override
  String get tournamentExitMessage => 'Are you sure you want to leave? Your progress will be lost.';

  @override
  String get tournamentExit => 'Leave';

  @override
  String get tournamentReviveTitle => '💫 Revive Crush';

  @override
  String get tournamentReviveDescription => 'Watch an ad to give a second chance to an eliminated crush';

  @override
  String get tournamentRevived => 'is back in the tournament!';

  @override
  String get tournamentComplete => 'Tournament Complete!';

  @override
  String get tournamentResultSubtitle => 'Here are the results of your love tournament';

  @override
  String get tournamentShare => 'Share Results';

  @override
  String get tournamentPlayAgain => 'Play Again';

  @override
  String get tournamentSummary => 'Tournament Summary';

  @override
  String get tournamentTotalMatches => 'Total matches';

  @override
  String get tournamentParticipantsCount => 'Participants';

  @override
  String get tournamentRoundsPlayed => 'Rounds played';

  @override
  String get tournamentFinalMatch => '🏆 Final Match';

  @override
  String get duelTitle => '⚔️ Love Duel';

  @override
  String get duelHeadline => 'Who wins your heart?';

  @override
  String get duelDescription => 'Pit two crushes against each other and discover who\'s more compatible with you across 4 love dimensions.';

  @override
  String get duelHowToPlayTitle => 'How does it work?';

  @override
  String get duelStep1 => 'Enter your name and the names of two special people';

  @override
  String get duelStep2 => 'Our algorithm analyzes compatibility across 4 dimensions';

  @override
  String get duelStep3 => 'Watch the epic battle unfold round by round!';

  @override
  String get duelDimExplainTitle => 'The 4 Dimensions of Love';

  @override
  String get duelDimEmotionalDesc => 'Emotional connection and sentimental depth';

  @override
  String get duelDimPassionDesc => 'Chemistry, attraction and romantic energy';

  @override
  String get duelDimIntellectualDesc => 'Mental affinity, humor and conversation';

  @override
  String get duelDimDestinyDesc => 'Cosmic compatibility and fate alignment';

  @override
  String get duelTiebreakerNote => 'If it\'s a 2-2 tie, a sudden-death tiebreaker round activates!';

  @override
  String get duelFunFact => 'Fun fact';

  @override
  String get duelFunFact1 => '68% of duels end with a clear winner in the first 3 rounds';

  @override
  String get duelFunFact2 => 'The Passion dimension is the most unpredictable of all';

  @override
  String get duelFunFact3 => 'Only 12% of duels reach the final tiebreaker';

  @override
  String get duelFunFact4 => 'Emotional connection is the most important dimension for long relationships';

  @override
  String get duelFunFact5 => 'Names with more than 6 letters tend to have higher intellectual compatibility';

  @override
  String get duelYourName => 'Your name';

  @override
  String get duelCrushA => 'Crush A\'s name';

  @override
  String get duelCrushB => 'Crush B\'s name';

  @override
  String get duelStart => 'Start Duel! ⚔️';

  @override
  String get duelLoading => 'Preparing battle...';

  @override
  String get duelSameNameError => 'Crush names cannot be the same.';

  @override
  String get duelGetReady => 'Get Ready!';

  @override
  String get duelRound => 'Round';

  @override
  String get duelDimEmotional => 'Emotional ❤️';

  @override
  String get duelDimPassion => 'Passion 🔥';

  @override
  String get duelDimIntellectual => 'Intellectual 🧠';

  @override
  String get duelDimDestiny => 'Destiny ✨';

  @override
  String get duelShare => 'Share';

  @override
  String get duelPlayAgain => 'Play Again';

  @override
  String get duelHome => 'Home';

  @override
  String get duelWelcomeSubtitle => 'Pit your crushes in an epic duel';
}
