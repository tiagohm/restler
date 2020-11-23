import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:restler/constants.dart';
import 'package:restler/extensions.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

const _libraries = [
  [
    'restio',
    'An HTTP client for Dart inspired by OkHttp',
    'https://github.com/tiagohm/restio',
  ],
  [
    'tradutor',
    'A Flutter package that simplify the internationalizing process',
    'https://github.com/tiagohm/tradutor',
  ],
  [
    'flutter_bloc',
    'Helps implement the BLoC pattern',
    'https://github.com/felangel/bloc',
  ],
  [
    'uuid',
    'Simple, fast generation of RFC4122 UUIDs',
    'https://github.com/Daegalus/dart-uuid',
  ],
  [
    'url_launcher',
    'A Flutter plugin for launching a URL',
    'https://github.com/flutter/plugins',
  ],
  [
    'sqflite',
    'SQLite plugin for Flutter',
    'https://github.com/tekartik/sqflite',
  ],
  [
    'archive',
    'Provides encoders and decoders for various compression formats',
    'https://github.com/brendan-duncan/archive',
  ],
  [
    'file_picker',
    'A package that allows you to use a native file explorer',
    'https://github.com/miguelpruivo/plugins_flutter_file_picker',
  ],
  [
    'flutter_typeahead',
    'A highly customizable autocomplete text input field',
    'https://github.com/AbdulRahmanAlHamali/flutter_typeahead',
  ],
  [
    'datetime_picker_formfield',
    'A TextFormField that emits DateTimes',
    'https://github.com/jifalops/datetime_picker_formfield',
  ],
  [
    'path_provider',
    'Flutter plugin for getting commonly used locations',
    'https://github.com/flutter/plugins/tree/master/packages/path_provider',
  ],
  [
    'permission_handler',
    'Permission plugin for Flutter',
    'https://github.com/baseflowit/flutter-permission-handler',
  ],
  [
    'flutter_svg',
    'An SVG rendering and widget library',
    'https://github.com/dnfield/flutter_svg',
  ],
  [
    'flutter_inapp_purchase',
    'In App Purchase plugin',
    'https://github.com/dooboolab/flutter_inapp_purchase',
  ],
  [
    'hive',
    'Lightweight and blazing fast key-value database',
    'https://github.com/hivedb/hive',
  ],
  [
    'equatable',
    'Helps to implement equality',
    'https://github.com/felangel/equatable',
  ],
  [
    'badges',
    'A flutter package for creating badges',
    'https://github.com/yadaniyil/flutter_badges',
  ],
  [
    'kiwi',
    'A simple yet efficient IoC container',
    'https://github.com/letsar/kiwi',
  ],
  [
    'syntax_highlighter',
    'Syntax highlighter for show your code in the app',
    'https://github.com/viztushar/syntax_highlighter',
  ],
  [
    'flushbar',
    'A flexible widget for user notification',
    'https://github.com/AndreHaueisen/flushbar',
  ],
  [
    'yaml',
    'A parser for YAML',
    'https://github.com/dart-lang/yaml',
  ],
  [
    'encrypt',
    'A set of high-level APIs for two-way cryptography',
    'https://github.com/leocavalcante/encrypt',
  ],
  [
    'connectivity',
    'Flutter plugin for discovering the state of the network',
    'https://github.com/flutter/plugins/tree/master/packages/connectivity',
  ],
  [
    'event_bus',
    'A simple Event Bus using Dart Streams for decoupling applications',
    'https://github.com/marcojakob/dart-event-bus',
  ],
  [
    'flutter_markdown',
    'A markdown renderer for Flutter',
    'https://github.com/flutter/flutter_markdown',
  ],
  [
    'fakedart',
    'This library is a port of faker.js that generates fake data',
    'https://github.com/tiagohm/fakedart',
  ],
  [
    'sqler',
    'A SQL query builder for Dart',
    'https://github.com/tiagohm/sqler',
  ],
];

