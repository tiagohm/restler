import 'package:restler/data/entities/response_entity.dart';
import 'package:restler/data/providers/response_provider.dart';

class ResponseRepository {
  final ResponseProvider responseProvider;

  ResponseRepository(this.responseProvider);

  Future<ResponseEntity> get(
    String uid) async {
    if (uid == null) return null;
    final res = await responseProvider.get(uid);
    return res != null && res.isNotEmpty
        ? ResponseEntity.fromDatabase(res, fetchBody: true)
        : null;
  }

  Future<bool> insert(ResponseEntity response) async {
    return responseProvider.insert(response.toDatabase());
  }

  Future<bool> update(ResponseEntity response) async {
    return responseProvider.update(response.uid, response.toDatabase());
  }

  Future<bool> delete(ResponseEntity response) async {
    return responseProvider.delete(response.uid);
  }
}
