// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'TraceOff — Liens Propres';

  @override
  String get tabClean => 'Nettoyer le Lien';

  @override
  String get tabHistory => 'Historique';

  @override
  String get tabSettings => 'Paramètres';

  @override
  String get supportedPlatformsTitle => 'Plateformes Prises en Charge';

  @override
  String get hide => 'Masquer';

  @override
  String get dontShowAgain => 'Ne plus afficher';

  @override
  String get privacyPolicy => 'Politique de Confidentialité';

  @override
  String get settings => 'Paramètres';

  @override
  String get history => 'Historique';

  @override
  String get inputHint => 'Collez un lien à nettoyer';

  @override
  String get clean => 'Nettoyer';

  @override
  String get snackPastedAndCleaning =>
      'URL collée du presse-papiers et nettoyage...';

  @override
  String get snackPasted => 'URL collée du presse-papiers';

  @override
  String get enterValidUrl => 'Veuillez entrer une URL valide http/https';

  @override
  String get processingMode => 'Mode de Traitement';

  @override
  String get pasteLinkTitle => 'Coller un Lien à Nettoyer';

  @override
  String get inputHintHttp => 'Collez un lien à nettoyer (http/https)';

  @override
  String get actionPaste => 'Coller';

  @override
  String get actionClear => 'Effacer';

  @override
  String get cleaning => 'Nettoyage...';

  @override
  String get processLocally => 'Traiter Localement';

  @override
  String get notCertainReviewAlternatives =>
      'Ce résultat n\'est pas sûr à 100%. Veuillez examiner les alternatives ci-dessous.';

  @override
  String get hideSupportedTitle => 'Masquer les Plateformes Prises en Charge';

  @override
  String get hideSupportedQuestion =>
      'Voulez-vous masquer ce panneau temporairement ou ne plus jamais l\'afficher ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get cleanLinkReady => 'Lien Propre Prêt';

  @override
  String get cleanLinkLabel => 'Lien Propre :';

  @override
  String get tipLongPressToCopy =>
      'Astuce : Appuyez longuement sur n\'importe quel lien pour le copier';

  @override
  String get copyCleanLink => 'Copier le Lien Propre';

  @override
  String get tipTapOpenLongPressCopy =>
      'Astuce : Touchez le lien pour l\'ouvrir, appuyez longuement pour copier';

  @override
  String get shareLink => 'Partager le Lien';

  @override
  String get technicalDetails => 'Détails Techniques';

  @override
  String get actionsTaken => 'Actions effectuées :';

  @override
  String get domain => 'Domaine';

  @override
  String get strategy => 'Stratégie';

  @override
  String get processingTime => 'Temps de Traitement';

  @override
  String get appliedAt => 'Appliqué à';

  @override
  String get alternativeResults => 'Résultats Alternatifs';

  @override
  String get alternative => 'Alternative';

  @override
  String get shareAltWarning =>
      'Partager (peut encore contenir des paramètres de suivi)';

  @override
  String get shareAltWarningSnack =>
      'Avertissement : L\'alternative peut encore contenir des traqueurs';

  @override
  String get tutorialProcessingModes => 'Modes de Traitement';

  @override
  String get tutorialLocalProcessing => 'Traitement Local';

  @override
  String get tutorialLocalDescription =>
      'Le nettoyage d\'URL se fait entièrement sur votre appareil';

  @override
  String get tutorialLocalPros1 =>
      'Confidentialité complète - aucune donnée ne quitte votre appareil';

  @override
  String get tutorialLocalPros2 =>
      'Fonctionne hors ligne - pas besoin d\'internet';

  @override
  String get tutorialLocalPros3 =>
      'Aucune dépendance serveur - toujours disponible';

  @override
  String get tutorialLocalPros4 =>
      'Parfait pour les liens sensibles que vous envoyez';

  @override
  String get tutorialLocalCons1 =>
      'Algorithmes de nettoyage moins sophistiqués';

  @override
  String get tutorialLocalCons2 => 'Peut manquer certains paramètres de suivi';

  @override
  String get tutorialLocalCons3 => 'Limité au suivi basique des redirections';

  @override
  String get tutorialLocalCons4 => 'Pas d\'intelligence côté serveur';

  @override
  String get tutorialLocalWhenToUse =>
      'Utilisez quand vous voulez une confidentialité maximale et que vous envoyez des liens à d\'autres. Votre adresse IP et l\'URL originale ne quittent jamais votre appareil.';

  @override
  String get tutorialRemoteProcessing => 'Traitement à Distance';

  @override
  String get tutorialRemoteDescription =>
      'Le nettoyage d\'URL se fait sur nos serveurs sécurisés';

  @override
  String get tutorialRemotePros1 => 'Algorithmes de nettoyage avancés';

  @override
  String get tutorialRemotePros2 =>
      'Détection complète des paramètres de suivi';

  @override
  String get tutorialRemotePros3 => 'Intelligence serveur et mises à jour';

  @override
  String get tutorialRemotePros4 =>
      'Meilleures capacités de suivi des redirections';

  @override
  String get tutorialRemotePros5 => 'Améliorations régulières des algorithmes';

  @override
  String get tutorialRemoteCons1 => 'Nécessite une connexion internet';

  @override
  String get tutorialRemoteCons2 => 'L\'URL est envoyée à nos serveurs';

  @override
  String get tutorialRemoteCons3 =>
      'Votre adresse IP est visible par nos serveurs';

  @override
  String get tutorialRemoteCons4 => 'Dépend de la disponibilité du serveur';

  @override
  String get tutorialRemoteWhenToUse =>
      'Utilisez quand vous voulez les meilleurs résultats de nettoyage et que vous traitez des liens reçus d\'autres. Nos serveurs peuvent détecter plus de paramètres de suivi que le traitement local.';

  @override
  String get tutorialSecurityPrivacy => 'Sécurité et Confidentialité';

  @override
  String get tutorialSec1 =>
      'Nous ne stockons jamais vos URLs ou données personnelles';

  @override
  String get tutorialSec2 => 'Tout le traitement se fait en temps réel';

  @override
  String get tutorialSec3 =>
      'Aucun journal de vos demandes de nettoyage n\'est conservé';

  @override
  String get tutorialSec4 =>
      'Nos serveurs utilisent un chiffrement standard de l\'industrie';

  @override
  String get tutorialSec5 =>
      'Vous pouvez changer de mode à tout moment sans perdre de données';

  @override
  String get tutorialRecommendations => 'Nos Recommandations';

  @override
  String get tutorialRec1 =>
      'Pour les liens que vous envoyez : Utilisez le Traitement Local';

  @override
  String get tutorialRec2 =>
      'Pour les liens reçus : Utilisez le Traitement à Distance';

  @override
  String get tutorialRec3 =>
      'Pour de meilleurs résultats : Utilisez le Traitement à Distance quand possible';

  @override
  String get tutorialRec4 =>
      'En cas de doute : Commencez par Distance, passez à Local si nécessaire';

  @override
  String get tutorialAdvantages => 'Avantages';

  @override
  String get tutorialLimitations => 'Limitations';

  @override
  String get tutorialWhenToUseLabel => 'Quand utiliser :';

  @override
  String get historyTitle => 'Historique';

  @override
  String get historySearchHint => 'Rechercher dans l\'historique...';

  @override
  String get historyShowAll => 'Tout Afficher';

  @override
  String get historyShowFavoritesOnly => 'Afficher Seulement les Favoris';

  @override
  String get historyExport => 'Exporter l\'Historique';

  @override
  String get historyClearAll => 'Effacer Tout l\'Historique';

  @override
  String get historyNoFavoritesYet => 'Aucun favori pour le moment';

  @override
  String get historyNoItemsYet => 'Aucun élément dans l\'historique';

  @override
  String get historyFavoritesHint =>
      'Touchez licône cœur sur n\'importe quel élément pour lajouter aux favoris';

  @override
  String get historyCleanSomeUrls => 'Nettoyez quelques URLs pour les voir ici';

  @override
  String get historyOriginal => 'Original :';

  @override
  String get historyCleaned => 'Nettoyé :';

  @override
  String get historyConfidence => 'confiance';

  @override
  String get historyCopyOriginal => 'Copier l\'Original';

  @override
  String get historyCopyCleaned => 'Copier le Nettoyé';

  @override
  String get historyShare => 'Partager';

  @override
  String get historyOpen => 'Ouvrir';

  @override
  String get historyReclean => 'Re-nettoyer';

  @override
  String get historyAddToFavorites => 'Ajouter aux Favoris';

  @override
  String get historyRemoveFromFavorites => 'Retirer des Favoris';

  @override
  String get historyDelete => 'Supprimer';

  @override
  String get historyDeleteItem => 'Supprimer l\'Élément';

  @override
  String get historyDeleteConfirm =>
      'Êtes-vous sûr de vouloir supprimer cet élément de l\'historique ?';

  @override
  String get historyClearAllTitle => 'Effacer Tout l\'Historique';

  @override
  String get historyClearAllConfirm =>
      'Êtes-vous sûr de vouloir supprimer tous les éléments de l\'historique ? Cette action ne peut pas être annulée.';

  @override
  String get historyClearAllAction => 'Tout Effacer';

  @override
  String get historyOriginalCopied =>
      'URL originale copiée dans le presse-papiers';

  @override
  String get historyCleanedCopied =>
      'URL nettoyée copiée dans le presse-papiers';

  @override
  String get historyExported => 'Historique exporté dans le presse-papiers';

  @override
  String get historyCouldNotLaunch => 'Impossible d\'ouvrir';

  @override
  String get historyErrorLaunching => 'Erreur lors de l\'ouverture de l\'URL :';

  @override
  String get historyJustNow => 'À l\'instant';

  @override
  String get historyDaysAgo => 'j il y a';

  @override
  String get historyHoursAgo => 'h il y a';

  @override
  String get historyMinutesAgo => 'm il y a';

  @override
  String get settingsGeneral => 'Général';

  @override
  String get settingsCleaningStrategies => 'Stratégies de Nettoyage';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsServer => 'Serveur';

  @override
  String get settingsDataManagement => 'Gestion des Données';

  @override
  String get settingsAbout => 'À Propos';

  @override
  String get settingsAutoCopyPrimary => 'Auto-copier le Résultat Principal';

  @override
  String get settingsAutoCopyPrimaryDesc =>
      'Copier automatiquement le lien propre principal dans le presse-papiers';

  @override
  String get settingsShowConfirmation => 'Afficher la Confirmation';

  @override
  String get settingsShowConfirmationDesc =>
      'Afficher les dialogues de confirmation pour les actions';

  @override
  String get settingsShowCleanLinkPreviews =>
      'Afficher les Aperçus de Liens Propres';

  @override
  String get settingsShowCleanLinkPreviewsDesc =>
      'Rendre les aperçus seulement pour les liens propres (local seulement, peut être désactivé)';

  @override
  String get settingsLocalProcessing => 'Traitement Local';

  @override
  String get settingsLocalProcessingDesc =>
      'Traiter les liens localement sur l\'appareil au lieu dutiliser lAPI cloud. Quand activé, tout le nettoyage se fait sur votre appareil pour une meilleure confidentialité.';

  @override
  String get settingsLocalProcessingWebDesc =>
      'Non disponible sur le web. Utilisez l\'application mobile pour le traitement hors ligne/local.';

  @override
  String get settingsManageLocalStrategies => 'Gérer les Stratégies Locales';

  @override
  String settingsManageLocalStrategiesDesc(Object strategyName) {
    return 'Actif : $strategyName';
  }

  @override
  String get settingsManageLocalStrategiesWebDesc =>
      'Non disponible sur le web. Téléchargez l\'application pour personnaliser les stratégies hors ligne.';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsServerUrl => 'URL du Serveur';

  @override
  String get settingsServerUrlDesc => 'Entrez l\'URL de votre serveur TraceOff';

  @override
  String get settingsClearHistory => 'Effacer l\'Historique';

  @override
  String get settingsClearHistoryDesc =>
      'Supprimer tous les éléments de l\'historique';

  @override
  String get settingsExportHistory => 'Exporter l\'Historique';

  @override
  String get settingsExportHistoryDesc =>
      'Exporter l\'historique dans le presse-papiers';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsOpenSource => 'Open Source';

  @override
  String get settingsOpenSourceDesc => 'Voir le code source sur GitHub';

  @override
  String get settingsGitHubNotImplemented => 'Lien GitHub non implémenté';

  @override
  String get settingsResetToDefaults =>
      'Paramètres réinitialisés aux valeurs par défaut';

  @override
  String get settingsResetToDefaultsDesc =>
      'Réinitialiser tous les paramètres à leurs valeurs par défaut';

  @override
  String get settingsSystemDefault => 'Par Défaut du Système';

  @override
  String get settingsLight => 'Clair';

  @override
  String get settingsDark => 'Sombre';

  @override
  String get settingsChooseTheme => 'Choisir le Thème';

  @override
  String get settingsChooseLanguage => 'Choisir la Langue';

  @override
  String get settingsClearHistoryTitle => 'Effacer l\'Historique';

  @override
  String get settingsClearHistoryConfirm =>
      'Êtes-vous sûr de vouloir supprimer tous les éléments de l\'historique ? Cette action ne peut pas être annulée.';

  @override
  String get settingsHistoryCleared => 'Historique effacé';

  @override
  String get settingsNoHistoryToExport =>
      'Aucun élément d\'historique à exporter';

  @override
  String get settingsHistoryExported =>
      'Historique exporté dans le presse-papiers';

  @override
  String get settingsResetSettings => 'Réinitialiser les Paramètres';

  @override
  String get settingsResetSettingsConfirm =>
      'Êtes-vous sûr de vouloir réinitialiser tous les paramètres à leurs valeurs par défaut ?';

  @override
  String get settingsReset => 'Réinitialiser';

  @override
  String get settingsSettingsResetToDefaults =>
      'Paramètres réinitialisés aux valeurs par défaut';

  @override
  String get settingsLocalStrategiesTitle => 'Stratégies de Nettoyage Locales';

  @override
  String get settingsDefaultOfflineCleaner => 'Nettoyeur hors ligne par défaut';

  @override
  String get settingsDefaultOfflineCleanerDesc =>
      'Utiliser la stratégie de nettoyage hors ligne intégrée';

  @override
  String get settingsAddStrategy => 'Ajouter une Stratégie';

  @override
  String get settingsNewStrategy => 'Nouvelle Stratégie';

  @override
  String get settingsEditStrategy => 'Modifier la Stratégie';

  @override
  String get settingsStrategyName => 'Nom';

  @override
  String get settingsSteps => 'Étapes';

  @override
  String get settingsAddStep => 'Ajouter une Étape';

  @override
  String get settingsRedirectStep => 'Étape de redirection';

  @override
  String get settingsTimes => 'Fois';

  @override
  String get settingsRemoveQueryKeys => 'Supprimer les clés de requête';

  @override
  String get settingsCommaSeparatedKeys => 'Clés séparées par des virgules';

  @override
  String get settingsCommaSeparatedKeysHint =>
      'ex. utm_source, utm_medium, fbclid';

  @override
  String get settingsRedirect => 'Rediriger (N fois)';

  @override
  String get settingsRemoveQuery => 'Supprimer les clés de requête';

  @override
  String get settingsStripFragment => 'Supprimer le fragment';

  @override
  String get settingsClose => 'Fermer';

  @override
  String get settingsSave => 'Enregistrer';

  @override
  String get settingsCancel => 'Annuler';

  @override
  String settingsRedirectTimes(Object times) {
    return 'Rediriger $times fois';
  }

  @override
  String get settingsRemoveNoQueryKeys => 'Ne supprimer aucune clé de requête';

  @override
  String settingsRemoveKeys(Object keys) {
    return 'Supprimer les clés : $keys';
  }

  @override
  String get settingsStripUrlFragment => 'Supprimer le fragment d\'URL';

  @override
  String get switchedToLocal =>
      'Passé au nettoyage local - utilisation du traitement sur l\'appareil';

  @override
  String get local => 'Local';

  @override
  String get switchedToRemote =>
      'Passé au nettoyage à distance - utilisation de l\'API cloud';

  @override
  String get remote => 'Distant';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get urlCleanedCopiedAndShared => 'URL nettoyée : copiée et partagée';

  @override
  String get couldNotLaunch => 'Impossible d\'ouvrir';

  @override
  String get errorLaunchingUrl => 'Erreur lors de l\'ouverture de l\'URL :';

  @override
  String get switchedToLocalProcessingAndCleaned =>
      'Passé au traitement local et nettoyé l\'URL';

  @override
  String get whyCleanLinks => 'Pourquoi nettoyer les liens ?';

  @override
  String get privacyNotes => 'Notes de Confidentialité';

  @override
  String get chooseTheme => 'Choisir le Thème';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get system => 'Système';

  @override
  String get debugInfo => 'Informations de Débogage :';

  @override
  String get originalInput => 'Entrée Originale';

  @override
  String get localRemote => 'Local/Distant';

  @override
  String get supportedPlatformsAndWhatWeClean =>
      'Plateformes Prises en Charge et Ce Que Nous Nettoyons';

  @override
  String get whyCleanLinksDescription =>
      'Pourquoi nettoyer les liens ? Les liens courts et les liens de \"partage\" transportent souvent des identifiants qui peuvent vous profiler ou exposer des comptes secondaires. Exemples : lnkd.in et pin.it peuvent révéler ce que vous avez ouvert ; les liens de partage Instagram (comme /share/...) incluent des codes dérivés de l\'expéditeur (igshid, igsh, si) qui peuvent lier le lien à vous. Nous normalisons vers une URL directe et canonique — pas seulement en supprimant utm_* — pour réduire l\'empreinte et les invites comme \"X a partagé un reel avec vous.\"';

  @override
  String get privacyNotesDescription =>
      'Notes de confidentialité :\n• Les liens de \"partage\" peuvent intégrer qui a partagé avec qui (ex. Instagram /share, contexte Reddit, X s=20).\n• Les raccourcisseurs (lnkd.in, pin.it) ajoutent des interstitiels qui peuvent enregistrer votre clic.\n• Les paramètres de plateforme (igshid, fbclid, rdt, share_app_id) peuvent lier l\'action à votre compte.\nNous promouvons les URLs directes et canoniques pour minimiser le profilage et les invites sociales comme \"X a partagé un reel avec vous.\"';

  @override
  String get example => 'ex.';

  @override
  String get general => 'Général';

  @override
  String get autoCopyPrimaryResult => 'Auto-copier le Résultat Principal';

  @override
  String get autoCopyPrimaryResultDesc =>
      'Copier automatiquement le lien propre principal dans le presse-papiers';

  @override
  String get showConfirmation => 'Afficher la Confirmation';

  @override
  String get showConfirmationDesc =>
      'Afficher les dialogues de confirmation pour les actions';

  @override
  String get showCleanLinkPreviews => 'Afficher les Aperçus de Liens Propres';

  @override
  String get showCleanLinkPreviewsDesc =>
      'Rendre les aperçus seulement pour les liens propres (local seulement, peut être désactivé)';

  @override
  String get localProcessing => 'Traitement Local';

  @override
  String get localProcessingDesc =>
      'Traiter les liens localement sur l\'appareil au lieu d\'utiliser l\'API cloud. Quand activé, tout le nettoyage se fait sur votre appareil pour une meilleure confidentialité.';

  @override
  String get localProcessingWebDesc =>
      'Non disponible sur le web. Utilisez l\'application mobile pour le traitement hors ligne/local.';

  @override
  String get manageLocalStrategies => 'Gérer les Stratégies Locales';

  @override
  String manageLocalStrategiesDesc(Object strategyName) {
    return 'Actif : $strategyName';
  }

  @override
  String get manageLocalStrategiesWebDesc =>
      'Non disponible sur le web. Téléchargez l\'application pour personnaliser les stratégies hors ligne.';

  @override
  String get theme => 'Thème';

  @override
  String get language => 'Langue';

  @override
  String get serverUrl => 'URL du Serveur';

  @override
  String get serverUrlDesc => 'Entrez l\'URL de votre serveur TraceOff';

  @override
  String get environment => 'Environnement :';

  @override
  String get baseUrl => 'URL de Base :';

  @override
  String get apiUrl => 'URL de l\'API :';

  @override
  String get clearHistory => 'Effacer l\'Historique';

  @override
  String get clearHistoryDesc => 'Supprimer tous les éléments de l\'historique';

  @override
  String get exportHistory => 'Exporter l\'Historique';

  @override
  String get exportHistoryDesc =>
      'Exporter l\'historique dans le presse-papiers';

  @override
  String get version => 'Version';

  @override
  String get openSource => 'Open Source';

  @override
  String get openSourceDesc => 'Voir le code source sur GitHub';

  @override
  String get githubLinkNotImplemented => 'Lien GitHub non implémenté';

  @override
  String get privacyPolicyDesc => 'Comment nous gérons vos données';

  @override
  String get resetToDefaults => 'Réinitialiser aux Valeurs par Défaut';

  @override
  String get resetToDefaultsDesc =>
      'Réinitialiser tous les paramètres à leurs valeurs par défaut';

  @override
  String get localOfflineNotAvailableWeb =>
      'Le traitement local hors ligne n\'est pas disponible sur le web. Téléchargez l\'application pour utiliser les stratégies locales.';

  @override
  String get chooseLanguage => 'Choisir la Langue';

  @override
  String get clearHistoryTitle => 'Effacer l\'Historique';

  @override
  String get clearHistoryConfirm =>
      'Êtes-vous sûr de vouloir supprimer tous les éléments de l\'historique ? Cette action ne peut pas être annulée.';

  @override
  String get clear => 'Effacer';

  @override
  String get historyCleared => 'Historique effacé';

  @override
  String get noHistoryToExport => 'Aucun élément d\'historique à exporter';

  @override
  String get localCleaningStrategies => 'Stratégies de Nettoyage Locales';

  @override
  String get defaultOfflineCleaner => 'Nettoyeur hors ligne par défaut';

  @override
  String get defaultOfflineCleanerDesc =>
      'Utiliser la stratégie de nettoyage hors ligne intégrée';

  @override
  String get addStrategy => 'Ajouter une Stratégie';

  @override
  String get close => 'Fermer';

  @override
  String get newStrategy => 'Nouvelle Stratégie';

  @override
  String get editStrategy => 'Modifier la Stratégie';

  @override
  String get steps => 'Étapes';

  @override
  String get addStep => 'Ajouter une Étape';

  @override
  String get redirect => 'Rediriger (N fois)';

  @override
  String get removeQuery => 'Supprimer les clés de requête';

  @override
  String get stripFragment => 'Supprimer le fragment';

  @override
  String get save => 'Enregistrer';

  @override
  String get redirectStep => 'Étape de redirection';

  @override
  String get removeQueryKeys => 'Supprimer les clés de requête';

  @override
  String get resetSettings => 'Réinitialiser les Paramètres';

  @override
  String get resetSettingsConfirm =>
      'Êtes-vous sûr de vouloir réinitialiser tous les paramètres à leurs valeurs par défaut ?';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get dataManagement => 'Gestion des Données';

  @override
  String get about => 'À Propos';
}
