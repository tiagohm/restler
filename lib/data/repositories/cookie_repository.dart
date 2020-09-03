import 'package:restler/data/entities/cookie_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/providers/cookie_provider.dart';

class CookieRepository {
  final CookieProvider cookieProvider;

  CookieRepository(this.cookieProvider);

  Future<List<CookieEntity>> all(WorkspaceEntity workspace) {
    return search(workspace);
  }

  Future<List<CookieEntity>> search(
    WorkspaceEntity workspace, {
    String text = '',
    String sortBy = 'domain',
    String sortOrder = 'asc',
  }) async {
    final data = await cookieProvider.search(workspace?.uid, text: text);
    return data == null ? const [] : _mapDataToCookieList(data);
  }

  Future<List<CookieEntity>> getByDomain(
    WorkspaceEntity workspace,
    String domain,
  ) async {
    final data = await cookieProvider.search(workspace?.uid, domain: domain);
    return _mapDataToCookieList(data);
  }

  Future<List<CookieEntity>> getByDomainAndPath(
    WorkspaceEntity workspace,
    String domain,
    String path,
  ) async {
    final data =
        await cookieProvider.search(workspace?.uid, domain: domain, path: path);
    return _mapDataToCookieList(data);
  }

  Future<List<CookieEntity>> getByDomainAndName(
    WorkspaceEntity workspace,
    String domain,
    String name,
  ) async {
    final data =
        await cookieProvider.search(workspace?.uid, domain: domain, name: name);
    return _mapDataToCookieList(data);
  }

  Future<bool> insert(CookieEntity cookie) {
    return cookieProvider.insert(cookie.toDatabase());
  }

  Future<bool> update(CookieEntity cookie) {
    return cookieProvider.update(cookie.uid, cookie.toDatabase());
  }

  Future<CookieEntity> persist(CookieEntity cookie) async {
    // Verifica se o cookie existe no banco e se suas cópias também existem.
    final cookies =
        await getByDomainAndName(cookie.workspace, cookie.domain, cookie.name);
    for (final item in cookies) {
      // Atualiza apenas o seu path, value, timestamp, secure, httpOnly.
      cookie = cookie.copyWith(
        uid: item.uid,
        // domains podem ser diferentes do cookie atualizado
        // porque podem casar com subdomains.
        // Manter o que já está salvo.
        domain: item.domain,
        // Manter o que já está salvo.
        enabled: item.enabled,
      );
      // Atualiza.
      if (await update(cookie)) {
        return cookie;
      }
    }
    // Não existe no banco.
    if (cookies.isEmpty && await insert(cookie)) {
      return cookie;
    }
    // Nada foi inserido.
    return null;
  }

  Future<bool> delete(CookieEntity cookie) {
    return cookieProvider.delete(cookie?.uid);
  }

  Future<bool> clear(WorkspaceEntity workspace) {
    return cookieProvider.clear(workspace?.uid);
  }

  static List<CookieEntity> _mapDataToCookieList(
    List<Map<String, dynamic>> data,
  ) {
    return [for (final item in data) CookieEntity.fromDatabase(item)];
  }
}
