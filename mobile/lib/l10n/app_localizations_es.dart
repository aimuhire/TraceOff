// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'TraceOff — Enlaces Limpios';

  @override
  String get tabClean => 'Limpiar Enlace';

  @override
  String get tabHistory => 'Historial';

  @override
  String get tabSettings => 'Configuración';

  @override
  String get supportedPlatformsTitle => 'Plataformas Compatibles';

  @override
  String get hide => 'Ocultar';

  @override
  String get dontShowAgain => 'No mostrar de nuevo';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get settings => 'Configuración';

  @override
  String get history => 'Historial';

  @override
  String get inputHint => 'Pega un enlace para limpiar';

  @override
  String get clean => 'Limpiar';

  @override
  String get snackPastedAndCleaning =>
      'URL pegada del portapapeles y limpiando...';

  @override
  String get snackPasted => 'URL pegada del portapapeles';

  @override
  String get enterValidUrl => 'Por favor ingresa una URL válida http/https';

  @override
  String get processingMode => 'Modo de Procesamiento';

  @override
  String get pasteLinkTitle => 'Pegar Enlace para Limpiar';

  @override
  String get inputHintHttp => 'Pega un enlace para limpiar (http/https)';

  @override
  String get actionPaste => 'Pegar';

  @override
  String get actionClear => 'Limpiar';

  @override
  String get cleaning => 'Limpiando...';

  @override
  String get processLocally => 'Procesar Localmente';

  @override
  String get notCertainReviewAlternatives =>
      'Este resultado no es 100% seguro. Por favor revisa las alternativas a continuación.';

  @override
  String get hideSupportedTitle => 'Ocultar Plataformas Compatibles';

  @override
  String get hideSupportedQuestion =>
      '¿Quieres ocultar este panel temporalmente o nunca mostrarlo de nuevo?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cleanLinkReady => 'Enlace Limpio Listo';

  @override
  String get cleanLinkLabel => 'Enlace Limpio:';

  @override
  String get tipLongPressToCopy =>
      'Consejo: Mantén presionado cualquier enlace para copiar';

  @override
  String get copyCleanLink => 'Copiar Enlace Limpio';

  @override
  String get tipTapOpenLongPressCopy =>
      'Consejo: Toca el enlace para abrir, mantén presionado para copiar';

  @override
  String get shareLink => 'Compartir Enlace';

  @override
  String get technicalDetails => 'Detalles Técnicos';

  @override
  String get actionsTaken => 'Acciones realizadas:';

  @override
  String get domain => 'Dominio';

  @override
  String get strategy => 'Estrategia';

  @override
  String get processingTime => 'Tiempo de Procesamiento';

  @override
  String get appliedAt => 'Aplicado en';

  @override
  String get alternativeResults => 'Resultados Alternativos';

  @override
  String get alternative => 'Alternativa';

  @override
  String get shareAltWarning =>
      'Compartir (puede contener parámetros de seguimiento)';

  @override
  String get shareAltWarningSnack =>
      'Advertencia: La alternativa puede contener rastreadores';

  @override
  String get tutorialProcessingModes => 'Modos de Procesamiento';

  @override
  String get tutorialLocalProcessing => 'Procesamiento Local';

  @override
  String get tutorialLocalDescription =>
      'La limpieza de URL ocurre completamente en tu dispositivo';

  @override
  String get tutorialLocalPros1 =>
      'Privacidad completa - ningún dato sale de tu dispositivo';

  @override
  String get tutorialLocalPros2 =>
      'Funciona sin conexión - no requiere internet';

  @override
  String get tutorialLocalPros3 =>
      'Sin dependencia del servidor - siempre disponible';

  @override
  String get tutorialLocalPros4 =>
      'Perfecto para enlaces sensibles que estás enviando';

  @override
  String get tutorialLocalCons1 => 'Algoritmos de limpieza menos sofisticados';

  @override
  String get tutorialLocalCons2 =>
      'Puede perder algunos parámetros de seguimiento';

  @override
  String get tutorialLocalCons3 =>
      'Limitado a seguimiento básico de redirecciones';

  @override
  String get tutorialLocalCons4 => 'Sin inteligencia del lado del servidor';

  @override
  String get tutorialLocalWhenToUse =>
      'Usa cuando quieras máxima privacidad y estés enviando enlaces a otros. Tu dirección IP y la URL original nunca salen de tu dispositivo.';

  @override
  String get tutorialRemoteProcessing => 'Procesamiento Remoto';

  @override
  String get tutorialRemoteDescription =>
      'La limpieza de URL ocurre en nuestros servidores seguros';

  @override
  String get tutorialRemotePros1 => 'Algoritmos de limpieza avanzados';

  @override
  String get tutorialRemotePros2 =>
      'Detección integral de parámetros de seguimiento';

  @override
  String get tutorialRemotePros3 =>
      'Inteligencia del servidor y actualizaciones';

  @override
  String get tutorialRemotePros4 =>
      'Mejores capacidades de seguimiento de redirecciones';

  @override
  String get tutorialRemotePros5 => 'Mejoras regulares de algoritmos';

  @override
  String get tutorialRemoteCons1 => 'Requiere conexión a internet';

  @override
  String get tutorialRemoteCons2 => 'La URL se envía a nuestros servidores';

  @override
  String get tutorialRemoteCons3 =>
      'Tu dirección IP es visible para nuestros servidores';

  @override
  String get tutorialRemoteCons4 => 'Depende de la disponibilidad del servidor';

  @override
  String get tutorialRemoteWhenToUse =>
      'Usa cuando quieras los mejores resultados de limpieza y estés procesando enlaces que recibiste de otros. Nuestros servidores pueden detectar más parámetros de seguimiento que el procesamiento local.';

  @override
  String get tutorialSecurityPrivacy => 'Seguridad y Privacidad';

  @override
  String get tutorialSec1 => 'Nunca almacenamos tus URLs o datos personales';

  @override
  String get tutorialSec2 => 'Todo el procesamiento se hace en tiempo real';

  @override
  String get tutorialSec3 =>
      'No se mantienen registros de tus solicitudes de limpieza';

  @override
  String get tutorialSec4 =>
      'Nuestros servidores usan cifrado estándar de la industria';

  @override
  String get tutorialSec5 =>
      'Puedes cambiar modos en cualquier momento sin perder datos';

  @override
  String get tutorialRecommendations => 'Nuestras Recomendaciones';

  @override
  String get tutorialRec1 =>
      'Para enlaces que estás enviando: Usa Procesamiento Local';

  @override
  String get tutorialRec2 =>
      'Para enlaces que recibiste: Usa Procesamiento Remoto';

  @override
  String get tutorialRec3 =>
      'Para mejores resultados: Usa Procesamiento Remoto cuando sea posible';

  @override
  String get tutorialRec4 =>
      'En caso de duda: Comienza con Remoto, cambia a Local si es necesario';

  @override
  String get tutorialAdvantages => 'Ventajas';

  @override
  String get tutorialLimitations => 'Limitaciones';

  @override
  String get tutorialWhenToUseLabel => 'Cuándo usar:';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historySearchHint => 'Buscar en historial...';

  @override
  String get historyShowAll => 'Mostrar Todo';

  @override
  String get historyShowFavoritesOnly => 'Mostrar Solo Favoritos';

  @override
  String get historyExport => 'Exportar Historial';

  @override
  String get historyClearAll => 'Limpiar Todo el Historial';

  @override
  String get historyNoFavoritesYet => 'Aún no hay elementos favoritos';

  @override
  String get historyNoItemsYet => 'Aún no hay elementos en el historial';

  @override
  String get historyFavoritesHint =>
      'Toca el ícono de corazón en cualquier elemento para agregarlo a favoritos';

  @override
  String get historyCleanSomeUrls => 'Limpia algunas URLs para verlas aquí';

  @override
  String get historyOriginal => 'Original:';

  @override
  String get historyCleaned => 'Limpiado:';

  @override
  String get historyConfidence => 'confianza';

  @override
  String get historyCopyOriginal => 'Copiar Original';

  @override
  String get historyCopyCleaned => 'Copiar Limpiado';

  @override
  String get historyShare => 'Compartir';

  @override
  String get historyOpen => 'Abrir';

  @override
  String get historyReclean => 'Re-limpiar';

  @override
  String get historyAddToFavorites => 'Agregar a Favoritos';

  @override
  String get historyRemoveFromFavorites => 'Quitar de Favoritos';

  @override
  String get historyDelete => 'Eliminar';

  @override
  String get historyDeleteItem => 'Eliminar Elemento';

  @override
  String get historyDeleteConfirm =>
      '¿Estás seguro de que quieres eliminar este elemento del historial?';

  @override
  String get historyClearAllTitle => 'Limpiar Todo el Historial';

  @override
  String get historyClearAllConfirm =>
      '¿Estás seguro de que quieres eliminar todos los elementos del historial? Esta acción no se puede deshacer.';

  @override
  String get historyClearAllAction => 'Limpiar Todo';

  @override
  String get historyOriginalCopied => 'URL original copiada al portapapeles';

  @override
  String get historyCleanedCopied => 'URL limpia copiada al portapapeles';

  @override
  String get historyExported => 'Historial exportado al portapapeles';

  @override
  String get historyCouldNotLaunch => 'No se pudo abrir';

  @override
  String get historyErrorLaunching => 'Error al abrir URL:';

  @override
  String get historyJustNow => 'Ahora mismo';

  @override
  String get historyDaysAgo => 'd atrás';

  @override
  String get historyHoursAgo => 'h atrás';

  @override
  String get historyMinutesAgo => 'm atrás';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsCleaningStrategies => 'Estrategias de Limpieza';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsServer => 'Servidor';

  @override
  String get settingsDataManagement => 'Gestión de Datos';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAutoCopyPrimary => 'Auto-copiar Resultado Principal';

  @override
  String get settingsAutoCopyPrimaryDesc =>
      'Copiar automáticamente el enlace limpio principal al portapapeles';

  @override
  String get settingsShowConfirmation => 'Mostrar Confirmación';

  @override
  String get settingsShowConfirmationDesc =>
      'Mostrar diálogos de confirmación para acciones';

  @override
  String get settingsShowCleanLinkPreviews =>
      'Mostrar Previsualizaciones de Enlaces Limpios';

  @override
  String get settingsShowCleanLinkPreviewsDesc =>
      'Renderizar previsualizaciones solo para enlaces limpios (solo local, se puede deshabilitar)';

  @override
  String get settingsLocalProcessing => 'Procesamiento Local';

  @override
  String get settingsLocalProcessingDesc =>
      'Procesar enlaces localmente en el dispositivo en lugar de usar la API en la nube. Cuando está habilitado, toda la limpieza ocurre en tu dispositivo para mejor privacidad.';

  @override
  String get settingsLocalProcessingWebDesc =>
      'No disponible en web. Usa la aplicación móvil para procesamiento fuera de línea/local.';

  @override
  String get settingsManageLocalStrategies => 'Gestionar Estrategias Locales';

  @override
  String settingsManageLocalStrategiesDesc(Object strategyName) {
    return 'Activo: $strategyName';
  }

  @override
  String get settingsManageLocalStrategiesWebDesc =>
      'No disponible en web. Descarga la aplicación para personalizar estrategias fuera de línea.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsServerUrl => 'URL del Servidor';

  @override
  String get settingsServerUrlDesc => 'Ingresa la URL de tu servidor TraceOff';

  @override
  String get settingsClearHistory => 'Limpiar Historial';

  @override
  String get settingsClearHistoryDesc =>
      'Eliminar todos los elementos del historial';

  @override
  String get settingsExportHistory => 'Exportar Historial';

  @override
  String get settingsExportHistoryDesc => 'Exportar historial al portapapeles';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsOpenSource => 'Código Abierto';

  @override
  String get settingsOpenSourceDesc => 'Ver código fuente en GitHub';

  @override
  String get settingsGitHubNotImplemented => 'Enlace de GitHub no implementado';

  @override
  String get settingsResetToDefaults =>
      'Configuraciones restablecidas a valores predeterminados';

  @override
  String get settingsResetToDefaultsDesc =>
      'Restablecer todas las configuraciones a sus valores predeterminados';

  @override
  String get settingsSystemDefault => 'Predeterminado del Sistema';

  @override
  String get settingsLight => 'Claro';

  @override
  String get settingsDark => 'Oscuro';

  @override
  String get settingsChooseTheme => 'Elegir Tema';

  @override
  String get settingsChooseLanguage => 'Elegir Idioma';

  @override
  String get settingsClearHistoryTitle => 'Limpiar Historial';

  @override
  String get settingsClearHistoryConfirm =>
      '¿Estás seguro de que quieres eliminar todos los elementos del historial? Esta acción no se puede deshacer.';

  @override
  String get settingsHistoryCleared => 'Historial limpiado';

  @override
  String get settingsNoHistoryToExport =>
      'No hay elementos del historial para exportar';

  @override
  String get settingsHistoryExported => 'Historial exportado al portapapeles';

  @override
  String get settingsResetSettings => 'Restablecer Configuración';

  @override
  String get settingsResetSettingsConfirm =>
      '¿Estás seguro de que quieres restablecer todas las configuraciones a sus valores predeterminados?';

  @override
  String get settingsReset => 'Restablecer';

  @override
  String get settingsSettingsResetToDefaults =>
      'Configuración restablecida a valores predeterminados';

  @override
  String get settingsLocalStrategiesTitle => 'Estrategias de Limpieza Locales';

  @override
  String get settingsDefaultOfflineCleaner =>
      'Limpiador fuera de línea predeterminado';

  @override
  String get settingsDefaultOfflineCleanerDesc =>
      'Usar estrategia de limpieza fuera de línea integrada';

  @override
  String get settingsAddStrategy => 'Agregar Estrategia';

  @override
  String get settingsNewStrategy => 'Nueva Estrategia';

  @override
  String get settingsEditStrategy => 'Editar Estrategia';

  @override
  String get settingsStrategyName => 'Nombre';

  @override
  String get settingsSteps => 'Pasos';

  @override
  String get settingsAddStep => 'Agregar Paso';

  @override
  String get settingsRedirectStep => 'Paso de redirección';

  @override
  String get settingsTimes => 'Veces';

  @override
  String get settingsRemoveQueryKeys => 'Eliminar claves de consulta';

  @override
  String get settingsCommaSeparatedKeys => 'Claves separadas por comas';

  @override
  String get settingsCommaSeparatedKeysHint =>
      'ej. utm_source, utm_medium, fbclid';

  @override
  String get settingsRedirect => 'Redirigir (N veces)';

  @override
  String get settingsRemoveQuery => 'Eliminar claves de consulta';

  @override
  String get settingsStripFragment => 'Eliminar fragmento';

  @override
  String get settingsClose => 'Cerrar';

  @override
  String get settingsSave => 'Guardar';

  @override
  String get settingsCancel => 'Cancelar';

  @override
  String settingsRedirectTimes(Object times) {
    return 'Redirigir $times vez(es)';
  }

  @override
  String get settingsRemoveNoQueryKeys => 'No eliminar claves de consulta';

  @override
  String settingsRemoveKeys(Object keys) {
    return 'Eliminar claves: $keys';
  }

  @override
  String get settingsStripUrlFragment => 'Eliminar fragmento de URL';

  @override
  String get switchedToLocal =>
      'Cambiado a limpieza local - usando procesamiento del dispositivo';

  @override
  String get local => 'Local';

  @override
  String get switchedToRemote =>
      'Cambiado a limpieza remota - usando API en la nube';

  @override
  String get remote => 'Remoto';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get urlCleanedCopiedAndShared => 'URL limpiada: copiada y compartida';

  @override
  String get couldNotLaunch => 'No se pudo abrir';

  @override
  String get errorLaunchingUrl => 'Error al abrir la URL:';

  @override
  String get switchedToLocalProcessingAndCleaned =>
      'Cambiado a procesamiento local y limpiado la URL';

  @override
  String get whyCleanLinks => '¿Por qué limpiar enlaces?';

  @override
  String get privacyNotes => 'Notas de Privacidad';

  @override
  String get chooseTheme => 'Elegir Tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get system => 'Sistema';

  @override
  String get debugInfo => 'Información de Depuración:';

  @override
  String get originalInput => 'Entrada Original';

  @override
  String get localRemote => 'Local/Remoto';

  @override
  String get supportedPlatformsAndWhatWeClean =>
      'Plataformas Compatibles y Lo Que Limpiamos';

  @override
  String get whyCleanLinksDescription =>
      '¿Por qué limpiar enlaces? Los enlaces cortos y los enlaces de \"compartir\" a menudo llevan identificadores que pueden perfilarte o exponer cuentas secundarias. Ejemplos: lnkd.in y pin.it pueden revelar lo que abriste; los enlaces de compartir de Instagram (como /share/...) incluyen códigos derivados del remitente (igshid, igsh, si) que pueden vincular el enlace contigo. Normalizamos a una URL directa y canónica — no solo removiendo utm_* — para reducir el fingerprinting y mensajes como \"X compartió un reel contigo.\"';

  @override
  String get privacyNotesDescription =>
      'Notas de privacidad:\n• Los enlaces de \"compartir\" pueden incrustar quién compartió con quién (ej. Instagram /share, contexto Reddit, X s=20).\n• Los acortadores (lnkd.in, pin.it) agregan intersticiales que pueden registrar tu clic.\n• Los parámetros de plataforma (igshid, fbclid, rdt, share_app_id) pueden vincular la acción a tu cuenta.\nPromovemos URLs directas y canónicas para minimizar el perfilado y mensajes sociales como \"X compartió un reel contigo.\"';

  @override
  String get example => 'ej.';

  @override
  String get general => 'General';

  @override
  String get autoCopyPrimaryResult => 'Auto-copiar Resultado Principal';

  @override
  String get autoCopyPrimaryResultDesc =>
      'Copiar automáticamente el enlace limpio principal al portapapeles';

  @override
  String get showConfirmation => 'Mostrar Confirmación';

  @override
  String get showConfirmationDesc =>
      'Mostrar diálogos de confirmación para acciones';

  @override
  String get showCleanLinkPreviews => 'Mostrar Vista Previa de Enlaces Limpios';

  @override
  String get showCleanLinkPreviewsDesc =>
      'Renderizar vistas previas solo para enlaces limpios (solo local, puede deshabilitarse)';

  @override
  String get localProcessing => 'Procesamiento Local';

  @override
  String get localProcessingDesc =>
      'Procesar enlaces localmente en el dispositivo en lugar de usar la API en la nube. Cuando está habilitado, toda la limpieza ocurre en tu dispositivo para mejor privacidad.';

  @override
  String get localProcessingWebDesc =>
      'No disponible en web. Usa la aplicación móvil para procesamiento offline/local.';

  @override
  String get manageLocalStrategies => 'Gestionar Estrategias Locales';

  @override
  String manageLocalStrategiesDesc(Object strategyName) {
    return 'Activo: $strategyName';
  }

  @override
  String get manageLocalStrategiesWebDesc =>
      'No disponible en web. Descarga la aplicación para personalizar estrategias offline.';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Idioma';

  @override
  String get serverUrl => 'URL del Servidor';

  @override
  String get serverUrlDesc => 'Ingresa la URL de tu servidor TraceOff';

  @override
  String get environment => 'Entorno:';

  @override
  String get baseUrl => 'URL Base:';

  @override
  String get apiUrl => 'URL de API:';

  @override
  String get clearHistory => 'Limpiar Historial';

  @override
  String get clearHistoryDesc => 'Eliminar todos los elementos del historial';

  @override
  String get exportHistory => 'Exportar Historial';

  @override
  String get exportHistoryDesc => 'Exportar historial al portapapeles';

  @override
  String get version => 'Versión';

  @override
  String get openSource => 'Código Abierto';

  @override
  String get openSourceDesc => 'Ver código fuente en GitHub';

  @override
  String get githubLinkNotImplemented => 'Enlace de GitHub no implementado';

  @override
  String get privacyPolicyDesc => 'Cómo manejamos tus datos';

  @override
  String get resetToDefaults => 'Restablecer a Valores Predeterminados';

  @override
  String get resetToDefaultsDesc =>
      'Restablecer todas las configuraciones a sus valores predeterminados';

  @override
  String get localOfflineNotAvailableWeb =>
      'El procesamiento local offline no está disponible en web. Descarga la aplicación para usar estrategias locales.';

  @override
  String get chooseLanguage => 'Elegir Idioma';

  @override
  String get clearHistoryTitle => 'Limpiar Historial';

  @override
  String get clearHistoryConfirm =>
      '¿Estás seguro de que quieres eliminar todos los elementos del historial? Esta acción no se puede deshacer.';

  @override
  String get clear => 'Limpiar';

  @override
  String get historyCleared => 'Historial limpiado';

  @override
  String get noHistoryToExport =>
      'No hay elementos del historial para exportar';

  @override
  String get localCleaningStrategies => 'Estrategias de Limpieza Locales';

  @override
  String get defaultOfflineCleaner => 'Limpiador offline predeterminado';

  @override
  String get defaultOfflineCleanerDesc =>
      'Usar estrategia de limpieza offline integrada';

  @override
  String get addStrategy => 'Agregar Estrategia';

  @override
  String get close => 'Cerrar';

  @override
  String get newStrategy => 'Nueva Estrategia';

  @override
  String get editStrategy => 'Editar Estrategia';

  @override
  String get steps => 'Pasos';

  @override
  String get addStep => 'Agregar Paso';

  @override
  String get redirect => 'Redirigir (N veces)';

  @override
  String get removeQuery => 'Eliminar claves de consulta';

  @override
  String get stripFragment => 'Eliminar fragmento';

  @override
  String get save => 'Guardar';

  @override
  String get redirectStep => 'Paso de redirección';

  @override
  String get removeQueryKeys => 'Eliminar claves de consulta';

  @override
  String get resetSettings => 'Restablecer Configuraciones';

  @override
  String get resetSettingsConfirm =>
      '¿Estás seguro de que quieres restablecer todas las configuraciones a sus valores predeterminados?';

  @override
  String get reset => 'Restablecer';

  @override
  String get dataManagement => 'Gestión de Datos';

  @override
  String get about => 'Acerca de';
}
