import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

extension StringExtension on String {
  Future<bool> launchUri() async {
    if (await canLaunch(this)) {
      return launch(this);
    } else {
      return false;
    }
  }

  Color get methodColor {
    switch (toUpperCase()) {
      case 'GET':
        return Colors.purple;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange[400];
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.yellow;
      case 'HEAD':
      case 'OPTIONS':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String shorten() {
    if (this == 'DELETE' || this == 'OPTIONS') {
      return substring(0, 3);
    } else if (length > 4) {
      var res = '';
      const vogais = ['a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U'];

      for (var i = 0; i < length; i++) {
        final c = this[i].toUpperCase();
        if (!vogais.contains(c)) {
          res += c;
        }
      }

      if (res.isEmpty) {
        return substring(0, min(4, length));
      } else {
        return res.substring(0, min(4, res.length));
      }
    } else {
      return substring(0, min(4, length));
    }
  }
}

extension IntExtension on int {
  Color get statusColor {
    if (this == 0) {
      return Colors.grey;
    } else if (this >= 200 && this < 300) {
      return Colors.green;
    } else if (this >= 300 && this < 400) {
      return Colors.blue;
    } else if (this >= 400 && this < 500) {
      return Colors.orange[400];
    } else {
      return Colors.red;
    }
  }
}
