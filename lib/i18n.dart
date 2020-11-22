import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' hide TextDirection;

// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unnecessary_brace_in_string_interps
// ignore_for_file: unused_import
// ignore_for_file: annotate_overrides
// ignore_for_file: avoid_annotating_with_dynamic
// ignore_for_file: implicit_dynamic_parameter

// See more about language plural rules: https://unicode-org.github.io/cldr-staging/charts/37/supplemental/language_plural_rules.html

const I18n enUS = _I18n_en_US();
const I18n esMX = _I18n_es_MX();
const I18n ptBR = _I18n_pt_BR();
const I18n zhCN = _I18n_zh_CN();

class _I18n_en_US extends I18n {
  const _I18n_en_US();
}

class I18n implements WidgetsLocalizations {
  const I18n();

  static Locale _locale;

  static bool _shouldReload = false;

  static const GeneratedLocalizationsDelegate delegate =
      GeneratedLocalizationsDelegate();

  static final _dateTimePatternFormatter =
      DateFormat('MMM d, yyyy h:mm:ss a', 'en_US');

  static final _timePatternFormatter = DateFormat('h:mm:ss a', 'en_US');

  static Locale get locale$ => _locale;
  static set locale$(Locale locale) {
    _shouldReload = true;
    _locale = locale;
  }

