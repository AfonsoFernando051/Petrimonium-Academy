import 'dart:io';

import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/utils/translator.dart';

/// Maps a caught error into copy that's safe and clear to show a user —
/// never the raw `Exception: ...` text, and something more useful than that
/// for the most common failure (no connectivity). Always returns text in the
/// user's currently selected language (see [Translator]).
String friendlyErrorMessage(Object error) {
  if (error is SocketException) {
    return Translator.translate(AppStrings.errorNoConnectionMessage);
  }

  final text = error.toString().replaceFirst('Exception: ', '').trim();
  final lower = text.toLowerCase();
  if (lower.contains('socketexception') || lower.contains('connection') || lower.contains('network')) {
    return Translator.translate(AppStrings.errorNoConnectionMessage);
  }

  return text.isEmpty ? Translator.translate(AppStrings.errorUnexpectedMessage) : text;
}
