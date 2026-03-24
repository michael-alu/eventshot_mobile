import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'dn0uuer1o';
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
      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      
      final strToSign = 'folder=$folder&timestamp=$timestamp$_apiSecret';
      final signature = sha1.convert(utf8.encode(strToSign)).toString();

      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl))
        ..fields['api_key'] = _apiKey
        ..fields['folder'] = folder
        ..fields['timestamp'] = timestamp
        ..fields['signature'] = signature
        ..files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );

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

  /// Commands Cloudinary to package a specific folder into a .zip and returns a secure download url
  /// Constructs a synchronously authenticated GET url to natively trigger
  /// Cloudinary's dynamic zip generator on the physical device's external browser.
  static String generateArchiveUrl({required String eventId}) {
    try {
      final folder = 'eventshot/$eventId/images/';
      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      
      final strToSign = 'mode=download&prefixes=$folder&target_format=zip&timestamp=$timestamp$_apiSecret';
      final signature = sha1.convert(utf8.encode(strToSign)).toString();

      final baseUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/generate_archive';
      
      final queryParams = [
        'api_key=$_apiKey',
        'timestamp=$timestamp',
        'signature=$signature',
        'prefixes=${Uri.encodeComponent(folder)}',
        'target_format=zip',
        'mode=download',
      ].join('&');

      return '$baseUrl?$queryParams';
    } catch (e) {
      debugPrint('CloudinaryService.generateArchiveUrl Error: $e');
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