  TextDirection get textDirection => TextDirection.ltr;
  static I18n of(BuildContext context) =>
      Localizations.of<I18n>(context, WidgetsLocalizations);
  String get about => 'About';
  String get add => 'Add';
  String get algorithm => 'Algorithm';
  String get appName => 'Restler';
  String get ascendingOrder => 'Ascending order';
  String get auth => 'Auth';
  String get basic => 'Basic';
  String get bearer => 'Bearer';
  String get binaryDataTypeIsNotSupported =>
      'Binary data type is not supported';
  String get body => 'Body';
  String get cache => 'Cache';
  String get call => 'Request';
  String callCount(int quantity) => Intl.plural(quantity,
      locale: 'en_US',
      one: '${quantity} request',
      other: '${quantity} requests');
  String get cancel => 'Cancel';
  String get cancelled => 'Cancelled';
  String get certificate => 'Certificate';
  String get changelog => 'Changelog';
  String charCount(int quantity) => Intl.plural(quantity,
      locale: 'en_US',
      one: '${quantity} character',
      other: '${quantity} characters');
  String get choose => 'Choose';
  String get chooseFile => 'Choose file...';
  String get clear => 'Clear';
  String get clearCertificateConfirmationMessage =>
      'Are you sure you want to clear all certificates?';
  String get clearCookieConfirmationMessage =>
      'Are you sure you want to clear all cookies?';
  String get clearDnsConfirmationMessage =>
      'Are you sure you want to clear all DNS?';
  String get clearEnvironmentConfirmationMessage =>
      'Are you sure you want to clear all environments?';
  String get clearHistoryConfirmationMessage =>
      'Are you sure you want to clear the entire history?';
  String get clearProxyConfirmationMessage =>
      'Are you sure you want to clear all proxies?';
  String get clearVariableConfirmationMessage =>
      'Are you sure you want to clear all variables?';
  String get clearWorkspaceConfirmationMessage =>
      'Are you sure you want to clear this workspace?';
  String get clientCertificate => 'Client certificate';
  String get collection => 'Collection';
  String get collectionImported => 'Collection imported successfully';
  String get collectionName => 'Collection name';
  String get connected => 'Connected';
  String get connecting => 'Connecting...';
  String get connectionTimeout => 'Connection timeout (ms)';
  String get contact => 'Contact';
  String get cookie => 'Cookie';
  String get copiedToClipboard => 'Copied to clipboard!';
  String get copy => 'Copy';
  String get copyCall => 'Copy call';
  String get copyCertificate => 'Copy certificate';
  String get copyCookie => 'Copy cookie';
  String get copyDns => 'Copy DNS';
  String get copyEnvironment => 'Copy environment';
  String get copyProxy => 'Copy proxy';
  String get darkTheme => 'Dark theme';
  String get data => 'Data';
  String get date => 'Date';
  String dateTimePattern(DateTime date) =>
      _dateTimePatternFormatter.format(date);
  String get defaultWorkspaceCantBeDeleted =>
      'Default workspace can\'t be deleted';
  String get defaultWorkspaceCantBeEdited =>
      'Default workspace can\'t be edited';
  String get delete => 'Delete';
  String get deleteCallConfirmationMessage =>
      'Are you sure you want to delete this request?';
  String get deleteCertificateConfirmationMessage =>
      'Are you sure you want to delete this certificate?';
  String get deleteCookieConfirmationMessage =>
      'Are you sure you want to delete this cookie?';
  String get deleteDnsConfirmationMessage =>
      'Are you sure you want to delete this DNS?';
  String get deleteEnvironmentConfirmationMessage =>
      'Are you sure you want to delete this environment?';
  String get deleteFolderConfirmationMessage =>
      'Are you sure you want to delete this folder?';
  String get deleteHistoryConfirmationMessage =>
      'Are you sure you want to delete this history?';
  String get deleteProxyConfirmationMessage =>
      'Are you sure you want to delete this proxy?';
  String get deleteVariableConfirmationMessage =>
      'Are you sure you want to delete this variable?';
  String get deleteWorkspaceConfirmationMessage =>
      'Are you sure you want to delete this workspace?';
  String get description => 'Description';
  String get digest => 'Digest';
  String get discardChanges => 'Discard changes';
  String get disconnected => 'Disconnected';
  String get dns => 'DNS';
  String get domain => 'Domain';
  String get donate => 'Donate';
  String get donateInstruction =>
      'You will be sent to Google Play to view the final amount in your local currency and complete the process.';
  String get donateMessage =>
      'If you like this app and want to say thank you to the developer you can donate some cash:';
  String get donateThankYou => 'Thank you for your support!';
  String get donation => 'Donation';
  String get duplicate => 'Duplicate';
  String get duplicateTab => 'Duplicate tab';
  String get duration => 'Duration';
  String get edit => 'Edit';
  String get editCall => 'Edit request';
  String get editCertificate => 'Edit certiticate';
  String get editCookie => 'Edit cookie';
  String get editDns => 'Edit DNS';
  String get editEnvironment => 'Edit environment';
  String get editFolder => 'Edit folder';
  String get editProxy => 'Edit proxy';
  String get editVariable => 'Edit variable';
  String get editWorkspace => 'Edit workspace';
  String get email => 'Email';
  String get enableVariables => 'Enable variables';
  String get enabled => 'Enabled';
  String get enterTextHere => 'Enter text here!';
  String get environment => 'Environment';
  String get error => 'Error';
  String get export => 'Export';
  String exportError(dynamic error) =>
      'An error occurred while exporting data: ${error}';
  String get ext => 'Ext';
  String get file => 'File';
  String fileSavedAt(dynamic path) =>
      'File has been saved successfully at ${path}';
  String get filename => 'Filename';
  String get filepathOrUrl => 'Filepath or URL';
  String get folder => 'Folder';
  String folderCount(int quantity) => Intl.plural(quantity,
      locale: 'en_US', one: '${quantity} folder', other: '${quantity} folders');
  String get followRedirects => 'Follow redirects';
  String get fontSize => 'Font size (px)';
  String get form => 'Form';
  String get format => 'Format';
  String get global => 'Global';
  String get hawk => 'Hawk';
  String get header => 'Header';
  String get history => 'History';
  String get host => 'Host';
  String get howToTranslateThisApp => 'How to translate this app?';
  String get howToUseVariable =>
      'Variables allow you to store and reuse values in your requests. To add a variable, click the Add Button and give it a name and a value. To use the variable in your request, in the any field, type {{VARIABLE_NAME}}.';
  String get httpMethod => 'HTTP Method';
  String get id => 'Id';
  String get import => 'Import';
  String get importError => 'An error occurred while importing data';
  String get importExport => 'Import & Export';
  String get insomnia => 'Insomnia';
  String get invalidFormat => 'Invalid format';
  String get invalidImage => 'Invalid or unsupported image format';
  String get invalidPassword => 'Invalid password (min is 8)';
  String itemCount(int quantity) => Intl.plural(quantity,
      locale: 'en_US', one: '${quantity} item', other: '${quantity} items');
  String get keepEqualSignForEmptyQuery => 'Keep equal sign for empty query';
  String get key => 'Key';
  String get licenses => 'Licenses';
  String get maxRedirects => 'Max redirects';
  String get maxSize => 'Max size';
  String get method => 'Method';
  String get minusOneForInfinite => '-1 for infinite';
  String get move => 'Move';
  String get moveCall => 'Move call';
  String get moveCertificate => 'Move certificate';
  String get moveCookie => 'Move cookie';
  String get moveDns => 'Move DNS';
  String get moveEnvironment => 'Move environment';
  String get moveFolder => 'Move folder';
  String get moveProxy => 'Move proxy';
  String get multipart => 'Multipart';
  String get name => 'Name';
  String get newCertificate => 'New certificate';
  String get newCookie => 'New cookie';
  String get newDns => 'New DNS';
  String get newEnvironment => 'New environment';
  String get newFolder => 'New folder';
  String get newProxy => 'New proxy';
  String get newTab => 'New tab';
  String get newVariable => 'New variable';
  String get newWorkspace => 'New workspace';
  String get noAuthTypeSelected => 'Select an auth type from above!';
  String get noBodyReturned => 'No body returned for response';
  String get noBodyTypeSelected => 'Select a body type from above!';
  String get noCookiesReturned => 'No cookies returned for response';
  String get noEnvironment => 'No environment';
  String get noFileSelected => 'No file selected';
  String get noHeadersReturned => 'No headers returned for response';
  String get noItems => 'No items';
  String get noMessages => 'No messages';
  String get none => 'None';
  String get ok => 'OK';
  String get optional => 'Optional';
  String get passphrase => 'Passphrase';
  String get password => 'Password';
  String get paste => 'Paste';
  String get path => 'Path';
  String get permissionDenied => 'Permission denied!';
  String get persistentConnection => 'Persistent Connection';
  String get port => 'Port';
  String get postman => 'Postman';
  String postmanDynamicVariableNotImplementedYet(dynamic variable) =>
      'The Postman Dynamic Variable \'${variable}\' is not implemented yet!';
  String get prefix => 'Prefix';
  String get pretty => 'Pretty';
  String get preview => 'Preview';
  String get privacyPolicy => 'Privacy policy';
  String get proxy => 'Proxy';
  String get query => 'Query';
  String get rateThisApp => 'Rate this app!';
  String get rateThisAppMessage =>
      'If you enjoy using this app, would you mind taking a moment to rate it? Thank you for  your support!';
  String get raw => 'Raw';
  String get remove => 'Remove';
  String get reopenClosedTab => 'Reopen closed tab';
  String get request => 'Request';
  String get required => 'Required';
  String get response => 'Response';
  String get responseNotFoundInCache => 'Response not found in cache';
  String get root => 'Root';
  String get save => 'Save';
  String get saveAs => 'Save as...';
  String get saveAsFile => 'Save as file';
  String get saveResponseBody => 'Save response body';
  String get search => 'Search';
  String get secret => 'Secret';
  String get sendCookies => 'Send cookies';
  String get sessionTimeout => 'Session timeout (ms)';
  String get settings => 'Settings';
  String get size => 'Size';
  String get sort => 'Sort';
  String get sortBy => 'Sort by';
  String get status => 'Status';
  String get storeCookies => 'Store cookies';
  String get submitBug => 'Submit a bug';
  String get tab => 'Tab';
  String tagCantBeResolved(dynamic tag) => 'The tag can\'t be resolved: ${tag}';
  String tagHasWrongParameter(dynamic tag) =>
      'The tag \'${tag}\' has wrong parameters';
  String get targets => 'Targets';
  String get text => 'Text';
  String get time => 'Time';
  String timePattern(DateTime date) => _timePatternFormatter.format(date);
  String get timeline => 'Timeline';
  String get token => 'Token';
  String get translators => 'Translators';
  String get type => 'Type';
  String get unnamed => 'Unnamed';
  String get update => 'Update';
  String get url => 'URL';
  String get userAgent => 'User-Agent';
  String get username => 'Username';
  String get validateCertificates => 'Validate certificates';
  String get value => 'Value';
  String get variable => 'Variable';
  String variableCantBeFound(dynamic variable) =>
      'The variable can\'t be found: ${variable}';
  String variableIsRecursive(dynamic variable) =>
      'The variable can\'t be resolved because a cycle was found: ${variable}';
  String get webSocket => 'WebSocket';
  String get website => 'Website';
  String get whatsNew => 'What\'s new?';
  String get workspace => 'Workspace';
  String get yes => 'Yes';
}

