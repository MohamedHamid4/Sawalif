import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 🖼️ خدمة ImgBB لرفع الصور (بديل مجاني لـ Firebase Storage)
class ImgBBService {
  static const String _apiKey = '345c33bf7447dba38e97d7d7a1c0e236';
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  /// رفع صورة من ملف وإرجاع رابطها
  Future<String?> uploadImage(File imageFile, {String? name}) async {
    final bytes = await imageFile.readAsBytes();
    if (kDebugMode) {
      debugPrint('[ImgBB] uploading file=${imageFile.path} '
          'bytes=${bytes.length}');
    }
    return uploadImageFromBytes(bytes, name: name);
  }

  /// رفع صورة من Bytes (مفيد للويب)
  Future<String?> uploadImageFromBytes(List<int> bytes, {String? name}) async {
    try {
      final base64Image = base64Encode(bytes);

      if (kDebugMode) {
        debugPrint('[ImgBB] POST $_uploadUrl '
            '(base64Len=${base64Image.length}, name=$name)');
      }

      final response = await http.post(
        Uri.parse(_uploadUrl),
        body: {
          'key': _apiKey,
          'image': base64Image,
          if (name != null) 'name': name,
        },
      );

      if (kDebugMode) {
        final preview = response.body.length > 200
            ? '${response.body.substring(0, 200)}…'
            : response.body;
        debugPrint('[ImgBB] status=${response.statusCode} body=$preview');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final url = data['data']['url'] as String;
          if (kDebugMode) debugPrint('[ImgBB] success url=$url');
          return url;
        }
      }
      return null;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[ImgBB] error: $e\n$st');
      }
      return null;
    }
  }
}
