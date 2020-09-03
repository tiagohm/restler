import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/response_entity.dart';
import 'package:sqler/sqler.dart';

final historyTable = table('history');
final historyUid = col('his_uid');
final historyDate = col('his_date');
final historyRequest = col('his_request');
final historyResponse = col('his_response');

class HistoryEntity extends Equatable {
  final String uid;
  final int date;
  final RequestEntity request;
  final ResponseEntity response;

  const HistoryEntity({
    this.uid,
    this.date,
    this.request,
    this.response,
  });

  HistoryEntity.fromDatabase(Map<String, dynamic> db)
      : uid = db['his_uid'],
        date = db['his_date'],
        request = RequestEntity.fromDatabase(db),
        response = ResponseEntity.fromDatabase(db);

  Map<String, dynamic> toDatabase() {
    return {
      'his_uid': uid,
      'his_date': date,
      'his_request': request.uid,
      'his_response': response.uid
    };
  }

  @override
  List get props => [uid, date, request, response];
}
