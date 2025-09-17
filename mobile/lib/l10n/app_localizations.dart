import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TraceOff — Clean Links'**
  String get appTitle;

  /// No description provided for @tabClean.
  ///
  /// In en, this message translates to:
  /// **'Clean Link'**
  String get tabClean;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @supportedPlatformsTitle.
  ///
  /// In en, this message translates to:
  /// **'Supported Platforms'**
  String get supportedPlatformsTitle;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'\'t show again'**
  String get dontShowAgain;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @inputHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a link to clean'**
  String get inputHint;

  /// No description provided for @clean.
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get clean;

  /// No description provided for @snackPastedAndCleaning.
  ///
  /// In en, this message translates to:
  /// **'Pasted URL from clipboard and cleaning...'**
  String get snackPastedAndCleaning;

  /// No description provided for @snackPasted.
  ///
  /// In en, this message translates to:
  /// **'Pasted URL from clipboard'**
  String get snackPasted;

  /// No description provided for @enterValidUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid http/https URL'**
  String get enterValidUrl;

  /// No description provided for @processingMode.
  ///
  /// In en, this message translates to:
  /// **'Processing Mode'**
  String get processingMode;

  /// No description provided for @pasteLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste Link to Clean'**
  String get pasteLinkTitle;

  /// No description provided for @inputHintHttp.
  ///
  /// In en, this message translates to:
  /// **'Paste a link to clean (http/https)'**
  String get inputHintHttp;

  /// No description provided for @actionPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get actionPaste;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @cleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning...'**
  String get cleaning;

  /// No description provided for @processLocally.
  ///
  /// In en, this message translates to:
  /// **'Process Locally'**
  String get processLocally;

  /// No description provided for @notCertainReviewAlternatives.
  ///
  /// In en, this message translates to:
  /// **'This result is not 100% certain. Please review the alternatives below.'**
  String get notCertainReviewAlternatives;

  /// No description provided for @hideSupportedTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide Supported Platforms'**
  String get hideSupportedTitle;

  /// No description provided for @hideSupportedQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to hide this panel temporarily or never show it again?'**
  String get hideSupportedQuestion;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cleanLinkReady.
  ///
  /// In en, this message translates to:
  /// **'Clean Link Ready'**
  String get cleanLinkReady;

  /// No description provided for @cleanLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Clean Link:'**
  String get cleanLinkLabel;

  /// No description provided for @tipLongPressToCopy.
  ///
  /// In en, this message translates to:
  /// **'Tip: Long-press any link to copy'**
  String get tipLongPressToCopy;

  /// No description provided for @copyCleanLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Clean Link'**
  String get copyCleanLink;

  /// No description provided for @tipTapOpenLongPressCopy.
  ///
  /// In en, this message translates to:
  /// **'Tip: Tap link to open, long-press to copy'**
  String get tipTapOpenLongPressCopy;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get shareLink;

  /// No description provided for @technicalDetails.
  ///
  /// In en, this message translates to:
  /// **'Technical Details'**
  String get technicalDetails;

  /// No description provided for @actionsTaken.
  ///
  /// In en, this message translates to:
  /// **'Actions taken:'**
  String get actionsTaken;

  /// No description provided for @domain.
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get domain;

  /// No description provided for @strategy.
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get strategy;

  /// No description provided for @processingTime.
  ///
  /// In en, this message translates to:
  /// **'Processing Time'**
  String get processingTime;

  /// No description provided for @appliedAt.
  ///
  /// In en, this message translates to:
  /// **'Applied At'**
  String get appliedAt;

  /// No description provided for @alternativeResults.
  ///
  /// In en, this message translates to:
  /// **'Alternative Results'**
  String get alternativeResults;

  /// No description provided for @alternative.
  ///
  /// In en, this message translates to:
  /// **'Alternative'**
  String get alternative;

  /// No description provided for @shareAltWarning.
  ///
  /// In en, this message translates to:
  /// **'Share (may still contain tracking parameters)'**
  String get shareAltWarning;

  /// No description provided for @shareAltWarningSnack.
  ///
  /// In en, this message translates to:
  /// **'Warning: Alternative may still contain trackers'**
  String get shareAltWarningSnack;

  /// No description provided for @tutorialProcessingModes.
  ///
  /// In en, this message translates to:
  /// **'Processing Modes'**
  String get tutorialProcessingModes;

  /// No description provided for @tutorialLocalProcessing.
  ///
  /// In en, this message translates to:
  /// **'Local Processing'**
  String get tutorialLocalProcessing;

  /// No description provided for @tutorialLocalDescription.
  ///
  /// In en, this message translates to:
  /// **'URL cleaning happens entirely on your device'**
  String get tutorialLocalDescription;

  /// No description provided for @tutorialLocalPros1.
  ///
  /// In en, this message translates to:
  /// **'Complete privacy - no data leaves your device'**
  String get tutorialLocalPros1;

  /// No description provided for @tutorialLocalPros2.
  ///
  /// In en, this message translates to:
  /// **'Works offline - no internet required'**
  String get tutorialLocalPros2;

  /// No description provided for @tutorialLocalPros3.
  ///
  /// In en, this message translates to:
  /// **'No server dependency - always available'**
  String get tutorialLocalPros3;

  /// No description provided for @tutorialLocalPros4.
  ///
  /// In en, this message translates to:
  /// **'Perfect for sensitive links you\'\'re sending'**
  String get tutorialLocalPros4;

  /// No description provided for @tutorialLocalCons1.
  ///
  /// In en, this message translates to:
  /// **'Less sophisticated cleaning algorithms'**
  String get tutorialLocalCons1;

  /// No description provided for @tutorialLocalCons2.
  ///
  /// In en, this message translates to:
  /// **'May miss some tracking parameters'**
  String get tutorialLocalCons2;

  /// No description provided for @tutorialLocalCons3.
  ///
  /// In en, this message translates to:
  /// **'Limited to basic redirect following'**
  String get tutorialLocalCons3;

  /// No description provided for @tutorialLocalCons4.
  ///
  /// In en, this message translates to:
  /// **'No server-side intelligence'**
  String get tutorialLocalCons4;

  /// No description provided for @tutorialLocalWhenToUse.
  ///
  /// In en, this message translates to:
  /// **'Use when you want maximum privacy and are sending links to others. Your IP address and the original URL never leave your device.'**
  String get tutorialLocalWhenToUse;

  /// No description provided for @tutorialRemoteProcessing.
  ///
  /// In en, this message translates to:
  /// **'Remote Processing'**
  String get tutorialRemoteProcessing;

  /// No description provided for @tutorialRemoteDescription.
  ///
  /// In en, this message translates to:
  /// **'URL cleaning happens on our secure servers'**
  String get tutorialRemoteDescription;

  /// No description provided for @tutorialRemotePros1.
  ///
  /// In en, this message translates to:
  /// **'Advanced cleaning algorithms'**
  String get tutorialRemotePros1;

  /// No description provided for @tutorialRemotePros2.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive tracking parameter detection'**
  String get tutorialRemotePros2;

  /// No description provided for @tutorialRemotePros3.
  ///
  /// In en, this message translates to:
  /// **'Server-side intelligence and updates'**
  String get tutorialRemotePros3;

  /// No description provided for @tutorialRemotePros4.
  ///
  /// In en, this message translates to:
  /// **'Better redirect following capabilities'**
  String get tutorialRemotePros4;

  /// No description provided for @tutorialRemotePros5.
  ///
  /// In en, this message translates to:
  /// **'Regular algorithm improvements'**
  String get tutorialRemotePros5;

  /// No description provided for @tutorialRemoteCons1.
  ///
  /// In en, this message translates to:
  /// **'Requires internet connection'**
  String get tutorialRemoteCons1;

  /// No description provided for @tutorialRemoteCons2.
  ///
  /// In en, this message translates to:
  /// **'URL is sent to our servers'**
  String get tutorialRemoteCons2;

  /// No description provided for @tutorialRemoteCons3.
  ///
  /// In en, this message translates to:
  /// **'Your IP address is visible to our servers'**
  String get tutorialRemoteCons3;

  /// No description provided for @tutorialRemoteCons4.
  ///
  /// In en, this message translates to:
  /// **'Depends on server availability'**
  String get tutorialRemoteCons4;

  /// No description provided for @tutorialRemoteWhenToUse.
  ///
  /// In en, this message translates to:
  /// **'Use when you want the best cleaning results and are processing links you received from others. Our servers can detect more tracking parameters than local processing.'**
  String get tutorialRemoteWhenToUse;

  /// No description provided for @tutorialSecurityPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get tutorialSecurityPrivacy;

  /// No description provided for @tutorialSec1.
  ///
  /// In en, this message translates to:
  /// **'We never store your URLs or personal data'**
  String get tutorialSec1;

  /// No description provided for @tutorialSec2.
  ///
  /// In en, this message translates to:
  /// **'All processing is done in real-time'**
  String get tutorialSec2;

  /// No description provided for @tutorialSec3.
  ///
  /// In en, this message translates to:
  /// **'No logs are kept of your cleaning requests'**
  String get tutorialSec3;

  /// No description provided for @tutorialSec4.
  ///
  /// In en, this message translates to:
  /// **'Our servers use industry-standard encryption'**
  String get tutorialSec4;

  /// No description provided for @tutorialSec5.
  ///
  /// In en, this message translates to:
  /// **'You can switch modes anytime without losing data'**
  String get tutorialSec5;

  /// No description provided for @tutorialRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Our Recommendations'**
  String get tutorialRecommendations;

  /// No description provided for @tutorialRec1.
  ///
  /// In en, this message translates to:
  /// **'For links you\'\'re sending: Use Local Processing'**
  String get tutorialRec1;

  /// No description provided for @tutorialRec2.
  ///
  /// In en, this message translates to:
  /// **'For links you received: Use Remote Processing'**
  String get tutorialRec2;

  /// No description provided for @tutorialRec3.
  ///
  /// In en, this message translates to:
  /// **'For best results: Use Remote Processing when possible'**
  String get tutorialRec3;

  /// No description provided for @tutorialRec4.
  ///
  /// In en, this message translates to:
  /// **'When in doubt: Start with Remote, switch to Local if needed'**
  String get tutorialRec4;

  /// No description provided for @tutorialAdvantages.
  ///
  /// In en, this message translates to:
  /// **'Advantages'**
  String get tutorialAdvantages;

  /// No description provided for @tutorialLimitations.
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get tutorialLimitations;

  /// No description provided for @tutorialWhenToUseLabel.
  ///
  /// In en, this message translates to:
  /// **'When to use:'**
  String get tutorialWhenToUseLabel;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search history...'**
  String get historySearchHint;

  /// No description provided for @historyShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get historyShowAll;

  /// No description provided for @historyShowFavoritesOnly.
  ///
  /// In en, this message translates to:
  /// **'Show Favorites Only'**
  String get historyShowFavoritesOnly;

  /// No description provided for @historyExport.
  ///
  /// In en, this message translates to:
  /// **'Export History'**
  String get historyExport;

  /// No description provided for @historyClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All History'**
  String get historyClearAll;

  /// No description provided for @historyNoFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorite items yet'**
  String get historyNoFavoritesYet;

  /// No description provided for @historyNoItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No history items yet'**
  String get historyNoItemsYet;

  /// No description provided for @historyFavoritesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any item to add it to favorites'**
  String get historyFavoritesHint;

  /// No description provided for @historyCleanSomeUrls.
  ///
  /// In en, this message translates to:
  /// **'Clean some URLs to see them here'**
  String get historyCleanSomeUrls;

  /// No description provided for @historyOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original:'**
  String get historyOriginal;

  /// No description provided for @historyCleaned.
  ///
  /// In en, this message translates to:
  /// **'Cleaned:'**
  String get historyCleaned;

  /// No description provided for @historyConfidence.
  ///
  /// In en, this message translates to:
  /// **'confidence'**
  String get historyConfidence;

  /// No description provided for @historyCopyOriginal.
  ///
  /// In en, this message translates to:
  /// **'Copy Original'**
  String get historyCopyOriginal;

  /// No description provided for @historyCopyCleaned.
  ///
  /// In en, this message translates to:
  /// **'Copy Cleaned'**
  String get historyCopyCleaned;

  /// No description provided for @historyShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get historyShare;

  /// No description provided for @historyOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get historyOpen;

  /// No description provided for @historyReclean.
  ///
  /// In en, this message translates to:
  /// **'Re-clean'**
  String get historyReclean;

  /// No description provided for @historyAddToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get historyAddToFavorites;

  /// No description provided for @historyRemoveFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get historyRemoveFromFavorites;

  /// No description provided for @historyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get historyDelete;

  /// No description provided for @historyDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get historyDeleteItem;

  /// No description provided for @historyDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this history item?'**
  String get historyDeleteConfirm;

  /// No description provided for @historyClearAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All History'**
  String get historyClearAllTitle;

  /// No description provided for @historyClearAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all history items? This action cannot be undone.'**
  String get historyClearAllConfirm;

  /// No description provided for @historyClearAllAction.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get historyClearAllAction;

  /// No description provided for @historyOriginalCopied.
  ///
  /// In en, this message translates to:
  /// **'Original URL copied to clipboard'**
  String get historyOriginalCopied;

  /// No description provided for @historyCleanedCopied.
  ///
  /// In en, this message translates to:
  /// **'Cleaned URL copied to clipboard'**
  String get historyCleanedCopied;

  /// No description provided for @historyExported.
  ///
  /// In en, this message translates to:
  /// **'History exported to clipboard'**
  String get historyExported;

  /// No description provided for @historyCouldNotLaunch.
  ///
  /// In en, this message translates to:
  /// **'Could not launch'**
  String get historyCouldNotLaunch;

  /// No description provided for @historyErrorLaunching.
  ///
  /// In en, this message translates to:
  /// **'Error launching URL:'**
  String get historyErrorLaunching;

  /// No description provided for @historyJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get historyJustNow;

  /// No description provided for @historyDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'d ago'**
  String get historyDaysAgo;

  /// No description provided for @historyHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'h ago'**
  String get historyHoursAgo;

  /// No description provided for @historyMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'m ago'**
  String get historyMinutesAgo;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsCleaningStrategies.
  ///
  /// In en, this message translates to:
  /// **'Cleaning Strategies'**
  String get settingsCleaningStrategies;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get settingsServer;

  /// No description provided for @settingsDataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get settingsDataManagement;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAutoCopyPrimary.
  ///
  /// In en, this message translates to:
  /// **'Auto-copy Primary Result'**
  String get settingsAutoCopyPrimary;

  /// No description provided for @settingsAutoCopyPrimaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically copy the primary cleaned link to clipboard'**
  String get settingsAutoCopyPrimaryDesc;

  /// No description provided for @settingsShowConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Show Confirmation'**
  String get settingsShowConfirmation;

  /// No description provided for @settingsShowConfirmationDesc.
  ///
  /// In en, this message translates to:
  /// **'Show confirmation dialogs for actions'**
  String get settingsShowConfirmationDesc;

  /// No description provided for @settingsShowCleanLinkPreviews.
  ///
  /// In en, this message translates to:
  /// **'Show Clean Link Previews'**
  String get settingsShowCleanLinkPreviews;

  /// No description provided for @settingsShowCleanLinkPreviewsDesc.
  ///
  /// In en, this message translates to:
  /// **'Render previews only for cleaned links (local only, can be disabled)'**
  String get settingsShowCleanLinkPreviewsDesc;

  /// No description provided for @settingsLocalProcessing.
  ///
  /// In en, this message translates to:
  /// **'Local Processing'**
  String get settingsLocalProcessing;

  /// No description provided for @settingsLocalProcessingDesc.
  ///
  /// In en, this message translates to:
  /// **'Process links locally on device instead of using cloud API. When enabled, all cleaning happens on your device for better privacy.'**
  String get settingsLocalProcessingDesc;

  /// No description provided for @settingsLocalProcessingWebDesc.
  ///
  /// In en, this message translates to:
  /// **'Not available on web. Use the mobile app for offline/local processing.'**
  String get settingsLocalProcessingWebDesc;

  /// No description provided for @settingsManageLocalStrategies.
  ///
  /// In en, this message translates to:
  /// **'Manage Local Strategies'**
  String get settingsManageLocalStrategies;

  /// No description provided for @settingsManageLocalStrategiesDesc.
  ///
  /// In en, this message translates to:
  /// **'Active: {strategyName}'**
  String settingsManageLocalStrategiesDesc(Object strategyName);

  /// No description provided for @settingsManageLocalStrategiesWebDesc.
  ///
  /// In en, this message translates to:
  /// **'Not available on web. Download the app to customize offline strategies.'**
  String get settingsManageLocalStrategiesWebDesc;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get settingsServerUrl;

  /// No description provided for @settingsServerUrlDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the URL of your TraceOff server'**
  String get settingsServerUrlDesc;

  /// No description provided for @settingsClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get settingsClearHistory;

  /// No description provided for @settingsClearHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove all history items'**
  String get settingsClearHistoryDesc;

  /// No description provided for @settingsExportHistory.
  ///
  /// In en, this message translates to:
  /// **'Export History'**
  String get settingsExportHistory;

  /// No description provided for @settingsExportHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Export history to clipboard'**
  String get settingsExportHistoryDesc;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Open Source'**
  String get settingsOpenSource;

  /// No description provided for @settingsOpenSourceDesc.
  ///
  /// In en, this message translates to:
  /// **'View source code on GitHub'**
  String get settingsOpenSourceDesc;

  /// No description provided for @settingsGitHubNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'GitHub link not implemented'**
  String get settingsGitHubNotImplemented;

  /// No description provided for @settingsResetToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsResetToDefaults;

  /// No description provided for @settingsResetToDefaultsDesc.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings to their default values'**
  String get settingsResetToDefaultsDesc;

  /// No description provided for @settingsSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsSystemDefault;

  /// No description provided for @settingsLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsLight;

  /// No description provided for @settingsDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsDark;

  /// No description provided for @settingsChooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get settingsChooseTheme;

  /// No description provided for @settingsChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get settingsChooseLanguage;

  /// No description provided for @settingsClearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get settingsClearHistoryTitle;

  /// No description provided for @settingsClearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all history items? This action cannot be undone.'**
  String get settingsClearHistoryConfirm;

  /// No description provided for @settingsHistoryCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get settingsHistoryCleared;

  /// No description provided for @settingsNoHistoryToExport.
  ///
  /// In en, this message translates to:
  /// **'No history items to export'**
  String get settingsNoHistoryToExport;

  /// No description provided for @settingsHistoryExported.
  ///
  /// In en, this message translates to:
  /// **'History exported to clipboard'**
  String get settingsHistoryExported;

  /// No description provided for @settingsResetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get settingsResetSettings;

  /// No description provided for @settingsResetSettingsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to their default values?'**
  String get settingsResetSettingsConfirm;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsReset;

  /// No description provided for @settingsSettingsResetToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsSettingsResetToDefaults;

  /// No description provided for @settingsLocalStrategiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Cleaning Strategies'**
  String get settingsLocalStrategiesTitle;

  /// No description provided for @settingsDefaultOfflineCleaner.
  ///
  /// In en, this message translates to:
  /// **'Default offline cleaner'**
  String get settingsDefaultOfflineCleaner;

  /// No description provided for @settingsDefaultOfflineCleanerDesc.
  ///
  /// In en, this message translates to:
  /// **'Use built-in offline cleaning strategy'**
  String get settingsDefaultOfflineCleanerDesc;

  /// No description provided for @settingsAddStrategy.
  ///
  /// In en, this message translates to:
  /// **'Add Strategy'**
  String get settingsAddStrategy;

  /// No description provided for @settingsNewStrategy.
  ///
  /// In en, this message translates to:
  /// **'New Strategy'**
  String get settingsNewStrategy;

  /// No description provided for @settingsEditStrategy.
  ///
  /// In en, this message translates to:
  /// **'Edit Strategy'**
  String get settingsEditStrategy;

  /// No description provided for @settingsStrategyName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsStrategyName;

  /// No description provided for @settingsSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get settingsSteps;

  /// No description provided for @settingsAddStep.
  ///
  /// In en, this message translates to:
  /// **'Add Step'**
  String get settingsAddStep;

  /// No description provided for @settingsRedirectStep.
  ///
  /// In en, this message translates to:
  /// **'Redirect step'**
  String get settingsRedirectStep;

  /// No description provided for @settingsTimes.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get settingsTimes;

  /// No description provided for @settingsRemoveQueryKeys.
  ///
  /// In en, this message translates to:
  /// **'Remove query keys'**
  String get settingsRemoveQueryKeys;

  /// No description provided for @settingsCommaSeparatedKeys.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated keys'**
  String get settingsCommaSeparatedKeys;

  /// No description provided for @settingsCommaSeparatedKeysHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. utm_source, utm_medium, fbclid'**
  String get settingsCommaSeparatedKeysHint;

  /// No description provided for @settingsRedirect.
  ///
  /// In en, this message translates to:
  /// **'Redirect (N times)'**
  String get settingsRedirect;

  /// No description provided for @settingsRemoveQuery.
  ///
  /// In en, this message translates to:
  /// **'Remove query keys'**
  String get settingsRemoveQuery;

  /// No description provided for @settingsStripFragment.
  ///
  /// In en, this message translates to:
  /// **'Strip fragment'**
  String get settingsStripFragment;

  /// No description provided for @settingsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get settingsClose;

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsSave;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsRedirectTimes.
  ///
  /// In en, this message translates to:
  /// **'Redirect {times} time(s)'**
  String settingsRedirectTimes(Object times);

  /// No description provided for @settingsRemoveNoQueryKeys.
  ///
  /// In en, this message translates to:
  /// **'Remove no query keys'**
  String get settingsRemoveNoQueryKeys;

  /// No description provided for @settingsRemoveKeys.
  ///
  /// In en, this message translates to:
  /// **'Remove keys: {keys}'**
  String settingsRemoveKeys(Object keys);

  /// No description provided for @settingsStripUrlFragment.
  ///
  /// In en, this message translates to:
  /// **'Strip URL fragment'**
  String get settingsStripUrlFragment;

  /// No description provided for @switchedToLocal.
  ///
  /// In en, this message translates to:
  /// **'Switched to local cleaning - using device processing'**
  String get switchedToLocal;

  /// No description provided for @local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get local;

  /// No description provided for @switchedToRemote.
  ///
  /// In en, this message translates to:
  /// **'Switched to remote cleaning - using cloud API'**
  String get switchedToRemote;

  /// No description provided for @remote.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get remote;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @urlCleanedCopiedAndShared.
  ///
  /// In en, this message translates to:
  /// **'URL cleaned: copied and shared'**
  String get urlCleanedCopiedAndShared;

  /// No description provided for @couldNotLaunch.
  ///
  /// In en, this message translates to:
  /// **'Could not launch'**
  String get couldNotLaunch;

  /// No description provided for @errorLaunchingUrl.
  ///
  /// In en, this message translates to:
  /// **'Error launching URL:'**
  String get errorLaunchingUrl;

  /// No description provided for @switchedToLocalProcessingAndCleaned.
  ///
  /// In en, this message translates to:
  /// **'Switched to local processing and cleaned URL'**
  String get switchedToLocalProcessingAndCleaned;

  /// No description provided for @whyCleanLinks.
  ///
  /// In en, this message translates to:
  /// **'Why clean links?'**
  String get whyCleanLinks;

  /// No description provided for @privacyNotes.
  ///
  /// In en, this message translates to:
  /// **'Privacy Notes'**
  String get privacyNotes;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @debugInfo.
  ///
  /// In en, this message translates to:
  /// **'Debug Info:'**
  String get debugInfo;

  /// No description provided for @originalInput.
  ///
  /// In en, this message translates to:
  /// **'Original Input'**
  String get originalInput;

  /// No description provided for @localRemote.
  ///
  /// In en, this message translates to:
  /// **'Local/Remote'**
  String get localRemote;

  /// No description provided for @supportedPlatformsAndWhatWeClean.
  ///
  /// In en, this message translates to:
  /// **'Supported Platforms & What We Clean'**
  String get supportedPlatformsAndWhatWeClean;

  /// No description provided for @whyCleanLinksDescription.
  ///
  /// In en, this message translates to:
  /// **'Why clean links? Short links and \"share\" links often carry identifiers that can profile you or expose secondary accounts. Examples: lnkd.in and pin.it can reveal what you opened; Instagram share links (like /share/...) include sender-derived codes (igshid, igsh, si) that can tie the link to you. We normalize to a direct, canonical URL — not just removing utm_* — to reduce fingerprinting and prompts like \"X shared a reel with you.\"'**
  String get whyCleanLinksDescription;

  /// No description provided for @privacyNotesDescription.
  ///
  /// In en, this message translates to:
  /// **'Privacy notes:\n• \"Share\" links can embed who shared to whom (e.g., Instagram /share, Reddit context, X s=20).\n• Shorteners (lnkd.in, pin.it) add interstitials that can log your click.\n• Platform params (igshid, fbclid, rdt, share_app_id) can link the action back to your account.\nWe promote direct, canonical URLs to minimize profiling and social prompts like \"X shared a reel with you.\"'**
  String get privacyNotesDescription;

  /// No description provided for @example.
  ///
  /// In en, this message translates to:
  /// **'e.g.,'**
  String get example;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @autoCopyPrimaryResult.
  ///
  /// In en, this message translates to:
  /// **'Auto-copy Primary Result'**
  String get autoCopyPrimaryResult;

  /// No description provided for @autoCopyPrimaryResultDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically copy the primary cleaned link to clipboard'**
  String get autoCopyPrimaryResultDesc;

  /// No description provided for @showConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Show Confirmation'**
  String get showConfirmation;

  /// No description provided for @showConfirmationDesc.
  ///
  /// In en, this message translates to:
  /// **'Show confirmation dialogs for actions'**
  String get showConfirmationDesc;

  /// No description provided for @showCleanLinkPreviews.
  ///
  /// In en, this message translates to:
  /// **'Show Clean Link Previews'**
  String get showCleanLinkPreviews;

  /// No description provided for @showCleanLinkPreviewsDesc.
  ///
  /// In en, this message translates to:
  /// **'Render previews only for cleaned links (local only, can be disabled)'**
  String get showCleanLinkPreviewsDesc;

  /// No description provided for @localProcessing.
  ///
  /// In en, this message translates to:
  /// **'Local Processing'**
  String get localProcessing;

  /// No description provided for @localProcessingDesc.
  ///
  /// In en, this message translates to:
  /// **'Process links locally on device instead of using cloud API. When enabled, all cleaning happens on your device for better privacy.'**
  String get localProcessingDesc;

  /// No description provided for @localProcessingWebDesc.
  ///
  /// In en, this message translates to:
  /// **'Not available on web. Use the mobile app for offline/local processing.'**
  String get localProcessingWebDesc;

  /// No description provided for @manageLocalStrategies.
  ///
  /// In en, this message translates to:
  /// **'Manage Local Strategies'**
  String get manageLocalStrategies;

  /// No description provided for @manageLocalStrategiesDesc.
  ///
  /// In en, this message translates to:
  /// **'Active: {strategyName}'**
  String manageLocalStrategiesDesc(Object strategyName);

  /// No description provided for @manageLocalStrategiesWebDesc.
  ///
  /// In en, this message translates to:
  /// **'Not available on web. Download the app to customize offline strategies.'**
  String get manageLocalStrategiesWebDesc;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @serverUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get serverUrl;

  /// No description provided for @serverUrlDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the URL of your TraceOff server'**
  String get serverUrlDesc;

  /// No description provided for @environment.
  ///
  /// In en, this message translates to:
  /// **'Environment:'**
  String get environment;

  /// No description provided for @baseUrl.
  ///
  /// In en, this message translates to:
  /// **'Base URL:'**
  String get baseUrl;

  /// No description provided for @apiUrl.
  ///
  /// In en, this message translates to:
  /// **'API URL:'**
  String get apiUrl;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @clearHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove all history items'**
  String get clearHistoryDesc;

  /// No description provided for @exportHistory.
  ///
  /// In en, this message translates to:
  /// **'Export History'**
  String get exportHistory;

  /// No description provided for @exportHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Export history to clipboard'**
  String get exportHistoryDesc;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @openSource.
  ///
  /// In en, this message translates to:
  /// **'Open Source'**
  String get openSource;

  /// No description provided for @openSourceDesc.
  ///
  /// In en, this message translates to:
  /// **'View source code on GitHub'**
  String get openSourceDesc;

  /// No description provided for @githubLinkNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'GitHub link not implemented'**
  String get githubLinkNotImplemented;

  /// No description provided for @privacyPolicyDesc.
  ///
  /// In en, this message translates to:
  /// **'How we handle your data'**
  String get privacyPolicyDesc;

  /// No description provided for @resetToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetToDefaults;

  /// No description provided for @resetToDefaultsDesc.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings to their default values'**
  String get resetToDefaultsDesc;

  /// No description provided for @localOfflineNotAvailableWeb.
  ///
  /// In en, this message translates to:
  /// **'Local offline processing is not available on web. Download the app to use local strategies.'**
  String get localOfflineNotAvailableWeb;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @clearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all history items? This action cannot be undone.'**
  String get clearHistoryConfirm;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @historyCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get historyCleared;

  /// No description provided for @noHistoryToExport.
  ///
  /// In en, this message translates to:
  /// **'No history items to export'**
  String get noHistoryToExport;

  /// No description provided for @localCleaningStrategies.
  ///
  /// In en, this message translates to:
  /// **'Local Cleaning Strategies'**
  String get localCleaningStrategies;

  /// No description provided for @defaultOfflineCleaner.
  ///
  /// In en, this message translates to:
  /// **'Default offline cleaner'**
  String get defaultOfflineCleaner;

  /// No description provided for @defaultOfflineCleanerDesc.
  ///
  /// In en, this message translates to:
  /// **'Use built-in offline cleaning strategy'**
  String get defaultOfflineCleanerDesc;

  /// No description provided for @addStrategy.
  ///
  /// In en, this message translates to:
  /// **'Add Strategy'**
  String get addStrategy;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @newStrategy.
  ///
  /// In en, this message translates to:
  /// **'New Strategy'**
  String get newStrategy;

  /// No description provided for @editStrategy.
  ///
  /// In en, this message translates to:
  /// **'Edit Strategy'**
  String get editStrategy;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @addStep.
  ///
  /// In en, this message translates to:
  /// **'Add Step'**
  String get addStep;

  /// No description provided for @redirect.
  ///
  /// In en, this message translates to:
  /// **'Redirect (N times)'**
  String get redirect;

  /// No description provided for @removeQuery.
  ///
  /// In en, this message translates to:
  /// **'Remove query keys'**
  String get removeQuery;

  /// No description provided for @stripFragment.
  ///
  /// In en, this message translates to:
  /// **'Strip fragment'**
  String get stripFragment;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @redirectStep.
  ///
  /// In en, this message translates to:
  /// **'Redirect step'**
  String get redirectStep;

  /// No description provided for @removeQueryKeys.
  ///
  /// In en, this message translates to:
  /// **'Remove query keys'**
  String get removeQueryKeys;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// No description provided for @resetSettingsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to their default values?'**
  String get resetSettingsConfirm;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'pt',
        'ru',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
