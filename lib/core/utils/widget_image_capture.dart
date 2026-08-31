import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

/// Renders a [RepaintBoundary]-wrapped widget to a PNG file in the temp
/// directory, for handing off to a native share sheet (`share_plus`). The
/// single place this "capture a widget as a shareable image" capability
/// lives — callers only need a [GlobalKey] on their `RepaintBoundary`.
class WidgetImageCapture {
  WidgetImageCapture._();

  static Future<File> captureToFile(
    GlobalKey boundaryKey, {
    required String fileName,
    double pixelRatio = 3.0,
  }) async {
    final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
