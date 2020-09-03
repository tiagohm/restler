import 'package:equatable/equatable.dart';

class RedirectEntity extends Equatable {
  final String uid;
  final int time;
  final int code;
  final String location;
  final String ip;

  const RedirectEntity({
    this.uid,
    this.time = 0,
    this.code = 0,
    this.location = '',
    this.ip = '',
  });

  static const empty = RedirectEntity();

  RedirectEntity.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        time = json['time'],
        code = json['code'],
        location = json['location'],
        ip = json['ip'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'time': time,
      'code': code,
      'location': location,
      'ip': ip,
    };
  }

  RedirectEntity copyWith({
    String uid,
    int time,
    int code,
    String location,
    String ip,
  }) {
    return RedirectEntity(
      uid: uid ?? this.uid,
      time: time ?? this.time,
      code: code ?? this.code,
      location: location ?? this.location,
      ip: ip ?? this.ip,
    );
  }

  @override
  List get props => [uid, time, code, location, ip];

  @override
  String toString() {
    return 'Redirect { uid: $uid, time: $time, code: $code, location:$location, ip: $ip }';
  }
}