class _I18n_es_MX extends I18n {
  const _I18n_es_MX();

  TextDirection get textDirection => TextDirection.ltr;
  String get about => 'Acerca de';
  String get algorithm => 'Algoritmo';
  String get appName => 'Restler';
  String get ascendingOrder => 'Orden ascendente';
  String get auth => 'Auth';
  String get basic => 'Basic';
  String get bearer => 'Bearer';
  String get body => 'Cuerpo';
  String get call => 'Solicitud';
  String callCount(int quantity) => Intl.plural(quantity,
      locale: 'es_MX',
      one: '${quantity} solicitud',
      other: '${quantity} solicitudes');
  String get cancel => 'Cancelar';
  String get cancelled => 'Cancelado';
  String get certificate => 'Certificado';
  String get changelog => 'Registro de cambios';
  String charCount(int quantity) => Intl.plural(quantity,
      locale: 'es_MX',
      one: '${quantity} caracter',
      other: '${quantity} caracteres');
  String get choose => 'Escoger';
  String get chooseFile => 'Elegir un archivo...';
  String get clear => 'Limpiar';
  String get clearCertificateConfirmationMessage =>
      '¿Estás seguro de que deseas borrar todos los certificados?';
  String get clearCookieConfirmationMessage =>
      '¿Seguro que quieres borrar todas las cookies?';
  String get clearHistoryConfirmationMessage =>
      '¿Seguro que quieres borrar todo el historial?';
  String get clientCertificate => 'Certificado de cliente';
  String get collection => 'Colección';
  String get collectionImported => 'Colección importada con éxito';
  String get connectionTimeout => 'Tiempo de espera de conexión (ms)';
  String get contact => 'Contactar';
  String get copiedToClipboard => '¡Copiado al portapapeles!';
  String get copy => 'Copiar';
  String get darkTheme => 'Tema oscuro';
  String get date => 'Fecha';
  String get delete => 'Borrar';
  String get deleteCallConfirmationMessage =>
      '¿Estás seguro de que deseas eliminar esta solicitud?';
  String get deleteCertificateConfirmationMessage =>
      '¿Seguro que quieres eliminar este certificado?';
  String get deleteCookieConfirmationMessage =>
      '¿Estás seguro de que deseas eliminar esta cookie?';
  String get deleteFolderConfirmationMessage =>
      '¿Estás seguro de que deseas eliminar esta carpeta?';
  String get deleteHistoryConfirmationMessage =>
      '¿Estás seguro de que deseas eliminar este historial?';
  String get donate => 'Donar';
  String get donateInstruction =>
      'Se lo enviarás a Google Play para ver el monto final en tu moneda local y completar el proceso.';
  String get donateMessage =>
      'Si te gusta esta aplicación y quieres agradecer al desarrollador, puedes donar algo de dinero en efectivo:';
  String get donateThankYou => '¡Gracias por tu apoyo!';
  String get donation => 'Donación';
  String get duplicate => 'Duplicar';
  String get duplicateTab => 'Duplicar pestaña';
  String get duration => 'Duración';
  String get edit => 'Editar';
  String get editCall => 'Editar solicitud';
  String get editCertificate => 'Editar certificado';
  String get editCookie => 'Editar cookie';
  String get editFolder => 'Editar carpeta';
  String get email => 'Correo electrónico';
  String get enterTextHere => '¡Introducir texto aquí!';
  String get error => 'Error';
  String get export => 'Exportar';
  String get ext => 'Ext';
  String fileSavedAt(dynamic path) =>
      'El archivo se ha guardado correctamente en ${path}';
  String get filename => 'Nombre del archivo';
  String get filepathOrUrl => 'Ruta de archivo o URL';
  String get folder => 'Carpeta';
  String folderCount(int quantity) => Intl.plural(quantity,
      locale: 'es_MX',
      one: '${quantity} carpeta',
      other: '${quantity} carpetas');
  String get followRedirects => 'Seguir redireccionamientos';
  String get fontSize => 'Tamaño de fuente (px)';
  String get format => 'Formato';
  String get header => 'Header';
  String get history => 'Historial';
  String get howToTranslateThisApp => '¿Cómo traducir esta aplicación?';
  String get httpMethod => 'Método HTTP';
  String get id => 'Id';
  String get import => 'Importar';
  String get importError => 'Se produjo un error al importar datos';
  String get importExport => 'Importar y Exportar';
  String get invalidImage => 'Formato de imagen no válido o no compatible';
  String get invalidPassword => 'Contraseña inválida (min es 8)';
  String itemCount(int quantity) => Intl.plural(quantity,
      locale: 'es_MX',
      one: '${quantity} objecto',
      other: '${quantity} objectos');
  String get key => 'Llave';
  String get licenses => 'Licencias';
  String get maxRedirects => 'Redirecciones máximas';
  String get method => 'Método';
  String get minusOneForInfinite => '-1 para infinito';
  String get move => 'Mover';
  String get moveCall => 'Mover llamada';
  String get moveFolder => 'Mover carpeta';
  String get name => 'Nombre';
  String get newCertificate => 'Nuevo certificado';
  String get newCookie => 'Nueva cookie';
  String get newFolder => 'Nueva carpeta';
  String get newTab => 'Nueva pestaña';
  String get noAuthTypeSelected =>
      '¡Seleccionar un tipo de autenticación de arriba!';
  String get noBodyReturned => 'La respuesta devolvió un cuerpo vacío.';
  String get noBodyTypeSelected =>
      '¡Seleccionar un tipo de cuerpo desde arriba!';
  String get noCookiesReturned => 'La respuesta no devolvió Cookies';
  String get noFileSelected => 'Ningún archivo seleccionado';
  String get noHeadersReturned => 'La respuesta no devolvió Headers';
  String get noItems => 'Sin contenido';
  String get none => 'Ninguno';
  String get ok => 'OK';
  String get optional => 'Opcional';
  String get passphrase => 'Frase de contraseña';
  String get password => 'Contraseña';
  String get paste => 'Pegar';
  String get permissionDenied => '¡Permiso denegado!';
  String get prefix => 'Prefijo';
  String get pretty => 'Pretty';
  String get preview => 'Vista previa';
  String get privacyPolicy => 'Política de privacidad';
  String get query => 'Query';
  String get rateThisApp => '¡Califica esta aplicación!';
  String get rateThisAppMessage =>
      'Si le gusta usar esta aplicación, ¿te importaría tomarte un momento para calificarla? ¡Gracias por tu apoyo!';
  String get raw => 'Raw';
  String get remove => 'Remover';
  String get reopenClosedTab => 'Reabrir pestaña cerrada';
  String get request => 'Solicitud';
  String get required => 'Requerido';
  String get response => 'Respuesta';
  String get root => 'Raíz';
  String get save => 'Guardar';
  String get saveAs => 'Guardar como...';
  String get saveAsFile => 'Guardar como archivo';
  String get saveResponseBody => 'Guardar cuerpo de respuesta';
  String get search => 'Buscar';
  String get settings => 'Configuraciones';
  String get size => 'Tamaño';
  String get sort => 'Ordenar';
  String get sortBy => 'Ordenar por';
  String get status => 'Estado';
  String get submitBug => 'Enviar un error';
  String get tab => 'Pestaña';
  String get token => 'Token';
  String get translators => 'Traductores';
  String get update => 'Actualizar';
  String get username => 'Nombre de usuario';
  String get validateCertificates => 'Validar certificados';
  String get value => 'Valor';
  String get website => 'Sitio web';
  String get yes => 'Si';
}

