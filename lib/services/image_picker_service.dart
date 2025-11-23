import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage() async {
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
        return File(image.path);
      } else {
        print('❌ No image selected');
        return null;
      }
    } catch (e) {
      print('💥 Error picking image: $e');
      return null;
    }
  }
}
