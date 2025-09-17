// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'TraceOff — Чистые ссылки';

  @override
  String get tabClean => 'Очистить ссылку';

  @override
  String get tabHistory => 'История';

  @override
  String get tabSettings => 'Настройки';

  @override
  String get supportedPlatformsTitle => 'Поддерживаемые платформы';

  @override
  String get hide => 'Скрыть';

  @override
  String get dontShowAgain => 'Больше не показывать';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get settings => 'Настройки';

  @override
  String get history => 'История';

  @override
  String get inputHint => 'Вставьте ссылку для очистки';

  @override
  String get clean => 'Очистить';

  @override
  String get snackPastedAndCleaning =>
      'URL вставлен из буфера обмена и очищается...';

  @override
  String get snackPasted => 'URL вставлен из буфера обмена';

  @override
  String get enterValidUrl =>
      'Пожалуйста, введите действительный http/https URL';

  @override
  String get processingMode => 'Режим обработки';

  @override
  String get pasteLinkTitle => 'Вставьте ссылку для очистки';

  @override
  String get inputHintHttp => 'Вставьте ссылку для очистки (http/https)';

  @override
  String get actionPaste => 'Вставить';

  @override
  String get actionClear => 'Очистить';

  @override
  String get cleaning => 'Очистка...';

  @override
  String get processLocally => 'Обработать локально';

  @override
  String get notCertainReviewAlternatives =>
      'Этот результат не на 100% точен. Пожалуйста, просмотрите альтернативы ниже.';

  @override
  String get hideSupportedTitle => 'Скрыть поддерживаемые платформы';

  @override
  String get hideSupportedQuestion =>
      'Хотите ли вы временно скрыть эту панель или больше никогда не показывать?';

  @override
  String get cancel => 'Отмена';

  @override
  String get cleanLinkReady => 'Чистая ссылка готова';

  @override
  String get cleanLinkLabel => 'Чистая ссылка:';

  @override
  String get tipLongPressToCopy =>
      'Совет: долго нажмите на любую ссылку для копирования';

  @override
  String get copyCleanLink => 'Копировать чистую ссылку';

  @override
  String get tipTapOpenLongPressCopy =>
      'Совет: нажмите на ссылку для открытия, долго нажмите для копирования';

  @override
  String get shareLink => 'Поделиться ссылкой';

  @override
  String get technicalDetails => 'Технические детали';

  @override
  String get actionsTaken => 'Выполненные действия:';

  @override
  String get domain => 'Домен';

  @override
  String get strategy => 'Стратегия';

  @override
  String get processingTime => 'Время обработки';

  @override
  String get appliedAt => 'Применено';

  @override
  String get alternativeResults => 'Альтернативные результаты';

  @override
  String get alternative => 'Альтернатива';

  @override
  String get shareAltWarning =>
      'Поделиться (может содержать параметры отслеживания)';

  @override
  String get shareAltWarningSnack =>
      'Предупреждение: альтернатива может содержать трекеры';

  @override
  String get tutorialProcessingModes => 'Processing Modes';

  @override
  String get tutorialLocalProcessing => 'Local Processing';

  @override
  String get tutorialLocalDescription =>
      'URL cleaning happens entirely on your device';

  @override
  String get tutorialLocalPros1 =>
      'Complete privacy - no data leaves your device';

  @override
  String get tutorialLocalPros2 => 'Works offline - no internet required';

  @override
  String get tutorialLocalPros3 => 'No server dependency - always available';

  @override
  String get tutorialLocalPros4 =>
      'Perfect for sensitive links you\'re sending';

  @override
  String get tutorialLocalCons1 => 'Less sophisticated cleaning algorithms';

  @override
  String get tutorialLocalCons2 => 'May miss some tracking parameters';

  @override
  String get tutorialLocalCons3 => 'Limited to basic redirect following';

  @override
  String get tutorialLocalCons4 => 'No server-side intelligence';

  @override
  String get tutorialLocalWhenToUse =>
      'Use when you want maximum privacy and are sending links to others. Your IP address and the original URL never leave your device.';

  @override
  String get tutorialRemoteProcessing => 'Remote Processing';

  @override
  String get tutorialRemoteDescription =>
      'URL cleaning happens on our secure servers';

  @override
  String get tutorialRemotePros1 => 'Advanced cleaning algorithms';

  @override
  String get tutorialRemotePros2 =>
      'Comprehensive tracking parameter detection';

  @override
  String get tutorialRemotePros3 => 'Server-side intelligence and updates';

  @override
  String get tutorialRemotePros4 => 'Better redirect following capabilities';

  @override
  String get tutorialRemotePros5 => 'Regular algorithm improvements';

  @override
  String get tutorialRemoteCons1 => 'Requires internet connection';

  @override
  String get tutorialRemoteCons2 => 'URL is sent to our servers';

  @override
  String get tutorialRemoteCons3 => 'Your IP address is visible to our servers';

  @override
  String get tutorialRemoteCons4 => 'Depends on server availability';

  @override
  String get tutorialRemoteWhenToUse =>
      'Use when you want the best cleaning results and are processing links you received from others. Our servers can detect more tracking parameters than local processing.';

  @override
  String get tutorialSecurityPrivacy => 'Security & Privacy';

  @override
  String get tutorialSec1 => 'We never store your URLs or personal data';

  @override
  String get tutorialSec2 => 'All processing is done in real-time';

  @override
  String get tutorialSec3 => 'No logs are kept of your cleaning requests';

  @override
  String get tutorialSec4 => 'Our servers use industry-standard encryption';

  @override
  String get tutorialSec5 => 'You can switch modes anytime without losing data';

  @override
  String get tutorialRecommendations => 'Our Recommendations';

  @override
  String get tutorialRec1 => 'For links you\'re sending: Use Local Processing';

  @override
  String get tutorialRec2 => 'For links you received: Use Remote Processing';

  @override
  String get tutorialRec3 =>
      'For best results: Use Remote Processing when possible';

  @override
  String get tutorialRec4 =>
      'When in doubt: Start with Remote, switch to Local if needed';

  @override
  String get tutorialAdvantages => 'Advantages';

  @override
  String get tutorialLimitations => 'Limitations';

  @override
  String get tutorialWhenToUseLabel => 'When to use:';

  @override
  String get historyTitle => 'History';

  @override
  String get historySearchHint => 'Search history...';

  @override
  String get historyShowAll => 'Show All';

  @override
  String get historyShowFavoritesOnly => 'Show Favorites Only';

  @override
  String get historyExport => 'Export History';

  @override
  String get historyClearAll => 'Clear All History';

  @override
  String get historyNoFavoritesYet => 'No favorite items yet';

  @override
  String get historyNoItemsYet => 'No history items yet';

  @override
  String get historyFavoritesHint =>
      'Tap the heart icon on any item to add it to favorites';

  @override
  String get historyCleanSomeUrls => 'Clean some URLs to see them here';

  @override
  String get historyOriginal => 'Original:';

  @override
  String get historyCleaned => 'Cleaned:';

  @override
  String get historyConfidence => 'confidence';

  @override
  String get historyCopyOriginal => 'Copy Original';

  @override
  String get historyCopyCleaned => 'Copy Cleaned';

  @override
  String get historyShare => 'Share';

  @override
  String get historyOpen => 'Open';

  @override
  String get historyReclean => 'Re-clean';

  @override
  String get historyAddToFavorites => 'Add to Favorites';

  @override
  String get historyRemoveFromFavorites => 'Remove from Favorites';

  @override
  String get historyDelete => 'Delete';

  @override
  String get historyDeleteItem => 'Delete Item';

  @override
  String get historyDeleteConfirm =>
      'Are you sure you want to delete this history item?';

  @override
  String get historyClearAllTitle => 'Clear All History';

  @override
  String get historyClearAllConfirm =>
      'Are you sure you want to delete all history items? This action cannot be undone.';

  @override
  String get historyClearAllAction => 'Clear All';

  @override
  String get historyOriginalCopied => 'Original URL copied to clipboard';

  @override
  String get historyCleanedCopied => 'Cleaned URL copied to clipboard';

  @override
  String get historyExported => 'История экспортирована в буфер обмена';

  @override
  String get historyCouldNotLaunch => 'Could not launch';

  @override
  String get historyErrorLaunching => 'Error launching URL:';

  @override
  String get historyJustNow => 'Just now';

  @override
  String get historyDaysAgo => 'd ago';

  @override
  String get historyHoursAgo => 'h ago';

  @override
  String get historyMinutesAgo => 'm ago';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsCleaningStrategies => 'Cleaning Strategies';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsServer => 'Server';

  @override
  String get settingsDataManagement => 'Data Management';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAutoCopyPrimary => 'Auto-copy Primary Result';

  @override
  String get settingsAutoCopyPrimaryDesc =>
      'Automatically copy the primary cleaned link to clipboard';

  @override
  String get settingsShowConfirmation => 'Show Confirmation';

  @override
  String get settingsShowConfirmationDesc =>
      'Show confirmation dialogs for actions';

  @override
  String get settingsShowCleanLinkPreviews => 'Show Clean Link Previews';

  @override
  String get settingsShowCleanLinkPreviewsDesc =>
      'Render previews only for cleaned links (local only, can be disabled)';

  @override
  String get settingsLocalProcessing => 'Local Processing';

  @override
  String get settingsLocalProcessingDesc =>
      'Process links locally on device instead of using cloud API. When enabled, all cleaning happens on your device for better privacy.';

  @override
  String get settingsLocalProcessingWebDesc =>
      'Not available on web. Use the mobile app for offline/local processing.';

  @override
  String get settingsManageLocalStrategies => 'Manage Local Strategies';

  @override
  String settingsManageLocalStrategiesDesc(Object strategyName) {
    return 'Active: $strategyName';
  }

  @override
  String get settingsManageLocalStrategiesWebDesc =>
      'Not available on web. Download the app to customize offline strategies.';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsServerUrl => 'Server URL';

  @override
  String get settingsServerUrlDesc => 'Enter the URL of your TraceOff server';

  @override
  String get settingsClearHistory => 'Clear History';

  @override
  String get settingsClearHistoryDesc => 'Remove all history items';

  @override
  String get settingsExportHistory => 'Export History';

  @override
  String get settingsExportHistoryDesc => 'Export history to clipboard';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsOpenSource => 'Open Source';

  @override
  String get settingsOpenSourceDesc => 'View source code on GitHub';

  @override
  String get settingsGitHubNotImplemented => 'GitHub link not implemented';

  @override
  String get settingsResetToDefaults =>
      'Настройки сброшены к значениям по умолчанию';

  @override
  String get settingsResetToDefaultsDesc =>
      'Reset all settings to their default values';

  @override
  String get settingsSystemDefault => 'System Default';

  @override
  String get settingsLight => 'Light';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsChooseTheme => 'Choose Theme';

  @override
  String get settingsChooseLanguage => 'Choose Language';

  @override
  String get settingsClearHistoryTitle => 'Clear History';

  @override
  String get settingsClearHistoryConfirm =>
      'Are you sure you want to delete all history items? This action cannot be undone.';

  @override
  String get settingsHistoryCleared => 'History cleared';

  @override
  String get settingsNoHistoryToExport => 'No history items to export';

  @override
  String get settingsHistoryExported => 'History exported to clipboard';

  @override
  String get settingsResetSettings => 'Reset Settings';

  @override
  String get settingsResetSettingsConfirm =>
      'Are you sure you want to reset all settings to their default values?';

  @override
  String get settingsReset => 'Reset';

  @override
  String get settingsSettingsResetToDefaults => 'Settings reset to defaults';

  @override
  String get settingsLocalStrategiesTitle => 'Local Cleaning Strategies';

  @override
  String get settingsDefaultOfflineCleaner => 'Default offline cleaner';

  @override
  String get settingsDefaultOfflineCleanerDesc =>
      'Use built-in offline cleaning strategy';

  @override
  String get settingsAddStrategy => 'Add Strategy';

  @override
  String get settingsNewStrategy => 'New Strategy';

  @override
  String get settingsEditStrategy => 'Edit Strategy';

  @override
  String get settingsStrategyName => 'Name';

  @override
  String get settingsSteps => 'Steps';

  @override
  String get settingsAddStep => 'Add Step';

  @override
  String get settingsRedirectStep => 'Redirect step';

  @override
  String get settingsTimes => 'Times';

  @override
  String get settingsRemoveQueryKeys => 'Remove query keys';

  @override
  String get settingsCommaSeparatedKeys => 'Comma-separated keys';

  @override
  String get settingsCommaSeparatedKeysHint =>
      'e.g. utm_source, utm_medium, fbclid';

  @override
  String get settingsRedirect => 'Redirect (N times)';

  @override
  String get settingsRemoveQuery => 'Remove query keys';

  @override
  String get settingsStripFragment => 'Strip fragment';

  @override
  String get settingsClose => 'Close';

  @override
  String get settingsSave => 'Save';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String settingsRedirectTimes(Object times) {
    return 'Redirect $times time(s)';
  }

  @override
  String get settingsRemoveNoQueryKeys => 'Remove no query keys';

  @override
  String settingsRemoveKeys(Object keys) {
    return 'Remove keys: $keys';
  }

  @override
  String get settingsStripUrlFragment => 'Strip URL fragment';

  @override
  String get switchedToLocal =>
      'Переключено на локальную очистку - использование обработки на устройстве';

  @override
  String get local => 'Локально';

  @override
  String get switchedToRemote =>
      'Переключено на удаленную очистку - использование облачного API';

  @override
  String get remote => 'Удаленно';

  @override
  String get copiedToClipboard => 'Скопировано в буфер обмена';

  @override
  String get urlCleanedCopiedAndShared => 'URL очищен: скопирован и поделен';

  @override
  String get couldNotLaunch => 'Не удалось запустить';

  @override
  String get errorLaunchingUrl => 'Ошибка запуска URL:';

  @override
  String get switchedToLocalProcessingAndCleaned =>
      'Переключено на локальную обработку и очищен URL';

  @override
  String get whyCleanLinks => 'Why clean links?';

  @override
  String get privacyNotes => 'Privacy Notes';

  @override
  String get chooseTheme => 'Выбрать тему';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Темная';

  @override
  String get system => 'Системная';

  @override
  String get debugInfo => 'Отладочная информация';

  @override
  String get originalInput => 'Исходный ввод';

  @override
  String get localRemote => 'Локально/Удаленно';

  @override
  String get supportedPlatformsAndWhatWeClean =>
      'Поддерживаемые платформы и что мы очищаем';

  @override
  String get whyCleanLinksDescription =>
      'Зачем очищать ссылки? Короткие ссылки и ссылки \"поделиться\" часто содержат идентификаторы, которые могут профилировать вас или раскрыть вторичные аккаунты. Примеры: lnkd.in и pin.it могут раскрыть, что вы открыли; ссылки для обмена Instagram (например, /share/...) включают коды, производные от отправителя (igshid, igsh, si), которые могут связать ссылку с вами. Мы нормализуем к прямой, канонической URL — не просто удаляя utm_* — чтобы уменьшить отпечатки и подсказки типа \"X поделился с вами рил\".';

  @override
  String get privacyNotesDescription =>
      'Примечания о конфиденциальности:\n• Ссылки \"поделиться\" могут встраивать информацию о том, кто с кем поделился (например, Instagram /share, контекст Reddit, X s=20).\n• Сокращатели ссылок (lnkd.in, pin.it) добавляют промежуточные страницы, которые могут записывать ваш клик.\n• Параметры платформы (igshid, fbclid, rdt, share_app_id) могут связать действие с вашим аккаунтом.\nМы продвигаем прямые, канонические URL для минимизации профилирования и социальных подсказок типа \"X поделился с вами рил\".';

  @override
  String get example => 'например';

  @override
  String get general => 'Общие';

  @override
  String get autoCopyPrimaryResult => 'Автокопирование основного результата';

  @override
  String get autoCopyPrimaryResultDesc =>
      'Автоматически копировать основную очищенную ссылку в буфер обмена';

  @override
  String get showConfirmation => 'Показывать подтверждение';

  @override
  String get showConfirmationDesc =>
      'Показывать диалоги подтверждения для действий';

  @override
  String get showCleanLinkPreviews => 'Показывать превью чистых ссылок';

  @override
  String get showCleanLinkPreviewsDesc =>
      'Рендерить превью только для очищенных ссылок (только локально, можно отключить)';

  @override
  String get localProcessing => 'Локальная обработка';

  @override
  String get localProcessingDesc =>
      'Обрабатывать ссылки локально на устройстве вместо использования облачного API. При включении вся очистка происходит на вашем устройстве для лучшей конфиденциальности.';

  @override
  String get localProcessingWebDesc =>
      'Недоступно в веб-версии. Используйте мобильное приложение для офлайн/локальной обработки.';

  @override
  String get manageLocalStrategies => 'Управление локальными стратегиями';

  @override
  String manageLocalStrategiesDesc(Object strategyName) {
    return 'Активна: $strategyName';
  }

  @override
  String get manageLocalStrategiesWebDesc =>
      'Недоступно в веб-версии. Скачайте приложение для настройки офлайн стратегий.';

  @override
  String get theme => 'Тема';

  @override
  String get language => 'Язык';

  @override
  String get serverUrl => 'URL сервера';

  @override
  String get serverUrlDesc => 'Введите URL вашего сервера TraceOff';

  @override
  String get environment => 'Окружение:';

  @override
  String get baseUrl => 'Базовый URL:';

  @override
  String get apiUrl => 'API URL:';

  @override
  String get clearHistory => 'Очистить историю';

  @override
  String get clearHistoryDesc => 'Удалить все элементы истории';

  @override
  String get exportHistory => 'Экспортировать историю';

  @override
  String get exportHistoryDesc => 'Экспортировать историю в буфер обмена';

  @override
  String get version => 'Версия';

  @override
  String get openSource => 'Открытый код';

  @override
  String get openSourceDesc => 'Посмотреть исходный код на GitHub';

  @override
  String get githubLinkNotImplemented => 'Ссылка на GitHub не реализована';

  @override
  String get privacyPolicyDesc => 'Как мы обрабатываем ваши данные';

  @override
  String get resetToDefaults => 'Сбросить к значениям по умолчанию';

  @override
  String get resetToDefaultsDesc =>
      'Сбросить все настройки к их значениям по умолчанию';

  @override
  String get localOfflineNotAvailableWeb =>
      'Локальная офлайн обработка недоступна в веб-версии. Скачайте приложение для использования локальных стратегий.';

  @override
  String get chooseLanguage => 'Выбрать язык';

  @override
  String get clearHistoryTitle => 'Очистить историю';

  @override
  String get clearHistoryConfirm =>
      'Вы уверены, что хотите удалить все элементы истории? Это действие нельзя отменить.';

  @override
  String get clear => 'Очистить';

  @override
  String get historyCleared => 'История очищена';

  @override
  String get noHistoryToExport => 'Нет элементов истории для экспорта';

  @override
  String get localCleaningStrategies => 'Локальные стратегии очистки';

  @override
  String get defaultOfflineCleaner => 'Офлайн очиститель по умолчанию';

  @override
  String get defaultOfflineCleanerDesc =>
      'Использовать встроенную стратегию офлайн очистки';

  @override
  String get addStrategy => 'Добавить стратегию';

  @override
  String get close => 'Закрыть';

  @override
  String get newStrategy => 'Новая стратегия';

  @override
  String get editStrategy => 'Редактировать стратегию';

  @override
  String get steps => 'Шаги';

  @override
  String get addStep => 'Добавить шаг';

  @override
  String get redirect => 'Перенаправить (N раз)';

  @override
  String get removeQuery => 'Удалить ключи запроса';

  @override
  String get stripFragment => 'Удалить фрагмент';

  @override
  String get save => 'Сохранить';

  @override
  String get redirectStep => 'Шаг перенаправления';

  @override
  String get removeQueryKeys => 'Удалить ключи запроса';

  @override
  String get resetSettings => 'Сбросить настройки';

  @override
  String get resetSettingsConfirm =>
      'Вы уверены, что хотите сбросить все настройки к их значениям по умолчанию?';

  @override
  String get reset => 'Сбросить';

  @override
  String get dataManagement => 'Управление Данными';

  @override
  String get about => 'О Приложении';
}
