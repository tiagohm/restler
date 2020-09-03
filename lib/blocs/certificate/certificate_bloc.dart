import 'package:bloc/bloc.dart';
import 'package:restler/blocs/certificate/certificate_event.dart';
import 'package:restler/blocs/certificate/certificate_state.dart';
import 'package:restler/blocs/constants.dart';
import 'package:restler/data/repositories/certificate_repository.dart';
import 'package:restler/data/repositories/workspace_repository.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:rxdart/rxdart.dart';

class CertificateBloc extends Bloc<CertificateEvent, CertificateState> {
  final _certificateRepository = kiwi<CertificateRepository>();
  final _workspaceRepository = kiwi<WorkspaceRepository>();

  CertificateBloc() : super(const CertificateState());

  @override
  Stream<Transition<CertificateEvent, CertificateState>> transformTransitions(
    Stream<Transition<CertificateEvent, CertificateState>> transitions,
  ) {
    final debounceStream = transitions
        .where((event) => event.event is SearchTextChanged)
        .debounceTime(const Duration(milliseconds: searchTextDebounceTime));
    final nonDebounceStream =
        transitions.where((event) => event.event is! SearchTextChanged);

    return Rx.merge([debounceStream, nonDebounceStream]);
  }

  @override
  Stream<CertificateState> mapEventToState(CertificateEvent event) async* {
    if (event is SearchTextChanged) {
      yield* _mapSearchTextChangedToState(event);
    } else if (event is SearchToggled) {
      yield* _mapSearchToggledToState(event);
    } else if (event is CertificateFetched) {
      yield* _mapCertificateFetchedToState(event);
    } else if (event is CertificateCreated) {
      yield* _mapCertificateCreatedToState(event);
    } else if (event is CertificateEdited) {
      yield* _mapCertificateEditedToState(event);
    } else if (event is CertificateDuplicated) {
      yield* _mapCertificateDuplicatedToState(event);
    } else if (event is CertificateDeleted) {
      yield* _mapCertificateDeletedToState(event);
    } else if (event is CertificateCleared) {
      yield* _mapCertificateClearedToState(event);
    } else if (event is CertificateMoved) {
      yield* _mapCertificateMovedToState(event);
    } else if (event is CertificateCopied) {
      yield* _mapCertificateCopiedToState(event);
    }
  }

  Stream<CertificateState> _mapSearchTextChangedToState(
    SearchTextChanged event,
  ) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();
    final data = await _certificateRepository.search(workspace, event.text);
    yield state.copyWith(data: data, searchText: event.text);
  }

  Stream<CertificateState> _mapSearchToggledToState(
    SearchToggled event,
  ) async* {
    yield state.copyWith(search: !state.search);
  }

  Stream<CertificateState> _mapCertificateFetchedToState(
    CertificateFetched event,
  ) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();
    final data =
        await _certificateRepository.search(workspace, state.searchText);
    yield state.copyWith(data: data);
  }

  Stream<CertificateState> _mapCertificateCreatedToState(
    CertificateCreated event,
  ) async* {
    await _certificateRepository.insert(event.certificate);
    add(CertificateFetched());
  }

  Stream<CertificateState> _mapCertificateEditedToState(
    CertificateEdited event,
  ) async* {
    await _certificateRepository.update(event.certificate);
    add(CertificateFetched());
  }

  Stream<CertificateState> _mapCertificateDuplicatedToState(
    CertificateDuplicated event,
  ) async* {
    final certificate = event.certificate.copyWith(uid: generateUuid());
    await _certificateRepository.insert(certificate);
    add(CertificateFetched());
  }

  Stream<CertificateState> _mapCertificateDeletedToState(
    CertificateDeleted event,
  ) async* {
    await _certificateRepository.delete(event.certificate);
    add(CertificateFetched());
  }

  Stream<CertificateState> _mapCertificateClearedToState(
    CertificateCleared event,
  ) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();
    await _certificateRepository.clear(workspace);
    add(CertificateFetched());
  }

  Stream<CertificateState> _mapCertificateMovedToState(
    CertificateMoved event,
  ) async* {
    if (event.certificate.workspace != event.workspace) {
      // Move o certificado para outro workspace.
      final certificate =
          event.certificate.copyWith(workspace: event.workspace);
      await _certificateRepository.update(certificate);
      add(CertificateFetched());
    }
  }

  Stream<CertificateState> _mapCertificateCopiedToState(
    CertificateCopied event,
  ) async* {
    // Copia o certificado para um workspace.
    final certificate = event.certificate.copyWith(
      uid: generateUuid(),
      workspace: event.workspace,
    );

    await _certificateRepository.insert(certificate);
    add(CertificateFetched());
  }
}
