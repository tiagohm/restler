abstract class DropdownEvent {}

class Populated extends DropdownEvent {
  final Map<String, dynamic> data;

  Populated([this.data = const {}]);
}

class ItemSelected<T> extends DropdownEvent {
  final T item;

  ItemSelected(this.item);
}
