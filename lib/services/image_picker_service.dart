import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: ${e.toString()}');
    }
  }

  Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile>? images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (images != null) {
        return images.map((image) => File(image.path)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to pick images: ${e.toString()}');
    }
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      // Convert file to base64 or use multipart upload
      // For now, we'll return a placeholder
      // In real implementation, you would upload to your server
      await Future.delayed(const Duration(seconds: 2)); // Simulate upload
      return 'https://example.com/profile-image.jpg';
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      // Implementation for general image upload
      // This would typically use multipart/form-data
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Placeholder - replace with actual upload logic
      return 'data:image/jpeg;base64,$base64Image';
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }
}
