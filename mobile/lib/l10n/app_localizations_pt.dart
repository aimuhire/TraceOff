// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'TraceOff — Links Limpos';

  @override
  String get tabClean => 'Limpar Link';

  @override
  String get tabHistory => 'Histórico';

  @override
  String get tabSettings => 'Configurações';

  @override
  String get supportedPlatformsTitle => 'Plataformas Suportadas';

  @override
  String get hide => 'Ocultar';

  @override
  String get dontShowAgain => 'Não mostrar novamente';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get settings => 'Configurações';

  @override
  String get history => 'Histórico';

  @override
  String get inputHint => 'Cole um link para limpar';

  @override
  String get clean => 'Limpar';

  @override
  String get snackPastedAndCleaning =>
      'URL colada da área de transferência e limpando...';

  @override
  String get snackPasted => 'URL colada da área de transferência';

  @override
  String get enterValidUrl => 'Por favor, insira uma URL válida http/https';

  @override
  String get processingMode => 'Modo de Processamento';

  @override
  String get pasteLinkTitle => 'Colar Link para Limpar';

  @override
  String get inputHintHttp => 'Cole um link para limpar (http/https)';

  @override
  String get actionPaste => 'Colar';

  @override
  String get actionClear => 'Limpar';

  @override
  String get cleaning => 'Limpando...';

  @override
  String get processLocally => 'Processar Localmente';

  @override
  String get notCertainReviewAlternatives =>
      'Este resultado não é 100% certo. Por favor, revise as alternativas abaixo.';

  @override
  String get hideSupportedTitle => 'Ocultar Plataformas Suportadas';

  @override
  String get hideSupportedQuestion =>
      'Você quer ocultar este painel temporariamente ou nunca mais mostrá-lo?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cleanLinkReady => 'Link Limpo Pronto';

  @override
  String get cleanLinkLabel => 'Link Limpo:';

  @override
  String get tipLongPressToCopy =>
      'Dica: Pressione e segure qualquer link para copiar';

  @override
  String get copyCleanLink => 'Copiar Link Limpo';

  @override
  String get tipTapOpenLongPressCopy =>
      'Dica: Toque no link para abrir, pressione e segure para copiar';

  @override
  String get shareLink => 'Compartilhar Link';

  @override
  String get technicalDetails => 'Detalhes Técnicos';

  @override
  String get actionsTaken => 'Ações realizadas:';

  @override
  String get domain => 'Domínio';

  @override
  String get strategy => 'Estratégia';

  @override
  String get processingTime => 'Tempo de Processamento';

  @override
  String get appliedAt => 'Aplicado em';

  @override
  String get alternativeResults => 'Resultados Alternativos';

  @override
  String get alternative => 'Alternativa';

  @override
  String get shareAltWarning =>
      'Compartilhar (pode ainda conter parâmetros de rastreamento)';

  @override
  String get shareAltWarningSnack =>
      'Aviso: A alternativa pode ainda conter rastreadores';

  @override
  String get tutorialProcessingModes => 'Modos de Processamento';

  @override
  String get tutorialLocalProcessing => 'Processamento Local';

  @override
  String get tutorialLocalDescription =>
      'A limpeza de URL acontece inteiramente no seu dispositivo';

  @override
  String get tutorialLocalPros1 =>
      'Privacidade completa - nenhum dado sai do seu dispositivo';

  @override
  String get tutorialLocalPros2 => 'Funciona offline - não requer internet';

  @override
  String get tutorialLocalPros3 =>
      'Sem dependência de servidor - sempre disponível';

  @override
  String get tutorialLocalPros4 =>
      'Perfeito para links sensíveis que você está enviando';

  @override
  String get tutorialLocalCons1 => 'Algoritmos de limpeza menos sofisticados';

  @override
  String get tutorialLocalCons2 =>
      'Pode perder alguns parâmetros de rastreamento';

  @override
  String get tutorialLocalCons3 =>
      'Limitado ao seguimento básico de redirecionamentos';

  @override
  String get tutorialLocalCons4 => 'Sem inteligência do lado do servidor';

  @override
  String get tutorialLocalWhenToUse =>
      'Use quando você quer máxima privacidade e está enviando links para outros. Seu endereço IP e a URL original nunca saem do seu dispositivo.';

  @override
  String get tutorialRemoteProcessing => 'Processamento Remoto';

  @override
  String get tutorialRemoteDescription =>
      'A limpeza de URL acontece em nossos servidores seguros';

  @override
  String get tutorialRemotePros1 => 'Algoritmos de limpeza avançados';

  @override
  String get tutorialRemotePros2 =>
      'Detecção abrangente de parâmetros de rastreamento';

  @override
  String get tutorialRemotePros3 =>
      'Inteligência do lado do servidor e atualizações';

  @override
  String get tutorialRemotePros4 =>
      'Melhores capacidades de seguimento de redirecionamentos';

  @override
  String get tutorialRemotePros5 => 'Melhorias regulares dos algoritmos';

  @override
  String get tutorialRemoteCons1 => 'Requer conexão com internet';

  @override
  String get tutorialRemoteCons2 => 'A URL é enviada para nossos servidores';

  @override
  String get tutorialRemoteCons3 =>
      'Seu endereço IP é visível para nossos servidores';

  @override
  String get tutorialRemoteCons4 => 'Depende da disponibilidade do servidor';

  @override
  String get tutorialRemoteWhenToUse =>
      'Use quando você quer os melhores resultados de limpeza e está processando links que recebeu de outros. Nossos servidores podem detectar mais parâmetros de rastreamento que o processamento local.';

  @override
  String get tutorialSecurityPrivacy => 'Segurança e Privacidade';

  @override
  String get tutorialSec1 => 'Nunca armazenamos suas URLs ou dados pessoais';

  @override
  String get tutorialSec2 => 'Todo o processamento é feito em tempo real';

  @override
  String get tutorialSec3 =>
      'Nenhum log é mantido de suas solicitações de limpeza';

  @override
  String get tutorialSec4 =>
      'Nossos servidores usam criptografia padrão da indústria';

  @override
  String get tutorialSec5 =>
      'Você pode alternar modos a qualquer momento sem perder dados';

  @override
  String get tutorialRecommendations => 'Nossas Recomendações';

  @override
  String get tutorialRec1 =>
      'Para links que você está enviando: Use Processamento Local';

  @override
  String get tutorialRec2 =>
      'Para links que você recebeu: Use Processamento Remoto';

  @override
  String get tutorialRec3 =>
      'Para melhores resultados: Use Processamento Remoto quando possível';

  @override
  String get tutorialRec4 =>
      'Em caso de dúvida: Comece com Remoto, mude para Local se necessário';

  @override
  String get tutorialAdvantages => 'Vantagens';

  @override
  String get tutorialLimitations => 'Limitações';

  @override
  String get tutorialWhenToUseLabel => 'Quando usar:';

  @override
  String get historyTitle => 'Histórico';

  @override
  String get historySearchHint => 'Pesquisar histórico...';

  @override
  String get historyShowAll => 'Mostrar Tudo';

  @override
  String get historyShowFavoritesOnly => 'Mostrar Apenas Favoritos';

  @override
  String get historyExport => 'Exportar Histórico';

  @override
  String get historyClearAll => 'Limpar Todo o Histórico';

  @override
  String get historyNoFavoritesYet => 'Nenhum item favorito ainda';

  @override
  String get historyNoItemsYet => 'Nenhum item no histórico ainda';

  @override
  String get historyFavoritesHint =>
      'Toque no ícone de coração em qualquer item para adicioná-lo aos favoritos';

  @override
  String get historyCleanSomeUrls => 'Limpe algumas URLs para vê-las aqui';

  @override
  String get historyOriginal => 'Original:';

  @override
  String get historyCleaned => 'Limpo:';

  @override
  String get historyConfidence => 'confiança';

  @override
  String get historyCopyOriginal => 'Copiar Original';

  @override
  String get historyCopyCleaned => 'Copiar Limpo';

  @override
  String get historyShare => 'Compartilhar';

  @override
  String get historyOpen => 'Abrir';

  @override
  String get historyReclean => 'Re-limpar';

  @override
  String get historyAddToFavorites => 'Adicionar aos Favoritos';

  @override
  String get historyRemoveFromFavorites => 'Remover dos Favoritos';

  @override
  String get historyDelete => 'Excluir';

  @override
  String get historyDeleteItem => 'Excluir Item';

  @override
  String get historyDeleteConfirm =>
      'Tem certeza de que deseja excluir este item do histórico?';

  @override
  String get historyClearAllTitle => 'Limpar Todo o Histórico';

  @override
  String get historyClearAllConfirm =>
      'Tem certeza de que deseja excluir todos os itens do histórico? Esta ação não pode ser desfeita.';

  @override
  String get historyClearAllAction => 'Limpar Tudo';

  @override
  String get historyOriginalCopied =>
      'URL original copiada para a área de transferência';

  @override
  String get historyCleanedCopied =>
      'URL limpa copiada para a área de transferência';

  @override
  String get historyExported =>
      'Histórico exportado para a área de transferência';

  @override
  String get historyCouldNotLaunch => 'Não foi possível abrir';

  @override
  String get historyErrorLaunching => 'Erro ao abrir URL:';

  @override
  String get historyJustNow => 'Agora mesmo';

  @override
  String get historyDaysAgo => 'd atrás';

  @override
  String get historyHoursAgo => 'h atrás';

  @override
  String get historyMinutesAgo => 'm atrás';

  @override
  String get settingsGeneral => 'Geral';

  @override
  String get settingsCleaningStrategies => 'Estratégias de Limpeza';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsServer => 'Servidor';

  @override
  String get settingsDataManagement => 'Gerenciamento de Dados';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get settingsAutoCopyPrimary => 'Auto-copiar Resultado Principal';

  @override
  String get settingsAutoCopyPrimaryDesc =>
      'Copiar automaticamente o link limpo principal para a área de transferência';

  @override
  String get settingsShowConfirmation => 'Mostrar Confirmação';

  @override
  String get settingsShowConfirmationDesc =>
      'Mostrar diálogos de confirmação para ações';

  @override
  String get settingsShowCleanLinkPreviews =>
      'Mostrar Visualizações de Links Limpos';

  @override
  String get settingsShowCleanLinkPreviewsDesc =>
      'Renderizar visualizações apenas para links limpos (apenas local, pode ser desabilitado)';

  @override
  String get settingsLocalProcessing => 'Processamento Local';

  @override
  String get settingsLocalProcessingDesc =>
      'Processar links localmente no dispositivo em vez de usar a API em nuvem. Quando habilitado, toda a limpeza acontece no seu dispositivo para melhor privacidade.';

  @override
  String get settingsLocalProcessingWebDesc =>
      'Não disponível na web. Use o aplicativo móvel para processamento offline/local.';

  @override
  String get settingsManageLocalStrategies => 'Gerenciar Estratégias Locais';

  @override
  String settingsManageLocalStrategiesDesc(Object strategyName) {
    return 'Ativo: $strategyName';
  }

  @override
  String get settingsManageLocalStrategiesWebDesc =>
      'Não disponível na web. Baixe o aplicativo para personalizar estratégias offline.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsServerUrl => 'URL do Servidor';

  @override
  String get settingsServerUrlDesc => 'Insira a URL do seu servidor TraceOff';

  @override
  String get settingsClearHistory => 'Limpar Histórico';

  @override
  String get settingsClearHistoryDesc => 'Remover todos os itens do histórico';

  @override
  String get settingsExportHistory => 'Exportar Histórico';

  @override
  String get settingsExportHistoryDesc =>
      'Exportar histórico para a área de transferência';

  @override
  String get settingsVersion => 'Versão';

  @override
  String get settingsOpenSource => 'Código Aberto';

  @override
  String get settingsOpenSourceDesc => 'Ver código fonte no GitHub';

  @override
  String get settingsGitHubNotImplemented => 'Link do GitHub não implementado';

  @override
  String get settingsResetToDefaults =>
      'Configurações redefinidas para padrões';

  @override
  String get settingsResetToDefaultsDesc =>
      'Redefinir todas as configurações para seus valores padrão';

  @override
  String get settingsSystemDefault => 'Padrão do Sistema';

  @override
  String get settingsLight => 'Claro';

  @override
  String get settingsDark => 'Escuro';

  @override
  String get settingsChooseTheme => 'Escolher Tema';

  @override
  String get settingsChooseLanguage => 'Escolher Idioma';

  @override
  String get settingsClearHistoryTitle => 'Limpar Histórico';

  @override
  String get settingsClearHistoryConfirm =>
      'Tem certeza de que deseja excluir todos os itens do histórico? Esta ação não pode ser desfeita.';

  @override
  String get settingsHistoryCleared => 'Histórico limpo';

  @override
  String get settingsNoHistoryToExport =>
      'Nenhum item do histórico para exportar';

  @override
  String get settingsHistoryExported =>
      'Histórico exportado para a área de transferência';

  @override
  String get settingsResetSettings => 'Redefinir Configurações';

  @override
  String get settingsResetSettingsConfirm =>
      'Tem certeza de que deseja redefinir todas as configurações para seus valores padrão?';

  @override
  String get settingsReset => 'Redefinir';

  @override
  String get settingsSettingsResetToDefaults =>
      'Configurações redefinidas para padrões';

  @override
  String get settingsLocalStrategiesTitle => 'Estratégias de Limpeza Locais';

  @override
  String get settingsDefaultOfflineCleaner => 'Limpeza offline padrão';

  @override
  String get settingsDefaultOfflineCleanerDesc =>
      'Usar estratégia de limpeza offline integrada';

  @override
  String get settingsAddStrategy => 'Adicionar Estratégia';

  @override
  String get settingsNewStrategy => 'Nova Estratégia';

  @override
  String get settingsEditStrategy => 'Editar Estratégia';

  @override
  String get settingsStrategyName => 'Nome';

  @override
  String get settingsSteps => 'Etapas';

  @override
  String get settingsAddStep => 'Adicionar Etapa';

  @override
  String get settingsRedirectStep => 'Etapa de redirecionamento';

  @override
  String get settingsTimes => 'Vezes';

  @override
  String get settingsRemoveQueryKeys => 'Remover chaves de consulta';

  @override
  String get settingsCommaSeparatedKeys => 'Chaves separadas por vírgula';

  @override
  String get settingsCommaSeparatedKeysHint =>
      'ex. utm_source, utm_medium, fbclid';

  @override
  String get settingsRedirect => 'Redirecionar (N vezes)';

  @override
  String get settingsRemoveQuery => 'Remover chaves de consulta';

  @override
  String get settingsStripFragment => 'Remover fragmento';

  @override
  String get settingsClose => 'Fechar';

  @override
  String get settingsSave => 'Salvar';

  @override
  String get settingsCancel => 'Cancelar';

  @override
  String settingsRedirectTimes(Object times) {
    return 'Redirecionar $times vez(es)';
  }

  @override
  String get settingsRemoveNoQueryKeys => 'Não remover chaves de consulta';

  @override
  String settingsRemoveKeys(Object keys) {
    return 'Remover chaves: $keys';
  }

  @override
  String get settingsStripUrlFragment => 'Remover fragmento de URL';

  @override
  String get switchedToLocal =>
      'Mudado para limpeza local - usando processamento do dispositivo';

  @override
  String get local => 'Local';

  @override
  String get switchedToRemote =>
      'Mudado para limpeza remota - usando API em nuvem';

  @override
  String get remote => 'Remoto';

  @override
  String get copiedToClipboard => 'Copiado para a área de transferência';

  @override
  String get urlCleanedCopiedAndShared => 'URL limpa: copiada e compartilhada';

  @override
  String get couldNotLaunch => 'Não foi possível abrir';

  @override
  String get errorLaunchingUrl => 'Erro ao abrir URL:';

  @override
  String get switchedToLocalProcessingAndCleaned =>
      'Mudado para processamento local e limpo a URL';

  @override
  String get whyCleanLinks => 'Por que limpar links?';

  @override
  String get privacyNotes => 'Notas de Privacidade';

  @override
  String get chooseTheme => 'Escolher Tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Escuro';

  @override
  String get system => 'Sistema';

  @override
  String get debugInfo => 'Informações de Debug:';

  @override
  String get originalInput => 'Entrada Original';

  @override
  String get localRemote => 'Local/Remoto';

  @override
  String get supportedPlatformsAndWhatWeClean =>
      'Plataformas Suportadas e O Que Limpamos';

  @override
  String get whyCleanLinksDescription =>
      'Por que limpar links? Links curtos e links de \"compartilhamento\" frequentemente carregam identificadores que podem perfilar você ou expor contas secundárias. Exemplos: lnkd.in e pin.it podem revelar o que você abriu; links de compartilhamento do Instagram (como /share/...) incluem códigos derivados do remetente (igshid, igsh, si) que podem vincular o link a você. Normalizamos para uma URL direta e canônica — não apenas removendo utm_* — para reduzir fingerprinting e prompts como \"X compartilhou um reel com você.\"';

  @override
  String get privacyNotesDescription =>
      'Notas de privacidade:\n• Links de \"compartilhamento\" podem incorporar quem compartilhou com quem (ex. Instagram /share, contexto Reddit, X s=20).\n• Encurtadores (lnkd.in, pin.it) adicionam intersticiais que podem registrar seu clique.\n• Parâmetros de plataforma (igshid, fbclid, rdt, share_app_id) podem vincular a ação à sua conta.\nPromovemos URLs diretas e canônicas para minimizar perfis e prompts sociais como \"X compartilhou um reel com você.\"';

  @override
  String get example => 'ex.';

  @override
  String get general => 'Geral';

  @override
  String get autoCopyPrimaryResult => 'Auto-copiar Resultado Principal';

  @override
  String get autoCopyPrimaryResultDesc =>
      'Copiar automaticamente o link limpo principal para a área de transferência';

  @override
  String get showConfirmation => 'Mostrar Confirmação';

  @override
  String get showConfirmationDesc =>
      'Mostrar diálogos de confirmação para ações';

  @override
  String get showCleanLinkPreviews => 'Mostrar Visualizações de Links Limpos';

  @override
  String get showCleanLinkPreviewsDesc =>
      'Renderizar visualizações apenas para links limpos (apenas local, pode ser desabilitado)';

  @override
  String get localProcessing => 'Processamento Local';

  @override
  String get localProcessingDesc =>
      'Processar links localmente no dispositivo em vez de usar a API em nuvem. Quando habilitado, toda a limpeza acontece no seu dispositivo para melhor privacidade.';

  @override
  String get localProcessingWebDesc =>
      'Não disponível na web. Use o aplicativo móvel para processamento offline/local.';

  @override
  String get manageLocalStrategies => 'Gerenciar Estratégias Locais';

  @override
  String manageLocalStrategiesDesc(Object strategyName) {
    return 'Ativo: $strategyName';
  }

  @override
  String get manageLocalStrategiesWebDesc =>
      'Não disponível na web. Baixe o aplicativo para personalizar estratégias offline.';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Idioma';

  @override
  String get serverUrl => 'URL do Servidor';

  @override
  String get serverUrlDesc => 'Digite a URL do seu servidor TraceOff';

  @override
  String get environment => 'Ambiente:';

  @override
  String get baseUrl => 'URL Base:';

  @override
  String get apiUrl => 'URL da API:';

  @override
  String get clearHistory => 'Limpar Histórico';

  @override
  String get clearHistoryDesc => 'Remover todos os itens do histórico';

  @override
  String get exportHistory => 'Exportar Histórico';

  @override
  String get exportHistoryDesc =>
      'Exportar histórico para a área de transferência';

  @override
  String get version => 'Versão';

  @override
  String get openSource => 'Código Aberto';

  @override
  String get openSourceDesc => 'Ver código fonte no GitHub';

  @override
  String get githubLinkNotImplemented => 'Link do GitHub não implementado';

  @override
  String get privacyPolicyDesc => 'Como lidamos com seus dados';

  @override
  String get resetToDefaults => 'Redefinir para Padrões';

  @override
  String get resetToDefaultsDesc =>
      'Redefinir todas as configurações para seus valores padrão';

  @override
  String get localOfflineNotAvailableWeb =>
      'Processamento local offline não está disponível na web. Baixe o aplicativo para usar estratégias locais.';

  @override
  String get chooseLanguage => 'Escolher Idioma';

  @override
  String get clearHistoryTitle => 'Limpar Histórico';

  @override
  String get clearHistoryConfirm =>
      'Tem certeza de que deseja excluir todos os itens do histórico? Esta ação não pode ser desfeita.';

  @override
  String get clear => 'Limpar';

  @override
  String get historyCleared => 'Histórico limpo';

  @override
  String get noHistoryToExport => 'Nenhum item do histórico para exportar';

  @override
  String get localCleaningStrategies => 'Estratégias de Limpeza Locais';

  @override
  String get defaultOfflineCleaner => 'Limpeza offline padrão';

  @override
  String get defaultOfflineCleanerDesc =>
      'Usar estratégia de limpeza offline integrada';

  @override
  String get addStrategy => 'Adicionar Estratégia';

  @override
  String get close => 'Fechar';

  @override
  String get newStrategy => 'Nova Estratégia';

  @override
  String get editStrategy => 'Editar Estratégia';

  @override
  String get steps => 'Passos';

  @override
  String get addStep => 'Adicionar Passo';

  @override
  String get redirect => 'Redirecionar (N vezes)';

  @override
  String get removeQuery => 'Remover chaves de consulta';

  @override
  String get stripFragment => 'Remover fragmento';

  @override
  String get save => 'Salvar';

  @override
  String get redirectStep => 'Passo de redirecionamento';

  @override
  String get removeQueryKeys => 'Remover chaves de consulta';

  @override
  String get resetSettings => 'Redefinir Configurações';

  @override
  String get resetSettingsConfirm =>
      'Tem certeza de que deseja redefinir todas as configurações para seus valores padrão?';

  @override
  String get reset => 'Redefinir';

  @override
  String get dataManagement => 'Gerenciamento de Dados';

  @override
  String get about => 'Sobre';
}
