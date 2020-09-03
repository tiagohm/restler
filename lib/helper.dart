import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restler/constants.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/inject.dart';
import 'package:restler/services/variable_loader.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

String generateUuidV1() => _uuid.v1();

String generateUuidV4() => _uuid.v4();

String generateUuid() => generateUuidV1();

int currentMillis() => DateTime.now().millisecondsSinceEpoch;

DateTime currentUtc() => DateTime.now().toUtc();

Future<bool> handlePermission(Permission permission) async {
  final status = await permission.status;

  if (status.isGranted) {
    return true;
  } else if (status.isDenied || status.isUndetermined) {
    final res = await permission.request();
    return res.isGranted;
  } else {
    return false;
  }
}

String compress(List<int> data) {
  if (data == null || data.isEmpty) return '';
  final compressedData = gzip.encode(data);
  return base64Encode(compressedData);
}

List<int> decompress(String data) {
  if (data == null || data.isEmpty) return const [];
  final List<int> rawData = base64Decode(data);
  return gzip.decode(rawData);
}

/// Copia o texto para à área de transferência.
Future<bool> copyToClipboard(String text) async {
  try {
    await Clipboard.setData(ClipboardData(text: text));
    return true;
  } catch (e) {
    return false;
  }
}

String obtainFilenameFromContentDisposition(String text) {
  try {
    final value = HeaderValue.parse(text);
    return value?.parameters['filename'];
  } catch (e) {
    return null;
  }
}

String insertTextAtCursorPosition(
  TextEditingController controller,
  String textToInsert, {
  bool fromSuggestion = false,
}) {
  final text = controller.text;

  if (controller.selection.start == -1) {
    controller.text = textToInsert;
    return textToInsert;
  }

  var a = '';
  var b = '';
  var braceLeftIndex = 0;
  var braceRightIndex = 0;

  if (fromSuggestion) {
    final texts = splitText(text, controller.selection.start);

    if (texts != null) {
      final String a = texts[0];
      final String b = texts[1] ?? '';

      for (var i = controller.selection.start - 1; i >= 0; i--) {
        if (text[i] == '{') {
          braceLeftIndex = controller.selection.start - i;

          if (i >= 1 && text[i - 1] == '{') {
            braceLeftIndex++;
          }
        }
      }

      for (var i = controller.selection.start; i < text.length; i++) {
        if (text[i] == '}') {
          braceRightIndex = i - controller.selection.start + 1;

          if (i < text.length - 1 && text[i + 1] == '}') {
            braceRightIndex++;
          }
        }
      }

      if (b.isNotEmpty && textToInsert.endsWith(b)) {
        textToInsert =
            textToInsert.substring(0, textToInsert.length - b.length);
      }
      if (a.isNotEmpty && textToInsert.startsWith(a)) {
        textToInsert = textToInsert.substring(a.length);
      }
    } else if (text.isNotEmpty) {
      if (textToInsert.startsWith(text) || textToInsert.endsWith(text)) {
        braceLeftIndex = text.length;
        braceRightIndex = text.length;
      }
    }
  }

  // FIM.
  if (controller.selection.start == text.length) {
    a = text.substring(0, controller.selection.start - braceLeftIndex);
  }
  // INICIO.
  else if (controller.selection.end == 0) {
    b = text.substring(controller.selection.end + braceRightIndex);
  }
  // MEIO ou SELEÇÂO.
  else {
    a = text.substring(0, controller.selection.start - braceLeftIndex);
    b = text.substring(controller.selection.end + braceRightIndex);
  }

  final start =
      controller.selection.start - braceLeftIndex + textToInsert.length;
  final end = start;
  final finalText = '$a$textToInsert$b';

  controller.value = TextEditingValue(
    composing: TextRange(start: start, end: end),
    selection: TextSelection(
      baseOffset: start,
      extentOffset: end,
      affinity: controller.selection.affinity,
      isDirectional: controller.selection.isDirectional,
    ),
    text: finalText,
  );

  return finalText;
}

Future<List<AutocompleteItem>> variableSuggestions(
  String text,
  int cursorPosition,
) async {
  if (cursorPosition < 1 || text.isEmpty) {
    return const [];
  }

  final texts = splitText(text, cursorPosition);
  String a, b;

  if (texts == null) {
    return const [];
  } else {
    a = texts[0].toLowerCase().replaceFirst('\$', '');
    b = texts[1]?.toLowerCase() ?? '';
  }

  final res = <AutocompleteItem>[];
  final loader = kiwi<VariableLoader>().load;

  if (loader != null) {
    for (final item in await loader()) {
      final value = item.toLowerCase();

      if ((a.isEmpty || value.startsWith(a)) &&
          (b.isEmpty || value.endsWith(b))) {
        res.add(VariableAutocompleteItem(item));
      }
    }
  }

  for (final item in postmanDynamicVariables) {
    final value = item.toLowerCase();

    if ((a.isEmpty || value.startsWith(a)) &&
        (b.isEmpty || value.endsWith(b))) {
      res.add(PostmanAutocompleteItem(item));
    }
  }

  return res;
}

List splitText(
  String text,
  int position, {
  final String leftChar = '{',
  final String rightChar = '}',
}) {
  final leftText = text.substring(0, position);
  final rightText = text.substring(position);
  var exit = true;
  String a, b;
  int aPos, bPos;

  for (var i = leftText.length - 1; i >= 0; i--) {
    if (leftText[i] == rightChar) {
      break;
    }
    if (leftText[i] == leftChar) {
      exit = false;
      a = leftText.substring(i + 1);
      aPos = i;
      break;
    }
  }

  if (exit) {
    return null;
  }

  exit = rightText.isNotEmpty;

  for (var i = 0; i < rightText.length; i++) {
    if (rightText[i] == leftChar) {
      break;
    }
    if (rightText[i] == rightChar) {
      exit = false;
      b = rightText.substring(0, i);
      bPos = i;
      break;
    }
  }

  print('$a | $b');

  if (exit) {
    return null;
  }

  return [a, b, aPos, bPos];
}

List<DropdownMenuItem<WorkspaceEntity>> mapWorkspaceEntityToDropdownItem(
  List<WorkspaceEntity> data, {
  TextStyle style,
}) {
  return [
    for (final item in data)
      DropdownMenuItem<WorkspaceEntity>(
        value: item,
        child: Text(item.name, style: style),
      ),
  ];
}
