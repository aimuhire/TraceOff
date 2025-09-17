// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'TraceOff — Saubere Links';

  @override
  String get tabClean => 'Link Bereinigen';

  @override
  String get tabHistory => 'Verlauf';

  @override
  String get tabSettings => 'Einstellungen';

  @override
  String get supportedPlatformsTitle => 'Unterstützte Plattformen';

  @override
  String get hide => 'Ausblenden';

  @override
  String get dontShowAgain => 'Nicht mehr anzeigen';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get settings => 'Einstellungen';

  @override
  String get history => 'Verlauf';

  @override
  String get inputHint => 'Fügen Sie einen Link zum Bereinigen ein';

  @override
  String get clean => 'Bereinigen';

  @override
  String get snackPastedAndCleaning =>
      'URL aus Zwischenablage eingefügt und bereinige...';

  @override
  String get snackPasted => 'URL aus Zwischenablage eingefügt';

  @override
  String get enterValidUrl => 'Bitte geben Sie eine gültige http/https URL ein';

  @override
  String get processingMode => 'Verarbeitungsmodus';

  @override
  String get pasteLinkTitle => 'Link zum Bereinigen Einfügen';

  @override
  String get inputHintHttp =>
      'Fügen Sie einen Link zum Bereinigen ein (http/https)';

  @override
  String get actionPaste => 'Einfügen';

  @override
  String get actionClear => 'Löschen';

  @override
  String get cleaning => 'Bereinige...';

  @override
  String get processLocally => 'Lokal Verarbeiten';

  @override
  String get notCertainReviewAlternatives =>
      'Dieses Ergebnis ist nicht 100% sicher. Bitte überprüfen Sie die Alternativen unten.';

  @override
  String get hideSupportedTitle => 'Unterstützte Plattformen Ausblenden';

  @override
  String get hideSupportedQuestion =>
      'Möchten Sie dieses Panel temporär ausblenden oder nie wieder anzeigen?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get cleanLinkReady => 'Sauberer Link Bereit';

  @override
  String get cleanLinkLabel => 'Sauberer Link:';

  @override
  String get tipLongPressToCopy =>
      'Tipp: Halten Sie jeden Link gedrückt, um ihn zu kopieren';

  @override
  String get copyCleanLink => 'Sauberen Link Kopieren';

  @override
  String get tipTapOpenLongPressCopy =>
      'Tipp: Tippen Sie auf den Link zum Öffnen, halten Sie gedrückt zum Kopieren';

  @override
  String get shareLink => 'Link Teilen';

  @override
  String get technicalDetails => 'Technische Details';

  @override
  String get actionsTaken => 'Durchgeführte Aktionen:';

  @override
  String get domain => 'Domain';

  @override
  String get strategy => 'Strategie';

  @override
  String get processingTime => 'Verarbeitungszeit';

  @override
  String get appliedAt => 'Angewendet um';

  @override
  String get alternativeResults => 'Alternative Ergebnisse';

  @override
  String get alternative => 'Alternative';

  @override
  String get shareAltWarning =>
      'Teilen (kann noch Tracking-Parameter enthalten)';

  @override
  String get shareAltWarningSnack =>
      'Warnung: Alternative kann noch Tracker enthalten';

  @override
  String get tutorialProcessingModes => 'Verarbeitungsmodi';

  @override
  String get tutorialLocalProcessing => 'Lokale Verarbeitung';

  @override
  String get tutorialLocalDescription =>
      'URL-Bereinigung erfolgt vollständig auf Ihrem Gerät';

  @override
  String get tutorialLocalPros1 =>
      'Vollständige Privatsphäre - keine Daten verlassen Ihr Gerät';

  @override
  String get tutorialLocalPros2 =>
      'Funktioniert offline - kein Internet erforderlich';

  @override
  String get tutorialLocalPros3 =>
      'Keine Server-Abhängigkeit - immer verfügbar';

  @override
  String get tutorialLocalPros4 => 'Perfekt für sensible Links, die Sie senden';

  @override
  String get tutorialLocalCons1 =>
      'Weniger ausgeklügelte Bereinigungsalgorithmen';

  @override
  String get tutorialLocalCons2 => 'Kann einige Tracking-Parameter verpassen';

  @override
  String get tutorialLocalCons3 =>
      'Begrenzt auf grundlegende Weiterleitungsverfolgung';

  @override
  String get tutorialLocalCons4 => 'Keine Server-seitige Intelligenz';

  @override
  String get tutorialLocalWhenToUse =>
      'Verwenden Sie, wenn Sie maximale Privatsphäre wollen und Links an andere senden. Ihre IP-Adresse und die ursprüngliche URL verlassen nie Ihr Gerät.';

  @override
  String get tutorialRemoteProcessing => 'Remote-Verarbeitung';

  @override
  String get tutorialRemoteDescription =>
      'URL-Bereinigung erfolgt auf unseren sicheren Servern';

  @override
  String get tutorialRemotePros1 => 'Erweiterte Bereinigungsalgorithmen';

  @override
  String get tutorialRemotePros2 => 'Umfassende Tracking-Parameter-Erkennung';

  @override
  String get tutorialRemotePros3 => 'Server-seitige Intelligenz und Updates';

  @override
  String get tutorialRemotePros4 => 'Bessere Weiterleitungsverfolgung';

  @override
  String get tutorialRemotePros5 => 'Regelmäßige Algorithmus-Verbesserungen';

  @override
  String get tutorialRemoteCons1 => 'Erfordert Internetverbindung';

  @override
  String get tutorialRemoteCons2 => 'URL wird an unsere Server gesendet';

  @override
  String get tutorialRemoteCons3 =>
      'Ihre IP-Adresse ist für unsere Server sichtbar';

  @override
  String get tutorialRemoteCons4 => 'Hängt von der Server-Verfügbarkeit ab';

  @override
  String get tutorialRemoteWhenToUse =>
      'Verwenden Sie, wenn Sie die besten Bereinigungsergebnisse wollen und Links verarbeiten, die Sie von anderen erhalten haben. Unsere Server können mehr Tracking-Parameter erkennen als die lokale Verarbeitung.';

  @override
  String get tutorialSecurityPrivacy => 'Sicherheit & Privatsphäre';

  @override
  String get tutorialSec1 =>
      'Wir speichern niemals Ihre URLs oder persönlichen Daten';

  @override
  String get tutorialSec2 => 'Alle Verarbeitung erfolgt in Echtzeit';

  @override
  String get tutorialSec3 =>
      'Es werden keine Protokolle Ihrer Bereinigungsanfragen geführt';

  @override
  String get tutorialSec4 =>
      'Unsere Server verwenden branchenübliche Verschlüsselung';

  @override
  String get tutorialSec5 =>
      'Sie können Modi jederzeit wechseln, ohne Daten zu verlieren';

  @override
  String get tutorialRecommendations => 'Unsere Empfehlungen';

  @override
  String get tutorialRec1 =>
      'Für Links, die Sie senden: Verwenden Sie lokale Verarbeitung';

  @override
  String get tutorialRec2 =>
      'Für Links, die Sie erhalten haben: Verwenden Sie Remote-Verarbeitung';

  @override
  String get tutorialRec3 =>
      'Für beste Ergebnisse: Verwenden Sie Remote-Verarbeitung wenn möglich';

  @override
  String get tutorialRec4 =>
      'Im Zweifel: Beginnen Sie mit Remote, wechseln Sie zu lokal wenn nötig';

  @override
  String get tutorialAdvantages => 'Vorteile';

  @override
  String get tutorialLimitations => 'Einschränkungen';

  @override
  String get tutorialWhenToUseLabel => 'Wann verwenden:';

  @override
  String get historyTitle => 'Verlauf';

  @override
  String get historySearchHint => 'Verlauf durchsuchen...';

  @override
  String get historyShowAll => 'Alle Anzeigen';

  @override
  String get historyShowFavoritesOnly => 'Nur Favoriten Anzeigen';

  @override
  String get historyExport => 'Verlauf Exportieren';

  @override
  String get historyClearAll => 'Gesamten Verlauf Löschen';

  @override
  String get historyNoFavoritesYet => 'Noch keine Favoriten';

  @override
  String get historyNoItemsYet => 'Noch keine Verlaufselemente';

  @override
  String get historyFavoritesHint =>
      'Tippen Sie auf das Herz-Symbol bei jedem Element, um es zu Favoriten hinzuzufügen';

  @override
  String get historyCleanSomeUrls =>
      'Bereinigen Sie einige URLs, um sie hier zu sehen';

  @override
  String get historyOriginal => 'Original:';

  @override
  String get historyCleaned => 'Bereinigt:';

  @override
  String get historyConfidence => 'Vertrauen';

  @override
  String get historyCopyOriginal => 'Original Kopieren';

  @override
  String get historyCopyCleaned => 'Bereinigt Kopieren';

  @override
  String get historyShare => 'Teilen';

  @override
  String get historyOpen => 'Öffnen';

  @override
  String get historyReclean => 'Neu Bereinigen';

  @override
  String get historyAddToFavorites => 'Zu Favoriten Hinzufügen';

  @override
  String get historyRemoveFromFavorites => 'Aus Favoriten Entfernen';

  @override
  String get historyDelete => 'Löschen';

  @override
  String get historyDeleteItem => 'Element Löschen';

  @override
  String get historyDeleteConfirm =>
      'Sind Sie sicher, dass Sie dieses Verlaufselement löschen möchten?';

  @override
  String get historyClearAllTitle => 'Gesamten Verlauf Löschen';

  @override
  String get historyClearAllConfirm =>
      'Sind Sie sicher, dass Sie alle Verlaufselemente löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get historyClearAllAction => 'Alles Löschen';

  @override
  String get historyOriginalCopied => 'Originale URL in Zwischenablage kopiert';

  @override
  String get historyCleanedCopied => 'Bereinigte URL in Zwischenablage kopiert';

  @override
  String get historyExported => 'Verlauf in die Zwischenablage exportiert';

  @override
  String get historyCouldNotLaunch => 'Konnte nicht öffnen';

  @override
  String get historyErrorLaunching => 'Fehler beim Öffnen der URL:';

  @override
  String get historyJustNow => 'Gerade eben';

  @override
  String get historyDaysAgo => 'T vor';

  @override
  String get historyHoursAgo => 'Std vor';

  @override
  String get historyMinutesAgo => 'Min vor';

  @override
  String get settingsGeneral => 'Allgemein';

  @override
  String get settingsCleaningStrategies => 'Bereinigungsstrategien';

  @override
  String get settingsAppearance => 'Erscheinungsbild';

  @override
  String get settingsServer => 'Server';

  @override
  String get settingsDataManagement => 'Datenverwaltung';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsAutoCopyPrimary => 'Primäres Ergebnis Auto-Kopieren';

  @override
  String get settingsAutoCopyPrimaryDesc =>
      'Primären bereinigten Link automatisch in Zwischenablage kopieren';

  @override
  String get settingsShowConfirmation => 'Bestätigung Anzeigen';

  @override
  String get settingsShowConfirmationDesc =>
      'Bestätigungsdialoge für Aktionen anzeigen';

  @override
  String get settingsShowCleanLinkPreviews =>
      'Saubere Link-Vorschauen Anzeigen';

  @override
  String get settingsShowCleanLinkPreviewsDesc =>
      'Vorschauen nur für bereinigte Links rendern (nur lokal, kann deaktiviert werden)';

  @override
  String get settingsLocalProcessing => 'Lokale Verarbeitung';

  @override
  String get settingsLocalProcessingDesc =>
      'Links lokal auf dem Gerät verarbeiten anstatt Cloud-API zu verwenden. Wenn aktiviert, erfolgt die gesamte Bereinigung auf Ihrem Gerät für bessere Privatsphäre.';

  @override
  String get settingsLocalProcessingWebDesc =>
      'Nicht verfügbar im Web. Verwenden Sie die mobile App für Offline-/lokale Verarbeitung.';

  @override
  String get settingsManageLocalStrategies => 'Lokale Strategien Verwalten';

  @override
  String settingsManageLocalStrategiesDesc(Object strategyName) {
    return 'Aktiv: $strategyName';
  }

  @override
  String get settingsManageLocalStrategiesWebDesc =>
      'Nicht verfügbar im Web. Laden Sie die App herunter, um Offline-Strategien anzupassen.';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsServerUrl => 'Server-URL';

  @override
  String get settingsServerUrlDesc =>
      'Geben Sie die URL Ihres TraceOff-Servers ein';

  @override
  String get settingsClearHistory => 'Verlauf Löschen';

  @override
  String get settingsClearHistoryDesc => 'Alle Verlaufselemente entfernen';

  @override
  String get settingsExportHistory => 'Verlauf Exportieren';

  @override
  String get settingsExportHistoryDesc =>
      'Verlauf in Zwischenablage exportieren';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsOpenSource => 'Open Source';

  @override
  String get settingsOpenSourceDesc => 'Quellcode auf GitHub anzeigen';

  @override
  String get settingsGitHubNotImplemented => 'GitHub-Link nicht implementiert';

  @override
  String get settingsResetToDefaults =>
      'Einstellungen auf Standardwerte zurückgesetzt';

  @override
  String get settingsResetToDefaultsDesc =>
      'Alle Einstellungen auf ihre Standardwerte zurücksetzen';

  @override
  String get settingsSystemDefault => 'System-Standard';

  @override
  String get settingsLight => 'Hell';

  @override
  String get settingsDark => 'Dunkel';

  @override
  String get settingsChooseTheme => 'Design Wählen';

  @override
  String get settingsChooseLanguage => 'Sprache Wählen';

  @override
  String get settingsClearHistoryTitle => 'Verlauf Löschen';

  @override
  String get settingsClearHistoryConfirm =>
      'Sind Sie sicher, dass Sie alle Verlaufselemente löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get settingsHistoryCleared => 'Verlauf gelöscht';

  @override
  String get settingsNoHistoryToExport =>
      'Keine Verlaufselemente zum Exportieren';

  @override
  String get settingsHistoryExported => 'Verlauf in Zwischenablage exportiert';

  @override
  String get settingsResetSettings => 'Einstellungen Zurücksetzen';

  @override
  String get settingsResetSettingsConfirm =>
      'Sind Sie sicher, dass Sie alle Einstellungen auf ihre Standardwerte zurücksetzen möchten?';

  @override
  String get settingsReset => 'Zurücksetzen';

  @override
  String get settingsSettingsResetToDefaults =>
      'Einstellungen auf Standard zurückgesetzt';

  @override
  String get settingsLocalStrategiesTitle => 'Lokale Bereinigungsstrategien';

  @override
  String get settingsDefaultOfflineCleaner => 'Standard-Offline-Bereiniger';

  @override
  String get settingsDefaultOfflineCleanerDesc =>
      'Integrierte Offline-Bereinigungsstrategie verwenden';

  @override
  String get settingsAddStrategy => 'Strategie Hinzufügen';

  @override
  String get settingsNewStrategy => 'Neue Strategie';

  @override
  String get settingsEditStrategy => 'Strategie Bearbeiten';

  @override
  String get settingsStrategyName => 'Name';

  @override
  String get settingsSteps => 'Schritte';

  @override
  String get settingsAddStep => 'Schritt Hinzufügen';

  @override
  String get settingsRedirectStep => 'Weiterleitungsschritt';

  @override
  String get settingsTimes => 'Mal';

  @override
  String get settingsRemoveQueryKeys => 'Abfrage-Schlüssel Entfernen';

  @override
  String get settingsCommaSeparatedKeys => 'Durch Kommas Getrennte Schlüssel';

  @override
  String get settingsCommaSeparatedKeysHint =>
      'z.B. utm_source, utm_medium, fbclid';

  @override
  String get settingsRedirect => 'Weiterleiten (N mal)';

  @override
  String get settingsRemoveQuery => 'Abfrage-Schlüssel Entfernen';

  @override
  String get settingsStripFragment => 'Fragment Entfernen';

  @override
  String get settingsClose => 'Schließen';

  @override
  String get settingsSave => 'Speichern';

  @override
  String get settingsCancel => 'Abbrechen';

  @override
  String settingsRedirectTimes(Object times) {
    return '$times mal weiterleiten';
  }

  @override
  String get settingsRemoveNoQueryKeys => 'Keine Abfrage-Schlüssel Entfernen';

  @override
  String settingsRemoveKeys(Object keys) {
    return 'Schlüssel Entfernen: $keys';
  }

  @override
  String get settingsStripUrlFragment => 'URL-Fragment Entfernen';

  @override
  String get switchedToLocal =>
      'Auf lokale Bereinigung umgestellt - Geräteverarbeitung verwenden';

  @override
  String get local => 'Lokal';

  @override
  String get switchedToRemote =>
      'Auf Remote-Bereinigung umgestellt - Cloud-API verwenden';

  @override
  String get remote => 'Remote';

  @override
  String get copiedToClipboard => 'In Zwischenablage kopiert';

  @override
  String get urlCleanedCopiedAndShared => 'URL bereinigt: kopiert und geteilt';

  @override
  String get couldNotLaunch => 'Konnte nicht starten';

  @override
  String get errorLaunchingUrl => 'Fehler beim Starten der URL:';

  @override
  String get switchedToLocalProcessingAndCleaned =>
      'Auf lokale Verarbeitung umgestellt und URL bereinigt';

  @override
  String get whyCleanLinks => 'Warum Links bereinigen?';

  @override
  String get privacyNotes => 'Datenschutzhinweise';

  @override
  String get chooseTheme => 'Thema Wählen';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get system => 'System';

  @override
  String get debugInfo => 'Debug-Informationen:';

  @override
  String get originalInput => 'Ursprüngliche Eingabe';

  @override
  String get localRemote => 'Lokal/Remote';

  @override
  String get supportedPlatformsAndWhatWeClean =>
      'Unterstützte Plattformen und Was Wir Bereinigen';

  @override
  String get whyCleanLinksDescription =>
      'Warum Links bereinigen? Kurze Links und \"Teilen\"-Links tragen oft Identifikatoren, die Sie profilieren oder sekundäre Konten preisgeben können. Beispiele: lnkd.in und pin.it können offenbaren, was Sie geöffnet haben; Instagram-Teil-Links (wie /share/...) enthalten absenderbasierte Codes (igshid, igsh, si), die den Link mit Ihnen verknüpfen können. Wir normalisieren zu einer direkten, kanonischen URL — nicht nur das Entfernen von utm_* — um Fingerprinting und Aufforderungen wie \"X hat einen Reel mit Ihnen geteilt\" zu reduzieren.';

  @override
  String get privacyNotesDescription =>
      'Datenschutzhinweise:\n• \"Teilen\"-Links können einbetten, wer mit wem geteilt hat (z.B. Instagram /share, Reddit-Kontext, X s=20).\n• URL-Verkürzer (lnkd.in, pin.it) fügen Interstitials hinzu, die Ihren Klick protokollieren können.\n• Plattform-Parameter (igshid, fbclid, rdt, share_app_id) können die Aktion mit Ihrem Konto verknüpfen.\nWir fördern direkte, kanonische URLs, um Profiling und soziale Aufforderungen wie \"X hat einen Reel mit Ihnen geteilt\" zu minimieren.';

  @override
  String get example => 'z.B.';

  @override
  String get general => 'Allgemein';

  @override
  String get autoCopyPrimaryResult => 'Primäres Ergebnis Auto-kopieren';

  @override
  String get autoCopyPrimaryResultDesc =>
      'Primären bereinigten Link automatisch in die Zwischenablage kopieren';

  @override
  String get showConfirmation => 'Bestätigung Anzeigen';

  @override
  String get showConfirmationDesc =>
      'Bestätigungsdialoge für Aktionen anzeigen';

  @override
  String get showCleanLinkPreviews => 'Saubere Link-Vorschauen Anzeigen';

  @override
  String get showCleanLinkPreviewsDesc =>
      'Vorschauen nur für bereinigte Links rendern (nur lokal, kann deaktiviert werden)';

  @override
  String get localProcessing => 'Lokale Verarbeitung';

  @override
  String get localProcessingDesc =>
      'Links lokal auf dem Gerät verarbeiten anstatt Cloud-API zu verwenden. Wenn aktiviert, erfolgt die gesamte Bereinigung auf Ihrem Gerät für bessere Privatsphäre.';

  @override
  String get localProcessingWebDesc =>
      'Nicht verfügbar im Web. Verwenden Sie die mobile App für Offline/Lokale Verarbeitung.';

  @override
  String get manageLocalStrategies => 'Lokale Strategien Verwalten';

  @override
  String manageLocalStrategiesDesc(Object strategyName) {
    return 'Aktiv: $strategyName';
  }

  @override
  String get manageLocalStrategiesWebDesc =>
      'Nicht verfügbar im Web. Laden Sie die App herunter, um Offline-Strategien anzupassen.';

  @override
  String get theme => 'Thema';

  @override
  String get language => 'Sprache';

  @override
  String get serverUrl => 'Server-URL';

  @override
  String get serverUrlDesc => 'Geben Sie die URL Ihres TraceOff-Servers ein';

  @override
  String get environment => 'Umgebung:';

  @override
  String get baseUrl => 'Basis-URL:';

  @override
  String get apiUrl => 'API-URL:';

  @override
  String get clearHistory => 'Verlauf Löschen';

  @override
  String get clearHistoryDesc => 'Alle Verlaufselemente entfernen';

  @override
  String get exportHistory => 'Verlauf Exportieren';

  @override
  String get exportHistoryDesc => 'Verlauf in die Zwischenablage exportieren';

  @override
  String get version => 'Version';

  @override
  String get openSource => 'Open Source';

  @override
  String get openSourceDesc => 'Quellcode auf GitHub anzeigen';

  @override
  String get githubLinkNotImplemented => 'GitHub-Link nicht implementiert';

  @override
  String get privacyPolicyDesc => 'Wie wir Ihre Daten behandeln';

  @override
  String get resetToDefaults => 'Auf Standardwerte Zurücksetzen';

  @override
  String get resetToDefaultsDesc =>
      'Alle Einstellungen auf ihre Standardwerte zurücksetzen';

  @override
  String get localOfflineNotAvailableWeb =>
      'Lokale Offline-Verarbeitung ist im Web nicht verfügbar. Laden Sie die App herunter, um lokale Strategien zu verwenden.';

  @override
  String get chooseLanguage => 'Sprache Wählen';

  @override
  String get clearHistoryTitle => 'Verlauf Löschen';

  @override
  String get clearHistoryConfirm =>
      'Sind Sie sicher, dass Sie alle Verlaufselemente löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get clear => 'Löschen';

  @override
  String get historyCleared => 'Verlauf gelöscht';

  @override
  String get noHistoryToExport => 'Keine Verlaufselemente zum Exportieren';

  @override
  String get localCleaningStrategies => 'Lokale Bereinigungsstrategien';

  @override
  String get defaultOfflineCleaner => 'Standard-Offline-Bereiniger';

  @override
  String get defaultOfflineCleanerDesc =>
      'Integrierte Offline-Bereinigungsstrategie verwenden';

  @override
  String get addStrategy => 'Strategie Hinzufügen';

  @override
  String get close => 'Schließen';

  @override
  String get newStrategy => 'Neue Strategie';

  @override
  String get editStrategy => 'Strategie Bearbeiten';

  @override
  String get steps => 'Schritte';

  @override
  String get addStep => 'Schritt Hinzufügen';

  @override
  String get redirect => 'Weiterleiten (N mal)';

  @override
  String get removeQuery => 'Abfrage-Schlüssel Entfernen';

  @override
  String get stripFragment => 'Fragment Entfernen';

  @override
  String get save => 'Speichern';

  @override
  String get redirectStep => 'Weiterleitungsschritt';

  @override
  String get removeQueryKeys => 'Abfrage-Schlüssel Entfernen';

  @override
  String get resetSettings => 'Einstellungen Zurücksetzen';

  @override
  String get resetSettingsConfirm =>
      'Sind Sie sicher, dass Sie alle Einstellungen auf ihre Standardwerte zurücksetzen möchten?';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get dataManagement => 'Datenverwaltung';

  @override
  String get about => 'Über';
}
