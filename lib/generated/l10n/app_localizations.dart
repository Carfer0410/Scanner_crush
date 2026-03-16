import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// Explanation for the difference between compatibility percentage and confidence in prediction cards.
  ///
  /// In en, this message translates to:
  /// **'The percentage in the phrase is your real average compatibility. The number in the corner is the confidence of the prediction.'**
  String get predictionInfoExplanation;

  /// No description provided for @insightMasterLove.
  ///
  /// In en, this message translates to:
  /// **'Master of Love'**
  String get insightMasterLove;

  /// No description provided for @insightMasterLoveDesc.
  ///
  /// In en, this message translates to:
  /// **'Your average compatibility is exceptional ({percent}%). You have a natural gift for love!'**
  String insightMasterLoveDesc(Object percent);

  /// No description provided for @insightGoodRadar.
  ///
  /// In en, this message translates to:
  /// **'Good Love Radar'**
  String get insightGoodRadar;

  /// No description provided for @insightGoodRadarDesc.
  ///
  /// In en, this message translates to:
  /// **'Your average compatibility is solid ({percent}%). You trust your instincts.'**
  String insightGoodRadarDesc(Object percent);

  /// No description provided for @insightExplorerLove.
  ///
  /// In en, this message translates to:
  /// **'Love Explorer'**
  String get insightExplorerLove;

  /// No description provided for @insightExplorerLoveDesc.
  ///
  /// In en, this message translates to:
  /// **'You are exploring different types of connections. Every scan brings you closer to your perfect match!'**
  String get insightExplorerLoveDesc;

  /// No description provided for @insightCelebrityCrusher.
  ///
  /// In en, this message translates to:
  /// **'Celebrity Crusher'**
  String get insightCelebrityCrusher;

  /// No description provided for @insightCelebrityCrusherDesc.
  ///
  /// In en, this message translates to:
  /// **'You prefer celebrities ({percent}% of your scans). You like high standards!'**
  String insightCelebrityCrusherDesc(Object percent);

  /// No description provided for @insightTrueRomantic.
  ///
  /// In en, this message translates to:
  /// **'True Romantic'**
  String get insightTrueRomantic;

  /// No description provided for @insightTrueRomanticDesc.
  ///
  /// In en, this message translates to:
  /// **'You prefer real connections ({percent}% of your scans). True love calls you.'**
  String insightTrueRomanticDesc(Object percent);

  /// No description provided for @insightExpert.
  ///
  /// In en, this message translates to:
  /// **'Compatibility Expert'**
  String get insightExpert;

  /// No description provided for @insightExpertDesc.
  ///
  /// In en, this message translates to:
  /// **'With {scans} scans, you are an expert. Your experience is invaluable.'**
  String insightExpertDesc(Object scans);

  /// No description provided for @insightDedicatedUser.
  ///
  /// In en, this message translates to:
  /// **'Dedicated User'**
  String get insightDedicatedUser;

  /// No description provided for @insightDedicatedUserDesc.
  ///
  /// In en, this message translates to:
  /// **'You already have {scans} scans. Your dedication to love is admirable!'**
  String insightDedicatedUserDesc(Object scans);

  /// No description provided for @insightCommittedExplorer.
  ///
  /// In en, this message translates to:
  /// **'Committed Explorer'**
  String get insightCommittedExplorer;

  /// No description provided for @insightCommittedExplorerDesc.
  ///
  /// In en, this message translates to:
  /// **'With {scans} scans, you are building a solid profile. Keep it up!'**
  String insightCommittedExplorerDesc(Object scans);

  /// No description provided for @insightNewAdventurer.
  ///
  /// In en, this message translates to:
  /// **'New Adventurer'**
  String get insightNewAdventurer;

  /// No description provided for @insightNewAdventurerDesc.
  ///
  /// In en, this message translates to:
  /// **'You have started your journey of love discovery. Every scan reveals something new!'**
  String get insightNewAdventurerDesc;

  /// No description provided for @predictionLoveRising.
  ///
  /// In en, this message translates to:
  /// **'Love Rising'**
  String get predictionLoveRising;

  /// No description provided for @predictionLoveRisingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your compatibility has improved lately. The coming weeks will be promising for love.'**
  String get predictionLoveRisingDesc;

  /// No description provided for @predictionTimeReflection.
  ///
  /// In en, this message translates to:
  /// **'Time for Reflection'**
  String get predictionTimeReflection;

  /// No description provided for @predictionTimeReflectionDesc.
  ///
  /// In en, this message translates to:
  /// **'It\'s a good time to reflect on what you seek in love. Clarity will bring better connections.'**
  String get predictionTimeReflectionDesc;

  /// No description provided for @predictionStableLove.
  ///
  /// In en, this message translates to:
  /// **'Stable Love'**
  String get predictionStableLove;

  /// No description provided for @predictionStableLoveDesc.
  ///
  /// In en, this message translates to:
  /// **'Your compatibility remains consistent. It\'s a good time to consolidate connections.'**
  String get predictionStableLoveDesc;

  /// No description provided for @predictionDiscoveringPattern.
  ///
  /// In en, this message translates to:
  /// **'Discovering Your Pattern'**
  String get predictionDiscoveringPattern;

  /// No description provided for @predictionDiscoveringPatternDesc.
  ///
  /// In en, this message translates to:
  /// **'You are building your love profile. Each scan helps us better understand your preferences.'**
  String get predictionDiscoveringPatternDesc;

  /// No description provided for @predictionJourneyStart.
  ///
  /// In en, this message translates to:
  /// **'Start of Your Journey'**
  String get predictionJourneyStart;

  /// No description provided for @predictionJourneyStartDesc.
  ///
  /// In en, this message translates to:
  /// **'You have started your love exploration. Keep scanning to discover fascinating patterns!'**
  String get predictionJourneyStartDesc;

  /// No description provided for @predictionPerfectMatchNear.
  ///
  /// In en, this message translates to:
  /// **'Perfect Match Near'**
  String get predictionPerfectMatchNear;

  /// No description provided for @predictionPerfectMatchNearDesc.
  ///
  /// In en, this message translates to:
  /// **'Your high average compatibility ({percent}%) suggests your perfect match is very close. Keep your eyes open.'**
  String predictionPerfectMatchNearDesc(Object percent);

  /// No description provided for @predictionGoodLovePath.
  ///
  /// In en, this message translates to:
  /// **'Good Love Path'**
  String get predictionGoodLovePath;

  /// No description provided for @predictionGoodLovePathDesc.
  ///
  /// In en, this message translates to:
  /// **'Your average compatibility ({percent}%) shows you have good judgment. Trust your instincts.'**
  String predictionGoodLovePathDesc(Object percent);

  /// No description provided for @predictionLoveAwaits.
  ///
  /// In en, this message translates to:
  /// **'Love Awaits You'**
  String get predictionLoveAwaits;

  /// No description provided for @predictionLoveAwaitsDesc.
  ///
  /// In en, this message translates to:
  /// **'Each scan brings you closer to understanding love. Keep exploring and discovering your path!'**
  String get predictionLoveAwaitsDesc;

  /// No description provided for @predictionTimeframeNext2Weeks.
  ///
  /// In en, this message translates to:
  /// **'Next 2 weeks'**
  String get predictionTimeframeNext2Weeks;

  /// No description provided for @predictionTimeframeNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get predictionTimeframeNextMonth;

  /// No description provided for @predictionTimeframeNext3Weeks.
  ///
  /// In en, this message translates to:
  /// **'Next 3 weeks'**
  String get predictionTimeframeNext3Weeks;

  /// No description provided for @predictionTimeframeNextWeeks.
  ///
  /// In en, this message translates to:
  /// **'Next weeks'**
  String get predictionTimeframeNextWeeks;

  /// No description provided for @predictionTimeframeAsYouExplore.
  ///
  /// In en, this message translates to:
  /// **'As you explore'**
  String get predictionTimeframeAsYouExplore;

  /// No description provided for @predictionTimeframeNext3Months.
  ///
  /// In en, this message translates to:
  /// **'Next 3 months'**
  String get predictionTimeframeNext3Months;

  /// No description provided for @predictionTimeframeNext2Months.
  ///
  /// In en, this message translates to:
  /// **'Next 2 months'**
  String get predictionTimeframeNext2Months;

  /// No description provided for @predictionTimeframeLoveJourney.
  ///
  /// In en, this message translates to:
  /// **'On your love journey'**
  String get predictionTimeframeLoveJourney;

  /// Error generating result message
  ///
  /// In en, this message translates to:
  /// **'Error generating result. Please try again.'**
  String get errorGeneratingResult;

  /// Celebrity crush title
  ///
  /// In en, this message translates to:
  /// **'Celebrity Crush'**
  String get celebrityCrush;

  /// Greeting with user name
  ///
  /// In en, this message translates to:
  /// **'Hello {userName}!'**
  String helloCelebrity(String userName);

  /// Choose celebrity description
  ///
  /// In en, this message translates to:
  /// **'Choose your celebrity crush and discover your compatibility'**
  String get chooseCelebrityDescription;

  /// Search celebrity placeholder
  ///
  /// In en, this message translates to:
  /// **'Search celebrity...'**
  String get searchCelebrity;

  /// No description provided for @noInsightsYet.
  ///
  /// In en, this message translates to:
  /// **'No insights yet'**
  String get noInsightsYet;

  /// No description provided for @scanMoreForInsights.
  ///
  /// In en, this message translates to:
  /// **'Scan more to get personalized insights'**
  String get scanMoreForInsights;

  /// No description provided for @noPredictionsYet.
  ///
  /// In en, this message translates to:
  /// **'No predictions available'**
  String get noPredictionsYet;

  /// No description provided for @scanMoreForPredictions.
  ///
  /// In en, this message translates to:
  /// **'Scan more to generate predictions about your love life'**
  String get scanMoreForPredictions;

  /// No description provided for @bannerLoaded.
  ///
  /// In en, this message translates to:
  /// **'Banner Ad loaded successfully'**
  String get bannerLoaded;

  /// No description provided for @bannerLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading Banner Ad:'**
  String get bannerLoadError;

  /// No description provided for @testingBannerAd.
  ///
  /// In en, this message translates to:
  /// **'🎯 Testing Banner Ad...'**
  String get testingBannerAd;

  /// No description provided for @bannerAdWorking.
  ///
  /// In en, this message translates to:
  /// **'✅ Banner Ad is working'**
  String get bannerAdWorking;

  /// No description provided for @bannerAdNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'❌ Banner Ad is not loaded'**
  String get bannerAdNotLoaded;

  /// No description provided for @testingInterstitialAd.
  ///
  /// In en, this message translates to:
  /// **'🎯 Testing Interstitial Ad...'**
  String get testingInterstitialAd;

  /// No description provided for @interstitialAdAvailable.
  ///
  /// In en, this message translates to:
  /// **'✅ Interstitial Ad available'**
  String get interstitialAdAvailable;

  /// No description provided for @interstitialShown.
  ///
  /// In en, this message translates to:
  /// **'✅ Interstitial shown'**
  String get interstitialShown;

  /// No description provided for @interstitialShowError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error showing Interstitial'**
  String get interstitialShowError;

  /// No description provided for @interstitialNotReady.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Interstitial Ad is not ready'**
  String get interstitialNotReady;

  /// No description provided for @testingRewardedAd.
  ///
  /// In en, this message translates to:
  /// **'🎯 Testing Rewarded Ad...'**
  String get testingRewardedAd;

  /// No description provided for @rewardedAdShown.
  ///
  /// In en, this message translates to:
  /// **'✅ Rewarded Ad shown and reward granted'**
  String get rewardedAdShown;

  /// No description provided for @rewardedAdError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error with Rewarded Ad'**
  String get rewardedAdError;

  /// No description provided for @adsTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Ads Test'**
  String get adsTestTitle;

  /// No description provided for @systemStatus.
  ///
  /// In en, this message translates to:
  /// **'System Status'**
  String get systemStatus;

  /// No description provided for @liveBannerAd.
  ///
  /// In en, this message translates to:
  /// **'📱 Live Banner Ad:'**
  String get liveBannerAd;

  /// No description provided for @testBanner.
  ///
  /// In en, this message translates to:
  /// **'Test Banner'**
  String get testBanner;

  /// No description provided for @testInterstitial.
  ///
  /// In en, this message translates to:
  /// **'Test Interstitial'**
  String get testInterstitial;

  /// No description provided for @testRewardedAd.
  ///
  /// In en, this message translates to:
  /// **'Test Rewarded Ad'**
  String get testRewardedAd;

  /// No description provided for @testResults.
  ///
  /// In en, this message translates to:
  /// **'Test Results'**
  String get testResults;

  /// No description provided for @pressButtonsToTestAds.
  ///
  /// In en, this message translates to:
  /// **'Press the buttons to test the ads'**
  String get pressButtonsToTestAds;

  /// Card text describing premium features for the premium universe.
  ///
  /// In en, this message translates to:
  /// **'Unlock the premium universe: daily personalized horoscopes, love advice, advanced compatibility analysis, no ads.'**
  String get premiumUniverseCard;

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Crush Scanner 💘'**
  String get appTitle;

  /// Subtitle shown on splash screen
  ///
  /// In en, this message translates to:
  /// **'Discover your love destiny'**
  String get splashSubtitle;

  /// Slogan shown on splash screen
  ///
  /// In en, this message translates to:
  /// **'Love is just the beginning! 💖'**
  String get splashSlogan;

  /// Welcome screen main title
  ///
  /// In en, this message translates to:
  /// **'Discover Your Secret Admirer'**
  String get welcomeTitle;

  /// Welcome screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Find out who has a crush on you with our advanced algorithm 💕'**
  String get welcomeSubtitle;

  /// Button to start scanning
  ///
  /// In en, this message translates to:
  /// **'Start Scan'**
  String get startScan;

  /// Celebrity scan button
  ///
  /// In en, this message translates to:
  /// **'Celebrity Scan'**
  String get celebrityScan;

  /// Daily love button
  ///
  /// In en, this message translates to:
  /// **'Daily Love'**
  String get dailyLove;

  /// Settings button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// History title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Premium title
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// Your name field placeholder
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// Your name input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// Crush name input label
  ///
  /// In en, this message translates to:
  /// **'Crush\'s Name'**
  String get crushName;

  /// Crush name input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your crush\'s name'**
  String get enterCrushName;

  /// Scan now button
  ///
  /// In en, this message translates to:
  /// **'Scan Now'**
  String get scanNow;

  /// Scanning status
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// Analyzing status
  ///
  /// In en, this message translates to:
  /// **'Analyzing compatibility...'**
  String get analyzing;

  /// Calculating love status
  ///
  /// In en, this message translates to:
  /// **'Calculating love percentage...'**
  String get calculatingLove;

  /// Scan complete message
  ///
  /// In en, this message translates to:
  /// **'Scan Complete!'**
  String get scanComplete;

  /// Love percentage label
  ///
  /// In en, this message translates to:
  /// **'Love Percentage'**
  String get lovePercentage;

  /// Compatibility level label
  ///
  /// In en, this message translates to:
  /// **'Compatibility Level'**
  String get compatibilityLevel;

  /// Share result button
  ///
  /// In en, this message translates to:
  /// **'Share Result'**
  String get shareResult;

  /// Scan again button
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanAgain;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Sound effects setting
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// Background music setting
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get backgroundMusic;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Volume setting
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No history message
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get noHistory;

  /// Start first scan message
  ///
  /// In en, this message translates to:
  /// **'Start your first scan to see results here'**
  String get startFirstScan;

  /// Scan history title
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scanHistory;

  /// Delete history button
  ///
  /// In en, this message translates to:
  /// **'Delete History'**
  String get deleteHistory;

  /// Confirm delete title
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// Delete history confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all scan history? This action cannot be undone.'**
  String get deleteHistoryMessage;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// History deleted message
  ///
  /// In en, this message translates to:
  /// **'History deleted successfully'**
  String get historyDeleted;

  /// Today's love title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Love'**
  String get todaysLove;

  /// Daily love reading subtitle
  ///
  /// In en, this message translates to:
  /// **'Your Daily Love Reading'**
  String get yourDailyLoveReading;

  /// Love advice section
  ///
  /// In en, this message translates to:
  /// **'Love Advice'**
  String get loveAdvice;

  /// Lucky number label
  ///
  /// In en, this message translates to:
  /// **'Lucky Number'**
  String get luckyNumber;

  /// Love compatibility label
  ///
  /// In en, this message translates to:
  /// **'Love Compatibility'**
  String get loveCompatibility;

  /// Perfect match message
  ///
  /// In en, this message translates to:
  /// **'Perfect Match! 💖'**
  String get perfectMatch;

  /// Excellent match message
  ///
  /// In en, this message translates to:
  /// **'Excellent Match! 💕'**
  String get excellentMatch;

  /// Good match message
  ///
  /// In en, this message translates to:
  /// **'Good Match! 💓'**
  String get goodMatch;

  /// Fair match message
  ///
  /// In en, this message translates to:
  /// **'Fair Match 💙'**
  String get fairMatch;

  /// Low match message
  ///
  /// In en, this message translates to:
  /// **'Low Match 💔'**
  String get lowMatch;

  /// Celebrity scanner title
  ///
  /// In en, this message translates to:
  /// **'Celebrity Scanner'**
  String get celebrityScanner;

  /// Celebrity scanner subtitle
  ///
  /// In en, this message translates to:
  /// **'Which celebrity likes you?'**
  String get whichCelebrityLikesYou;

  /// Select gender label
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @appTitleFull.
  ///
  /// In en, this message translates to:
  /// **'Crush Scanner 💘'**
  String get appTitleFull;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @premiumOnly.
  ///
  /// In en, this message translates to:
  /// **'Premium Only'**
  String get premiumOnly;

  /// No description provided for @remainingScans.
  ///
  /// In en, this message translates to:
  /// **'You have {count} scans left today! 💕'**
  String remainingScans(Object count);

  /// No scans left message
  ///
  /// In en, this message translates to:
  /// **'No scans left! Watch ads for more'**
  String get noScansLeft;

  /// No description provided for @useWisely.
  ///
  /// In en, this message translates to:
  /// **'Use them wisely or get more below 😉'**
  String get useWisely;

  /// No description provided for @moreTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow you\'ll have 5 fresh scans waiting, or you can get more now:'**
  String get moreTomorrow;

  /// No description provided for @watchShortAd.
  ///
  /// In en, this message translates to:
  /// **'Watch short ad'**
  String get watchShortAd;

  /// No description provided for @extraScansFree.
  ///
  /// In en, this message translates to:
  /// **'+2 free scans'**
  String get extraScansFree;

  /// Unlimited scans feature
  ///
  /// In en, this message translates to:
  /// **'Unlimited Scans'**
  String get unlimitedScans;

  /// No description provided for @premiumPriceText.
  ///
  /// In en, this message translates to:
  /// **'Premium for \$2.99/month'**
  String get premiumPriceText;

  /// No description provided for @waitUntilTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Wait until tomorrow'**
  String get waitUntilTomorrow;

  /// No description provided for @freshScans.
  ///
  /// In en, this message translates to:
  /// **'5 fresh scans free'**
  String get freshScans;

  /// No description provided for @perfectScan.
  ///
  /// In en, this message translates to:
  /// **'Perfect, let\'s scan! 💘'**
  String get perfectScan;

  /// No description provided for @limitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Limit reached!'**
  String get limitReachedTitle;

  /// No description provided for @limitReachedBody.
  ///
  /// In en, this message translates to:
  /// **'You have used all your free scans for today.'**
  String get limitReachedBody;

  /// No description provided for @limitReachedWhatToDo.
  ///
  /// In en, this message translates to:
  /// **'What can you do?'**
  String get limitReachedWhatToDo;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch ad'**
  String get watchAd;

  /// No description provided for @winExtraScans.
  ///
  /// In en, this message translates to:
  /// **'Win +2 extra scans'**
  String get winExtraScans;

  /// No description provided for @extraScansWon.
  ///
  /// In en, this message translates to:
  /// **'+2 extra scans won!'**
  String get extraScansWon;

  /// Go premium button
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get goPremium;

  /// No description provided for @wait.
  ///
  /// In en, this message translates to:
  /// **'Wait'**
  String get wait;

  /// No description provided for @moreScansTomorrow.
  ///
  /// In en, this message translates to:
  /// **'More scans tomorrow'**
  String get moreScansTomorrow;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Any gender option
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// Find celebrity match button
  ///
  /// In en, this message translates to:
  /// **'Find Celebrity Match'**
  String get findCelebrityMatch;

  /// Your celebrity match title
  ///
  /// In en, this message translates to:
  /// **'Your Celebrity Match'**
  String get yourCelebrityMatch;

  /// Compatibility score label
  ///
  /// In en, this message translates to:
  /// **'Compatibility Score'**
  String get compatibilityScore;

  /// Why this match section
  ///
  /// In en, this message translates to:
  /// **'Why this match?'**
  String get whyThisMatch;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// Error message for loading love day
  ///
  /// In en, this message translates to:
  /// **'Could not load your love day: {error}'**
  String errorLoadingLoveDay(Object error);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @freeTrialBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'FREE Trial Period!'**
  String get freeTrialBannerTitle;

  /// No description provided for @freeTrialBannerDayLeft.
  ///
  /// In en, this message translates to:
  /// **'1 DAY LEFT'**
  String get freeTrialBannerDayLeft;

  /// No description provided for @freeTrialBannerDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} DAYS LEFT'**
  String freeTrialBannerDaysLeft(Object days);

  /// No description provided for @freeTrialBannerUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited scans!'**
  String get freeTrialBannerUnlimited;

  /// No description provided for @freeTrialBannerEnjoy.
  ///
  /// In en, this message translates to:
  /// **'Enjoy unlimited love scans during your trial'**
  String get freeTrialBannerEnjoy;

  /// Daily limit reached message
  ///
  /// In en, this message translates to:
  /// **'Limit reached!'**
  String get limitReached;

  /// Scans remaining today message
  ///
  /// In en, this message translates to:
  /// **'{count} scans remaining today'**
  String scansRemainingToday(int count);

  /// Watch ad to get more scans
  ///
  /// In en, this message translates to:
  /// **'Watch ad for +2 more'**
  String get watchAdForMore;

  /// Upgrade to premium for unlimited scans
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all your scans today. Upgrade to Premium for unlimited scans.'**
  String get upgradeForUnlimited;

  /// No description provided for @watchAdForScans.
  ///
  /// In en, this message translates to:
  /// **'Watch ad (+2 scans)'**
  String get watchAdForScans;

  /// No description provided for @noAdsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No ads available. Try again later.'**
  String get noAdsAvailable;

  /// Options when limit is reached
  ///
  /// In en, this message translates to:
  /// **'Watch ad or upgrade for more'**
  String get watchAdOrUpgrade;

  /// No description provided for @dailyStreak.
  ///
  /// In en, this message translates to:
  /// **'Daily Streak'**
  String get dailyStreak;

  /// No description provided for @startLoveStreak.
  ///
  /// In en, this message translates to:
  /// **'Start your love streak today!'**
  String get startLoveStreak;

  /// No description provided for @best.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get best;

  /// Current streak label
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// Best streak label
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// Total scans label
  ///
  /// In en, this message translates to:
  /// **'Total Scans'**
  String get totalScans;

  /// No description provided for @streakStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'🔥 Streak Stats'**
  String get streakStatsTitle;

  /// No description provided for @learnAboutStats.
  ///
  /// In en, this message translates to:
  /// **'Learn about stats'**
  String get learnAboutStats;

  /// No description provided for @streakStatsDialogCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get streakStatsDialogCurrent;

  /// No description provided for @streakStatsDialogBest.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get streakStatsDialogBest;

  /// No description provided for @streakStatsDialogTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Scans'**
  String get streakStatsDialogTotal;

  /// No description provided for @streakStatsDialogMotivation.
  ///
  /// In en, this message translates to:
  /// **'{motivation}'**
  String streakStatsDialogMotivation(Object motivation);

  /// No description provided for @streakInfoDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'What do these stats mean?'**
  String get streakInfoDialogTitle;

  /// No description provided for @streakInfoCurrentDesc.
  ///
  /// In en, this message translates to:
  /// **'How many consecutive days you\'ve used the app without missing a day.'**
  String get streakInfoCurrentDesc;

  /// No description provided for @streakInfoCurrentExample.
  ///
  /// In en, this message translates to:
  /// **'Example: If you used it yesterday and today, your current streak is 2 days.'**
  String get streakInfoCurrentExample;

  /// No description provided for @streakInfoBestDesc.
  ///
  /// In en, this message translates to:
  /// **'Your personal record - the longest streak you\'ve ever achieved. It\'s always equal or greater than your current streak.'**
  String get streakInfoBestDesc;

  /// No description provided for @streakInfoBestExample.
  ///
  /// In en, this message translates to:
  /// **'Example: If your current streak is 2 days, your best streak is at least 2 days (or higher if you had a longer streak before).'**
  String get streakInfoBestExample;

  /// No description provided for @streakInfoTotalDesc.
  ///
  /// In en, this message translates to:
  /// **'The total number of love scans you\'ve performed since you started using the app.'**
  String get streakInfoTotalDesc;

  /// No description provided for @streakInfoTotalExample.
  ///
  /// In en, this message translates to:
  /// **'Example: Every time you scan your crush compatibility, this number goes up.'**
  String get streakInfoTotalExample;

  /// No description provided for @streakInfoTip.
  ///
  /// In en, this message translates to:
  /// **'💡 Tip: Keep using the app daily to build your streak and discover your love compatibility!'**
  String get streakInfoTip;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @premiumRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Required'**
  String get premiumRequiredTitle;

  /// No description provided for @premiumRequiredContent.
  ///
  /// In en, this message translates to:
  /// **'This feature is available only for Premium users. Upgrade now and unlock all exclusive features!'**
  String get premiumRequiredContent;

  /// View premium button
  ///
  /// In en, this message translates to:
  /// **'View Premium'**
  String get viewPremium;

  /// Premium features subtitle
  ///
  /// In en, this message translates to:
  /// **'Unlock all features and enjoy the full experience!'**
  String get unlockAllFeatures;

  /// Premium features title
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get premiumFeatures;

  /// Detailed analysis feature
  ///
  /// In en, this message translates to:
  /// **'Detailed Analysis'**
  String get detailedAnalysis;

  /// No ads feature
  ///
  /// In en, this message translates to:
  /// **'No Ads'**
  String get noAds;

  /// Exclusive content feature
  ///
  /// In en, this message translates to:
  /// **'Exclusive Content'**
  String get exclusiveContent;

  /// Advanced compatibility feature
  ///
  /// In en, this message translates to:
  /// **'Advanced Compatibility'**
  String get advancedCompatibility;

  /// Monthly plan option
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get monthlyPlan;

  /// Yearly plan option
  ///
  /// In en, this message translates to:
  /// **'Yearly Plan'**
  String get yearlyPlan;

  /// Most popular plan badge
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// Save percentage message
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String save(String percentage);

  /// Subscribe button
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// Restore purchases button
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// Please enter name error
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// Please enter crush name error
  ///
  /// In en, this message translates to:
  /// **'Please enter your crush\'s name'**
  String get pleaseEnterCrushName;

  /// Share message template
  ///
  /// In en, this message translates to:
  /// **'I got {percentage}% compatibility with {crushName} on Crush Scanner! 💕 Try it yourself: [App Link]'**
  String shareMessage(String percentage, String crushName);

  /// Footer message about app creation
  ///
  /// In en, this message translates to:
  /// **'Made with 💕 to discover love'**
  String get madeWithLove;

  /// Subtitle for regular crush scan option
  ///
  /// In en, this message translates to:
  /// **'Discover your compatibility with someone special'**
  String get regularScanSubtitle;

  /// Subtitle for celebrity scan option
  ///
  /// In en, this message translates to:
  /// **'Your compatibility with the stars'**
  String get celebrityScanSubtitle;

  /// Instructions on the form screen
  ///
  /// In en, this message translates to:
  /// **'Enter your name and that of that special person to discover what the heart says about your connection'**
  String get formInstructions;

  /// Main scan button text
  ///
  /// In en, this message translates to:
  /// **'Scan Love ❤️'**
  String get scanLoveButton;

  /// Personal algorithm title
  ///
  /// In en, this message translates to:
  /// **'✨ Personal Algorithm ✨'**
  String get personalAlgorithm;

  /// Description of how the algorithm works
  ///
  /// In en, this message translates to:
  /// **'Our love algorithm analyzes compatibility between real people, based on energies, names and heart connections to reveal romantic secrets.'**
  String get algorithmDescription;

  /// Subtitle for sound effects setting
  ///
  /// In en, this message translates to:
  /// **'Sounds on buttons and actions'**
  String get soundEffectsSubtitle;

  /// Subtitle for background music setting
  ///
  /// In en, this message translates to:
  /// **'Relaxing ambient music'**
  String get backgroundMusicSubtitle;

  /// Premium upgrade button text in settings
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeSettings;

  /// Premium upgrade subtitle in settings
  ///
  /// In en, this message translates to:
  /// **'Unlock all features'**
  String get unlockAllFeaturesSettings;

  /// New badge text
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// Loading message for daily love screen
  ///
  /// In en, this message translates to:
  /// **'Preparing your love day...'**
  String get preparingLoveDay;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// Button to go back
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Title for daily love screen
  ///
  /// In en, this message translates to:
  /// **'Your Love Universe'**
  String get yourLoveUniverse;

  /// Streak counter label
  ///
  /// In en, this message translates to:
  /// **'Consecutive days'**
  String get consecutiveDays;

  /// Average compatibility label
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// Title for personalized advice section
  ///
  /// In en, this message translates to:
  /// **'Personalized Tip'**
  String get personalizedTip;

  /// Title for achievements section
  ///
  /// In en, this message translates to:
  /// **'🏆 Unlocked Achievements'**
  String get unlockedAchievements;

  /// Error message when sharing fails
  ///
  /// In en, this message translates to:
  /// **'Error sharing. Please try again.'**
  String get shareError;

  /// Title for result screen
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// Compatibility level for 80%+ results
  ///
  /// In en, this message translates to:
  /// **'Perfect Compatibility!'**
  String get perfectCompatibility;

  /// Compatibility level for 60-79% results
  ///
  /// In en, this message translates to:
  /// **'Great Compatibility!'**
  String get greatCompatibility;

  /// Compatibility level for 40-59% results
  ///
  /// In en, this message translates to:
  /// **'Good Compatibility'**
  String get goodCompatibility;

  /// Share button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Celebrity crush main title
  ///
  /// In en, this message translates to:
  /// **'🌟 Celebrity Crush 🌟'**
  String get celebrityCrushTitle;

  /// Celebrity crush description
  ///
  /// In en, this message translates to:
  /// **'Discover your compatibility with the brightest stars of Hollywood and the entertainment world'**
  String get celebrityCrushDescription;

  /// Button to choose celebrity crush
  ///
  /// In en, this message translates to:
  /// **'Choose My Celebrity Crush ✨'**
  String get chooseMyCommit;

  /// Celebrity mode title
  ///
  /// In en, this message translates to:
  /// **'✨ Celebrity Mode ✨'**
  String get celebrityMode;

  /// Celebrity mode description
  ///
  /// In en, this message translates to:
  /// **'Our stellar algorithm analyzes your name and the cosmic energy of celebrities to reveal unique connections from the entertainment world.'**
  String get celebrityModeDescription;

  /// Popular celebrities title
  ///
  /// In en, this message translates to:
  /// **'🎬 Popular Celebrities'**
  String get popularCelebrities;

  /// And many more text
  ///
  /// In en, this message translates to:
  /// **'And many more...'**
  String get andManyMore;

  /// No history message
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No history description
  ///
  /// In en, this message translates to:
  /// **'Your compatibility scans will appear here'**
  String get noHistoryDescription;

  /// Start scanning button
  ///
  /// In en, this message translates to:
  /// **'Start Scanning'**
  String get startScanning;

  /// Error loading history message
  ///
  /// In en, this message translates to:
  /// **'Error loading history: {error}'**
  String errorLoadingHistory(String error);

  /// Time ago indicator
  ///
  /// In en, this message translates to:
  /// **'ago'**
  String get agoTime;

  /// Minutes abbreviation
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// Hours abbreviation
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hours;

  /// Days text
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Clear history button
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// Confirm clear history message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear your history?'**
  String get confirmClearHistory;

  /// Confirm clear button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get confirmClear;

  /// History cleared message
  ///
  /// In en, this message translates to:
  /// **'History cleared successfully'**
  String get historyCleared;

  /// Error clearing history message
  ///
  /// In en, this message translates to:
  /// **'Error clearing history'**
  String get errorClearingHistory;

  /// Error sharing result message
  ///
  /// In en, this message translates to:
  /// **'Error sharing result'**
  String get errorSharingResult;

  /// Premium screen title
  ///
  /// In en, this message translates to:
  /// **'Scanner Crush Premium'**
  String get premiumTitle;

  /// Premium screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Unlock the full potential of love!'**
  String get premiumSubtitle;

  /// No ads feature title
  ///
  /// In en, this message translates to:
  /// **'No Ads'**
  String get noAdsTitle;

  /// No ads feature description
  ///
  /// In en, this message translates to:
  /// **'Enjoy the complete experience without interruptions'**
  String get noAdsDescription;

  /// Unlimited scans feature title
  ///
  /// In en, this message translates to:
  /// **'Unlimited Scans'**
  String get unlimitedScansTitle;

  /// Unlimited scans feature description
  ///
  /// In en, this message translates to:
  /// **'Scan as much as you want without restrictions'**
  String get unlimitedScansDescription;

  /// Exclusive results feature title
  ///
  /// In en, this message translates to:
  /// **'Exclusive Results'**
  String get exclusiveResultsTitle;

  /// Exclusive results feature description
  ///
  /// In en, this message translates to:
  /// **'Access special messages and predictions'**
  String get exclusiveResultsDescription;

  /// Crush history feature title
  ///
  /// In en, this message translates to:
  /// **'Crush History'**
  String get crushHistoryTitle;

  /// Crush history feature description
  ///
  /// In en, this message translates to:
  /// **'Save and review all your previous scans'**
  String get crushHistoryDescription;

  /// Special themes feature title
  ///
  /// In en, this message translates to:
  /// **'Special Themes'**
  String get specialThemesTitle;

  /// Special themes feature description
  ///
  /// In en, this message translates to:
  /// **'Customize the app with unique and exclusive themes'**
  String get specialThemesDescription;

  /// Premium support feature title
  ///
  /// In en, this message translates to:
  /// **'Premium Support'**
  String get premiumSupportTitle;

  /// Premium support feature description
  ///
  /// In en, this message translates to:
  /// **'Priority attention and advanced technical support'**
  String get premiumSupportDescription;

  /// Purchase premium button
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get purchasePremium;

  /// Welcome to premium title
  ///
  /// In en, this message translates to:
  /// **'Welcome to Premium!'**
  String get welcomeToPremium;

  /// Premium activated message
  ///
  /// In en, this message translates to:
  /// **'Your Premium account has been successfully activated. Enjoy all the exclusive features!'**
  String get premiumActivated;

  /// Great button text
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// Restore purchases button
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchasesButton;

  /// Processing text
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No previous purchases message
  ///
  /// In en, this message translates to:
  /// **'No previous purchases found'**
  String get noPreviousPurchases;

  /// Love horoscope title
  ///
  /// In en, this message translates to:
  /// **'💘 Magnetic Connection'**
  String get magneticConnection;

  /// Love horoscope message
  ///
  /// In en, this message translates to:
  /// **'Today love energies are especially strong. It\'s the perfect time to discover new connections.'**
  String get magneticConnectionMessage;

  /// Love horoscope advice
  ///
  /// In en, this message translates to:
  /// **'Keep your heart open to love\'s surprises.'**
  String get magneticConnectionAdvice;

  /// Love horoscope title
  ///
  /// In en, this message translates to:
  /// **'✨ Day of Revelations'**
  String get dayOfRevelations;

  /// Love horoscope message
  ///
  /// In en, this message translates to:
  /// **'Heart secrets are ready to be revealed. Someone special might confess something important to you.'**
  String get dayOfRevelationsMessage;

  /// Love horoscope advice
  ///
  /// In en, this message translates to:
  /// **'Pay attention to subtle signs from those around you.'**
  String get dayOfRevelationsAdvice;

  /// Love horoscope title
  ///
  /// In en, this message translates to:
  /// **'🌹 Romance in the Air'**
  String get romanceInTheAir;

  /// Love horoscope message
  ///
  /// In en, this message translates to:
  /// **'The universe conspires to create romantic moments. Your crush might be thinking about you more than you imagine.'**
  String get romanceInTheAirMessage;

  /// Love horoscope advice
  ///
  /// In en, this message translates to:
  /// **'Be brave and take the first step.'**
  String get romanceInTheAirAdvice;

  /// Love horoscope title
  ///
  /// In en, this message translates to:
  /// **'💫 Destiny Aligned'**
  String get destinyAligned;

  /// Love horoscope message
  ///
  /// In en, this message translates to:
  /// **'The stars align to favor casual encounters that can change your love life.'**
  String get destinyAlignedMessage;

  /// Love horoscope advice
  ///
  /// In en, this message translates to:
  /// **'Step out of your comfort zone and socialize more.'**
  String get destinyAlignedAdvice;

  /// Love horoscope title
  ///
  /// In en, this message translates to:
  /// **'🦋 Butterflies in Your Stomach'**
  String get butterfliesInStomach;

  /// Love horoscope message
  ///
  /// In en, this message translates to:
  /// **'Today you\'ll feel those special butterflies. Your love intuition is at its highest point.'**
  String get butterfliesInStomachMessage;

  /// Love horoscope advice
  ///
  /// In en, this message translates to:
  /// **'Trust your heart\'s instincts.'**
  String get butterfliesInStomachAdvice;

  /// Love horoscope title
  ///
  /// In en, this message translates to:
  /// **'🔥 Burning Passion'**
  String get burningPassion;

  /// Love horoscope message
  ///
  /// In en, this message translates to:
  /// **'Romantic energy is at its maximum. It\'s a perfect day to express your feelings.'**
  String get burningPassionMessage;

  /// Love horoscope advice
  ///
  /// In en, this message translates to:
  /// **'Don\'t repress your emotions, let them flow.'**
  String get burningPassionAdvice;

  /// Love horoscope title
  ///
  /// In en, this message translates to:
  /// **'💎 Authentic Love'**
  String get authenticLove;

  /// Love horoscope message
  ///
  /// In en, this message translates to:
  /// **'Today you can recognize true love. Superficial connections fade away.'**
  String get authenticLoveMessage;

  /// Love horoscope advice
  ///
  /// In en, this message translates to:
  /// **'Seek depth in your relationships.'**
  String get authenticLoveAdvice;

  /// Personalized tip for streak
  ///
  /// In en, this message translates to:
  /// **'🔥 Incredible {streak}-day streak! Your love energy is at its peak.'**
  String personalizedTipStreak(int streak);

  /// Personalized tip for compatibility
  ///
  /// In en, this message translates to:
  /// **'⭐ Your average compatibility is excellent ({compatibility}%). You have a good eye for love!'**
  String personalizedTipCompatibility(int compatibility);

  /// Personalized tip for total scans
  ///
  /// In en, this message translates to:
  /// **'💡 With {scans} scans completed, your love experience is growing. Keep exploring!'**
  String personalizedTipScans(int scans);

  /// Personalized tip for good compatibility
  ///
  /// In en, this message translates to:
  /// **'💫 Your average compatibility is good. Trust your love instincts.'**
  String get personalizedTipGoodCompatibility;

  /// Encouragement tip
  ///
  /// In en, this message translates to:
  /// **'🌱 Each scan brings you closer to finding your perfect connection. Don\'t give up!'**
  String get personalizedTipEncouragement;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'🔥 Fire Streak'**
  String get fireStreak;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'{days} consecutive days'**
  String fireStreakDescription(int days);

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'🎯 Love Explorer'**
  String get loveExplorer;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'{scans} scans completed'**
  String loveExplorerDescription(int scans);

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'⭐ Compatibility Master'**
  String get compatibilityMaster;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'{average}% average'**
  String compatibilityMasterDescription(int average);

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'👑 Romance Guru'**
  String get romanceGuru;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'Love expert'**
  String get romanceGuruDescription;

  /// Title for personal scanner screen in app bar
  ///
  /// In en, this message translates to:
  /// **'Personal Scanner'**
  String get personalScannerTitle;

  /// Main title for personal compatibility screen
  ///
  /// In en, this message translates to:
  /// **'💕 Your Personal Compatibility 💕'**
  String get personalCompatibilityTitle;

  /// Title for result screen in app bar
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultTitle;

  /// Compatibility level for under 40% results
  ///
  /// In en, this message translates to:
  /// **'There Is Potential'**
  String get thereIsPotential;

  /// Button to share the result
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// Button to scan again
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanAgainButton;

  /// No description provided for @celebrityMessage1.
  ///
  /// In en, this message translates to:
  /// **'OMG! Your compatibility with a celebrity is incredible 🌟'**
  String get celebrityMessage1;

  /// No description provided for @celebrityMessage2.
  ///
  /// In en, this message translates to:
  /// **'Hollywood stars approve this combination ⭐'**
  String get celebrityMessage2;

  /// No description provided for @celebrityMessage3.
  ///
  /// In en, this message translates to:
  /// **'Your celebrity crush could be your soulmate! 💫'**
  String get celebrityMessage3;

  /// No description provided for @celebrityMessage4.
  ///
  /// In en, this message translates to:
  /// **'Hollywood is talking about this compatibility 🎬'**
  String get celebrityMessage4;

  /// No description provided for @celebrityMessage5.
  ///
  /// In en, this message translates to:
  /// **'Plot twist! You have chemistry with a superstar 🎭'**
  String get celebrityMessage5;

  /// No description provided for @celebrityMessage6.
  ///
  /// In en, this message translates to:
  /// **'Your celebrity compatibility level is off the charts! 📈'**
  String get celebrityMessage6;

  /// No description provided for @celebrityMessage7.
  ///
  /// In en, this message translates to:
  /// **'Breaking news! You\'re compatible with a star 📺'**
  String get celebrityMessage7;

  /// No description provided for @celebrityMessage8.
  ///
  /// In en, this message translates to:
  /// **'Love\'s red carpet is waiting for you 🌹'**
  String get celebrityMessage8;

  /// No description provided for @celebrityMessage9.
  ///
  /// In en, this message translates to:
  /// **'Paparazzi alert! You have a special connection 📸'**
  String get celebrityMessage9;

  /// No description provided for @celebrityMessage10.
  ///
  /// In en, this message translates to:
  /// **'Your love story could be a blockbuster movie 🍿'**
  String get celebrityMessage10;

  /// No description provided for @celebrityMessage11.
  ///
  /// In en, this message translates to:
  /// **'Award-winning compatibility detected! 🏆'**
  String get celebrityMessage11;

  /// No description provided for @celebrityMessage12.
  ///
  /// In en, this message translates to:
  /// **'Gossip magazines would be talking about you two 📰'**
  String get celebrityMessage12;

  /// No description provided for @celebrityMessage13.
  ///
  /// In en, this message translates to:
  /// **'Your celebrity crush approves this combination 💕'**
  String get celebrityMessage13;

  /// No description provided for @celebrityMessage14.
  ///
  /// In en, this message translates to:
  /// **'Lights, camera, love! You have celebrity couple potential 🎥'**
  String get celebrityMessage14;

  /// No description provided for @celebrityMessage15.
  ///
  /// In en, this message translates to:
  /// **'The celebrity universe conspires in your favor ✨'**
  String get celebrityMessage15;

  /// No description provided for @romanticMessage1.
  ///
  /// In en, this message translates to:
  /// **'Your hearts beat in perfect rhythm! 💕'**
  String get romanticMessage1;

  /// No description provided for @romanticMessage2.
  ///
  /// In en, this message translates to:
  /// **'The stars align perfectly for you both ✨'**
  String get romanticMessage2;

  /// No description provided for @romanticMessage3.
  ///
  /// In en, this message translates to:
  /// **'There\'s a special connection waiting to be discovered 🌙'**
  String get romanticMessage3;

  /// No description provided for @romanticMessage4.
  ///
  /// In en, this message translates to:
  /// **'Destiny has woven its threads between you two 💫'**
  String get romanticMessage4;

  /// No description provided for @romanticMessage5.
  ///
  /// In en, this message translates to:
  /// **'Your souls seem to speak love\'s same language 💝'**
  String get romanticMessage5;

  /// No description provided for @romanticMessage6.
  ///
  /// In en, this message translates to:
  /// **'Love\'s magic is floating in the air 🎭'**
  String get romanticMessage6;

  /// No description provided for @romanticMessage7.
  ///
  /// In en, this message translates to:
  /// **'There\'s undeniable chemistry between you 🔥'**
  String get romanticMessage7;

  /// No description provided for @romanticMessage8.
  ///
  /// In en, this message translates to:
  /// **'The universe conspires in favor of your love 🌟'**
  String get romanticMessage8;

  /// No description provided for @romanticMessage9.
  ///
  /// In en, this message translates to:
  /// **'Your energies complement each other perfectly 🌸'**
  String get romanticMessage9;

  /// No description provided for @romanticMessage10.
  ///
  /// In en, this message translates to:
  /// **'There\'s more than friendship waiting to bloom 🌺'**
  String get romanticMessage10;

  /// No description provided for @romanticMessage11.
  ///
  /// In en, this message translates to:
  /// **'The compatibility between you is amazing 💖'**
  String get romanticMessage11;

  /// No description provided for @romanticMessage12.
  ///
  /// In en, this message translates to:
  /// **'True love might be closer than you think 💘'**
  String get romanticMessage12;

  /// No description provided for @romanticMessage13.
  ///
  /// In en, this message translates to:
  /// **'Your hearts vibrate on the same frequency 🎵'**
  String get romanticMessage13;

  /// No description provided for @romanticMessage14.
  ///
  /// In en, this message translates to:
  /// **'The attraction between you is magnetic ⚡'**
  String get romanticMessage14;

  /// No description provided for @romanticMessage15.
  ///
  /// In en, this message translates to:
  /// **'Cupid already has his arrows aimed at you 🏹'**
  String get romanticMessage15;

  /// No description provided for @romanticMessage16.
  ///
  /// In en, this message translates to:
  /// **'Your paths are destined to cross again and again 🛤️'**
  String get romanticMessage16;

  /// No description provided for @romanticMessage17.
  ///
  /// In en, this message translates to:
  /// **'Love\'s flame burns intensely between you 🕯️'**
  String get romanticMessage17;

  /// No description provided for @romanticMessage18.
  ///
  /// In en, this message translates to:
  /// **'There\'s a cosmic connection that binds you 🌌'**
  String get romanticMessage18;

  /// No description provided for @romanticMessage19.
  ///
  /// In en, this message translates to:
  /// **'Love is writing its own story 📖'**
  String get romanticMessage19;

  /// No description provided for @romanticMessage20.
  ///
  /// In en, this message translates to:
  /// **'Your hearts speak a language only you understand 💬'**
  String get romanticMessage20;

  /// No description provided for @mysteriousMessage1.
  ///
  /// In en, this message translates to:
  /// **'Heart\'s secrets are about to be revealed... 🔮'**
  String get mysteriousMessage1;

  /// No description provided for @mysteriousMessage2.
  ///
  /// In en, this message translates to:
  /// **'Someone thinks of you more than you imagine 👁️'**
  String get mysteriousMessage2;

  /// No description provided for @mysteriousMessage3.
  ///
  /// In en, this message translates to:
  /// **'Universe\'s signals are trying to tell you something 🌠'**
  String get mysteriousMessage3;

  /// No description provided for @mysteriousMessage4.
  ///
  /// In en, this message translates to:
  /// **'Hidden feelings will soon come to light 🌅'**
  String get mysteriousMessage4;

  /// No description provided for @mysteriousMessage5.
  ///
  /// In en, this message translates to:
  /// **'Love\'s mystery is about to unfold 🎭'**
  String get mysteriousMessage5;

  /// No description provided for @mysteriousMessage6.
  ///
  /// In en, this message translates to:
  /// **'Invisible forces are working in your favor 👻'**
  String get mysteriousMessage6;

  /// No description provided for @mysteriousMessage7.
  ///
  /// In en, this message translates to:
  /// **'Heart\'s whispers are reaching you 🍃'**
  String get mysteriousMessage7;

  /// No description provided for @mysteriousMessage8.
  ///
  /// In en, this message translates to:
  /// **'There\'s a love story waiting to be told 📚'**
  String get mysteriousMessage8;

  /// No description provided for @mysteriousMessage9.
  ///
  /// In en, this message translates to:
  /// **'Destiny\'s threads are intertwining 🕸️'**
  String get mysteriousMessage9;

  /// No description provided for @mysteriousMessage10.
  ///
  /// In en, this message translates to:
  /// **'Something magical is about to happen in love 🎪'**
  String get mysteriousMessage10;

  /// No description provided for @mysteriousMessage11.
  ///
  /// In en, this message translates to:
  /// **'Love\'s tarot cards are shuffling 🃏'**
  String get mysteriousMessage11;

  /// No description provided for @mysteriousMessage12.
  ///
  /// In en, this message translates to:
  /// **'A romantic secret is floating in the air 💨'**
  String get mysteriousMessage12;

  /// No description provided for @mysteriousMessage13.
  ///
  /// In en, this message translates to:
  /// **'The full moon brings heart revelations 🌕'**
  String get mysteriousMessage13;

  /// No description provided for @mysteriousMessage14.
  ///
  /// In en, this message translates to:
  /// **'There are glances that say more than a thousand words 👀'**
  String get mysteriousMessage14;

  /// No description provided for @mysteriousMessage15.
  ///
  /// In en, this message translates to:
  /// **'A loving heart\'s echo resonates nearby 🔊'**
  String get mysteriousMessage15;

  /// No description provided for @mysteriousMessage16.
  ///
  /// In en, this message translates to:
  /// **'Something beautiful is brewing in silence 🤫'**
  String get mysteriousMessage16;

  /// No description provided for @mysteriousMessage17.
  ///
  /// In en, this message translates to:
  /// **'Stars whisper love secrets 🌟'**
  String get mysteriousMessage17;

  /// No description provided for @mysteriousMessage18.
  ///
  /// In en, this message translates to:
  /// **'A heart message is waiting to be sent 💌'**
  String get mysteriousMessage18;

  /// No description provided for @mysteriousMessage19.
  ///
  /// In en, this message translates to:
  /// **'Love\'s magic is creating invisible connections ✨'**
  String get mysteriousMessage19;

  /// No description provided for @mysteriousMessage20.
  ///
  /// In en, this message translates to:
  /// **'There\'s a romantic surprise on the horizon 🎁'**
  String get mysteriousMessage20;

  /// No description provided for @funMessage1.
  ///
  /// In en, this message translates to:
  /// **'Houston, we have a connection! 🚀'**
  String get funMessage1;

  /// No description provided for @funMessage2.
  ///
  /// In en, this message translates to:
  /// **'Your crush-o-meter is through the roof 📈'**
  String get funMessage2;

  /// No description provided for @funMessage3.
  ///
  /// In en, this message translates to:
  /// **'Heart alert! Danger of falling in love 🚨'**
  String get funMessage3;

  /// No description provided for @funMessage4.
  ///
  /// In en, this message translates to:
  /// **'The love detector is ringing loudly 📢'**
  String get funMessage4;

  /// No description provided for @funMessage5.
  ///
  /// In en, this message translates to:
  /// **'Bingo! You\'ve found a perfect match 🎯'**
  String get funMessage5;

  /// No description provided for @funMessage6.
  ///
  /// In en, this message translates to:
  /// **'Your compatibility level is off the charts! 📊'**
  String get funMessage6;

  /// No description provided for @funMessage7.
  ///
  /// In en, this message translates to:
  /// **'Ding ding ding! We have a love winner 🛎️'**
  String get funMessage7;

  /// No description provided for @funMessage8.
  ///
  /// In en, this message translates to:
  /// **'Love\'s GPS is guiding you to something special 🗺️'**
  String get funMessage8;

  /// No description provided for @funMessage9.
  ///
  /// In en, this message translates to:
  /// **'Emotional jackpot! You\'ve hit the bullseye 🎰'**
  String get funMessage9;

  /// No description provided for @funMessage10.
  ///
  /// In en, this message translates to:
  /// **'Your heart just made a perfect match 💕'**
  String get funMessage10;

  /// No description provided for @funMessage11.
  ///
  /// In en, this message translates to:
  /// **'Eureka! Love\'s formula has been deciphered 🧪'**
  String get funMessage11;

  /// No description provided for @funMessage12.
  ///
  /// In en, this message translates to:
  /// **'The romance thermometer is about to explode 🌡️'**
  String get funMessage12;

  /// No description provided for @funMessage13.
  ///
  /// In en, this message translates to:
  /// **'Breaking news! Chemistry detected between you 📺'**
  String get funMessage13;

  /// No description provided for @funMessage14.
  ///
  /// In en, this message translates to:
  /// **'Your love radar is picking up strong signals 📡'**
  String get funMessage14;

  /// No description provided for @funMessage15.
  ///
  /// In en, this message translates to:
  /// **'Plot twist! Your crush might be thinking of you 🎬'**
  String get funMessage15;

  /// No description provided for @funMessage16.
  ///
  /// In en, this message translates to:
  /// **'Love\'s algorithm says you\'re compatible 💻'**
  String get funMessage16;

  /// No description provided for @funMessage17.
  ///
  /// In en, this message translates to:
  /// **'Spoiler alert! There\'s romance in your future 📱'**
  String get funMessage17;

  /// No description provided for @funMessage18.
  ///
  /// In en, this message translates to:
  /// **'Your love app just sent a notification 📲'**
  String get funMessage18;

  /// No description provided for @funMessage19.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocked! You\'ve found your match 🏆'**
  String get funMessage19;

  /// No description provided for @funMessage20.
  ///
  /// In en, this message translates to:
  /// **'Heart\'s bluetooth has connected successfully 📶'**
  String get funMessage20;

  /// No description provided for @lowCompatibilityMessage1.
  ///
  /// In en, this message translates to:
  /// **'Sometimes differences create the perfect spark ⚡'**
  String get lowCompatibilityMessage1;

  /// No description provided for @lowCompatibilityMessage2.
  ///
  /// In en, this message translates to:
  /// **'True love overcomes any percentage 💪'**
  String get lowCompatibilityMessage2;

  /// No description provided for @lowCompatibilityMessage3.
  ///
  /// In en, this message translates to:
  /// **'Opposites attract and create magic 🧲'**
  String get lowCompatibilityMessage3;

  /// No description provided for @lowCompatibilityMessage4.
  ///
  /// In en, this message translates to:
  /// **'Not all great loves start with 100% 📈'**
  String get lowCompatibilityMessage4;

  /// No description provided for @lowCompatibilityMessage5.
  ///
  /// In en, this message translates to:
  /// **'Give time to time, love grows step by step 🌱'**
  String get lowCompatibilityMessage5;

  /// No description provided for @lowCompatibilityMessage6.
  ///
  /// In en, this message translates to:
  /// **'Compatibility is built day by day 🏗️'**
  String get lowCompatibilityMessage6;

  /// No description provided for @lowCompatibilityMessage7.
  ///
  /// In en, this message translates to:
  /// **'Maybe you need to get to know each other better 🤔'**
  String get lowCompatibilityMessage7;

  /// No description provided for @lowCompatibilityMessage8.
  ///
  /// In en, this message translates to:
  /// **'Real love doesn\'t always follow statistics 📊'**
  String get lowCompatibilityMessage8;

  /// No description provided for @lowCompatibilityMessage9.
  ///
  /// In en, this message translates to:
  /// **'There\'s room for something beautiful to grow 🌻'**
  String get lowCompatibilityMessage9;

  /// No description provided for @lowCompatibilityMessage10.
  ///
  /// In en, this message translates to:
  /// **'The best romances start as friendship 👫'**
  String get lowCompatibilityMessage10;

  /// Theme toggle description in settings
  ///
  /// In en, this message translates to:
  /// **'Change the app theme'**
  String get changeAppTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// Premium user status message
  ///
  /// In en, this message translates to:
  /// **'You are Premium!'**
  String get youArePremium;

  /// Premium user benefits description
  ///
  /// In en, this message translates to:
  /// **'Enjoy all features without limits'**
  String get enjoyAllFeatures;

  /// Purchase error message
  ///
  /// In en, this message translates to:
  /// **'Purchase error: {error}'**
  String purchaseError(String error);

  /// Error when app store is not available
  ///
  /// In en, this message translates to:
  /// **'The store is not available right now. Check your internet connection and try again.'**
  String get storeNotAvailable;

  /// Error when product ID is not found in store
  ///
  /// In en, this message translates to:
  /// **'This product is not available right now. Please try again later.'**
  String get productNotConfigured;

  /// Error when user tries to buy while another purchase is pending
  ///
  /// In en, this message translates to:
  /// **'A purchase is already in progress. Please wait a moment.'**
  String get purchaseAlreadyInProgress;

  /// Error when purchase flow fails to start
  ///
  /// In en, this message translates to:
  /// **'Could not start the purchase. Please try again.'**
  String get purchaseCouldNotStart;

  /// Generic purchase error
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again later.'**
  String get purchaseUnexpectedError;

  /// Info message when purchase flow opens successfully
  ///
  /// In en, this message translates to:
  /// **'Purchase started. Complete the payment in the store window.'**
  String get purchaseStartedCompleteInStore;

  /// Premium description text
  ///
  /// In en, this message translates to:
  /// **'Get full access to all special features'**
  String get getFullAccess;

  /// Special offer label
  ///
  /// In en, this message translates to:
  /// **'Special Offer'**
  String get specialOffer;

  /// Cancel subscription anytime text
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get cancelAnytime;

  /// Support section title
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @settingsHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View all your previous scans'**
  String get settingsHistorySubtitle;

  /// No description provided for @changeThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change the app theme'**
  String get changeThemeSubtitle;

  /// No description provided for @backgroundAnimationTitle.
  ///
  /// In en, this message translates to:
  /// **'Background Animation'**
  String get backgroundAnimationTitle;

  /// No description provided for @backgroundAnimationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show floating flowers and hearts'**
  String get backgroundAnimationSubtitle;

  /// Help and questions menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Questions'**
  String get helpAndQuestions;

  /// Help subtitle description
  ///
  /// In en, this message translates to:
  /// **'Get help on how to use the app'**
  String get getHelpOnApp;

  /// Help dialog title
  ///
  /// In en, this message translates to:
  /// **'💕 Help'**
  String get helpDialogTitle;

  /// Help dialog content text
  ///
  /// In en, this message translates to:
  /// **'Crush Scanner is a fun app that estimates compatibility based on names.\\n\\n- Enter your name and your crush\'s name\\n- Tap \\\"Scan Love\\\"\\n- Check your compatibility result\\n- Share your favorite result\\n\\nThis app is for entertainment purposes.'**
  String get helpDialogContent;

  /// Understood button text
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get understood;

  /// About dialog title
  ///
  /// In en, this message translates to:
  /// **'💘 About'**
  String get aboutDialogTitle;

  /// About dialog content text
  ///
  /// In en, this message translates to:
  /// **'Crush Scanner v1.0.0\n\nA fun app to discover love compatibility.\n\nMade with love by Perlaza Studio\n\n© 2026 Crush Scanner'**
  String get aboutDialogContent;

  /// Daily streak title
  ///
  /// In en, this message translates to:
  /// **'Daily Streak'**
  String get streakTitle;

  /// Days in streak
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 days} =1{1 day} other{{count} days}}'**
  String daysStreak(int count);

  /// Streak maintenance message
  ///
  /// In en, this message translates to:
  /// **'Don\'t break your streak!'**
  String get streakMaintain;

  /// Streak at risk warning
  ///
  /// In en, this message translates to:
  /// **'Streak at risk! Scan now to maintain it 🔥'**
  String get streakAtRisk;

  /// First scan streak message
  ///
  /// In en, this message translates to:
  /// **'🎉 Welcome! Your love journey begins now!'**
  String get firstScanStreak;

  /// Streak broken message
  ///
  /// In en, this message translates to:
  /// **'💔 Streak broken, but you\'re back! New streak started'**
  String get streakBroken;

  /// New streak record message
  ///
  /// In en, this message translates to:
  /// **'🏆 NEW RECORD! {days} days streak! You\'re unstoppable!'**
  String newStreakRecord(int days);

  /// Streak continues message
  ///
  /// In en, this message translates to:
  /// **'🔥 Streak continues! {days} days of love scanning!'**
  String streakContinues(int days);

  /// Love Analytics screen title
  ///
  /// In en, this message translates to:
  /// **'📊 Love Analytics'**
  String get loveAnalytics;

  /// Premium required dialog title
  ///
  /// In en, this message translates to:
  /// **'✨ Premium Required'**
  String get premiumRequired;

  /// Premium required dialog message
  ///
  /// In en, this message translates to:
  /// **'This theme is available only for Premium users. Unlock all themes and more features!'**
  String get premiumRequiredMessage;

  /// Analytics premium title
  ///
  /// In en, this message translates to:
  /// **'🔒 Analytics Premium'**
  String get analyticsPremium;

  /// Analytics premium description
  ///
  /// In en, this message translates to:
  /// **'Unlock deep insights about your love life with advanced analytics, predictions and compatibility patterns.'**
  String get unlockDeepInsights;

  /// Upgrade to premium button for analytics
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremiumAnalytics;

  /// Analyzing love life loading message
  ///
  /// In en, this message translates to:
  /// **'Analyzing your love life...'**
  String get analyzingLoveLife;

  /// Error loading analytics title
  ///
  /// In en, this message translates to:
  /// **'Error loading analytics'**
  String get errorLoadingAnalytics;

  /// Unknown error message for analytics
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownErrorAnalytics;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Statistics tab label
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTab;

  /// Insights tab label
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTab;

  /// Predictions tab label
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get predictionsTab;

  /// Total scans analytics label
  ///
  /// In en, this message translates to:
  /// **'Total Scans'**
  String get totalScansAnalytics;

  /// Average analytics label
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get averageAnalytics;

  /// Best match analytics label
  ///
  /// In en, this message translates to:
  /// **'Best Match'**
  String get bestMatch;

  /// Celebrities analytics label
  ///
  /// In en, this message translates to:
  /// **'Celebrities'**
  String get celebritiesAnalytics;

  /// Compatibility trend chart title
  ///
  /// In en, this message translates to:
  /// **'📈 Compatibility Trend (30 days)'**
  String get compatibilityTrend;

  /// Not enough data message for trends
  ///
  /// In en, this message translates to:
  /// **'Not enough data to show trends'**
  String get notEnoughDataTrends;

  /// Last 30 days label
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// Your best matches section title
  ///
  /// In en, this message translates to:
  /// **'🏆 Your Best Matches'**
  String get yourBestMatches;

  /// Celebrity label
  ///
  /// In en, this message translates to:
  /// **'Celebrity'**
  String get celebrity;

  /// Personal label
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// Advanced analytics feature title
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get advancedAnalytics;

  /// Advanced analytics feature description
  ///
  /// In en, this message translates to:
  /// **'Compatibility charts and statistics'**
  String get analyticsDescription;

  /// Cloud backup feature title
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup'**
  String get cloudBackup;

  /// Cloud backup feature description
  ///
  /// In en, this message translates to:
  /// **'Your data safe and synchronized'**
  String get cloudBackupDescription;

  /// Per month suffix
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get perYear;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get choosePlan;

  /// No description provided for @premiumPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumPlanTitle;

  /// No description provided for @premiumPlusPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Plus'**
  String get premiumPlusPlanTitle;

  /// No description provided for @premiumPlusDescription.
  ///
  /// In en, this message translates to:
  /// **'Everything in Premium + Unlimited 16-player tournaments, advanced analytics and exclusive Plus themes'**
  String get premiumPlusDescription;

  /// No description provided for @subscribeTo.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribeTo;

  /// No description provided for @selectedPlan.
  ///
  /// In en, this message translates to:
  /// **'Selected plan'**
  String get selectedPlan;

  /// Monthly price
  ///
  /// In en, this message translates to:
  /// **'\$2.99'**
  String get monthlyPrice;

  /// Premium subtitle
  ///
  /// In en, this message translates to:
  /// **'Unlock the full potential of love!'**
  String get unlockFullPotential;

  /// Purchases restored success message
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully'**
  String get purchasesRestoredSuccessfully;

  /// Default price fallback
  ///
  /// In en, this message translates to:
  /// **'\$2.99/month'**
  String get defaultPrice;

  /// Themes screen title
  ///
  /// In en, this message translates to:
  /// **'🎨 Premium Themes'**
  String get themesTitle;

  /// Themes screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Customize your experience'**
  String get customizeExperience;

  /// Current theme label
  ///
  /// In en, this message translates to:
  /// **'Current Theme'**
  String get currentTheme;

  /// Active theme status
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// Theme applied success message
  ///
  /// In en, this message translates to:
  /// **'Theme {themeName} applied'**
  String themeApplied(String themeName);

  /// Classic theme name
  ///
  /// In en, this message translates to:
  /// **'💘 Classic'**
  String get classicThemeName;

  /// Classic theme description
  ///
  /// In en, this message translates to:
  /// **'The original love theme'**
  String get classicThemeDescription;

  /// Sunset theme name
  ///
  /// In en, this message translates to:
  /// **'🌅 Sunset'**
  String get sunsetThemeName;

  /// Sunset theme description
  ///
  /// In en, this message translates to:
  /// **'Warm golden and orange tones'**
  String get sunsetThemeDescription;

  /// Ocean theme name
  ///
  /// In en, this message translates to:
  /// **'🌊 Ocean'**
  String get oceanThemeName;

  /// Ocean theme description
  ///
  /// In en, this message translates to:
  /// **'Deep marine blues'**
  String get oceanThemeDescription;

  /// Forest theme name
  ///
  /// In en, this message translates to:
  /// **'🌲 Forest'**
  String get forestThemeName;

  /// Forest theme description
  ///
  /// In en, this message translates to:
  /// **'Natural and fresh greens'**
  String get forestThemeDescription;

  /// Lavender theme name
  ///
  /// In en, this message translates to:
  /// **'💜 Lavender'**
  String get lavenderThemeName;

  /// Lavender theme description
  ///
  /// In en, this message translates to:
  /// **'Elegant purples and violets'**
  String get lavenderThemeDescription;

  /// Cosmic theme name
  ///
  /// In en, this message translates to:
  /// **'🌌 Cosmic'**
  String get cosmicThemeName;

  /// Cosmic theme description
  ///
  /// In en, this message translates to:
  /// **'Mysterious deep space'**
  String get cosmicThemeDescription;

  /// Cherry theme name
  ///
  /// In en, this message translates to:
  /// **'🌸 Cherry'**
  String get cherryThemeName;

  /// Cherry theme description
  ///
  /// In en, this message translates to:
  /// **'Elegant Japanese sakura pink'**
  String get cherryThemeDescription;

  /// Golden theme name
  ///
  /// In en, this message translates to:
  /// **'✨ Golden'**
  String get goldenThemeName;

  /// Golden theme description
  ///
  /// In en, this message translates to:
  /// **'Luxury and golden elegance'**
  String get goldenThemeDescription;

  /// Scans counter for today
  ///
  /// In en, this message translates to:
  /// **'Today\'s scans: {remaining}/{total}'**
  String scansToday(int remaining, int total);

  /// Remaining scans message
  ///
  /// In en, this message translates to:
  /// **'{count} free scans remaining'**
  String scansRemaining(int count);

  /// Premium benefits text
  ///
  /// In en, this message translates to:
  /// **'🚀 Unlimited scans • 🚫 No ads • ⭐ Exclusive content'**
  String get premiumBenefits;

  /// Trial period banner title
  ///
  /// In en, this message translates to:
  /// **'🎉 Trial Period!'**
  String get trialPeriod;

  /// Trial period remaining days message
  ///
  /// In en, this message translates to:
  /// **'UNLIMITED scans for {days} more days'**
  String unlimitedScansRemaining(int days);

  /// Premium Analytics title
  ///
  /// In en, this message translates to:
  /// **'Premium Analytics'**
  String get premiumAnalytics;

  /// Analytics subtitle
  ///
  /// In en, this message translates to:
  /// **'Analyze your compatibility patterns'**
  String get analyzeCompatibilityPatterns;

  /// Premium Themes title
  ///
  /// In en, this message translates to:
  /// **'Premium Themes'**
  String get premiumThemes;

  /// Themes subtitle
  ///
  /// In en, this message translates to:
  /// **'Customize with 8 unique themes'**
  String get customizeWithThemes;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @sectionAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get sectionAudio;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get sectionData;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @clearAllDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete statistics, history and streaks'**
  String get clearAllDataSubtitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Information about the application'**
  String get aboutSubtitle;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View our privacy policy'**
  String get privacySubtitle;

  /// No description provided for @privacyDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'🔒 Privacy Policy'**
  String get privacyDialogTitle;

  /// No description provided for @privacyDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is important to us.\n\n• Names are stored only locally\n• We don\'t share personal information\n• Results are generated randomly\n• You can delete your history anytime\n\nThis app is for entertainment only.'**
  String get privacyDialogContent;

  /// No description provided for @viewFullPolicy.
  ///
  /// In en, this message translates to:
  /// **'View full policy'**
  String get viewFullPolicy;

  /// No description provided for @confirmClearDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data?'**
  String get confirmClearDataTitle;

  /// No description provided for @confirmClearDataContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all your statistics, history, and streaks? This action cannot be undone.'**
  String get confirmClearDataContent;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @dataDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'All data has been successfully deleted'**
  String get dataDeletedSuccess;

  /// No description provided for @errorDeletingData.
  ///
  /// In en, this message translates to:
  /// **'Error deleting data: {error}'**
  String errorDeletingData(Object error);

  /// No description provided for @appVersionFooter.
  ///
  /// In en, this message translates to:
  /// **'Crush Scanner v1.0.0\nMade with 💕 for love'**
  String get appVersionFooter;

  /// No description provided for @welcomeNewUserTitle.
  ///
  /// In en, this message translates to:
  /// **'🎉 Welcome New User!'**
  String get welcomeNewUserTitle;

  /// No description provided for @enjoyUnlimitedTrialScans.
  ///
  /// In en, this message translates to:
  /// **'Enjoy unlimited scans during your trial!'**
  String get enjoyUnlimitedTrialScans;

  /// No description provided for @unlimitedScansActive.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Scans Active'**
  String get unlimitedScansActive;

  /// No description provided for @trialDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day remaining in trial} other{{count} days remaining in trial}}'**
  String trialDaysRemaining(int count);

  /// No description provided for @trialEndingToday.
  ///
  /// In en, this message translates to:
  /// **'Trial ending today'**
  String get trialEndingToday;

  /// No description provided for @upgradeToPremiumPromo.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremiumPromo;

  /// No description provided for @watchAdToUnlockInsights.
  ///
  /// In en, this message translates to:
  /// **'Watch ad to unlock'**
  String get watchAdToUnlockInsights;

  /// No description provided for @watchAdToUnlockPredictions.
  ///
  /// In en, this message translates to:
  /// **'Watch ad to unlock'**
  String get watchAdToUnlockPredictions;

  /// No description provided for @insightsLockedDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover unique patterns about your love life. Watch a short ad or go Premium for unlimited access.'**
  String get insightsLockedDescription;

  /// No description provided for @predictionsLockedDescription.
  ///
  /// In en, this message translates to:
  /// **'Get personalized predictions about your love future. Watch a short ad or go Premium for unlimited access.'**
  String get predictionsLockedDescription;

  /// No description provided for @adNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Ad not available right now'**
  String get adNotAvailable;

  /// No description provided for @orGetPremium.
  ///
  /// In en, this message translates to:
  /// **'or go Premium'**
  String get orGetPremium;

  /// No description provided for @insightsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'✨ Insights unlocked'**
  String get insightsUnlocked;

  /// No description provided for @predictionsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'✨ Predictions unlocked'**
  String get predictionsUnlocked;

  /// No description provided for @coinsClaimedMessage.
  ///
  /// In en, this message translates to:
  /// **'+{count} coins claimed.'**
  String coinsClaimedMessage(int count);

  /// No description provided for @scanPackBoughtMessage.
  ///
  /// In en, this message translates to:
  /// **'You got +{scans} scans for {cost} coins.'**
  String scanPackBoughtMessage(int scans, int cost);

  /// No description provided for @notEnoughCoinsCurrentPackMessage.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins. Current pack costs {cost}.'**
  String notEnoughCoinsCurrentPackMessage(int cost);

  /// No description provided for @notEnoughCoinsThisPackMessage.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins. This pack costs {cost}.'**
  String notEnoughCoinsThisPackMessage(int cost);

  /// No description provided for @dailyPackLimitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'Daily pack limit reached. Come back tomorrow.'**
  String get dailyPackLimitReachedMessage;

  /// No description provided for @dailyPackLimitReachedTryTomorrowMessage.
  ///
  /// In en, this message translates to:
  /// **'Daily pack limit reached. Try again tomorrow.'**
  String get dailyPackLimitReachedTryTomorrowMessage;

  /// No description provided for @premiumUnlimitedScansMessage.
  ///
  /// In en, this message translates to:
  /// **'Premium already has unlimited scans.'**
  String get premiumUnlimitedScansMessage;

  /// No description provided for @coinsEarnedMessage.
  ///
  /// In en, this message translates to:
  /// **'+{count} coins earned.'**
  String coinsEarnedMessage(int count);

  /// No description provided for @coinsWonMessage.
  ///
  /// In en, this message translates to:
  /// **'+{count} coins earned'**
  String coinsWonMessage(int count);

  /// No description provided for @noAdAvailableNowMessage.
  ///
  /// In en, this message translates to:
  /// **'No ad available now.'**
  String get noAdAvailableNowMessage;

  /// No description provided for @loadingRetentionRewards.
  ///
  /// In en, this message translates to:
  /// **'Loading retention rewards...'**
  String get loadingRetentionRewards;

  /// No description provided for @retentionPanelUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Retention panel unavailable. Tap to retry.'**
  String get retentionPanelUnavailable;

  /// No description provided for @dailyRetentionRewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily retention rewards'**
  String get dailyRetentionRewardsTitle;

  /// No description provided for @coinsLabel.
  ///
  /// In en, this message translates to:
  /// **'Coins: {count}'**
  String coinsLabel(int count);

  /// No description provided for @streakDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak: {days}d'**
  String streakDaysLabel(int days);

  /// No description provided for @premiumScannerEconomyNotice.
  ///
  /// In en, this message translates to:
  /// **'Premium active: unlimited scans, no ads, faster coin progression. Use coins for Tournament perks.'**
  String get premiumScannerEconomyNotice;

  /// No description provided for @scanPackButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'+{scans} scans ({cost}c) - {remaining} left'**
  String scanPackButtonLabel(int scans, int cost, int remaining);

  /// No description provided for @scanPackExhaustedToday.
  ///
  /// In en, this message translates to:
  /// **'Scan packs exhausted today'**
  String get scanPackExhaustedToday;

  /// No description provided for @adCoinsButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Ad +{count}c'**
  String adCoinsButtonLabel(int count);

  /// No description provided for @dailyMissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily missions'**
  String get dailyMissionsTitle;

  /// No description provided for @claimedLabel.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get claimedLabel;

  /// No description provided for @retentionRewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Retention rewards'**
  String get retentionRewardsTitle;

  /// No description provided for @youGotPlusTwoScansMessage.
  ///
  /// In en, this message translates to:
  /// **'You got +2 scans.'**
  String get youGotPlusTwoScansMessage;

  /// No description provided for @useCoinsLabel.
  ///
  /// In en, this message translates to:
  /// **'Use coins'**
  String get useCoinsLabel;

  /// No description provided for @plusTwoScansWithCoins.
  ///
  /// In en, this message translates to:
  /// **'+2 scans with coins'**
  String get plusTwoScansWithCoins;

  /// No description provided for @useCoinsPackPlusTwoScans.
  ///
  /// In en, this message translates to:
  /// **'Use coins (pack +2 scans)'**
  String get useCoinsPackPlusTwoScans;

  /// No description provided for @watchAdPlusTwoScans.
  ///
  /// In en, this message translates to:
  /// **'Watch ad (+2 scans)'**
  String get watchAdPlusTwoScans;

  /// No description provided for @tournamentFunnelTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'🎯 Tournament Funnel (Today)'**
  String get tournamentFunnelTodayTitle;

  /// No description provided for @funnelStartsLabel.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get funnelStartsLabel;

  /// No description provided for @funnelCompletionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Completions'**
  String get funnelCompletionsLabel;

  /// No description provided for @funnelCompletionRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get funnelCompletionRateLabel;

  /// No description provided for @funnelTicketAdsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket Ads'**
  String get funnelTicketAdsLabel;

  /// No description provided for @funnelReviveAdsLabel.
  ///
  /// In en, this message translates to:
  /// **'Revive Ads'**
  String get funnelReviveAdsLabel;

  /// No description provided for @funnelReviveCoinsLabel.
  ///
  /// In en, this message translates to:
  /// **'Revive Coins'**
  String get funnelReviveCoinsLabel;

  /// No description provided for @funnelShopBuysLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop Buys'**
  String get funnelShopBuysLabel;

  /// No description provided for @loveIntelligenceStudio.
  ///
  /// In en, this message translates to:
  /// **'Love Intelligence Studio'**
  String get loveIntelligenceStudio;

  /// No description provided for @tournament16UnlimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited 16-Player Tournaments'**
  String get tournament16UnlimitedTitle;

  /// No description provided for @tournament16UnlimitedDescription.
  ///
  /// In en, this message translates to:
  /// **'Play epic 16-player tournaments every day with no limits'**
  String get tournament16UnlimitedDescription;

  /// No description provided for @tournamentTitle.
  ///
  /// In en, this message translates to:
  /// **'🏆 Love Tournament'**
  String get tournamentTitle;

  /// No description provided for @tournamentWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pit your crushes against each other in an epic tournament!'**
  String get tournamentWelcomeSubtitle;

  /// No description provided for @tournamentDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your crushes\' names and discover who is your ultimate match in an elimination tournament'**
  String get tournamentDescription;

  /// No description provided for @tournamentYourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get tournamentYourName;

  /// No description provided for @tournamentYourNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name...'**
  String get tournamentYourNameHint;

  /// No description provided for @tournamentSelectFormat.
  ///
  /// In en, this message translates to:
  /// **'Tournament Format'**
  String get tournamentSelectFormat;

  /// No description provided for @tournamentParticipants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get tournamentParticipants;

  /// No description provided for @tournamentCrush.
  ///
  /// In en, this message translates to:
  /// **'Crush'**
  String get tournamentCrush;

  /// No description provided for @tournamentAddCelebrity.
  ///
  /// In en, this message translates to:
  /// **'⭐ Celebrity'**
  String get tournamentAddCelebrity;

  /// No description provided for @tournamentFillAll.
  ///
  /// In en, this message translates to:
  /// **'✨ Fill'**
  String get tournamentFillAll;

  /// No description provided for @tournamentStart.
  ///
  /// In en, this message translates to:
  /// **'Start Tournament!'**
  String get tournamentStart;

  /// No description provided for @tournamentEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get tournamentEnterYourName;

  /// No description provided for @tournamentFillAllNames.
  ///
  /// In en, this message translates to:
  /// **'You must fill in all names'**
  String get tournamentFillAllNames;

  /// No description provided for @tournamentNoDuplicates.
  ///
  /// In en, this message translates to:
  /// **'You can\'t have duplicate names'**
  String get tournamentNoDuplicates;

  /// No description provided for @tournament16PremiumOnly.
  ///
  /// In en, this message translates to:
  /// **'The 16-participant format is exclusive to Premium users. Upgrade to unlock epic tournaments!'**
  String get tournament16PremiumOnly;

  /// No description provided for @tournamentBracket.
  ///
  /// In en, this message translates to:
  /// **'Tournament Bracket'**
  String get tournamentBracket;

  /// No description provided for @tournamentMatchesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Matches played'**
  String get tournamentMatchesPlayed;

  /// No description provided for @tournamentNextMatch.
  ///
  /// In en, this message translates to:
  /// **'Next Match!'**
  String get tournamentNextMatch;

  /// No description provided for @tournamentExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Tournament?'**
  String get tournamentExitTitle;

  /// No description provided for @tournamentExitMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave? Your progress will be lost.'**
  String get tournamentExitMessage;

  /// No description provided for @tournamentExit.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get tournamentExit;

  /// No description provided for @tournamentReviveTitle.
  ///
  /// In en, this message translates to:
  /// **'💫 Revive Crush'**
  String get tournamentReviveTitle;

  /// No description provided for @tournamentReviveDescription.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad to give a second chance to an eliminated crush'**
  String get tournamentReviveDescription;

  /// No description provided for @tournamentRevived.
  ///
  /// In en, this message translates to:
  /// **'is back in the tournament!'**
  String get tournamentRevived;

  /// No description provided for @tournamentComplete.
  ///
  /// In en, this message translates to:
  /// **'Tournament Complete!'**
  String get tournamentComplete;

  /// No description provided for @tournamentResultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here are the results of your love tournament'**
  String get tournamentResultSubtitle;

  /// No description provided for @tournamentShare.
  ///
  /// In en, this message translates to:
  /// **'Share Results'**
  String get tournamentShare;

  /// No description provided for @tournamentPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get tournamentPlayAgain;

  /// No description provided for @tournamentSummary.
  ///
  /// In en, this message translates to:
  /// **'Tournament Summary'**
  String get tournamentSummary;

  /// No description provided for @tournamentTotalMatches.
  ///
  /// In en, this message translates to:
  /// **'Total matches'**
  String get tournamentTotalMatches;

  /// No description provided for @tournamentParticipantsCount.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get tournamentParticipantsCount;

  /// No description provided for @tournamentRoundsPlayed.
  ///
  /// In en, this message translates to:
  /// **'Rounds played'**
  String get tournamentRoundsPlayed;

  /// No description provided for @tournamentFinalMatch.
  ///
  /// In en, this message translates to:
  /// **'🏆 Final Match'**
  String get tournamentFinalMatch;

  /// No description provided for @duelTitle.
  ///
  /// In en, this message translates to:
  /// **'⚔️ Love Duel'**
  String get duelTitle;

  /// No description provided for @duelHeadline.
  ///
  /// In en, this message translates to:
  /// **'Who wins your heart?'**
  String get duelHeadline;

  /// No description provided for @duelDescription.
  ///
  /// In en, this message translates to:
  /// **'Pit two crushes against each other and discover who\'s more compatible with you across 4 love dimensions.'**
  String get duelDescription;

  /// No description provided for @duelHowToPlayTitle.
  ///
  /// In en, this message translates to:
  /// **'How does it work?'**
  String get duelHowToPlayTitle;

  /// No description provided for @duelStep1.
  ///
  /// In en, this message translates to:
  /// **'Enter your name and the names of two special people'**
  String get duelStep1;

  /// No description provided for @duelStep2.
  ///
  /// In en, this message translates to:
  /// **'Our algorithm analyzes compatibility across 4 dimensions'**
  String get duelStep2;

  /// No description provided for @duelStep3.
  ///
  /// In en, this message translates to:
  /// **'Watch the epic battle unfold round by round!'**
  String get duelStep3;

  /// No description provided for @duelDimExplainTitle.
  ///
  /// In en, this message translates to:
  /// **'The 4 Dimensions of Love'**
  String get duelDimExplainTitle;

  /// No description provided for @duelDimEmotionalDesc.
  ///
  /// In en, this message translates to:
  /// **'Emotional connection and sentimental depth'**
  String get duelDimEmotionalDesc;

  /// No description provided for @duelDimPassionDesc.
  ///
  /// In en, this message translates to:
  /// **'Chemistry, attraction and romantic energy'**
  String get duelDimPassionDesc;

  /// No description provided for @duelDimIntellectualDesc.
  ///
  /// In en, this message translates to:
  /// **'Mental affinity, humor and conversation'**
  String get duelDimIntellectualDesc;

  /// No description provided for @duelDimDestinyDesc.
  ///
  /// In en, this message translates to:
  /// **'Cosmic compatibility and fate alignment'**
  String get duelDimDestinyDesc;

  /// No description provided for @duelTiebreakerNote.
  ///
  /// In en, this message translates to:
  /// **'If it\'s a 2-2 tie, a sudden-death tiebreaker round activates!'**
  String get duelTiebreakerNote;

  /// No description provided for @duelFunFact.
  ///
  /// In en, this message translates to:
  /// **'Fun fact'**
  String get duelFunFact;

  /// No description provided for @duelFunFact1.
  ///
  /// In en, this message translates to:
  /// **'68% of duels end with a clear winner in the first 3 rounds'**
  String get duelFunFact1;

  /// No description provided for @duelFunFact2.
  ///
  /// In en, this message translates to:
  /// **'The Passion dimension is the most unpredictable of all'**
  String get duelFunFact2;

  /// No description provided for @duelFunFact3.
  ///
  /// In en, this message translates to:
  /// **'Only 12% of duels reach the final tiebreaker'**
  String get duelFunFact3;

  /// No description provided for @duelFunFact4.
  ///
  /// In en, this message translates to:
  /// **'Emotional connection is the most important dimension for long relationships'**
  String get duelFunFact4;

  /// No description provided for @duelFunFact5.
  ///
  /// In en, this message translates to:
  /// **'Names with more than 6 letters tend to have higher intellectual compatibility'**
  String get duelFunFact5;

  /// No description provided for @duelYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get duelYourName;

  /// No description provided for @duelCrushA.
  ///
  /// In en, this message translates to:
  /// **'Crush A\'s name'**
  String get duelCrushA;

  /// No description provided for @duelCrushB.
  ///
  /// In en, this message translates to:
  /// **'Crush B\'s name'**
  String get duelCrushB;

  /// No description provided for @duelStart.
  ///
  /// In en, this message translates to:
  /// **'Start Duel! ⚔️'**
  String get duelStart;

  /// No description provided for @duelLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing battle...'**
  String get duelLoading;

  /// No description provided for @duelSameNameError.
  ///
  /// In en, this message translates to:
  /// **'Crush names cannot be the same.'**
  String get duelSameNameError;

  /// No description provided for @duelGetReady.
  ///
  /// In en, this message translates to:
  /// **'Get Ready!'**
  String get duelGetReady;

  /// No description provided for @duelRound.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get duelRound;

  /// No description provided for @duelDimEmotional.
  ///
  /// In en, this message translates to:
  /// **'Emotional ❤️'**
  String get duelDimEmotional;

  /// No description provided for @duelDimPassion.
  ///
  /// In en, this message translates to:
  /// **'Passion 🔥'**
  String get duelDimPassion;

  /// No description provided for @duelDimIntellectual.
  ///
  /// In en, this message translates to:
  /// **'Intellectual 🧠'**
  String get duelDimIntellectual;

  /// No description provided for @duelDimDestiny.
  ///
  /// In en, this message translates to:
  /// **'Destiny ✨'**
  String get duelDimDestiny;

  /// No description provided for @duelShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get duelShare;

  /// No description provided for @duelPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get duelPlayAgain;

  /// No description provided for @duelHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get duelHome;

  /// No description provided for @duelWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pit your crushes in an epic duel'**
  String get duelWelcomeSubtitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