class _I18n_pt_BR extends I18n {
  const _I18n_pt_BR();

  static final _dateTimePatternFormatter =
      DateFormat('dd/MM/yyyy HH:mm:ss', 'pt_BR');

  static final _timePatternFormatter = DateFormat('HH:mm:ss', 'pt_BR');

  TextDirection get textDirection => TextDirection.ltr;
  String get about => 'Sobre';
  String get add => 'Adicionar';
  String get algorithm => 'Algoritmo';
  String get appName => 'Restler';
  String get ascendingOrder => 'Ordem crescente';
  String get auth => 'Autenticação';
  String get basic => 'Basic';
  String get bearer => 'Bearer';
  String get binaryDataTypeIsNotSupported =>
      'Tipo binário de dado não é suportado';
  String get body => 'Corpo';
  String get cache => 'Cache';
  String get call => 'Chamada';
  String callCount(int quantity) => Intl.plural(quantity,
      locale: 'pt_BR',
      one: '${quantity} requisição',
      other: '${quantity} requisições');
  String get cancel => 'Cancelar';
  String get cancelled => 'Cancelado';
  String get certificate => 'Certificado';
  String get changelog => 'Changelog';
  String charCount(int quantity) => Intl.plural(quantity,
      locale: 'pt_BR',
      one: '${quantity} caractere',
      other: '${quantity} caracteres');
  String get choose => 'Escolher';
  String get chooseFile => 'Escolher arquivo...';
  String get clear => 'Limpar';
  String get clearCertificateConfirmationMessage =>
      'Você tem certeza que quer excluir todos os certificados?';
  String get clearCookieConfirmationMessage =>
      'Você tem certeza que quer excluir todos os cookies?';
  String get clearDnsConfirmationMessage =>
      'Você tem certeza que quer excluir todos os DNSs?';
  String get clearEnvironmentConfirmationMessage =>
      'Você tem certeza que quer excluir todos os ambientes?';
  String get clearHistoryConfirmationMessage =>
      'Você tem certeza que quer limpar todo o histórico?';
  String get clearProxyConfirmationMessage =>
      'Você tem certeza que quer excluir todos os proxies?';
  String get clearVariableConfirmationMessage =>
      'Você tem certeza que quer excluir todas as variávels?';
  String get clearWorkspaceConfirmationMessage =>
      'Você tem certeza que quer limpar esta área de trabalho?';
  String get clientCertificate => 'Certificado de cliente';
  String get collection => 'Coleção';
  String get collectionImported => 'Coleção importada com sucesso';
  String get collectionName => 'Nome da coleção';
  String get connected => 'Conectado';
  String get connecting => 'Conectando...';
  String get connectionTimeout => 'Limite de tempo de conexão (ms)';
  String get contact => 'Contato';
  String get cookie => 'Cookie';
  String get copiedToClipboard => 'Copiado para a área de transferência!';
  String get copy => 'Copiar';
  String get copyCall => 'Copiar chamada';
  String get copyCertificate => 'Copiar certificado';
  String get copyCookie => 'Copiar cookie';
  String get copyDns => 'Copiar DNS';
  String get copyEnvironment => 'Copiar ambiente';
  String get copyProxy => 'Copiar proxy';
  String get darkTheme => 'Tema escuro';
  String get data => 'Dado';
  String get date => 'Data';
  String dateTimePattern(DateTime date) =>
      _dateTimePatternFormatter.format(date);
  String get defaultWorkspaceCantBeDeleted =>
      'Área de trabalho padrão não pode ser excluído';
  String get defaultWorkspaceCantBeEdited =>
      'Área de trabalho padrão não pode ser editado';
  String get delete => 'Excluir';
  String get deleteCallConfirmationMessage =>
      'Você tem certeza que quer excluir esta requisição?';
  String get deleteCertificateConfirmationMessage =>
      'Você tem certeza que quer excluir este certificado?';
  String get deleteCookieConfirmationMessage =>
      'Você tem certeza que quer excluir este cookie?';
  String get deleteDnsConfirmationMessage =>
      'Você tem certeza que quer excluir este DNS?';
  String get deleteEnvironmentConfirmationMessage =>
      'Você tem certeza que quer excluir este ambiente?';
  String get deleteFolderConfirmationMessage =>
      'Você tem certeza que quer excluir esta pasta?';
  String get deleteHistoryConfirmationMessage =>
      'Você tem certeza que quer excluir este histórico?';
  String get deleteProxyConfirmationMessage =>
      'Você tem certeza que quer excluir este proxy?';
  String get deleteVariableConfirmationMessage =>
      'Você tem certeza que quer excluir esta variável?';
  String get deleteWorkspaceConfirmationMessage =>
      'Você tem certeza que quer excluir esta área de trabalho?';
  String get description => 'Descrição';
  String get digest => 'Digest';
  String get discardChanges => 'Descartar alterações';
  String get disconnected => 'Desconectado';
  String get dns => 'DNS';
  String get domain => 'Domínio';
  String get donate => 'Doar';
  String get donateInstruction =>
      'Você será enviado ao Google Play para visualizar a quantia que será doada e completar o processo.';
  String get donateMessage =>
      'Se você gostou deste app e gostaria de agradecer o desenvolvedor, você pode doar algum dinheiro:';
  String get donateThankYou => 'Muito obrigado pelo seu apoio!';
  String get donation => 'Doação';
  String get duplicate => 'Duplicar';
  String get duplicateTab => 'Duplicar aba';
  String get duration => 'Duração';
  String get edit => 'Editar';
  String get editCall => 'Editar requisição';
  String get editCertificate => 'Editar certificado';
  String get editCookie => 'Editar cookie';
  String get editDns => 'Editar DNS';
  String get editEnvironment => 'Editar ambiente';
  String get editFolder => 'Editar pasta';
  String get editProxy => 'Editar proxy';
  String get editVariable => 'Editar variável';
  String get editWorkspace => 'Editar área de trabalho';
  String get email => 'E-mail';
  String get enableVariables => 'Habilitar variáveis';
  String get enabled => 'Habilitado';
  String get enterTextHere => 'Digite o texto aqui!';
  String get environment => 'Ambiente';
  String get error => 'Erro';
  String get export => 'Exportar';
  String exportError(dynamic error) =>
      'An error occurred while exporting data: ${error}';
  String get ext => 'Ext';
  String get file => 'File';
  String fileSavedAt(dynamic path) => 'Arquivo salvo com sucesso em ${path}';
  String get filename => 'Nome do arquivo';
  String get filepathOrUrl => 'Caminho ou URL';
  String get folder => 'Pasta';
  String folderCount(int quantity) => Intl.plural(quantity,
      locale: 'pt_BR', one: '${quantity} pasta', other: '${quantity} pastas');
  String get followRedirects => 'Seguir redirecionamentos';
  String get fontSize => 'Tamanho da fonte (px)';
  String get form => 'Form';
  String get format => 'Formato';
  String get global => 'Global';
  String get hawk => 'Hawk';
  String get header => 'Cabeçalho';
  String get history => 'Histórico';
  String get host => 'Host';
  String get howToTranslateThisApp => 'Como traduzir este app?';
  String get howToUseVariable =>
      'Variáveis ​​permitem armazenar e reutilizar valores em suas requisições. Para adicionar uma variável, clique no botão Adicionar (+) e dê um nome e um valor para ela. Para usar a variável em sua requisição, em qualquer campo, digite {{NOME_DA_VARIÁVEL}}.';
  String get httpMethod => 'Método HTTP';
  String get id => 'Id';
  String get import => 'Importar';
  String get importError => 'Um erro ocorreu enquanto importava os dados';
  String get importExport => 'Importar & Exportar';
  String get insomnia => 'Insomnia';
  String get invalidFormat => 'Formato inválido';
  String get invalidImage => 'Formato de imagem inválido ou não suportado';
  String get invalidPassword => 'Senha inválida (mínimo é 8)';
  String itemCount(int quantity) => Intl.plural(quantity,
      locale: 'pt_BR', one: '${quantity} item', other: '${quantity} itens');
  String get keepEqualSignForEmptyQuery =>
      'Manter o símbolo de igual para query vazia';
  String get key => 'Chave';
  String get licenses => 'Licenças';
  String get maxRedirects => 'Número máximo de redirecionamentos';
  String get maxSize => 'Tamanho máximo';
  String get method => 'Método';
  String get minusOneForInfinite => '-1 para infinito';
  String get move => 'Mover';
  String get moveCall => 'Mover chamada';
  String get moveCertificate => 'Mover certificado';
  String get moveCookie => 'Mover cookie';
  String get moveDns => 'Mover DNS';
  String get moveEnvironment => 'Mover ambiente';
  String get moveFolder => 'Mover pasta';
  String get moveProxy => 'Mover proxy';
  String get multipart => 'Multipart';
  String get name => 'Nome';
  String get newCertificate => 'Novo certificado';
  String get newCookie => 'Novo cookie';
  String get newDns => 'Novo DNS';
  String get newEnvironment => 'Novo ambiente';
  String get newFolder => 'Nova pasta';
  String get newProxy => 'Novo proxy';
  String get newTab => 'Nova aba';
  String get newVariable => 'Nova variável';
  String get newWorkspace => 'Nova área de trabalho';
  String get noAuthTypeSelected => 'Selecione acima o método de autenticação!';
  String get noBodyReturned => 'Nenhum corpo retornado na resposta';
  String get noBodyTypeSelected => 'Selecione acima o tipo do corpo!';
  String get noCookiesReturned => 'Nenhum cookie retornado na resposta';
  String get noEnvironment => 'Nenhum ambiente';
  String get noFileSelected => 'Nenhum arquivo selecionado';
  String get noHeadersReturned => 'Nenhum cabeçalho retornado na resposta';
  String get noItems => 'Nenhum item';
  String get noMessages => 'Nenhuma mensagem';
  String get none => 'Nenhum';
  String get ok => 'OK';
  String get optional => 'Opcional';
  String get passphrase => 'Palavra-passe';
  String get password => 'Senha';
  String get paste => 'Colar';
  String get path => 'Caminho';
  String get permissionDenied => 'Permissão negada!';
  String get persistentConnection => 'Conexão persistente';
  String get port => 'Porta';
  String get postman => 'Postman';
  String postmanDynamicVariableNotImplementedYet(dynamic variable) =>
      'A Variável Dinâmica do Postman \'${variable}\' ainda não foi implementada!';
  String get prefix => 'Prefixo';
  String get pretty => 'Embelezar';
  String get preview => 'Pré-visualização';
  String get privacyPolicy => 'Política de privacidade';
  String get proxy => 'Proxy';
  String get query => 'Query';
  String get rateThisApp => 'Avalie este app!';
  String get rateThisAppMessage =>
      'Se você curtiu o app, poderia reservar um minutinho do seu tempo e avaliar este app? Obrigado pelo seu apoio!';
  String get raw => 'Texto';
  String get remove => 'Remover';
  String get reopenClosedTab => 'Reabrir aba fechada';
  String get request => 'Requisição';
  String get required => 'Obrigatório';
  String get response => 'Resposta';
  String get responseNotFoundInCache =>
      'Nenhuma resposta foi encontrada no cache';
  String get root => 'Raiz';
  String get save => 'Salvar';
  String get saveAs => 'Salvar como...';
  String get saveAsFile => 'Salvar como arquivo';
  String get saveResponseBody => 'Salvar corpo da resposta';
  String get search => 'Buscar';
  String get secret => 'Secreto';
  String get sendCookies => 'Enviar cookies';
  String get sessionTimeout => 'Tempo limite da sessão (ms)';
  String get settings => 'Configurações';
  String get size => 'Tamanho';
  String get sort => 'Ordenar';
  String get sortBy => 'Ordenar por';
  String get status => 'Status';
  String get storeCookies => 'Armazenar cookies';
  String get submitBug => 'Relatar um problema';
  String get tab => 'Aba';
  String tagCantBeResolved(dynamic tag) =>
      'A tag não pode ser resolvida: ${tag}';
  String tagHasWrongParameter(dynamic tag) =>
      'A tag \'${tag}\' possui parâmetros errados';
  String get targets => 'Destinos';
  String get text => 'Text';
  String get time => 'Tempo';
  String timePattern(DateTime date) => _timePatternFormatter.format(date);
  String get timeline => 'Linha do tempo';
  String get token => 'Token';
  String get translators => 'Tradutores';
  String get type => 'Tipo';
  String get unnamed => 'Sem nome';
  String get update => 'Atualizar';
  String get url => 'URL';
  String get userAgent => 'User-Agent';
  String get username => 'Nome de usuário';
  String get validateCertificates => 'Validar certificados';
  String get value => 'Valor';
  String get variable => 'Variável';
  String variableCantBeFound(dynamic variable) =>
      'Não foi possível encontrar a variável: ${variable}';
  String variableIsRecursive(dynamic variable) =>
      'A variável não pode ser resolvida porque um ciclo foi encontrado: ${variable}';
  String get webSocket => 'WebSocket';
  String get website => 'Website';
  String get whatsNew => 'O que há de novo?';
  String get workspace => 'Área de Trabalho';
  String get yes => 'Sim';
}

