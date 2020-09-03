import 'package:flutter/material.dart';
import 'package:restler/ui/constants.dart';

class Code extends StatefulWidget {
  final TextSpan highlight;
  final double fontSize;
  final int numberOfLines;

  const Code({
    @required this.highlight,
    this.fontSize = 14,
    this.numberOfLines = 1000,
  });

  @override
  State<StatefulWidget> createState() {
    return _CodeState();
  }
}

class _CodeState extends State<Code> {
  final _controller = TrackingScrollController();
  var _end = 1000;

  @override
  void initState() {
    _controller.addListener(_fetchMoreLines);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_fetchMoreLines);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spans = widget.highlight.children;

    if (widget.highlight == null) {
      return Container();
    } else {
      return ListView(
        shrinkWrap: true,
        controller: _controller,
        children: [
          SelectableText.rich(
            TextSpan(
              style: defaultInputTextStyle.copyWith(fontSize: widget.fontSize),
              children: [
                for (var i = 0; i < _end && i < spans.length; i++) spans[i],
              ],
            ),
          ),
        ],
      );
    }
  }

  void _fetchMoreLines() {
    // End.
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 16) {
      if (widget.highlight.children.length > _end) {
        setState(() {
          _end += widget.numberOfLines;
        });
      }
    }
  }
}
