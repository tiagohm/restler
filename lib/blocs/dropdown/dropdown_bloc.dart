import 'package:bloc/bloc.dart';
import 'package:restler/blocs/dropdown/dropdown_event.dart';
import 'package:restler/blocs/dropdown/dropdown_state.dart';

abstract class DropdownBloc<T> extends Bloc<DropdownEvent, DropdownState<T>> {
  DropdownBloc(DropdownState<T> initialState) : super(initialState);

  @override
  Stream<DropdownState<T>> mapEventToState(DropdownEvent event) async* {
    if (event is Populated) {
      yield* mapPopulatedToState(event);
    } else if (event is ItemSelected) {
      yield* _mapItemSelectedToState(event);
    }
  }

  Stream<DropdownState<T>> mapPopulatedToState(Populated event);

  Stream<DropdownState<T>> _mapItemSelectedToState(ItemSelected event) async* {
    yield state.copyWith(selected: event.item);
  }
}
