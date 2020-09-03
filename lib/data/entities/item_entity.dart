abstract class ItemEntity {
  String get uid;
  String get name;
  String get value;
  bool get enabled;

  ItemEntity copyWith({
    String uid,
    String name,
    String value,
    bool enabled,
  });
}
