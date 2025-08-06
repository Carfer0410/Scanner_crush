import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n/app_localizations.dart';
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
/// To configure the locales supported by your app, you'll need to edit this
/// file.
///
/// First, open your project's ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project's Runner folder.
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

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Crush Scanner 💘'**
  String get appTitle;

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

  /// History button
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Premium button
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// Your name input label
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
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

  /// Upgrade to premium title
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

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

  /// Unlimited scans feature
  ///
  /// In en, this message translates to:
  /// **'Unlimited Scans'**
  String get unlimitedScans;

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
  /// **'Save {percentage}%'**
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

  /// Total scans counter label
  ///
  /// In en, this message translates to:
  /// **'Total scans'**
  String get totalScans;

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

  /// Perfect compatibility message
  ///
  /// In en, this message translates to:
  /// **'Perfect Compatibility!'**
  String get perfectCompatibility;

  /// Great compatibility message
  ///
  /// In en, this message translates to:
  /// **'Great Compatibility!'**
  String get greatCompatibility;

  /// Good compatibility message
  ///
  /// In en, this message translates to:
  /// **'Good Compatibility'**
  String get goodCompatibility;

  /// Share button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;
  
  String get celebrityCrush;
  String get celebrityCrushTitle;
  String get celebrityCrushDescription;
  String get chooseMyCommit;
  String get celebrityMode;
  String get celebrityModeDescription;
  String get popularCelebrities;
  String get andManyMore;
  String helloCelebrity(String userName);
  String get chooseCelebrityDescription;
  String get searchCelebrity;
  String get errorGeneratingResult;
  
  String get noHistoryYet;
  String get noHistoryDescription;
  String get startScanning;
  String errorLoadingHistory(String error);
  String get agoTime;
  String get minutes;
  String get hours;
  String get days;
  String get clearHistory;
  String get confirmClearHistory;
  String get confirmClear;
  String get errorClearingHistory;
  String get errorSharingResult;
  
  String get goPremium;
  String get premiumSubtitle;
  String get noAdsTitle;
  String get noAdsDescription;
  String get unlimitedScansTitle;
  String get unlimitedScansDescription;
  String get exclusiveResultsTitle;
  String get exclusiveResultsDescription;
  String get crushHistoryTitle;
  String get crushHistoryDescription;
  String get specialThemesTitle;
  String get specialThemesDescription;
  String get premiumSupportTitle;
  String get premiumSupportDescription;
  String get purchasePremium;
  String get welcomeToPremium;
  String get premiumActivated;
  String get great;
  String get restorePurchasesButton;
  String get processing;
  String get noPreviousPurchases;
  
  String get magneticConnection;
  String get magneticConnectionMessage;
  String get magneticConnectionAdvice;
  String get dayOfRevelations;
  String get dayOfRevelationsMessage;
  String get dayOfRevelationsAdvice;
  String get romanceInTheAir;
  String get romanceInTheAirMessage;
  String get romanceInTheAirAdvice;
  String get destinyAligned;
  String get destinyAlignedMessage;
  String get destinyAlignedAdvice;
  String get butterfliesInStomach;
  String get butterfliesInStomachMessage;
  String get butterfliesInStomachAdvice;
  String get burningPassion;
  String get burningPassionMessage;
  String get burningPassionAdvice;
  String get authenticLove;
  String get authenticLoveMessage;
  String get authenticLoveAdvice;
  
  String personalizedTipStreak(int streak);
  String personalizedTipCompatibility(int compatibility);
  String personalizedTipScans(int scans);
  String get personalizedTipGoodCompatibility;
  String get personalizedTipEncouragement;
  
  String get fireStreak;
  String fireStreakDescription(int days);
  String get loveExplorer;
  String loveExplorerDescription(int scans);
  String get compatibilityMaster;
  String compatibilityMasterDescription(int average);
  String get romanceGuru;
  String get romanceGuruDescription;
  String get personalScannerTitle;
  String get personalCompatibilityTitle;
  String get resultTitle;
  String get thereIsPotential;
  String get shareButton;
  String get scanAgainButton;
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
