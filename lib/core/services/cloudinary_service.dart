import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'dn0uuer1o';
  static const String _uploadPreset = 'eventshot';
  static const String _uploadUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Uploads an image to Cloudinary using an Unsigned Upload Preset.
  /// Returns the permanent 'secure_url' of the uploaded image.
  static Future<String> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl))
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonMap = json.decode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonMap['secure_url'] as String;
      } else {
        throw Exception('Cloudinary upload failed: ${jsonMap['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('CloudinaryService Error: $e');
      rethrow;
    }
  }
}
