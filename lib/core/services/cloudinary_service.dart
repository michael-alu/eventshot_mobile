import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'dn0uuer1o';
  static const String _uploadPreset = 'eventshot';
  static const String _apiKey = '431225626468716';
  static const String _apiSecret = 'm3LB1Il7DONG7nanGSraX3q3eGY';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Uploads an image to Cloudinary using an Unsigned Upload Preset.
  /// Files are organized into eventshot/[eventId]/images/ folder.
  /// Returns the permanent 'secure_url' of the uploaded image.
  static Future<String> uploadImage(File imageFile, {required String eventId}) async {
    try {
      final folder = 'eventshot/$eventId/images';

      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl))
        ..fields['upload_preset'] = _uploadPreset
        ..fields['folder'] = folder
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonMap = json.decode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonMap['secure_url'] as String;
      } else {
        throw Exception(
            'Cloudinary upload failed: ${jsonMap['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('CloudinaryService.uploadImage Error: $e');
      rethrow;
    }
  }

  /// Fetches live storage stats for an event folder from the Cloudinary Admin API.
  /// Returns total file count and total bytes stored under eventshot/[eventId]/images.
  static Future<CloudinaryFolderStats> getFolderStats({
    required String eventId,
  }) async {
    try {
      final folder = 'eventshot/$eventId/images';
      final credentials = base64Encode(utf8.encode('$_apiKey:$_apiSecret'));

      // Use the Cloudinary Search API to aggregate folder stats
      final searchUrl =
          'https://api.cloudinary.com/v1_1/$_cloudName/resources/search';

      final response = await http.post(
        Uri.parse(searchUrl),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'expression': 'folder=$folder',
          'with_field': ['image_metadata'],
          'max_results': 500,
        }),
      );

      final jsonMap = json.decode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
            'Cloudinary Stats API failed: ${jsonMap['error']?['message'] ?? response.statusCode}');
      }

      final resources = jsonMap['resources'] as List<dynamic>? ?? [];
      final totalBytes = resources.fold<int>(
          0, (sum, r) => sum + ((r['bytes'] as num?)?.toInt() ?? 0));
      final totalCount = resources.length;

      return CloudinaryFolderStats(
        totalBytes: totalBytes,
        totalCount: totalCount,
      );
    } catch (e) {
      debugPrint('CloudinaryService.getFolderStats Error: $e');
      rethrow;
    }
  }
}

class CloudinaryFolderStats {
  final int totalBytes;
  final int totalCount;

  const CloudinaryFolderStats({
    required this.totalBytes,
    required this.totalCount,
  });

  /// Storage consumed in human-readable MB
  double get totalMb => totalBytes / (1024 * 1024);

  @override
  String toString() =>
      'CloudinaryFolderStats(files: $totalCount, size: ${totalMb.toStringAsFixed(2)} MB)';
}
