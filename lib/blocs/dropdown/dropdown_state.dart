class DropdownState<T> {
  final List<T> data;
  final T selected;

  const DropdownState({
    this.data = const [],
    this.selected,
  });

  DropdownState<T> copyWith({
    List<T> data,
    T selected,
  }) {
    return DropdownState<T>(
      data: data ?? this.data,
      selected: selected ?? this.selected,
    );
  }
}
