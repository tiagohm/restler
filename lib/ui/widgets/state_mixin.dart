import 'package:flutter/material.dart';
import 'package:restler/i18n.dart';

mixin StateMixin<T extends StatefulWidget> on State<T> {
  I18n get i18n => I18n.of(context);

  String textIsRequired(String text) {
    return text == null || text.isEmpty ? i18n.required : null;
  }

  String itemIsRequired(item) {
    return item == null ? i18n.required : null;
  }
}
