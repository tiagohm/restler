import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restler/blocs/response/bloc.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:restler/mdi.dart';
import 'package:restler/settings.dart';
import 'package:restler/ui/home/response/response_body_page.dart';
import 'package:restler/ui/home/response/response_cookie_page.dart';
import 'package:restler/ui/home/response/response_header_page.dart';
import 'package:restler/ui/home/response/response_redirect_page.dart';
import 'package:restler/ui/widgets/checkable_tab.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/input_text_dialog.dart';
import 'package:restler/ui/widgets/label.dart';

enum BodyAction { copy, pretty, raw, visual, saveAsFile }

class ResponsePage extends StatefulWidget {
  final ResponseBloc bloc;
  final bool isRest;

  const ResponsePage({
    Key key,
    @required this.bloc,
    this.isRest = true,
  }) : super(key: key);

  @override
  _ResponsePageState createState() => _ResponsePageState();
}

class _ResponsePageState extends State<ResponsePage>
    with AutomaticKeepAliveClientMixin, StateMixin<ResponsePage> {
  final Settings _settings = kiwi();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // Abas.
          TabBar(
            isScrollable: true,
            tabs: [
              // Body.
              BlocBuilder<ResponseBloc, ResponseState>(
                cubit: widget.bloc,
                builder: (context, state) {
                  return CheckableTab(
                    isCheckable: false,
                    title: Row(
                      children: <Widget>[
                        Text(i18n.body.toUpperCase()),
                        Container(width: 4),
                        Visibility(
                          visible: state.response.cache,
                          child: Label(
                            text: i18n.cache.toUpperCase(),
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    items: _obtainBodyActions(state),
                    itemBuilder: (context, index, item) {
                      return ListTile(
                        leading: Icon(_obtainBodyActionIcon(item)),
                        title: Text(_obtainBodyActionName(item)),
                      );
                    },
                    onItemSelected: _onBodyActionSelected,
                  );
                },
              ),
              // Header.
              BlocBuilder<ResponseBloc, ResponseState>(
                cubit: widget.bloc,
                buildWhen: (a, b) =>
                    a.response.headers.length != b.response.headers.length,
                builder: (context, state) {
                  return CheckableTab(
                    isCheckable: false,
                    title: Text(i18n.header.toUpperCase()),
                    badgeCount: state.response.headers.length,
                  );
                },
              ),
              // Cookie.
              BlocBuilder<ResponseBloc, ResponseState>(
                cubit: widget.bloc,
                buildWhen: (a, b) =>
                    a.response.cookies.length != b.response.cookies.length,
                builder: (context, state) {
                  return CheckableTab(
                    isCheckable: false,
                    title: Text(i18n.cookie.toUpperCase()),
                    badgeCount: state.response.cookies.length,
                  );
                },
              ),
              // Redirect.
              BlocBuilder<ResponseBloc, ResponseState>(
                cubit: widget.bloc,
                buildWhen: (a, b) =>
                    a.response.redirects.length != b.response.redirects.length,
                builder: (context, state) {
                  return CheckableTab(
                    isCheckable: false,
                    title: Text(i18n.timeline.toUpperCase()),
                    badgeCount: state.response.redirects.length,
                  );
                },
              ),
            ],
          ),
          // Content.
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: TabBarView(
                children: [
                  // Body.
                  BlocBuilder<ResponseBloc, ResponseState>(
                    cubit: widget.bloc,
                    builder: (context, state) {
                      return ResponseBodyPage(
                        key: Key(state.response.uid),
                        fontSize: _settings.responseBodyFontSize,
                        state: state,
                      );
                    },
                  ),
                  // Header.
                  BlocBuilder<ResponseBloc, ResponseState>(
                    cubit: widget.bloc,
                    buildWhen: (a, b) =>
                        a.response.headers != b.response.headers,
                    builder: (context, state) {
                      return ResponseHeaderPage(items: state.response.headers);
                    },
                  ),
                  // Cookie.
                  BlocBuilder<ResponseBloc, ResponseState>(
                    cubit: widget.bloc,
                    buildWhen: (a, b) =>
                        a.response.cookies != b.response.cookies,
                    builder: (context, state) {
                      return ResponseCookiePage(items: state.response.cookies);
                    },
                  ),
                  // Redirect.
                  BlocBuilder<ResponseBloc, ResponseState>(
                    cubit: widget.bloc,
                    buildWhen: (a, b) =>
                        a.response.redirects != b.response.redirects,
                    builder: (context, state) {
                      return ResponseRedirectPage(
                        items: state.response.redirects,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _obtainBodyActionIcon(BodyAction action) {
    switch (action) {
      case BodyAction.copy:
        return Icons.content_copy;
      case BodyAction.raw:
        return Mdi.text;
      case BodyAction.pretty:
        return Mdi.magic;
      case BodyAction.visual:
        return Mdi.eye;
      case BodyAction.saveAsFile:
        return Mdi.save;
      default:
        return null;
    }
  }

  String _obtainBodyActionName(BodyAction action) {
    switch (action) {
      case BodyAction.copy:
        return i18n.copy;
      case BodyAction.raw:
        return i18n.raw;
      case BodyAction.pretty:
        return i18n.pretty;
      case BodyAction.visual:
        return i18n.preview;
      case BodyAction.saveAsFile:
        return i18n.saveAsFile;
      default:
        return null;
    }
  }

  List<BodyAction> _obtainBodyActions(ResponseState state) {
    return [
      // Copy.
      if (state.response.data.isNotEmpty) BodyAction.copy,
      // Pretty (formatado e colorizado).
      if (!state.invalid && state.response.isHighlighted) BodyAction.pretty,
      // Source-Code.
      BodyAction.raw,
      // Visual.
      if (!state.invalid && state.response.isVisual) BodyAction.visual,
      // Save as file.
      if (state.response.data.isNotEmpty) BodyAction.saveAsFile
    ];
  }

  Future<void> _onBodyActionSelected(BodyAction action) async {
    switch (action) {
      case BodyAction.copy:
        widget.bloc.add(ResponseBodyCopied());
        break;
      case BodyAction.raw:
        widget.bloc.add(ResponseModeChanged(ResponseMode.raw));
        break;
      case BodyAction.pretty:
        widget.bloc.add(ResponseModeChanged(ResponseMode.pretty));
        break;
      case BodyAction.visual:
        widget.bloc.add(ResponseModeChanged(ResponseMode.visual));
        break;
      case BodyAction.saveAsFile:
        if (await handlePermission(Permission.storage)) {
          String suggestedFilename;

          for (final header in widget.bloc.state.response.headers) {
            if (header.name.toLowerCase() == 'content-disposition') {
              suggestedFilename =
                  obtainFilenameFromContentDisposition(header.value);
              break;
            }
          }

          // Exibe uma janela de diálogo para o usuário entrar com o nome do arquivo.
          final res = await InputTextDialog.show(
            context,
            suggestedFilename ?? '',
            i18n.filename,
            i18n.saveAs,
          );

          // O usuário escolheu um nome (não cancelou a janela).
          if (res != null && !res.cancelled) {
            final path = await FilePicker.platform.getDirectoryPath();

            if (path != null) {
              widget.bloc.add(ResponseBodySavedAsFile(res.data, path));
            }
          }
        }
        break;
    }
  }

  @override
  bool get wantKeepAlive => true;
}
