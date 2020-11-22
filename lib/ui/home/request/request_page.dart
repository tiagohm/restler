import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/request/bloc.dart';
import 'package:restler/data/entities/request_auth_entity.dart';
import 'package:restler/data/entities/request_body_entity.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/home/request/auth/request_auth_basic_page.dart';
import 'package:restler/ui/home/request/auth/request_auth_bearer_page.dart';
import 'package:restler/ui/home/request/auth/request_auth_digest_page.dart';
import 'package:restler/ui/home/request/auth/request_auth_hawk_page.dart';
import 'package:restler/ui/home/request/body/request_body_file_page.dart';
import 'package:restler/ui/home/request/body/request_body_form_page.dart';
import 'package:restler/ui/home/request/body/request_body_multipart_page.dart';
import 'package:restler/ui/home/request/body/request_body_text_page.dart';
import 'package:restler/ui/home/request/data/request_data_page.dart';
import 'package:restler/ui/home/request/header/request_header_page.dart';
import 'package:restler/ui/home/request/notification/request_notification_page.dart';
import 'package:restler/ui/home/request/query/request_query_page.dart';
import 'package:restler/ui/home/request/target/request_target_page.dart';
import 'package:restler/ui/widgets/checkable_tab.dart';
import 'package:restler/ui/widgets/empty.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class RequestPage extends StatefulWidget {
  final RequestBloc bloc;
  final bool isRest;

  const RequestPage({
    Key key,
    @required this.bloc,
    this.isRest = true,
  }) : super(key: key);

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage>
    with AutomaticKeepAliveClientMixin, StateMixin<RequestPage> {
  @override
  void initState() {
    super.initState();
  }

  RequestEntity get request => widget.bloc.state.request;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return DefaultTabController(
      length: widget.isRest ? 4 : 3,
      child: Column(
        children: [
          // Abas.
          TabBar(
            isScrollable: true,
            key: Key('${request.uid}-${request.type}'),
            tabs: [
              // FCM.
              // Target.
              if (!widget.isRest)
                BlocBuilder<RequestBloc, RequestState>(
                  cubit: widget.bloc,
                  buildWhen: (a, b) {
                    return a.request.target.enabled !=
                            b.request.target.enabled ||
                        a.request.target.targets != b.request.target.targets;
                  },
                  builder: (context, state) {
                    return CheckableTab(
                      title: Text(i18n.targets.toUpperCase()),
                      isCheckable: false,
                      badgeCount: state.request.target.targets.length,
                    );
                  },
                ),
              // Data.
              if (!widget.isRest)
                BlocBuilder<RequestBloc, RequestState>(
                  cubit: widget.bloc,
                  buildWhen: (a, b) {
                    return a.request.data.enabled != b.request.data.enabled ||
                        a.request.data.data != b.request.data.data;
                  },
                  builder: (context, state) {
                    return CheckableTab(
                      title: const Text('DATA'),
                      checked: state.request.data.enabled,
                      onChecked: (enabled) {
                        _dispatch(DataEnabled(enabled: enabled));
                      },
                      badgeCount: state.request.data.data.length,
                    );
                  },
                ),
              // Notification.
              if (!widget.isRest)
                BlocBuilder<RequestBloc, RequestState>(
                  cubit: widget.bloc,
                  buildWhen: (a, b) {
                    return a.request.notification.enabled !=
                            b.request.notification.enabled ||
                        a.request.notification.notifications !=
                            b.request.notification.notifications;
                  },
                  builder: (context, state) {
                    return CheckableTab(
                      title: const Text('NOTIFICATION'),
                      checked: state.request.notification.enabled,
                      onChecked: (enabled) {
                        _dispatch(NotificationEnabled(enabled: enabled));
                      },
                      badgeCount:
                          state.request.notification.notifications.length,
                    );
                  },
                ),

              // REST.
              // Body.
              if (widget.isRest)
                BlocBuilder<RequestBloc, RequestState>(
                  cubit: widget.bloc,
                  buildWhen: (a, b) {
                    return a.request.body != b.request.body;
                  },
                  builder: (context, state) {
                    return CheckableTab(
                      title: Text(
                        _obtainRequestBodyTypeName(state.request.body.type)
                            .toUpperCase(),
                      ),
                      checked: state.request.body.enabled,
                      items: RequestBodyType.values,
                      itemBuilder: (context, index, item) {
                        return Text(_obtainRequestBodyTypeName(item));
                      },
                      onChecked: (enabled) {
                        _dispatch(BodyEnabled(enabled: enabled));
                      },
                      onItemSelected: (type) {
                        _dispatch(BodyTypeChanged(type));
                      },
                      badgeCount: _obtainBodyBadgeCount(state.request.body),
                    );
                  },
                ),
              // Query.
              if (widget.isRest)
                BlocBuilder<RequestBloc, RequestState>(
                  cubit: widget.bloc,
                  buildWhen: (a, b) {
                    return a.request.query.enabled != b.request.query.enabled ||
                        a.request.query.queries != b.request.query.queries;
                  },
                  builder: (context, state) {
                    return CheckableTab(
                      title: Text(i18n.query.toUpperCase()),
                      checked: state.request.query.enabled,
                      onChecked: (enabled) {
                        _dispatch(QueryEnabled(enabled: enabled));
                      },
                      badgeCount: state.request.query.queries.length,
                    );
                  },
                ),
              // Header.
              if (widget.isRest)
                BlocBuilder<RequestBloc, RequestState>(
                  cubit: widget.bloc,
                  buildWhen: (a, b) {
                    return a.request.header.enabled !=
                            b.request.header.enabled ||
                        a.request.header.headers != b.request.header.headers;
                  },
                  builder: (context, state) {
                    return CheckableTab(
                      title: Text(i18n.header.toUpperCase()),
                      checked: state.request.header.enabled,
                      onChecked: (enabled) {
                        _dispatch(HeaderEnabled(enabled: enabled));
                      },
                      badgeCount: state.request.header.headers.length,
                    );
                  },
                ),
              // Auth.
              if (widget.isRest)
                BlocBuilder<RequestBloc, RequestState>(
                  cubit: widget.bloc,
                  buildWhen: (a, b) {
                    return a.request.auth.type != b.request.auth.type ||
                        a.request.auth.enabled != b.request.auth.enabled;
                  },
                  builder: (context, state) {
                    return CheckableTab(
                      title: Text(
                        _obtainRequestAuthTypeName(state.request.auth.type)
                            .toUpperCase(),
                      ),
                      checked: state.request.auth.enabled,
                      items: RequestAuthType.values,
                      itemBuilder: (context, index, item) {
                        return Text(_obtainRequestAuthTypeName(item));
                      },
                      onChecked: (checked) {
                        _dispatch(AuthEdited(enabled: checked));
                      },
                      onItemSelected: (type) {
                        _dispatch(AuthEdited(type: type));
                      },
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
                  // FCM.
                  // Target.
                  if (!widget.isRest)
                    BlocBuilder<RequestBloc, RequestState>(
                      cubit: widget.bloc,
                      buildWhen: (a, b) {
                        return a.request.target.targets !=
                            b.request.target.targets;
                      },
                      builder: (context, state) {
                        return RequestTargetPage(
                          items: state.request.target.targets,
                          onAdded: () {
                            _dispatch(TargetAdded());
                          },
                          onItemDeleted: (item) {
                            _dispatch(TargetDeleted(item));
                          },
                          onItemDuplicated: (item) {
                            _dispatch(TargetDuplicated(item));
                          },
                          onItemChanged: (item) {
                            _dispatch(TargetEdited(item));
                          },
                        );
                      },
                    ),
                  // Data.
                  if (!widget.isRest)
                    BlocBuilder<RequestBloc, RequestState>(
                      cubit: widget.bloc,
                      buildWhen: (a, b) {
                        return a.request.data.data != b.request.data.data;
                      },
                      builder: (context, state) {
                        return RequestDataPage(
                          items: state.request.data.data,
                          onAdded: () {
                            _dispatch(DataAdded());
                          },
                          onItemDeleted: (item) {
                            _dispatch(DataDeleted(item));
                          },
                          onItemDuplicated: (item) {
                            _dispatch(DataDuplicated(item));
                          },
                          onItemChanged: (item) {
                            _dispatch(DataEdited(item));
                          },
                        );
                      },
                    ),
                  // Notification.
                  if (!widget.isRest)
                    BlocBuilder<RequestBloc, RequestState>(
                      cubit: widget.bloc,
                      buildWhen: (a, b) {
                        return a.request.notification.notifications !=
                            b.request.notification.notifications;
                      },
                      builder: (context, state) {
                        return RequestNotificationPage(
                          items: state.request.notification.notifications,
                          onAdded: () {
                            _dispatch(NotificationAdded());
                          },
                          onItemDeleted: (item) {
                            _dispatch(NotificationDeleted(item));
                          },
                          onItemDuplicated: (item) {
                            _dispatch(NotificationDuplicated(item));
                          },
                          onItemChanged: (item) {
                            _dispatch(NotificationEdited(item));
                          },
                        );
                      },
                    ),

                  // REST.
                  // Body.
                  if (widget.isRest)
                    BlocBuilder<RequestBloc, RequestState>(
                      cubit: widget.bloc,
                      buildWhen: (a, b) {
                        return a.request.body != b.request.body;
                      },
                      builder: (context, state) {
                        // None.
                        if (state.request.body.type == RequestBodyType.none) {
                          return Center(
                            child: SingleChildScrollView(
                              child: Empty(
                                icon: Mdi.viewList,
                                text: i18n.noBodyTypeSelected,
                              ),
                            ),
                          );
                        }
                        // Form.
                        else if (state.request.body.type ==
                            RequestBodyType.form) {
                          return BlocBuilder<RequestBloc, RequestState>(
                            cubit: widget.bloc,
                            buildWhen: (a, b) {
                              return a.request.body.formItems !=
                                  b.request.body.formItems;
                            },
                            builder: (context, state) {
                              return RequestBodyFormPage(
                                items: state.request.body.formItems,
                                onAdded: () {
                                  _dispatch(FormAdded());
                                },
                                onItemDeleted: (item) {
                                  _dispatch(FormDeleted(item));
                                },
                                onItemDuplicated: (item) {
                                  _dispatch(FormDuplicated(item));
                                },
                                onItemChanged: (item) {
                                  _dispatch(FormEdited(item));
                                },
                              );
                            },
                          );
                        }
                        // Multipart.
                        else if (state.request.body.type ==
                            RequestBodyType.multipart) {
                          return BlocBuilder<RequestBloc, RequestState>(
                            cubit: widget.bloc,
                            buildWhen: (a, b) {
                              return a.request.body.multipartItems !=
                                  b.request.body.multipartItems;
                            },
                            builder: (context, state) {
                              return RequestBodyMultipartPage(
                                items: state.request.body.multipartItems,
                                onAdded: () {
                                  _dispatch(MultipartAdded());
                                },
                                onItemDeleted: (item) {
                                  _dispatch(MultipartDeleted(item));
                                },
                                onItemDuplicated: (item) {
                                  _dispatch(MultipartDuplicated(item));
                                },
                                onItemChanged: (item) {
                                  _dispatch(MultipartEdited(item));
                                },
                              );
                            },
                          );
                        }
                        // File.
                        else if (state.request.body.type ==
                            RequestBodyType.file) {
                          return BlocBuilder<RequestBloc, RequestState>(
                            cubit: widget.bloc,
                            buildWhen: (a, b) {
                              return a.request.body.file != b.request.body.file;
                            },
                            builder: (context, state) {
                              return RequestBodyFilePage(
                                path: state.request.body.file,
                                onFileChoosed: (path) {
                                  if (path == null) {
                                    _dispatch(FileRemoved());
                                  } else {
                                    _dispatch(FileChoosed(path));
                                  }
                                },
                              );
                            },
                          );
                        }
                        // Text.
                        else {
                          return BlocBuilder<RequestBloc, RequestState>(
                            cubit: widget.bloc,
                            buildWhen: (a, b) {
                              return a.request.body.text !=
                                      b.request.body.text ||
                                  a.request.header.contentType !=
                                      b.request.header.contentType;
                            },
                            builder: (context, state) {
                              return RequestBodyTextPage(
                                key: Key(state.request.uid),
                                text: state.request.body.text,
                                contentType: state.request.header.contentType,
                                onTextChanged: (text) {
                                  _dispatch(TextEdited(text));
                                },
                                onTypeChanged: (text) {
                                  _dispatch(TextContentTypeChanged(text));
                                },
                              );
                            },
                          );
                        }
                      },
                    ),
                  // Query.
                  if (widget.isRest)
                    BlocBuilder<RequestBloc, RequestState>(
                      cubit: widget.bloc,
                      buildWhen: (a, b) {
                        return a.request.query.queries !=
                            b.request.query.queries;
                      },
                      builder: (context, state) {
                        return RequestQueryPage(
                          items: state.request.query.queries,
                          onAdded: () {
                            _dispatch(QueryAdded());
                          },
                          onItemDeleted: (item) {
                            _dispatch(QueryDeleted(item));
                          },
                          onItemDuplicated: (item) {
                            _dispatch(QueryDuplicated(item));
                          },
                          onItemChanged: (item) {
                            _dispatch(QueryEdited(item));
                          },
                        );
                      },
                    ),
                  // Header.
                  if (widget.isRest)
                    BlocBuilder<RequestBloc, RequestState>(
                      cubit: widget.bloc,
                      buildWhen: (a, b) {
                        return a.request.header.headers !=
                            b.request.header.headers;
                      },
                      builder: (context, state) {
                        return RequestHeaderPage(
                          items: state.request.header.headers,
                          onAdded: () {
                            _dispatch(HeaderAdded());
                          },
                          onItemDeleted: (item) {
                            _dispatch(HeaderDeleted(item));
                          },
                          onItemDuplicated: (item) {
                            _dispatch(HeaderDuplicated(item));
                          },
                          onItemChanged: (item) {
                            _dispatch(HeaderEdited(item));
                          },
                        );
                      },
                    ),
                  // Auth.
                  if (widget.isRest)
                    BlocBuilder<RequestBloc, RequestState>(
                      cubit: widget.bloc,
                      buildWhen: (a, b) {
                        return a.request.auth.type != b.request.auth.type;
                      },
                      builder: (context, state) {
                        switch (state.request.auth.type) {
                          case RequestAuthType.basic:
                            return BlocBuilder<RequestBloc, RequestState>(
                              cubit: widget.bloc,
                              buildWhen: (a, b) {
                                return a.request.auth != b.request.auth;
                              },
                              builder: (context, state) {
                                return RequestAuthBasicPage(
                                  username: state.request.auth.basicUsername,
                                  password: state.request.auth.basicPassword,
                                  onUsernameChanged: (text) {
                                    _dispatch(AuthEdited(basicUsername: text));
                                  },
                                  onPasswordChanged: (text) {
                                    _dispatch(AuthEdited(basicPassword: text));
                                  },
                                );
                              },
                            );
                          case RequestAuthType.bearer:
                            return BlocBuilder<RequestBloc, RequestState>(
                              cubit: widget.bloc,
                              buildWhen: (a, b) {
                                return a.request.auth != b.request.auth;
                              },
                              builder: (context, state) {
                                return RequestAuthBearerPage(
                                  token: state.request.auth.bearerToken,
                                  prefix: state.request.auth.bearerPrefix,
                                  onTokenChanged: (text) {
                                    _dispatch(AuthEdited(bearerToken: text));
                                  },
                                  onPrefixChanged: (text) {
                                    _dispatch(AuthEdited(bearerPrefix: text));
                                  },
                                );
                              },
                            );
                          case RequestAuthType.digest:
                            return BlocBuilder<RequestBloc, RequestState>(
                              cubit: widget.bloc,
                              buildWhen: (a, b) {
                                return a.request.auth != b.request.auth;
                              },
                              builder: (context, state) {
                                return RequestAuthDigestPage(
                                  username: state.request.auth.digestUsername,
                                  password: state.request.auth.digestPassword,
                                  onUsernameChanged: (text) {
                                    _dispatch(AuthEdited(digestUsername: text));
                                  },
                                  onPasswordChanged: (text) {
                                    _dispatch(AuthEdited(digestPassword: text));
                                  },
                                );
                              },
                            );
                          case RequestAuthType.hawk:
                            return BlocBuilder<RequestBloc, RequestState>(
                              cubit: widget.bloc,
                              buildWhen: (a, b) {
                                return a.request.auth != b.request.auth;
                              },
                              builder: (context, state) {
                                return RequestAuthHawkPage(
                                  id: state.request.auth.hawkId,
                                  hkey: state.request.auth.hawkKey,
                                  algorithm: state.request.auth.hawkAlgorithm,
                                  ext: state.request.auth.hawkExt,
                                  onIdChanged: (text) {
                                    _dispatch(AuthEdited(hawkId: text));
                                  },
                                  onKeyChanged: (text) {
                                    _dispatch(AuthEdited(hawkKey: text));
                                  },
                                  onExtChanged: (text) {
                                    _dispatch(AuthEdited(hawkExt: text));
                                  },
                                  onAlgorithmChanged: (item) {
                                    _dispatch(AuthEdited(hawkAlgorithm: item));
                                  },
                                );
                              },
                            );
                          default:
                            return Center(
                              child: SingleChildScrollView(
                                child: Empty(
                                  icon: Icons.lock,
                                  text: i18n.noAuthTypeSelected,
                                ),
                              ),
                            );
                        }
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

  @override
  bool get wantKeepAlive => true;

  void _dispatch(RequestEvent event) {
    widget.bloc.add(event);
  }

  String _obtainRequestBodyTypeName(RequestBodyType type) {
    switch (type) {
      case RequestBodyType.multipart:
        return i18n.multipart;
      case RequestBodyType.form:
        return i18n.form;
      case RequestBodyType.text:
        return i18n.text;
      case RequestBodyType.file:
        return i18n.file;
      default:
        return i18n.none;
    }
  }

  String _obtainRequestAuthTypeName(RequestAuthType type) {
    switch (type) {
      case RequestAuthType.basic:
        return i18n.basic;
      case RequestAuthType.bearer:
        return i18n.bearer;
      case RequestAuthType.digest:
        return i18n.digest;
      case RequestAuthType.hawk:
        return i18n.hawk;
      default:
        return i18n.none;
    }
  }

  int _obtainBodyBadgeCount(RequestBodyEntity body) {
    switch (body.type) {
      case RequestBodyType.form:
        return body.formItems.length;
      case RequestBodyType.multipart:
        return body.multipartItems.length;
      default:
        return 0;
    }
  }
}
