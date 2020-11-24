import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:restler/helper.dart';
import 'package:restler/i18n.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

// ignore_for_file: avoid_annotating_with_dynamic

class AutocompleteItem {
  final String label;
  final String value;

  const AutocompleteItem(this.label, this.value);

  Color get color => null;

  String get type => null;
}

class ValueAutocompleteItem extends AutocompleteItem {
  @override
  final String type;

  const ValueAutocompleteItem(String value, this.type) : super(value, value);
}

class VariableAutocompleteItem extends AutocompleteItem {
  const VariableAutocompleteItem(String value) : super(value, '{{$value}}');

  @override
  Color get color => Colors.green;

  @override
  String get type => 'VAR';
}

class PostmanAutocompleteItem extends AutocompleteItem {
  const PostmanAutocompleteItem(String value) : super(value, '{{\$$value}}');

  @override
  Color get color => Colors.blue;

  @override
  String get type => 'POSTMAN';
}

typedef AutocompleteItemSuggestionCallback
    = FutureOr<Iterable<AutocompleteItem>> Function(
        String pattern, int cursorPosition);

class PowerfulTextField<T> extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle style;
  final StrutStyle strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final TextDirection textDirection;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType smartDashesType;
  final SmartQuotesType smartQuotesType;
  final bool enableSuggestions;
  final int maxLines;
  final int minLines;
  final bool expands;
  final bool readOnly;
  final ToolbarOptions toolbarOptions;
  final bool showCursor;
  final int maxLength;
  final bool maxLengthEnforced;
  final ValueChanged<String> onChanged;
  final VoidCallback onEditingComplete;
  final ValueChanged<String> onSubmitted;
  final List<TextInputFormatter> inputFormatters;
  final bool enabled;
  final double cursorWidth;
  final Radius cursorRadius;
  final Color cursorColor;
  final BoxHeightStyle selectionHeightStyle;
  final BoxWidthStyle selectionWidthStyle;
  final Brightness keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool enableInteractiveSelection;
  final DragStartBehavior dragStartBehavior;

  final GestureTapCallback onTap;
  final InputCounterWidgetBuilder buildCounter;
  final ScrollPhysics scrollPhysics;
  final ScrollController scrollController;

  final Key inputKey;
  final void Function(bool) onFocusChanged;
  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final void Function(T item) onItemSelected;
  final bool showDefaultItems;
  final bool isPassword;
  final String hintText;

  // TypeAHead.
  final AutocompleteItemSuggestionCallback suggestionsCallback;
  final SuggestionsBoxDecoration suggestionsBoxDecoration;
  final Duration debounceDuration;
  final WidgetBuilder loadingBuilder;
  final WidgetBuilder noItemsFoundBuilder;
  final ErrorBuilder errorBuilder;
  final AnimationTransitionBuilder transitionBuilder;
  final Duration animationDuration;
  final double animationStart;
  final double suggestionsBoxVerticalOffset;
  final bool getImmediateSuggestions;

  final bool underlined;

  const PowerfulTextField({
    Key key,
    this.inputKey,
    this.controller,
    this.decoration = const InputDecoration(),
    TextInputType keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    ToolbarOptions toolbarOptions,
    this.showCursor,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = false,
    SmartDashesType smartDashesType,
    SmartQuotesType smartQuotesType,
    this.enableSuggestions = false,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforced = true,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.cursorColor,
    this.selectionHeightStyle = BoxHeightStyle.tight,
    this.selectionWidthStyle = BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection = true,
    this.onTap,
    this.buildCounter,
    this.scrollController,
    this.scrollPhysics,
    this.onFocusChanged,
    this.items,
    this.itemBuilder,
    this.onItemSelected,
    this.showDefaultItems = true,
    this.isPassword = false,
    this.hintText,
    // TypeAHead.
    this.suggestionsCallback,
    this.suggestionsBoxDecoration = const SuggestionsBoxDecoration(),
    this.debounceDuration = const Duration(milliseconds: 1000),
    this.loadingBuilder,
    this.noItemsFoundBuilder,
    this.errorBuilder,
    this.transitionBuilder,
    this.animationStart = 0.25,
    this.animationDuration = const Duration(milliseconds: 500),
    this.getImmediateSuggestions = true,
    this.suggestionsBoxVerticalOffset = 4.0,
    this.underlined = false,
  })  : smartDashesType = smartDashesType ??
            (obscureText ? SmartDashesType.disabled : SmartDashesType.enabled),
        smartQuotesType = smartQuotesType ??
            (obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled),
        keyboardType = keyboardType ??
            (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
        toolbarOptions = toolbarOptions ??
            (obscureText
                ? const ToolbarOptions(
                    selectAll: true,
                    paste: true,
                  )
                : const ToolbarOptions(
                    copy: true,
                    cut: true,
                    selectAll: true,
                    paste: true,
                  )),
        super(key: key);

  static const int noMaxLength = -1;

  bool get selectionEnabled => enableInteractiveSelection;

  @override
  PowerfulTextFieldState<T> createState() => PowerfulTextFieldState<T>();
}

