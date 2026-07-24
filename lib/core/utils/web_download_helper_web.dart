// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void downloadFileWeb(String filename, String content) {
  final bytes = html.Blob([content], 'text/plain;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(bytes);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = filename;

  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
