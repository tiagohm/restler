import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:restio/restio.dart' hide RequestEvent;
import 'package:restler/blocs/request/request_event.dart';
import 'package:restler/blocs/request/request_state.dart';
import 'package:restler/data/entities/cookie_entity.dart';
import 'package:restler/data/entities/data_entity.dart';
import 'package:restler/data/entities/form_entity.dart';
import 'package:restler/data/entities/header_entity.dart';
import 'package:restler/data/entities/history_entity.dart';
import 'package:restler/data/entities/multipart_entity.dart';
import 'package:restler/data/entities/notification_entity.dart';
import 'package:restler/data/entities/query_entity.dart';
import 'package:restler/data/entities/redirect_entity.dart';
import 'package:restler/data/entities/request_auth_entity.dart';
import 'package:restler/data/entities/request_body_entity.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/request_header_entity.dart';
import 'package:restler/data/entities/request_query_entity.dart';
import 'package:restler/data/entities/request_settings_entity.dart';
import 'package:restler/data/entities/response_entity.dart';
import 'package:restler/data/entities/target_entity.dart';
import 'package:restler/data/entities/variable_entity.dart';
import 'package:restler/data/repositories/certificate_repository.dart';
import 'package:restler/data/repositories/cookie_repository.dart';
import 'package:restler/data/repositories/dns_repository.dart';
import 'package:restler/data/repositories/environment_repository.dart';
import 'package:restler/data/repositories/history_repository.dart';
import 'package:restler/data/repositories/proxy_repository.dart';
import 'package:restler/data/repositories/variable_repository.dart';
import 'package:restler/data/repositories/workspace_repository.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:restler/messager.dart';
import 'package:restler/services/variable_resolver.dart';
import 'package:restler/settings.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState>
    implements CookieJar {
  final _cookieRepository = kiwi<CookieRepository>();
  final _historyRepository = kiwi<HistoryRepository>();
  final _certificateRepository = kiwi<CertificateRepository>();
  final _proxyRepository = kiwi<ProxyRepository>();
  final _dnsRepository = kiwi<DnsRepository>();
  final _workspaceRepository = kiwi<WorkspaceRepository>();
  final _environmentRepository = kiwi<EnvironmentRepository>();
  final _variableRepository = kiwi<VariableRepository>();
  final _settings = kiwi<Settings>();
  final _messager = kiwi<Messager>();

  RequestBloc() : super(const RequestState());

  @override
  Stream<RequestState> mapEventToState(RequestEvent event) async* {
    if (event is RequestSent) {
      yield* _mapRequestSentToState(event);
    } else if (event is RequestLoaded) {
      yield* _mapRequestLoadedToState(event);
    } else if (event is RequestCleared) {
      yield* _mapRequestClearedToState();
    } else if (event is MethodChanged) {
      yield* _mapMethodChangedToState(event);
    } else if (event is TypeChanged) {
      yield* _mapTypeChangedToState(event);
    } else if (event is SchemeChanged) {
      yield* _mapSchemeChangedToState(event);
    } else if (event is UrlChanged) {
      yield* _mapUrlChangedToState(event);
    } else if (event is DescriptionChanged) {
      yield* _mapDescriptionChangedToState(event);
    } else if (event is BodyEnabled) {
      yield* _mapBodyEnabledToState(event);
    } else if (event is BodyTypeChanged) {
      yield* _mapBodyTypeChangedToState(event);
    } else if (event is DataEnabled) {
      yield* _mapDataEnabledToState(event);
    } else if (event is NotificationEnabled) {
      yield* _mapNotificationEnabledToState(event);
    } else if (event is QueryEnabled) {
      yield* _mapQueryEnabledToState(event);
    } else if (event is HeaderEnabled) {
      yield* _mapHeaderEnabledToState(event);
    } else if (event is FormAdded) {
      yield* _mapFormAddedToState();
    } else if (event is FormEdited) {
      yield* _mapFormEditedToState(event);
    } else if (event is FormDuplicated) {
      yield* _mapFormDuplicatedToState(event);
    } else if (event is FormDeleted) {
      yield* _mapFormDeletedToState(event);
    } else if (event is MultipartAdded) {
      yield* _mapMultipartAddedToState();
    } else if (event is MultipartEdited) {
      yield* _mapMultipartEditedToState(event);
    } else if (event is MultipartDuplicated) {
      yield* _mapMultipartDuplicatedToState(event);
    } else if (event is MultipartDeleted) {
      yield* _mapMultipartDeletedToState(event);
    } else if (event is TextEdited) {
      yield* _mapTextEditedToState(event);
    } else if (event is TextContentTypeChanged) {
      yield* _mapTextContentTypeChangedToState(event);
    } else if (event is FileChoosed) {
      yield* _mapFileChoosedToState(event);
    } else if (event is FileRemoved) {
      yield* _mapFileRemovedToState(event);
    } else if (event is TargetAdded) {
      yield* _mapTargetAddedToState();
    } else if (event is TargetEdited) {
      yield* _mapTargetEditedToState(event);
    } else if (event is TargetDuplicated) {
      yield* _mapTargetDuplicatedToState(event);
    } else if (event is TargetDeleted) {
      yield* _mapTargetDeletedToState(event);
    } else if (event is DataAdded) {
      yield* _mapDataAddedToState();
    } else if (event is DataEdited) {
      yield* _mapDataEditedToState(event);
    } else if (event is DataDuplicated) {
      yield* _mapDataDuplicatedToState(event);
    } else if (event is DataDeleted) {
      yield* _mapDataDeletedToState(event);
    } else if (event is NotificationAdded) {
      yield* _mapNotificationAddedToState();
    } else if (event is NotificationEdited) {
      yield* _mapNotificationEditedToState(event);
    } else if (event is NotificationDuplicated) {
      yield* _mapNotificationDuplicatedToState(event);
    } else if (event is NotificationDeleted) {
      yield* _mapNotificationDeletedToState(event);
    } else if (event is QueryAdded) {
      yield* _mapQueryAddedToState();
    } else if (event is QueryEdited) {
      yield* _mapQueryEditedToState(event);
    } else if (event is QueryDuplicated) {
      yield* _mapQueryDuplicatedToState(event);
    } else if (event is QueryDeleted) {
      yield* _mapQueryDeletedToState(event);
    } else if (event is HeaderAdded) {
      yield* _mapHeaderAddedToState();
    } else if (event is HeaderEdited) {
      yield* _mapHeaderEditedToState(event);
    } else if (event is HeaderDuplicated) {
      yield* _mapHeaderDuplicatedToState(event);
    } else if (event is HeaderDeleted) {
      yield* _mapHeaderDeletedToState(event);
    } else if (event is AuthEdited) {
      yield* _mapAuthEditedToState(event);
    } else if (event is RequestSettingsEdited) {
      yield* _mapRequestSettingsEditedToState(event);
    }
  }

  Stream<RequestState> _mapRequestSentToState(RequestSent event) async* {
    final request = state.request;

    try {
      if (request.isREST) {
        yield* _makeRestRequestAndSendIt(request);
      } else if (request.isFCM) {
        yield* _makeFcmRequestAndSendIt(request);
      }
    } on CancelledException {
      yield state.copyWith(sending: false);
    } on TooManyRedirectsException {
      final response = _obtainResponseError('Too many redirects');
      yield state.copyWith(sending: false, response: response);
    } on TimedOutException {
      final response = _obtainResponseError('Connection timed out');
      yield state.copyWith(sending: false, response: response);
    } on ArgumentError catch (e) {
      final response = _obtainResponseError(e.message);
      yield state.copyWith(sending: false, response: response);
    } on FormatException catch (e) {
      final response = _obtainResponseError(e.message);
      yield state.copyWith(sending: false, response: response);
    } on FileSystemException catch (e) {
      final response = _obtainResponseError('${e.message}: ${e.path}');
      yield state.copyWith(sending: false, response: response);
    } on HandshakeException catch (e) {
      final message = e.osError?.message ?? e.message;
      final response = _obtainResponseError(message);
      yield state.copyWith(sending: false, response: response);
    } on TlsException catch (e) {
      final response = _obtainResponseError(e.osError?.message ?? e.message);
      yield state.copyWith(sending: false, response: response);
    } on HttpException catch (e) {
      final message = e.toString();
      final response = _obtainResponseError(message);
      yield state.copyWith(sending: false, response: response);
    } on SocketException catch (e) {
      final response = _obtainResponseError(e.osError?.message ?? e.message);
      yield state.copyWith(sending: false, response: response);
    } on VariableException catch (e) {
      _messager.show(
        (i18n) => obtainVariableExceptionMessage(i18n, e),
        type: MessagerType.error,
      );
    } catch (e) {
      final response = _obtainResponseError(e.toString());
      yield state.copyWith(sending: false, response: response);
    }
  }

  Stream<RequestState> _makeRestRequestAndSendIt(RequestEntity request) async* {
    // Força o cache se não tiver internet.
    final connectivity = await Connectivity().checkConnectivity();
    final forceCache =
        request.settings.cache && connectivity == ConnectivityResult.none
            ? CacheControl.forceCache
            : null;

    final connectTimeout = _settings.connectionTimeout;
    final certificateEnabled = _settings.certificateEnabled;
    // Busca o proxy.
    final proxy = _settings.proxyEnabled && request.settings?.proxy?.uid != null
        ? await _proxyRepository.get(request.settings.proxy.uid)
        : null;
    // Busca o DNS.
    final dns = _settings.dnsEnabled && request.settings?.dns?.uid != null
        ? await _dnsRepository.get(request.settings.dns.uid)
        : null;
    // Habilita variáveis.
    final enableVariables = request.settings.enableVariables;
    // Variáveis de ambiente.
    final workspace = await _workspaceRepository.active();
    final environment = await _environmentRepository.active(workspace);
    // Busca as variáveis do ambiente selecionado.
    final variables = _mapVariables(await _variableRepository.all(environment));
    // Busca as variáveis globais do workspace.
    final globals = _mapVariables(await _variableRepository.global(workspace));

    final vr = VariableResolver(globals: globals, variables: variables);

    // Método que resolve um texto a partir das variáveis.
    String variableResolver(String text) {
      return enableVariables ? vr.resolve(text) : text;
    }

    Restio restio;

    try {
      final options = RequestOptions(
        auth: _buildAuthenticator(request, variableResolver),
        followRedirects: _settings.followRedirects,
        maxRedirects: _settings.maxRedirects,
        verifySSLCertificate: _settings.validateCertificates,
        connectTimeout:
            connectTimeout <= -1 ? null : Duration(seconds: connectTimeout),
        userAgent: _settings.userAgent,
        proxy: proxy?.enabled == true ? proxy : null,
        dns: dns != null && dns.enabled
            ? (dns.https == true
                ? DnsOverHttps(RequestUri.parse(dns.url))
                : DnsOverUdp(
                    remoteAddress: dns.address,
                    remotePort: dns.port,
                  ))
            : null,
        http2: request.scheme == 'http2',
        persistentConnection: request.settings.persistentConnection,
      );

      // Cria o cliente.
      restio = Restio(
        options: options,
        // networkInterceptors: [const LogInterceptor()],
        cookieJar: _settings.cookieEnabled ? this : null,
        certificates: certificateEnabled && request.scheme == 'https'
            ? await _fetchCertificates()
            : null,
        cache: request.settings.cache && _settings.cacheEnabled
            ? kiwi<Cache>()
            : null,
        connectionPool: kiwi<ConnectionPool>(),
      );
    } on VariableException catch (e) {
      _messager.show(
        (i18n) => obtainVariableExceptionMessage(i18n, e),
        type: MessagerType.error,
      );

      return;
    } catch (e) {
      _messager.show(
        (i18n) => 'DNS: $e',
        type: MessagerType.error,
      );

      return;
    }

    Response httpResponse;

    // Inicia a chamada.
    try {
      final req = Request(
        method: request.method,
        uri: _obtainUri(request, variableResolver),
        headers: _obtainHeaders(request.header, variableResolver),
        queries: _obtainQueries(request.query, variableResolver),
        body: _obtainBody(request, variableResolver),
        cacheControl: forceCache,
        keepEqualSign: request.settings.keepEqualSign,
      );

      final call = restio.newCall(req);

      yield state.copyWith(sending: true, call: call);

      httpResponse = await call.execute();
      final response = await _obtainResponse(httpResponse);

      print('TCP port: ${httpResponse.localPort}');
      print('DNS address: ${httpResponse.address}');

      if (_settings.historyEnabled && response.status > 0) {
        final saveResponseBody = _settings.saveResponseBody;

        final history = HistoryEntity(
          uid: generateUuid(),
          date: currentMillis(),
          request: request.clone(),
          response: response.copyWith(
            data: saveResponseBody ? null : const <int>[],
          ),
        );

        await _historyRepository.insert(history);
      }

      yield state.copyWith(
        sending: false,
        response: response,
      );

      if (httpResponse.code == 504 && forceCache != null) {
        _messager.show(
          (i18n) => i18n.responseNotFoundInCache,
          type: MessagerType.error,
        );
      }
    } finally {
      await httpResponse?.close();
    }
  }

  Stream<RequestState> _makeFcmRequestAndSendIt(RequestEntity request) async* {
    final connectTimeout = _settings.connectionTimeout;
    // Busca o proxy.
    final proxy = _settings.proxyEnabled && request.settings?.proxy?.uid != null
        ? await _proxyRepository.get(request.settings.proxy.uid)
        : null;
    // Busca o DNS.
    final dns = _settings.dnsEnabled && request.settings?.dns?.uid != null
        ? await _dnsRepository.get(request.settings.dns.uid)
        : null;
    // Habilita variáveis.
    final enableVariables = request.settings.enableVariables;
    // Variáveis de ambiente.
    final workspace = await _workspaceRepository.active();
    final environment = await _environmentRepository.active(workspace);
    // Busca as variáveis do ambiente selecionado.
    final variables = _mapVariables(await _variableRepository.all(environment));
    // Busca as variáveis globais do workspace.
    final globals = _mapVariables(await _variableRepository.global(workspace));

    final vr = VariableResolver(globals: globals, variables: variables);

    // Método que resolve um texto a partir das variáveis.
    String variableResolver(String text) {
      return enableVariables ? vr.resolve(text) : text;
    }

    Restio restio;

    try {
      final options = RequestOptions(
        followRedirects: _settings.followRedirects,
        maxRedirects: _settings.maxRedirects,
        verifySSLCertificate: _settings.validateCertificates,
        connectTimeout:
            connectTimeout <= -1 ? null : Duration(seconds: connectTimeout),
        userAgent: _settings.userAgent,
        proxy: proxy?.enabled == true ? proxy : null,
        dns: dns != null && dns.enabled
            ? (dns.https == true
                ? DnsOverHttps(RequestUri.parse(dns.url))
                : DnsOverUdp(
                    remoteAddress: dns.address,
                    remotePort: dns.port,
                  ))
            : null,
        http2: true,
        persistentConnection: request.settings.persistentConnection,
      );

      // Cria o cliente.
      restio = Restio(
        options: options,
        // networkInterceptors: [const LogInterceptor()],
        cookieJar: _settings.cookieEnabled ? this : null,
        connectionPool: kiwi<ConnectionPool>(),
      );
    } on VariableException catch (e) {
      _messager.show(
        (i18n) => obtainVariableExceptionMessage(i18n, e),
        type: MessagerType.error,
      );

      return;
    } catch (e) {
      _messager.show(
        (i18n) => 'DNS: $e',
        type: MessagerType.error,
      );

      return;
    }

    Response httpResponse;

    // Inicia a chamada.
    try {
      final req = Request(
        method: 'POST',
        uri: RequestUri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: _obtainFcmHeaders(request, variableResolver),
        queries: _obtainFcmQueries(request, variableResolver),
        body: _obtainFcmBody(request, variableResolver),
      );

      final call = restio.newCall(req);

      yield state.copyWith(sending: true, call: call);

      httpResponse = await call.execute();
      final response = await _obtainResponse(httpResponse);

      print('TCP port: ${httpResponse.localPort}');
      print('DNS address: ${httpResponse.address}');

      if (_settings.historyEnabled && response.status > 0) {
        final saveResponseBody = _settings.saveResponseBody;

        final history = HistoryEntity(
          uid: generateUuid(),
          date: currentMillis(),
          request: request.clone(),
          response: response.copyWith(
            data: saveResponseBody ? null : const <int>[],
          ),
        );

        await _historyRepository.insert(history);
      }

      yield state.copyWith(
        sending: false,
        response: response,
      );
    } finally {
      await httpResponse?.close();
    }
  }

  static Map<String, String> _mapVariables(List<VariableEntity> variables) {
    return {
      for (final item in variables)
        if (item.enabled) item.name: item.value,
    };
  }

  static ResponseEntity _obtainResponseError(String message) {
    final data = message?.codeUnits ?? const <int>[];

    return ResponseEntity(
      uid: generateUuid(),
      status: -1,
      contentType: MediaType.text,
      data: data,
      size: data.length,
    );
  }

  static RequestUri _obtainUri(
    RequestEntity request,
    VariableResolverCallback callback,
  ) {
    // Uri.
    final uri = RequestUri.parse(callback(request.rightUrl));
    // Port.
    var port = uri.effectivePort;
    if (request.scheme == 'http' &&
        (uri.effectivePort == 443 || uri.effectivePort == 0)) {
      port = 80;
    } else if ((request.scheme == 'https' || request.scheme == 'http2') &&
        (uri.effectivePort == 80 || uri.effectivePort == 0)) {
      port = 443;
    }

    return uri.copyWith(
      scheme: request.scheme == 'http2'
          ? 'https'
          : request.scheme == 'auto'
              ? uri.scheme
              : request.scheme,
      port: port,
    );
  }

  static Headers _obtainHeaders(
    RequestHeaderEntity requestHeader,
    VariableResolverCallback callback,
  ) {
    final headers = HeadersBuilder();

    if (requestHeader.enabled) {
      for (final item in requestHeader.headers) {
        if (item.isValid) {
          headers.add(
            callback(item.name),
            callback(item.value),
          );
        }
      }
    }

    return headers.build();
  }

  static Headers _obtainFcmHeaders(
    RequestEntity request,
    VariableResolverCallback callback,
  ) {
    final headers = HeadersBuilder();
    headers.add('Authorization', 'key=${request.url}');
    return headers.build();
  }

  static Queries _obtainQueries(
    RequestQueryEntity requestQuery,
    VariableResolverCallback callback,
  ) {
    final queries = QueriesBuilder();

    if (requestQuery.enabled) {
      for (final item in requestQuery.queries) {
        if (item.isValid) {
          queries.add(
            callback(item.name),
            callback(item.value),
          );
        }
      }
    }

    return queries.build();
  }

  static Queries _obtainFcmQueries(
    RequestEntity request,
    VariableResolverCallback callback,
  ) {
    return Queries.empty;
  }

  static RequestBody _obtainBody(
    RequestEntity request,
    VariableResolverCallback callback,
  ) {
    if (!request.body.enabled) {
      return null;
    }

    // Texto.
    if (request.body.type == RequestBodyType.text) {
      return _obtainTextBody(request, callback);
    }

    // Form.
    if (request.body.type == RequestBodyType.form) {
      return _obtainForm(request, callback);
    }

    // File.
    if (request.body.type == RequestBodyType.file) {
      return _obtainBinaryFile(request);
    }

    // Multipart.
    if (request.body.type == RequestBodyType.multipart) {
      return _obtainMultipart(request, callback);
    }

    return null;
  }

  static RequestBody _obtainFcmBody(
    RequestEntity request,
    VariableResolverCallback callback,
  ) {
    final data = <String, dynamic>{};

    if (request.data.enabled) {
      data['data'] = <String, dynamic>{};

      for (final item in request.data.data) {
        if (item.isValid) {
          final key = callback(item.name);
          final value = callback(item.value);
          data['data'][key] = value;
        }
      }
    }

    if (request.notification.enabled) {
      data['notification'] = <String, dynamic>{};

      for (final item in request.notification.notifications) {
        if (item.isValid) {
          final key = callback(item.name);
          final value = callback(item.value);
          data['notification'][key] = value;
        }
      }
    }

    String to, condition;
    final ids = <String>[];

    for (final item in request.target.targets) {
      if (item.isValid) {
        final key = callback(item.name);
        final value = callback(item.value);

        if (key == 'to') {
          to = value;
        } else if (key == 'registration_id') {
          ids.add(value);
        } else if (key == 'condition') {
          condition = value;
        }
      }
    }

    if (to != null && to.isNotEmpty) {
      data['to'] = to;
    }

    if (condition != null && condition.isNotEmpty) {
      data['condition'] = condition;
    }

    if (ids.isNotEmpty) {
      data['registration_ids'] = ids;
    }

    return RequestBody.json(data);
  }

  static RequestBody _obtainTextBody(
    RequestEntity request,
    VariableResolverCallback callback,
  ) {
    return RequestBody.string(callback(request.body.text));
  }

  static RequestBody _obtainForm(
    RequestEntity request,
    VariableResolverCallback callback,
  ) {
    final items = <String, List<String>>{};

    for (final item in request.body.formItems) {
      if (!item.isValid) {
        continue;
      }

      final name = callback(item.name);

      if (!items.containsKey(name)) {
        items[name] = [];
      }

      items[name].add(callback(item.value));
    }

    return FormBody.fromMap(items);
  }

  static RequestBody _obtainMultipart(
    RequestEntity request,
    VariableResolverCallback callback,
  ) {
    final parts = <Part>[];

    for (final item in request.body.multipartItems) {
      if (!item.isValid) {
        continue;
      }
      final name = callback(item.name);
      // Text.
      if (item.type == MultipartType.text) {
        parts.add(Part.form(name, callback(item.value)));
      }
      // File.
      else if (item.file != null) {
        final file = File(item.file.path);

        parts.add(
          Part.file(
            name,
            item.file.name,
            RequestBody.file(file),
          ),
        );
      }
    }

    return MultipartBody(parts: parts);
  }

  static RequestBody _obtainBinaryFile(RequestEntity request) {
    final file = request.body.file;

    if (file != null && file.isNotEmpty) {
      return RequestBody.file(File(file));
    } else {
      return null;
    }
  }

  static Authenticator _buildAuthenticator(
    RequestEntity request,
    VariableResolverCallback callback,
  ) {
    if (request.auth.enabled) {
      if (request.auth.type == RequestAuthType.basic) {
        return BasicAuthenticator(
          username: callback(request.auth.basicUsername),
          password: callback(request.auth.basicPassword),
        );
      }

      if (request.auth.type == RequestAuthType.hawk) {
        return HawkAuthenticator(
          id: callback(request.auth.hawkId),
          key: callback(request.auth.hawkKey),
          ext: callback(request.auth.hawkExt),
          algorithm: request.auth.hawkAlgorithm,
        );
      }

      if (request.auth.type == RequestAuthType.bearer) {
        return BearerAuthenticator(
          token: callback(request.auth.bearerToken),
          prefix: callback(request.auth.bearerPrefix),
        );
      }

      if (request.auth.type == RequestAuthType.digest) {
        return DigestAuthenticator(
          username: callback(request.auth.digestUsername),
          password: callback(request.auth.digestPassword),
        );
      }
    }

    return null;
  }

  Future<ResponseEntity> _obtainResponse(Response response) async {
    final bytes = await response.body.decompressed() ?? const <int>[];
    final headers = _obtainResponseHeaders(response);
    final contentType = response.headers.has('content-type')
        ? MediaType.parse(response.headers.value('content-type'))
        : null;

    return ResponseEntity(
      uid: generateUuid(),
      status: response.code,
      time: response.totalMilliseconds,
      contentType: contentType,
      data: bytes,
      size: bytes.length,
      headers: headers,
      cookies: _obtainResponseCookies(response),
      redirects: _obtainResponseRedirects(response),
      cache: response.cacheResponse != null,
    );
  }

  List<HeaderEntity> _obtainResponseHeaders(Response response) {
    final headers = <HeaderEntity>[];

    response.headers.forEach((item) {
      if (item.name != 'set-cookie') {
        headers.add(
          HeaderEntity(
            uid: generateUuid(),
            name: item.name,
            value: item.value,
          ),
        );
      }
    });

    return headers;
  }

  List<CookieEntity> _obtainResponseCookies(Response response) {
    return [
      for (final r in response.redirects)
        for (final cookie in r.response.cookies)
          CookieEntity(
            uid: generateUuid(),
            timestamp: currentMillis(),
            name: cookie.name,
            value: cookie.value,
            expires: cookie.expires,
            maxAge: cookie.maxAge,
            domain: cookie.domain,
            path: cookie.path,
            secure: cookie.secure,
            httpOnly: cookie.httpOnly,
          ),
      for (final cookie in response.cookies)
        CookieEntity(
          uid: generateUuid(),
          timestamp: currentMillis(),
          name: cookie.name,
          value: cookie.value,
          expires: cookie.expires,
          maxAge: cookie.maxAge,
          domain: cookie.domain,
          path: cookie.path,
          secure: cookie.secure,
          httpOnly: cookie.httpOnly,
        ),
    ];
  }

  List<RedirectEntity> _obtainResponseRedirects(Response response) {
    // Retorna todos os redirecionamentos.
    return <RedirectEntity>[
      for (final item in response.redirects)
        RedirectEntity(
          uid: generateUuid(),
          location: item.location.toString(),
          time: item.elapsedMilliseconds,
          code: item.response.code,
          ip: item.response.address?.toString() ?? '',
        ),
      // Validou o cache.
      if (response.networkResponse != null)
        RedirectEntity(
          uid: generateUuid(),
          location: response.networkResponse.request.uri.toUriString(),
          time: response.totalMilliseconds,
          code: response.networkResponse.code,
          ip: response.address?.toString() ?? '',
        )
      else
        RedirectEntity(
          uid: generateUuid(),
          location: response.request.uri.toUriString(),
          time: response.totalMilliseconds,
          code: response.code,
          ip: response.address?.toString() ?? '',
        ),
    ];
  }

  Stream<RequestState> _mapRequestLoadedToState(RequestLoaded event) async* {
    yield state.copyWith(request: event.request);
  }

  Stream<RequestState> _mapRequestClearedToState() async* {
    final request = state.request.copyWith(
      method: 'GET',
      scheme: 'https',
      body: const RequestBodyEntity(),
      query: const RequestQueryEntity(),
      header: const RequestHeaderEntity(),
      auth: const RequestAuthEntity(),
      url: '',
      settings: RequestSettingsEntity.empty,
    );

    yield state.copyWith(request: request);
  }

  Stream<RequestState> _mapMethodChangedToState(MethodChanged event) async* {
    final request = state.request;
    final newRequest = request.copyWith(method: event.method);

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapTypeChangedToState(
    TypeChanged event,
  ) async* {
    final request = state.request;
    final newRequest = request.copyWith(type: event.type);

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapSchemeChangedToState(
    SchemeChanged event,
  ) async* {
    final request = state.request;
    final newRequest = request.copyWith(scheme: event.scheme);

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapUrlChangedToState(
    UrlChanged event,
  ) async* {
    final request = state.request;
    final newRequest = request.copyWith(url: event.url);

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapDescriptionChangedToState(
    DescriptionChanged event,
  ) async* {
    final request = state.request;
    final newRequest = request.copyWith(description: event.description);

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapBodyEnabledToState(BodyEnabled event) async* {
    final request = state.request;
    if (request.body.enabled != event.enabled) {
      final newRequest = request.copyWith(
        body: request.body.copyWith(
          enabled: event.enabled,
        ),
      );

      yield state.copyWith(request: newRequest);
    }
  }

  Stream<RequestState> _mapBodyTypeChangedToState(
    BodyTypeChanged event,
  ) async* {
    final request = state.request;
    final newRequest = request.copyWith(
      body: request.body.copyWith(
        type: event.type,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapDataEnabledToState(DataEnabled event) async* {
    final request = state.request;
    final newRequest = request.copyWith(
      data: request.data.copyWith(
        enabled: event.enabled,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapNotificationEnabledToState(
      NotificationEnabled event) async* {
    final request = state.request;
    final newRequest = request.copyWith(
      notification: request.notification.copyWith(
        enabled: event.enabled,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapQueryEnabledToState(QueryEnabled event) async* {
    final request = state.request;
    final newRequest = request.copyWith(
      query: request.query.copyWith(
        enabled: event.enabled,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapHeaderEnabledToState(HeaderEnabled event) async* {
    final request = state.request;
    final newRequest = request.copyWith(
      header: request.header.copyWith(
        enabled: event.enabled,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapFormAddedToState() async* {
    final request = state.request;
    final newRequest = request.copyWith(
      body: request.body.copyWith(
        formItems: [
          ...request.body.formItems,
          FormEntity(uid: generateUuid()),
        ],
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapFormEditedToState(FormEdited event) async* {
    final request = state.request;
    final items = List.of(request.body.formItems);

    final index = items.indexWhere((item) => item.uid == event.form.uid);

    if (index < 0) {
      return;
    }

    items[index] = event.form;

    final newRequest = request.copyWith(
      body: request.body.copyWith(
        formItems: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapFormDuplicatedToState(FormDuplicated event) async* {
    final request = state.request;
    final items = List.of(request.body.formItems);

    final index = items.indexWhere((item) => item.uid == event.form.uid);

    if (index < 0) {
      return;
    }

    items.insert(index, items[index].copyWith(uid: generateUuid()));

    final newRequest = request.copyWith(
      body: request.body.copyWith(
        formItems: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapFormDeletedToState(FormDeleted event) async* {
    final request = state.request;
    final items = List.of(request.body.formItems);

    final index = items.indexWhere((item) => item.uid == event.form.uid);

    if (index < 0) {
      return;
    }

    items.removeAt(index);

    final newRequest = request.copyWith(
      body: request.body.copyWith(
        formItems: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapMultipartAddedToState() async* {
    final request = state.request;
    final newRequest = request.copyWith(
      body: request.body.copyWith(
        multipartItems: [
          ...request.body.multipartItems,
          MultipartEntity(uid: generateUuid()),
        ],
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapMultipartEditedToState(
    MultipartEdited event,
  ) async* {
    final request = state.request;
    final items = List.of(request.body.multipartItems);

    final index = items.indexWhere((item) => item.uid == event.multipart.uid);

    if (index < 0) {
      return;
    }

    items[index] = event.multipart;

    final newRequest = request.copyWith(
      body: request.body.copyWith(
        multipartItems: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapMultipartDuplicatedToState(
    MultipartDuplicated event,
  ) async* {
    final request = state.request;
    final items = List.of(request.body.multipartItems);

    final index = items.indexWhere((item) => item.uid == event.multipart.uid);

    if (index < 0) {
      return;
    }

    items.insert(index, items[index].copyWith(uid: generateUuid()));

    final newRequest = request.copyWith(
      body: request.body.copyWith(
        multipartItems: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapMultipartDeletedToState(
    MultipartDeleted event,
  ) async* {
    final request = state.request;
    final items = List.of(request.body.multipartItems);

    final index = items.indexWhere((item) => item.uid == event.multipart.uid);

    if (index < 0) {
      return;
    }

    items.removeAt(index);

    final newRequest = request.copyWith(
      body: request.body.copyWith(
        multipartItems: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapTextEditedToState(
    TextEdited event,
  ) async* {
    final request = state.request;
    final newRequest = request.copyWith(
      body: request.body.copyWith(
        text: event.text,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapTextContentTypeChangedToState(
    TextContentTypeChanged event,
  ) async* {
    final request = state.request;
    final headers = List.of(request.header.headers);
    var encontrou = false;

    // Busca pelo header 'Content-Type' e atualiza-o.
    for (var i = 0; i < headers.length; i++) {
      if (headers[i].name.toLowerCase() == HttpHeaders.contentTypeHeader) {
        headers[i] = headers[i].copyWith(value: event.contentType);
        encontrou = true;
        break;
      }
    }

    if (!encontrou) {
      headers.add(HeaderEntity(
        uid: generateUuid(),
        name: HttpHeaders.contentTypeHeader,
        value: event.contentType,
      ));
    }

    yield state.copyWith(
      request: request.copyWith(
        header: request.header.copyWith(
          headers: headers,
        ),
      ),
    );
  }

  Stream<RequestState> _mapFileChoosedToState(
    FileChoosed event,
  ) async* {
    final request = state.request;
    final newRequest = request.copyWith(
      body: request.body.copyWith(
        file: event.file,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapFileRemovedToState(
    FileRemoved event,
  ) async* {
    final request = state.request;
    final newRequest = request.copyWith(
      body: request.body.copyWith(file: ''),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapTargetAddedToState() async* {
    final request = state.request;
    final newRequest = request.copyWith(
      target: request.target.copyWith(
        targets: [
          ...request.target.targets,
          TargetEntity(uid: generateUuid()),
        ],
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapTargetEditedToState(
    TargetEdited event,
  ) async* {
    final request = state.request;
    final items = List.of(request.target.targets);

    final index = items.indexWhere((item) => item.uid == event.target.uid);

    if (index < 0) {
      return;
    }

    items[index] = event.target;

    final newRequest = request.copyWith(
      target: request.target.copyWith(
        targets: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapTargetDuplicatedToState(
    TargetDuplicated event,
  ) async* {
    final request = state.request;
    final items = List.of(request.target.targets);

    final index = items.indexWhere((item) => item.uid == event.target.uid);

    if (index < 0) {
      return;
    }

    items.insert(index, items[index].copyWith(uid: generateUuid()));

    final newRequest = request.copyWith(
      target: request.target.copyWith(
        targets: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapTargetDeletedToState(
    TargetDeleted event,
  ) async* {
    final request = state.request;
    final items = List.of(request.target.targets);

    final index = items.indexWhere((item) => item.uid == event.target.uid);

    if (index < 0) {
      return;
    }

    items.removeAt(index);

    final newRequest = request.copyWith(
      target: request.target.copyWith(
        targets: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapDataAddedToState() async* {
    final request = state.request;
    final newRequest = request.copyWith(
      data: request.data.copyWith(
        data: [
          ...request.data.data,
          DataEntity(uid: generateUuid()),
        ],
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapDataEditedToState(
    DataEdited event,
  ) async* {
    final request = state.request;
    final items = List.of(request.data.data);

    final index = items.indexWhere((item) => item.uid == event.data.uid);

    if (index < 0) {
      return;
    }

    items[index] = event.data;

    final newRequest = request.copyWith(
      data: request.data.copyWith(
        data: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapDataDuplicatedToState(
    DataDuplicated event,
  ) async* {
    final request = state.request;
    final items = List.of(request.data.data);

    final index = items.indexWhere((item) => item.uid == event.data.uid);

    if (index < 0) {
      return;
    }

    items.insert(index, items[index].copyWith(uid: generateUuid()));

    final newRequest = request.copyWith(
      data: request.data.copyWith(
        data: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapDataDeletedToState(
    DataDeleted event,
  ) async* {
    final request = state.request;
    final items = List.of(request.data.data);

    final index = items.indexWhere((item) => item.uid == event.data.uid);

    if (index < 0) {
      return;
    }

    items.removeAt(index);

    final newRequest = request.copyWith(
      data: request.data.copyWith(
        data: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapNotificationAddedToState() async* {
    final request = state.request;
    final newRequest = request.copyWith(
      notification: request.notification.copyWith(
        notifications: [
          ...request.notification.notifications,
          NotificationEntity(uid: generateUuid()),
        ],
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapNotificationEditedToState(
    NotificationEdited event,
  ) async* {
    final request = state.request;
    final items = List.of(request.notification.notifications);

    final index =
        items.indexWhere((item) => item.uid == event.notification.uid);

    if (index < 0) {
      return;
    }

    items[index] = event.notification;

    final newRequest = request.copyWith(
      notification: request.notification.copyWith(
        notifications: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapNotificationDuplicatedToState(
    NotificationDuplicated event,
  ) async* {
    final request = state.request;
    final items = List.of(request.notification.notifications);

    final index =
        items.indexWhere((item) => item.uid == event.notification.uid);

    if (index < 0) {
      return;
    }

    items.insert(index, items[index].copyWith(uid: generateUuid()));

    final newRequest = request.copyWith(
      notification: request.notification.copyWith(
        notifications: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapNotificationDeletedToState(
    NotificationDeleted event,
  ) async* {
    final request = state.request;
    final items = List.of(request.notification.notifications);

    final index =
        items.indexWhere((item) => item.uid == event.notification.uid);

    if (index < 0) {
      return;
    }

    items.removeAt(index);

    final newRequest = request.copyWith(
      notification: request.notification.copyWith(
        notifications: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapQueryAddedToState() async* {
    final request = state.request;
    final newRequest = request.copyWith(
      query: request.query.copyWith(
        queries: [
          ...request.query.queries,
          QueryEntity(uid: generateUuid()),
        ],
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapQueryEditedToState(
    QueryEdited event,
  ) async* {
    final request = state.request;
    final items = List.of(request.query.queries);

    final index = items.indexWhere((item) => item.uid == event.query.uid);

    if (index < 0) {
      return;
    }

    items[index] = event.query;

    final newRequest = request.copyWith(
      query: request.query.copyWith(
        queries: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapQueryDuplicatedToState(
    QueryDuplicated event,
  ) async* {
    final request = state.request;
    final items = List.of(request.query.queries);

    final index = items.indexWhere((item) => item.uid == event.query.uid);

    if (index < 0) {
      return;
    }

    items.insert(index, items[index].copyWith(uid: generateUuid()));

    final newRequest = request.copyWith(
      query: request.query.copyWith(
        queries: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapQueryDeletedToState(
    QueryDeleted event,
  ) async* {
    final request = state.request;
    final items = List.of(request.query.queries);

    final index = items.indexWhere((item) => item.uid == event.query.uid);

    if (index < 0) {
      return;
    }

    items.removeAt(index);

    final newRequest = request.copyWith(
      query: request.query.copyWith(
        queries: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapHeaderAddedToState() async* {
    final request = state.request;
    final newRequest = request.copyWith(
      header: request.header.copyWith(
        headers: [
          ...request.header.headers,
          HeaderEntity(uid: generateUuid()),
        ],
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapHeaderEditedToState(
    HeaderEdited event,
  ) async* {
    final request = state.request;
    final items = List.of(request.header.headers);

    final index = items.indexWhere((item) => item.uid == event.header.uid);

    if (index < 0) {
      return;
    }

    items[index] = event.header;

    final newRequest = request.copyWith(
      header: request.header.copyWith(
        headers: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapHeaderDuplicatedToState(
    HeaderDuplicated event,
  ) async* {
    final request = state.request;
    final items = List.of(request.header.headers);

    final index = items.indexWhere((item) => item.uid == event.header.uid);

    if (index < 0) {
      return;
    }

    items.insert(index, items[index].copyWith(uid: generateUuid()));

    final newRequest = request.copyWith(
      header: request.header.copyWith(
        headers: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapHeaderDeletedToState(
    HeaderDeleted event,
  ) async* {
    final request = state.request;
    final items = List.of(request.header.headers);

    final index = items.indexWhere((item) => item.uid == event.header.uid);

    if (index < 0) {
      return;
    }

    items.removeAt(index);

    final newRequest = request.copyWith(
      header: request.header.copyWith(
        headers: items,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapAuthEditedToState(
    AuthEdited event,
  ) async* {
    final request = state.request;
    final newRequest = request.copyWith(
      auth: request.auth.copyWith(
        type: event.type,
        enabled: event.enabled,
        basicUsername: event.basicUsername,
        basicPassword: event.basicPassword,
        digestUsername: event.digestUsername,
        digestPassword: event.digestPassword,
        bearerPrefix: event.bearerPrefix,
        bearerToken: event.bearerToken,
        hawkId: event.hawkId,
        hawkKey: event.hawkKey,
        hawkExt: event.hawkExt,
        hawkAlgorithm: event.hawkAlgorithm,
      ),
    );

    yield state.copyWith(request: newRequest);
  }

  Stream<RequestState> _mapRequestSettingsEditedToState(
    RequestSettingsEdited event,
  ) async* {
    final request = state.request;
    final newRequest = request.copyWith(
      settings: event.settings,
    );

    yield state.copyWith(request: newRequest);
  }

  @override
  Future<List<Cookie>> load(Request request) async {
    final settings = state.request.settings;

    if (!settings.sendCookies) {
      return const [];
    }

    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    final path = request.uri.path.isEmpty ? '/' : request.uri.path;
    final cookies = await _cookieRepository.getByDomainAndPath(
      workspace,
      request.uri.host,
      path,
    );

    return [
      for (final cookie in cookies)
        if (cookie.enabled &&
            (!cookie.secure ||
                request.uri.scheme == 'https' ||
                request.uri.scheme == 'http2') &&
            !cookie.expired)
          Cookie(cookie.name, cookie.value),
    ];
  }

  @override
  Future<void> save(Response response) async {
    final settings = state.request.settings;

    if (!settings.storeCookies) {
      return;
    }

    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    for (final cookie in response.cookies) {
      // Cookie casa com o domain da requisição e, caso seja seguro, casar apenas com HTTPS.
      if (response.request.uri.host.endsWith(cookie.domain) &&
          (!cookie.secure || response.request.uri.scheme == 'https')) {
        final item = CookieEntity(
          uid: generateUuid(),
          timestamp: currentMillis(),
          name: cookie.name,
          value: cookie.value,
          expires: cookie.expires,
          maxAge: cookie.maxAge,
          domain: cookie.domain,
          path: cookie.path,
          secure: cookie.secure,
          httpOnly: cookie.httpOnly,
          workspace: workspace,
        );
        // Insere o cookie.
        await _cookieRepository.persist(item);
      }
    }
  }

  Future<List<Certificate>> _fetchCertificates() async {
    final res = <Certificate>[];
    final workspace = await _workspaceRepository.active();
    final certificates = await _certificateRepository.all(workspace);

    for (final c in certificates) {
      final crt = c.crt == null || c.crt.isEmpty ? null : File(c.crt);
      final key = c.key == null || c.key.isEmpty ? null : File(c.key);
      final port = c.port == null || c.port == 0 ? null : c.port;
      final password =
          c.passphrase == null || c.passphrase.isEmpty ? null : c.passphrase;

      res.add(Certificate(
        host: c.host,
        certificate: crt?.readAsBytesSync(),
        privateKey: key?.readAsBytesSync(),
        port: port,
        password: password,
      ));
    }

    return res;
  }
}