class _I18n_zh_CN extends I18n {
  const _I18n_zh_CN();

  static final _dateTimePatternFormatter =
      DateFormat('yyyy年MM月d日 h:mm:ss a', 'zh_CN');

  static final _timePatternFormatter = DateFormat('h:mm:ss a', 'zh_CN');

  TextDirection get textDirection => TextDirection.ltr;
  String get about => '关于';
  String get add => '添加';
  String get algorithm => '算法';
  String get appName => 'Restler';
  String get ascendingOrder => '升序';
  String get auth => '认证';
  String get basic => 'Basic';
  String get bearer => 'Bearer';
  String get body => '返回值';
  String get cache => '缓存';
  String get call => '请求';
  String callCount(int quantity) => Intl.plural(quantity,
      locale: 'zh_CN', one: '${quantity}个请求', other: '${quantity}个请求');
  String get cancel => '取消';
  String get cancelled => '已取消';
  String get certificate => '证书';
  String get changelog => '更新日志';
  String charCount(int quantity) => Intl.plural(quantity,
      locale: 'zh_CN', one: '${quantity}个字符', other: '${quantity}个字符');
  String get choose => '选择';
  String get chooseFile => '选择文件...';
  String get clear => '清除';
  String get clearCertificateConfirmationMessage => '确定要删除所有证书吗？';
  String get clearCookieConfirmationMessage => '确定要删除所有的cookie吗？';
  String get clearDnsConfirmationMessage => '确定要删除所有的DNS吗？';
  String get clearEnvironmentConfirmationMessage => '确定要删除所有环境吗？';
  String get clearHistoryConfirmationMessage => '确定要删除所有的历史记录吗？';
  String get clearProxyConfirmationMessage => '确定要输出所有代理吗？';
  String get clearVariableConfirmationMessage => '确定要删除所有变量吗？';
  String get clearWorkspaceConfirmationMessage => '确定要清除这个工作空间吗？';
  String get clientCertificate => '客户端证书';
  String get collection => '收藏夹';
  String get collectionImported => '收藏夹导入成功';
  String get collectionName => '收藏夹名';
  String get connected => '已连接';
  String get connecting => '连接中...';
  String get connectionTimeout => '连接超时时间 (ms)';
  String get contact => '联系';
  String get cookie => 'Cookie';
  String get copiedToClipboard => '已复制到剪切板！';
  String get copy => '复制';
  String get copyCall => '复制全部';
  String get copyCertificate => '复制证书';
  String get copyCookie => '复制cookie';
  String get copyDns => '复制DNS';
  String get copyEnvironment => '复制环境';
  String get copyProxy => '复制代理';
  String get darkTheme => '深色模式';
  String get data => '数据';
  String get date => '日期';
  String dateTimePattern(DateTime date) =>
      _dateTimePatternFormatter.format(date);
  String get defaultWorkspaceCantBeDeleted => '默认工作空间不能删除';
  String get defaultWorkspaceCantBeEdited => '默认工作空间不能编辑';
  String get delete => '删除';
  String get deleteCallConfirmationMessage => '确定要删除这条请求吗？';
  String get deleteCertificateConfirmationMessage => '确定要删除这个证书吗？';
  String get deleteCookieConfirmationMessage => '确定要删除这条cookie吗？';
  String get deleteDnsConfirmationMessage => '确定要删除这条DNS吗？';
  String get deleteEnvironmentConfirmationMessage => '确定要删除这个环境吗？';
  String get deleteFolderConfirmationMessage => '确定要删除这个文件夹吗？';
  String get deleteHistoryConfirmationMessage => '确定要删除这条历史记录吗？';
  String get deleteProxyConfirmationMessage => '确定要删除这条代理吗？';
  String get deleteVariableConfirmationMessage => '确定要删除这个变量吗？';
  String get deleteWorkspaceConfirmationMessage => '确定要删除这个工作空间吗？';
  String get description => '描述';
  String get digest => 'Digest';
  String get discardChanges => '不保存';
  String get disconnected => '连接已取消';
  String get dns => 'DNS';
  String get domain => '域名';
  String get donate => '捐款';
  String get donateInstruction => '您将打开Google Play并且以当地货币查看以及完成此次交易。';
  String get donateMessage => '如果喜欢并且想捐助这个app：';
  String get donateThankYou => '谢谢您的支持！';
  String get donation => '捐款';
  String get duplicate => '复制';
  String get duplicateTab => '复制标签';
  String get duration => '时间';
  String get edit => '编辑';
  String get editCall => '编辑请求';
  String get editCertificate => '编辑证书';
  String get editCookie => '编辑cookie';
  String get editDns => '编辑DNS';
  String get editEnvironment => '编辑环境';
  String get editFolder => '编辑文件夹';
  String get editProxy => '编辑代理';
  String get editVariable => '编辑变量';
  String get editWorkspace => '编辑工作空间';
  String get email => '电子邮件';
  String get enableVariables => '启用变量';
  String get enabled => '已允许';
  String get enterTextHere => '请在这里输入！';
  String get environment => '环境';
  String get error => '错误';
  String get export => '导出';
  String get ext => 'Ext';
  String get file => '文件';
  String fileSavedAt(dynamic path) => '文件已成功保存在${path}';
  String get filename => '文件名';
  String get filepathOrUrl => '文件路径或者URL';
  String get folder => '文件夹';
  String folderCount(int quantity) => Intl.plural(quantity,
      locale: 'zh_CN', one: '${quantity}个文件夹', other: '${quantity}个文件夹');
  String get followRedirects => '跟随重定向';
  String get fontSize => '字体大小 (px)';
  String get form => '表单';
  String get format => '格式';
  String get global => '全局';
  String get hawk => 'Hawk';
  String get header => '头部';
  String get history => 'History';
  String get host => '主机';
  String get howToTranslateThisApp => '帮助翻译？';
  String get howToUseVariable =>
      '变量允许您在请求中存储和重用值。要添加变量，请单击添加按钮并给它一个名称和值。要在请求中使用变量，请在任何字段中输入{{VARIABLE_NAME}}。';
  String get httpMethod => 'HTTP请求方式';
  String get id => 'Id';
  String get import => '导入';
  String get importError => '导入数据过程中出现错误';
  String get importExport => '导入和导出';
  String get insomnia => 'Insomnia';
  String get invalidFormat => '无效格式';
  String get invalidImage => '无效或者不支持的图片格式';
  String get invalidPassword => '无效密码 (最少8个字符)';
  String itemCount(int quantity) => Intl.plural(quantity,
      locale: 'zh_CN', one: '${quantity}项', other: '${quantity}项');
  String get key => '键';
  String get licenses => '法律';
  String get maxRedirects => '最多重定向次数';
  String get method => 'Method';
  String get minusOneForInfinite => '-1 （永不超时）';
  String get move => 'Move';
  String get moveCall => '移除请求';
  String get moveCertificate => '移动证书';
  String get moveCookie => '移动cookie';
  String get moveDns => '移动DNS';
  String get moveEnvironment => '移动环境';
  String get moveFolder => '删除文件夹';
  String get moveProxy => '移动代理';
  String get multipart => '混合';
  String get name => '名称';
  String get newCertificate => '新建证书';
  String get newCookie => '新建cookie';
  String get newDns => '新建DNS';
  String get newEnvironment => '新建环境';
  String get newFolder => '新建文件夹';
  String get newProxy => '新建代理';
  String get newTab => '新标签';
  String get newVariable => '新建变量';
  String get newWorkspace => '新建工作空间';
  String get noAuthTypeSelected => '请从上面选择一个认证的类型！';
  String get noBodyReturned => '响应体没有返回值';
  String get noBodyTypeSelected => '请从上面选择一个参数的类型！';
  String get noCookiesReturned => '响应体没有cookies';
  String get noEnvironment => '没有环境';
  String get noFileSelected => '未选择任何文件';
  String get noHeadersReturned => '响应体没有返回头';
  String get noItems => '没有项目';
  String get noMessages => '没有消息';
  String get none => '空白';
  String get ok => '好的';
  String get optional => '可选';
  String get passphrase => '密码';
  String get password => '密码';
  String get paste => '粘贴';
  String get path => '路径';
  String get permissionDenied => '权限被拒绝！';
  String get port => '端口';
  String get postman => 'Postman';
  String postmanDynamicVariableNotImplementedYet(dynamic variable) =>
      'Postman动态变量\'${variable}\'仍未实现！';
  String get prefix => '前缀';
  String get pretty => '美化';
  String get preview => '预览';
  String get privacyPolicy => '隐私政策';
  String get proxy => '代理';
  String get query => '参数';
  String get rateThisApp => '评价此app！';
  String get rateThisAppMessage => '如果喜欢这个app，可以给个好评吗？谢谢！';
  String get raw => '源代码';
  String get remove => '移除';
  String get reopenClosedTab => '恢复已关闭的标签';
  String get request => '请求';
  String get required => '必填';
  String get response => '响应';
  String get responseNotFoundInCache => '缓存不存在响应体';
  String get root => 'Root';
  String get save => '保存';
  String get saveAs => '另存为...';
  String get saveAsFile => '保存为文件';
  String get saveResponseBody => '保存响应体返回值';
  String get search => '搜索';
  String get secret => '密钥';
  String get sendCookies => '发送cookies';
  String get settings => '设置';
  String get size => '大小';
  String get sort => '排序';
  String get sortBy => '排序方式';
  String get status => '状态';
  String get storeCookies => '存储cookies';
  String get submitBug => '提交bug';
  String get tab => '标签';
  String tagCantBeResolved(dynamic tag) => '无法解析此标记：${tag}';
  String tagHasWrongParameter(dynamic tag) => '标记\'${tag}\'存在错误参数';
  String get text => '文本';
  String get time => '用时';
  String timePattern(DateTime date) => _timePatternFormatter.format(date);
  String get timeline => '时间线';
  String get token => 'Token';
  String get translators => '翻译人员';
  String get type => '类型';
  String get unnamed => '未命名';
  String get update => '更新';
  String get url => 'URL';
  String get userAgent => 'User-Agent';
  String get username => '用户名';
  String get validateCertificates => '验证证书';
  String get value => '值';
  String get variable => '变量';
  String variableCantBeFound(dynamic variable) => '变量${variable}无法找到';
  String variableIsRecursive(dynamic variable) => '无法解析该变量，因为存在循环：${variable}';
  String get webSocket => 'WebSocket';
  String get website => '网站';
  String get whatsNew => '更新了啥？';
  String get workspace => '工作空间';
  String get yes => '是的';
}

class GeneratedLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const GeneratedLocalizationsDelegate();

  List<Locale> get supportedLocales => const [
        Locale('en', 'US'),
        Locale('es', 'MX'),
        Locale('pt', 'BR'),
        Locale('zh', 'CN')
      ];
  LocaleResolutionCallback resolution({Locale fallback}) {
    return (locale, supported) {
      return isSupported(locale) ? locale : (fallback ?? supported.first);
    };
  }

  Future<WidgetsLocalizations> load(Locale locale) {
    I18n._locale ??= locale;
    I18n._shouldReload = false;
    locale = I18n._locale;
    final lang = locale?.toString() ?? '';
    final languageCode = locale?.languageCode ?? '';
    if ('en_US' == lang) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_en_US());
    }
    if ('es_MX' == lang) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_es_MX());
    }
    if ('pt_BR' == lang) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_pt_BR());
    }
    if ('zh_CN' == lang) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_zh_CN());
    }
    if ('en' == languageCode) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_en_US());
    }
    if ('es' == languageCode) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_es_MX());
    }
    if ('pt' == languageCode) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_pt_BR());
    }
    if ('zh' == languageCode) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_zh_CN());
    }
    return SynchronousFuture<WidgetsLocalizations>(const I18n());
  }

  bool isSupported(Locale locale) {
    for (var i = 0; i < supportedLocales.length && locale != null; i++) {
      final l = supportedLocales[i];
      if (l.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }

  bool shouldReload(GeneratedLocalizationsDelegate old) => I18n._shouldReload;
}
