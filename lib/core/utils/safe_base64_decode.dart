import 'dart:convert';
import 'dart:typed_data';

Uint8List safeBase64Decode(String base64String) {
  try {
    String cleanStr = base64String;
    if (cleanStr.contains(',')) {
      cleanStr = cleanStr.split(',').last;
    }
    cleanStr = cleanStr.replaceAll(RegExp(r'\s+'), '');
    return base64Decode(base64.normalize(cleanStr));
  } catch (e) {
    return Uint8List(0);
  }
}
