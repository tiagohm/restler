import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:restler/blocs/response/bloc.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/code.dart';
import 'package:restler/ui/widgets/empty.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:syntax_highlighter/syntax_highlighter.dart';

class ResponseBodyPage extends StatefulWidget {
  final double fontSize;
  final ResponseState state;

  const ResponseBodyPage({
    Key key,
    this.fontSize = 14,
    @required this.state,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ResponseBodyState();
  }
}

class _ResponseBodyState extends State<ResponseBodyPage>
    with StateMixin<ResponseBodyPage> {
  var _shouldUpdate = false;
  TextSpan _highlighted;
  bool _isDark;

  @override
  void didUpdateWidget(ResponseBodyPage a) {
    _shouldUpdate = widget.state.response.uid != a.state.response.uid;
    super.didUpdateWidget(a);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _buildBody(context, widget.state),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data;
        } else {
          return Empty(
            icon: Mdi.text,
            text: i18n.noBodyReturned,
          );
        }
      },
    );
  }

  Future<Widget> _buildBody(
    BuildContext context,
    ResponseState state,
  ) async {
    final response = state.response;
    final mode = state.mode;

    // Nothing to display.
    if (response.data == null || response.data.isEmpty) {
      return Empty(
        icon: Mdi.text,
        text: i18n.noBodyReturned,
      );
    }
    // SVG.
    if (mode == ResponseMode.visual && response.isVisual && response.isXml) {
      return SvgPicture.memory(Uint8List.fromList(response.data));
    }
    // Image.
    if (mode == ResponseMode.visual && response.isVisual) {
      final subType = response.contentType?.subType;
      // JPEG, PNG or WEBP.
      if (subType == 'jpeg' || subType == 'png' || subType == 'webp') {
        return Image.memory(Uint8List.fromList(response.data));
      }
      // Invalid format.
      return Empty(
        icon: Mdi.text,
        text: i18n.noBodyReturned,
      );
    }
    // JSON/XML.
    if (mode == ResponseMode.pretty && response.isHighlighted) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      if (_highlighted == null || _isDark != isDark || _shouldUpdate) {
        _shouldUpdate = false;
        _isDark = isDark;
        _highlighted = await compute(
          isDark ? highlightDark : highlightLight,
          state.prettyText,
        );
      }

      return Padding(
        padding: const EdgeInsets.all(8),
        child: Scrollbar(
          child: Code(
            highlight: _highlighted,
            fontSize: widget.fontSize,
          ),
        ),
      );
    }
    // HTML/TEXT.
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Scrollbar(
        child: SelectableText(
          state.text,
          style: defaultInputTextStyle.copyWith(fontSize: widget.fontSize),
        ),
      ),
    );
  }
}

TextSpan highlightDark(String text) {
  return DartSyntaxHighlighter(SyntaxHighlighterStyle.darkThemeStyle())
      .format(text);
}

TextSpan highlightLight(String text) {
  return DartSyntaxHighlighter(SyntaxHighlighterStyle.lightThemeStyle())
      .format(text);
}