class AboutTheAppDialog extends StatefulWidget {
  const AboutTheAppDialog({
    Key key,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AboutTheAppDialog(),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _AboutTheAppDialogState();
  }
}

class _AboutTheAppDialogState extends State<AboutTheAppDialog>
    with StateMixin<AboutTheAppDialog> {
  @override
  Widget build(BuildContext context) {
    return DataDialog<void>(
      showDone: false,
      cancelText: i18n.ok,
      onDone: () => null,
      title: i18n.about,
      bodyBuilder: (context) {
        return Container(
          width: 0,
          height: 360,
          child: SingleChildScrollView(
            child: DefaultTabController(
              length: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Logo.
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 84,
                    height: 84,
                  ),
                  // App name.
                  Text(
                    i18n.appName,
                    style: defaultInputTextStyle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // App version.
                  Text(
                    appVersion,
                    style: defaultInputTextStyle.copyWith(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  // App copyright.
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '© 2019-2020 Tiago Melo 🇧🇷',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Tabs.
                  TabBar(
                    isScrollable: true,
                    tabs: <Widget>[
                      Tab(text: i18n.contact.toUpperCase()),
                      Tab(text: i18n.licenses.toUpperCase()),
                      Tab(text: i18n.changelog.toUpperCase()),
                      Tab(text: i18n.translators.toUpperCase()),
                    ],
                  ),
                  // Body.
                  Container(
                    height: 2215,
                    child: TabBarView(
                      children: <Widget>[
                        // Contact.
                        Material(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                          color: Theme.of(context).dialogBackgroundColor,
                          child: Column(
                            children: <Widget>[
                              // Email.
                              ListTile(
                                title: Text(i18n.email),
                                subtitle: const Text(authorEmail),
                                onTap: () {
                                  'mailto:$authorEmail'.launchUri();
                                },
                              ),
                              // Website.
                              ListTile(
                                title: const Text('GitHub'),
                                subtitle: const Text(gitHubUrl),
                                onTap: () {
                                  gitHubUrl.launchUri();
                                },
                              ),
                              // Website.
                              ListTile(
                                title: Text(i18n.website),
                                subtitle: const Text(appWebsite),
                                onTap: () {
                                  appWebsite.launchUri();
                                },
                              ),
                              // Rate this app!
                              ListTile(
                                title: Text(i18n.rateThisApp),
                                subtitle: Text(i18n.rateThisAppMessage),
                                onTap: () {
                                  playStoreUrl.launchUri();
                                },
                              ),
                              // Submit a bug.
                              ListTile(
                                title: Text(i18n.submitBug),
                                onTap: () {
                                  issueUrl.launchUri();
                                },
                              ),
                              // How to translate this app.
                              ListTile(
                                title: Text(i18n.howToTranslateThisApp),
                                onTap: () {
                                  translationsUrl.launchUri();
                                },
                              ),
                              // Privacy policy.
                              ListTile(
                                title: Text(i18n.privacyPolicy),
                                onTap: () {
                                  privacyPolicyUrl.launchUri();
                                },
                              ),
                            ],
                          ),
                        ),
                        // Licenses.
                        Material(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                          color: Theme.of(context).dialogBackgroundColor,
                          child: Column(
                            children: <Widget>[
                              for (final item in _libraries)
                                _License(
                                  title: item[0],
                                  subtitle: item[1],
                                  url: item[2],
                                ),
                            ],
                          ),
                        ),
                        // Changelog.
                        Material(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                          color: Theme.of(context).dialogBackgroundColor,
                          child: _Changelog(),
                        ),
                        // Translators.
                        Material(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                          color: Theme.of(context).dialogBackgroundColor,
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: _Translator(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _License extends StatelessWidget {
  final String title;
  final String subtitle;
  final String url;

  const _License({
    Key key,
    @required this.title,
    @required this.subtitle,
    @required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: url.launchUri,
    );
  }
}

class _Changelog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final version in changelog.keys)
            _ChangelogItem(
              version: version,
              items: changelog[version],
            ),
        ],
      ),
    );
  }
}

class _ChangelogItem extends StatelessWidget {
  final String version;
  final List<String> items;

  const _ChangelogItem({
    Key key,
    this.version,
    this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            version,
            style: defaultInputTextStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          for (final item in items)
            Text(
              '- $item',
              style: defaultInputTextStyle.copyWith(fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _Translator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final language in translators.keys)
            _TranslatorItem(
              language: language,
              items: translators[language],
            ),
        ],
      ),
    );
  }
}

class _TranslatorItem extends StatelessWidget {
  final String language;
  final List<String> items;

  const _TranslatorItem({
    Key key,
    this.language,
    this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            language,
            style: defaultInputTextStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          for (final item in items)
            Text(
              '- $item',
              style: defaultInputTextStyle.copyWith(fontSize: 12),
            ),
        ],
      ),
    );
  }
}
