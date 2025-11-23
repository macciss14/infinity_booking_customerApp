import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<dynamic> pickImage() async {
    try {
      print('📸 Opening image picker...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        print('✅ Image selected: ${image.path}');
        print('📁 File name: ${image.name}');

        if (kIsWeb) {
          // For web, return the XFile directly
          return image;
        } else {
          // For mobile, return File
          return File(image.path);
        }
      } else {
        print('❌ No image selected');
        return null;
      }
    } catch (e) {
      print('💥 Error picking image: $e');
      return null;
    }
  }

  // Web-compatible method that returns image bytes
  static Future<Uint8List?> pickImageAsBytes() async {
    try {
      print('📸 Opening image picker for bytes...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        print('✅ Image selected, reading as bytes...');
        final bytes = await image.readAsBytes();
        print('📊 Bytes length: ${bytes.length}');
        return bytes;
      } else {
        print('❌ No image selected');
        return null;
      }
    } catch (e) {
      print('💥 Error picking image as bytes: $e');
      return null;
    }
  }

  // Alternative method specifically for web
  static Future<Uint8List?> pickImageWeb() async {
    try {
      print('🌐 Web: Opening image picker...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        print('🌐 Web: Image selected, reading bytes...');
        final bytes = await image.readAsBytes();
        return bytes;
      }
      return null;
    } catch (e) {
      print('💥 Web: Error picking image: $e');
      return null;
    }
  }
}
