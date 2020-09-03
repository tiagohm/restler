import 'package:bloc/bloc.dart';
import 'package:restler/blocs/constants.dart';
import 'package:restler/blocs/dns/dns_event.dart';
import 'package:restler/blocs/dns/dns_state.dart';
import 'package:restler/data/repositories/dns_repository.dart';
import 'package:restler/data/repositories/workspace_repository.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:rxdart/rxdart.dart';

class DnsBloc extends Bloc<DnsEvent, DnsState> {
  final _dnsRepository = kiwi<DnsRepository>();
  final _workspaceRepository = kiwi<WorkspaceRepository>();

  DnsBloc() : super(const DnsState());

  @override
  Stream<Transition<DnsEvent, DnsState>> transformTransitions(
    Stream<Transition<DnsEvent, DnsState>> transitions,
  ) {
    final debounceStream = transitions
        .where((event) => event.event is SearchTextChanged)
        .debounceTime(const Duration(milliseconds: searchTextDebounceTime));
    final nonDebounceStream =
        transitions.where((event) => event.event is! SearchTextChanged);

    return Rx.merge([debounceStream, nonDebounceStream]);
  }

  @override
  Stream<DnsState> mapEventToState(DnsEvent event) async* {
    if (event is SearchTextChanged) {
      yield* _mapSearchTextChangedToState(event);
    } else if (event is SearchToggled) {
      yield* _mapSearchToggledToState(event);
    } else if (event is DnsFetched) {
      yield* _mapDnsFetchedToState(event);
    } else if (event is DnsCreated) {
      yield* _mapDnsCreatedToState(event);
    } else if (event is DnsEdited) {
      yield* _mapDnsEditedToState(event);
    } else if (event is DnsDuplicated) {
      yield* _mapDnsDuplicatedToState(event);
    } else if (event is DnsDeleted) {
      yield* _mapDnsDeletedToState(event);
    } else if (event is DnsCleared) {
      yield* _mapDnsClearedToState(event);
    } else if (event is DnsMoved) {
      yield* _mapDnsMovedToState(event);
    } else if (event is DnsCopied) {
      yield* _mapDnsCopiedToState(event);
    }
  }

  Stream<DnsState> _mapSearchTextChangedToState(
    SearchTextChanged event,
  ) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();
    final data = await _dnsRepository.search(workspace, event.text);
    yield state.copyWith(data: data, searchText: event.text);
  }

  Stream<DnsState> _mapSearchToggledToState(SearchToggled event) async* {
    yield state.copyWith(search: !state.search);
  }

  Stream<DnsState> _mapDnsFetchedToState(DnsFetched event) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();
    final data = await _dnsRepository.search(workspace, state.searchText);
    yield state.copyWith(data: data);
  }

  Stream<DnsState> _mapDnsCreatedToState(DnsCreated event) async* {
    await _dnsRepository.insert(event.dns);
    add(DnsFetched());
  }

  Stream<DnsState> _mapDnsEditedToState(DnsEdited event) async* {
    await _dnsRepository.update(event.dns);
    add(DnsFetched());
  }

  Stream<DnsState> _mapDnsDuplicatedToState(
    DnsDuplicated event,
  ) async* {
    final dns = event.dns.copyWith(uid: generateUuid());
    await _dnsRepository.insert(dns);
    add(DnsFetched());
  }

  Stream<DnsState> _mapDnsDeletedToState(DnsDeleted event) async* {
    await _dnsRepository.delete(event.dns);
    add(DnsFetched());
  }

  Stream<DnsState> _mapDnsClearedToState(DnsCleared event) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();
    await _dnsRepository.clear(workspace);
    add(DnsFetched());
  }

  Stream<DnsState> _mapDnsMovedToState(DnsMoved event) async* {
    if (event.dns.workspace != event.workspace) {
      // Antes devemos removê-lo, para não deixar referenciado por uma chamada.
      await _dnsRepository.delete(event.dns);
      // Copia o dns para outro workspace.
      add(DnsCopied(event.dns, event.workspace));
    }
  }

  Stream<DnsState> _mapDnsCopiedToState(DnsCopied event) async* {
    // Copia o dns para um workspace.
    final dns = event.dns.copyWith(
      uid: generateUuid(),
      workspace: event.workspace,
    );

    await _dnsRepository.insert(dns);

    add(DnsFetched());
  }
}
