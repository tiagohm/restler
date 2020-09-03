import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/providers/request_provider.dart';

class RequestRepository {
  final RequestProvider requestProvider;

  RequestRepository(this.requestProvider);

  Future<RequestEntity> get(String uid) async {
    if (uid == null) return null;
    final res = await requestProvider.get(uid);
    return res != null && res.isNotEmpty
        ? RequestEntity.fromDatabase(res)
        : null;
  }

  Future<bool> insert(RequestEntity request) async {
    return requestProvider.insert(request.toDatabase());
  }

  Future<bool> update(RequestEntity request) async {
    return requestProvider.update(request.uid, request.toDatabase());
  }

  Future<bool> delete(RequestEntity request) async {
    return requestProvider.delete(request.uid);
  }
}
