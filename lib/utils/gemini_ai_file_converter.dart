import 'dart:convert';
import 'dart:io';

class FileConverter {
  static String convertIntoBase64(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    return base64Encode(imageBytes);
  }
}
