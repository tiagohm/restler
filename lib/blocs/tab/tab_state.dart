import 'package:restler/data/entities/tab_entity.dart';

class TabState {
  final List<TabEntity> tabs;
  final int position;

  TabEntity get currentTab =>
      position >= 0 && position < tabs.length ? tabs[position] : null;

  const TabState({
    this.tabs = const [],
    this.position = -1,
  });

  TabState copyWith({
    List<TabEntity> tabs,
    int position,
  }) {
    return TabState(
      tabs: tabs ?? this.tabs,
      position: position ?? this.position,
    );
  }
}
