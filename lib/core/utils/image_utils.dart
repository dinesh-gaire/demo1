import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageUtils {
  static Future<String?> imageToBase64(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  static Future<String> saveBase64Image(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      final dir = await getApplicationDocumentsDirectory();
      final filename = const Uuid().v4() + '.jpg';
      final file = File('${dir.path}/$filename');
      file.writeAsBytesSync(bytes);
      return file.path;
    } catch (e) {
      print('Error saving base64 image: $e');
      return '';
    }
  }
}