class PowerfulTextFieldState<T> extends State<PowerfulTextField>
    with StateMixin<PowerfulTextField> {
  final _focusNode = FocusNode();
  final _showPassword = ValueNotifier<bool>(false);

  @override
  void initState() {
    _focusNode.addListener(_onFocus);

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus);
    _focusNode.dispose();

    super.dispose();
  }

  bool get hasFocus => _focusNode.hasFocus;

  void _onFocus() {
    widget.onFocusChanged?.call(hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: ValueListenableBuilder(
            valueListenable: _showPassword,
            builder: (context, show, child) {
              return TypeAheadField<AutocompleteItem>(
                key: widget.inputKey,
                textFieldConfiguration: TextFieldConfiguration<String>(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  decoration: widget.hintText != null
                      ? InputDecoration(
                          border: widget.underlined
                              ? InputBorder.none
                              : const OutlineInputBorder(),
                          enabledBorder: widget.underlined
                              ? null
                              : OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .indicatorColor
                                          .withOpacity(0.1)),
                                ),
                          filled: !widget.underlined,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.grey[100],
                          labelText: widget.hintText,
                          labelStyle: TextStyle(
                            color: Theme.of(context)
                                .indicatorColor
                                .withOpacity(0.4),
                          ),
                          contentPadding:
                              const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                        )
                      : widget.decoration,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  textCapitalization: widget.textCapitalization,
                  style: widget.style ??
                      const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.grey,
                      ),
                  // strutStyle: widget.strutStyle,
                  textAlign: widget.textAlign,
                  // textAlignVertical: widget.textAlignVertical,
                  textDirection: widget.textDirection,
                  // readOnly: widget.readOnly,
                  // toolbarOptions: widget.toolbarOptions,
                  // showCursor: widget.showCursor,
                  autofocus: widget.autofocus,
                  obscureText:
                      !show && (widget.obscureText || widget.isPassword),
                  autocorrect: widget.autocorrect,
                  // smartDashesType: widget.smartDashesType,
                  // smartQuotesType: widget.smartQuotesType,
                  // enableSuggestions: widget.enableSuggestions,
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  // expands: widget.expands,
                  maxLength: widget.maxLength,
                  maxLengthEnforced: widget.maxLengthEnforced,
                  onChanged: (dynamic text) => widget.onChanged?.call(text),
                  onEditingComplete: widget.onEditingComplete,
                  onSubmitted: (dynamic text) => widget.onSubmitted?.call(text),
                  inputFormatters: widget.inputFormatters,
                  enabled: widget.enabled,
                  cursorWidth: widget.cursorWidth,
                  cursorRadius: widget.cursorRadius,
                  cursorColor: widget.cursorColor,
                  // selectionHeightStyle: widget.selectionHeightStyle,
                  // selectionWidthStyle: widget.selectionWidthStyle,
                  keyboardAppearance: widget.keyboardAppearance,
                  scrollPadding: widget.scrollPadding,
                  // dragStartBehavior: widget.dragStartBehavior,
                  enableInteractiveSelection: widget.enableInteractiveSelection,
                  onTap: widget.onTap,
                  // buildCounter: widget.buildCounter,
                  // scrollController: widget.scrollController,
                  // scrollPhysics: widget.scrollPhysics,
                ),
                animationDuration: widget.animationDuration,
                animationStart: widget.animationStart,
                debounceDuration: widget.debounceDuration,
                errorBuilder: widget.errorBuilder,
                getImmediateSuggestions: widget.suggestionsCallback != null &&
                    !widget.isPassword &&
                    widget.getImmediateSuggestions,
                loadingBuilder: widget.loadingBuilder,
                noItemsFoundBuilder: (context) => null,
                suggestionsBoxDecoration: widget.suggestionsBoxDecoration,
                suggestionsBoxVerticalOffset:
                    widget.suggestionsBoxVerticalOffset,
                transitionBuilder: widget.transitionBuilder,
                autoFlipDirection: true,
                itemBuilder: (context, item) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Type.
                        if (item.type != null)
                          Text(
                            item.type,
                            style: defaultInputTextStyle.copyWith(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        // Name.
                        Text(
                          item.label,
                          style: defaultInputTextStyle.copyWith(
                            color: item.color,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onSuggestionSelected: (item) {
                  final text = insertTextAtCursorPosition(
                    widget.controller,
                    item.value,
                    fromSuggestion: true,
                  );
                  widget.onChanged?.call(text);
                },
                suggestionsCallback: (item) async {
                  final cursorPosition = widget.controller.selection.start;
                  return await widget.suggestionsCallback
                          ?.call(item, cursorPosition) ??
                      const [];
                },
              );
            },
          ),
        ),
        // Hide/Show Password.
        if (widget.isPassword)
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _showPassword,
              builder: (context, show, child) {
                return show ? const Icon(Mdi.eyeOff) : const Icon(Mdi.eye);
              },
            ),
            onPressed: () => _showPassword.value = !_showPassword.value,
          )
        // Options.
        else if (widget.items != null && widget.items.isNotEmpty)
          DotMenuButton<T>(
            items: widget.items,
            itemBuilder: widget.itemBuilder,
          )
        else if (widget.showDefaultItems)
          DotMenuButton<int>(
            items: const [0, 1],
            itemBuilder: (context, index, item) {
              return ListTile(
                leading: Icon(_obtainDefaultItemIcon(item)),
                title: Text(_obtainDefaultItemTitle(item)),
              );
            },
            onSelected: _onDefaultItemSelected,
          ),
      ],
    );
  }

  static const _defaultItemIcons = [Icons.content_paste, Icons.clear];

  IconData _obtainDefaultItemIcon(int item) {
    return _defaultItemIcons[item];
  }

  String _obtainDefaultItemTitle(int item) {
    final i18n = I18n.of(context);
    return [i18n.paste, i18n.clear][item];
  }

  void _onDefaultItemSelected(int item) {
    switch (item) {
      case 0:
        _onPaste();
        break;
      case 1:
        _onClear();
        break;
    }
  }

  void _onClear() {
    widget.controller.text = '';
    widget.onChanged?.call('');
  }

  Future<void> _onPaste() async {
    final data = await Clipboard.getData('text/plain');

    if (data?.text != null) {
      final text = insertTextAtCursorPosition(widget.controller, data.text);
      widget.onChanged?.call(text);
    }
  }
}
