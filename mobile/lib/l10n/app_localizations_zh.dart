// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'TraceOff — 清洁链接';

  @override
  String get tabClean => '清理链接';

  @override
  String get tabHistory => '历史';

  @override
  String get tabSettings => '设置';

  @override
  String get supportedPlatformsTitle => '支持的平台';

  @override
  String get hide => '隐藏';

  @override
  String get dontShowAgain => '不再显示';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get settings => '设置';

  @override
  String get history => '历史';

  @override
  String get inputHint => '粘贴需要清理的链接';

  @override
  String get clean => '清理';

  @override
  String get snackPastedAndCleaning => '已从剪贴板粘贴URL并正在清理...';

  @override
  String get snackPasted => '已从剪贴板粘贴URL';

  @override
  String get enterValidUrl => '请输入有效的http/https URL';

  @override
  String get processingMode => '处理模式';

  @override
  String get pasteLinkTitle => '粘贴要清理的链接';

  @override
  String get inputHintHttp => '粘贴要清理的链接 (http/https)';

  @override
  String get actionPaste => '粘贴';

  @override
  String get actionClear => '清除';

  @override
  String get cleaning => '正在清理...';

  @override
  String get processLocally => '本地处理';

  @override
  String get notCertainReviewAlternatives => '此结果不是100%确定的。请查看下面的替代方案。';

  @override
  String get hideSupportedTitle => '隐藏支持的平台';

  @override
  String get hideSupportedQuestion => '您想临时隐藏此面板还是永远不再显示？';

  @override
  String get cancel => '取消';

  @override
  String get cleanLinkReady => '清洁链接已就绪';

  @override
  String get cleanLinkLabel => '清洁链接：';

  @override
  String get tipLongPressToCopy => '提示：长按任何链接进行复制';

  @override
  String get copyCleanLink => '复制清洁链接';

  @override
  String get tipTapOpenLongPressCopy => '提示：点击链接打开，长按复制';

  @override
  String get shareLink => '分享链接';

  @override
  String get technicalDetails => '技术详情';

  @override
  String get actionsTaken => '已执行的操作：';

  @override
  String get domain => '域名';

  @override
  String get strategy => '策略';

  @override
  String get processingTime => '处理时间';

  @override
  String get appliedAt => '应用时间';

  @override
  String get alternativeResults => '替代结果';

  @override
  String get alternative => '替代';

  @override
  String get shareAltWarning => '分享（可能仍包含跟踪参数）';

  @override
  String get shareAltWarningSnack => '警告：替代方案可能仍包含跟踪器';

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
  String get historyExported => '历史已导出到剪贴板';

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
  String get settingsResetToDefaults => '设置已重置为默认值';

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
  String get switchedToLocal => '切换到本地清理 - 使用设备处理';

  @override
  String get local => '本地';

  @override
  String get switchedToRemote => '切换到远程清理 - 使用云API';

  @override
  String get remote => '远程';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get urlCleanedCopiedAndShared => 'URL已清理：已复制并分享';

  @override
  String get couldNotLaunch => '无法启动';

  @override
  String get errorLaunchingUrl => '启动URL时出错：';

  @override
  String get switchedToLocalProcessingAndCleaned => '切换到本地处理并清理了URL';

  @override
  String get whyCleanLinks => 'Why clean links?';

  @override
  String get privacyNotes => 'Privacy Notes';

  @override
  String get chooseTheme => '选择主题';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get system => '系统';

  @override
  String get debugInfo => '调试信息';

  @override
  String get originalInput => '原始输入';

  @override
  String get localRemote => '本地/远程';

  @override
  String get supportedPlatformsAndWhatWeClean => '支持的平台和我们清理的内容';

  @override
  String get whyCleanLinksDescription =>
      '为什么要清理链接？短链接和\'分享\'链接通常携带可以分析您或暴露次要账户的标识符。例如：lnkd.in和pin.it可以揭示您打开的内容；Instagram分享链接（如/share/...）包含发送者派生的代码（igshid、igsh、si），可以将链接与您关联。我们标准化为直接、规范的URL——不仅仅是删除utm_*——以减少指纹识别和\'X与您分享了reel\'等提示。';

  @override
  String get privacyNotesDescription =>
      '隐私说明：\n• \'分享\'链接可以嵌入谁与谁分享了（例如Instagram /share、Reddit上下文、X s=20）。\n• 短链接服务（lnkd.in、pin.it）添加可以记录您点击的插页。\n• 平台参数（igshid、fbclid、rdt、share_app_id）可以将操作链接回您的账户。\n我们推广直接、规范的URL，以最小化分析和\'X与您分享了reel\'等社交提示。';

  @override
  String get example => '例如';

  @override
  String get general => '常规';

  @override
  String get autoCopyPrimaryResult => '自动复制主要结果';

  @override
  String get autoCopyPrimaryResultDesc => '自动将主要清洁链接复制到剪贴板';

  @override
  String get showConfirmation => '显示确认';

  @override
  String get showConfirmationDesc => '为操作显示确认对话框';

  @override
  String get showCleanLinkPreviews => '显示清洁链接预览';

  @override
  String get showCleanLinkPreviewsDesc => '仅为清洁链接渲染预览（仅本地，可禁用）';

  @override
  String get localProcessing => '本地处理';

  @override
  String get localProcessingDesc =>
      '在设备上本地处理链接而不是使用云API。启用时，所有清理都在您的设备上进行以获得更好的隐私。';

  @override
  String get localProcessingWebDesc => '在Web上不可用。使用移动应用进行离线/本地处理。';

  @override
  String get manageLocalStrategies => '管理本地策略';

  @override
  String manageLocalStrategiesDesc(Object strategyName) {
    return '活跃：$strategyName';
  }

  @override
  String get manageLocalStrategiesWebDesc => '在Web上不可用。下载应用以自定义离线策略。';

  @override
  String get theme => '主题';

  @override
  String get language => '语言';

  @override
  String get serverUrl => '服务器URL';

  @override
  String get serverUrlDesc => '输入您的TraceOff服务器URL';

  @override
  String get environment => '环境：';

  @override
  String get baseUrl => '基础URL：';

  @override
  String get apiUrl => 'API URL：';

  @override
  String get clearHistory => '清除历史';

  @override
  String get clearHistoryDesc => '删除所有历史项目';

  @override
  String get exportHistory => '导出历史';

  @override
  String get exportHistoryDesc => '将历史导出到剪贴板';

  @override
  String get version => '版本';

  @override
  String get openSource => '开源';

  @override
  String get openSourceDesc => '在GitHub上查看源代码';

  @override
  String get githubLinkNotImplemented => 'GitHub链接未实现';

  @override
  String get privacyPolicyDesc => '我们如何处理您的数据';

  @override
  String get resetToDefaults => '重置为默认值';

  @override
  String get resetToDefaultsDesc => '将所有设置重置为其默认值';

  @override
  String get localOfflineNotAvailableWeb => '本地离线处理在Web上不可用。下载应用以使用本地策略。';

  @override
  String get chooseLanguage => '选择语言';

  @override
  String get clearHistoryTitle => '清除历史';

  @override
  String get clearHistoryConfirm => '您确定要删除所有历史项目吗？此操作无法撤销。';

  @override
  String get clear => '清除';

  @override
  String get historyCleared => '历史已清除';

  @override
  String get noHistoryToExport => '没有要导出的历史项目';

  @override
  String get localCleaningStrategies => '本地清理策略';

  @override
  String get defaultOfflineCleaner => '默认离线清理器';

  @override
  String get defaultOfflineCleanerDesc => '使用内置离线清理策略';

  @override
  String get addStrategy => '添加策略';

  @override
  String get close => '关闭';

  @override
  String get newStrategy => '新策略';

  @override
  String get editStrategy => '编辑策略';

  @override
  String get steps => '步骤';

  @override
  String get addStep => '添加步骤';

  @override
  String get redirect => '重定向（N次）';

  @override
  String get removeQuery => '删除查询键';

  @override
  String get stripFragment => '删除片段';

  @override
  String get save => '保存';

  @override
  String get redirectStep => '重定向步骤';

  @override
  String get removeQueryKeys => '删除查询键';

  @override
  String get resetSettings => '重置设置';

  @override
  String get resetSettingsConfirm => '您确定要将所有设置重置为其默认值吗？';

  @override
  String get reset => '重置';

  @override
  String get dataManagement => '数据管理';

  @override
  String get about => '关于';
}
