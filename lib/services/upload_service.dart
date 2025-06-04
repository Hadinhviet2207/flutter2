import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class UploadService {
  static final cloudinary = CloudinaryPublic(
    'dua5bpeht',
    'planera',
    cache: false,
  );

  static const String cloudName = 'dua5bpeht';
  static const String uploadPreset = 'planera';

  static Future<String?> uploadBytesToCloudinary(
    Uint8List fileBytes,
    String fileName,
  ) async {
    if (fileBytes.isEmpty) {
      print('Error: File bytes is empty');
      throw Exception('File bytes is empty');
    }

    final extension = fileName.split('.').last.toLowerCase();
    String resourceType = 'raw';

    // Xác định loại file dựa theo phần mở rộng
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      resourceType = 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      resourceType = 'video';
    } else {
      resourceType = 'raw'; // cho text, pdf, zip, docx, v.v.
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload',
    );

    try {
      final request =
          http.MultipartRequest('POST', uri)
            ..fields['upload_preset'] = uploadPreset
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                fileBytes,
                filename: fileName,
              ),
            );

      print('Uploading file: $fileName (${fileBytes.length} bytes)');
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = json.decode(responseData.body);
        print('Upload successful: ${data['secure_url']}');
        return data['secure_url'];
      } else {
        print(
          'Failed to upload: ${response.statusCode} | ${responseData.body}',
        );
        throw Exception('Upload failed: ${responseData.body}');
      }
    } catch (e) {
      print('Error during upload: $e');
      throw Exception('Upload failed: $e');
    }
  }

  static Future<String?> pickAndUploadImage({
    required String userId,
    required String projectId,
    String? parentId,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;
      final file = result.files.first;

      if (file.bytes == null || file.bytes!.isEmpty) {
        print('Error: File bytes is null or empty');
        return null;
      }

      String secureUrl;
      if (kIsWeb) {
        // Web
        final uploadedUrl = await uploadBytesToCloudinary(
          file.bytes!,
          file.name,
        );
        if (uploadedUrl == null) throw Exception('Upload failed');
        secureUrl = uploadedUrl;
      } else {
        // Mobile
        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            file.path!,
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        secureUrl = response.secureUrl;
      }

      // Lưu thông tin file vào Firestore
      final fileData = {
        'url': secureUrl,
        'type': 'image',
        'name': file.name,
        'size': file.size,
        'uploadedBy': userId,
        'uploadedAt': FieldValue.serverTimestamp(),
        'projectId': projectId,
        if (parentId != null) 'parentId': parentId,
      };

      final fileRef = await FirebaseFirestore.instance
          .collection('files')
          .add(fileData);

      // Nếu là ảnh nền của project detail
      if (parentId != null) {
        await FirebaseFirestore.instance
            .collection('project_details')
            .doc(parentId)
            .update({
              'backgroundImage': secureUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }

      // Nếu là ảnh trong comment
      if (parentId != null && parentId.startsWith('comment_')) {
        final commentId = parentId.replaceFirst('comment_', '');
        await FirebaseFirestore.instance
            .collection('comments')
            .doc(commentId)
            .update({
              'imageUrl': secureUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }

      return secureUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  static Future<String?> pickAndUploadFile({
    required String userId,
    required String projectId,
    String? parentId,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;
      final file = result.files.first;

      if (file.bytes == null || file.bytes!.isEmpty) {
        print('Error: File bytes is null or empty');
        return null;
      }

      // Xác định loại file
      String fileType = 'file';
      final fileName = file.name.toLowerCase();
      if (fileName.endsWith('.jpg') ||
          fileName.endsWith('.jpeg') ||
          fileName.endsWith('.png') ||
          fileName.endsWith('.gif') ||
          fileName.endsWith('.webp')) {
        fileType = 'image';
      }
      // File âm thanh
      else if (fileName.endsWith('.mp3') ||
          fileName.endsWith('.wav') ||
          fileName.endsWith('.ogg')) {
        fileType = 'audio';
      }
      // File video
      else if (fileName.endsWith('.mp4') || fileName.endsWith('.mov')) {
        fileType = 'video';
      }
      // File PDF
      else if (fileName.endsWith('.pdf')) {
        fileType = 'pdf';
      }
      // File Word
      else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
        fileType = 'document';
      }
      // File text
      else if (fileName.endsWith('.txt') || fileName.endsWith('.text')) {
        fileType = 'text';
      }
      // File Excel
      else if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx')) {
        fileType = 'spreadsheet';
      }
      // File PowerPoint
      else if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx')) {
        fileType = 'presentation';
      }
      // File nén
      else if (fileName.endsWith('.zip') ||
          fileName.endsWith('.rar') ||
          fileName.endsWith('.7z')) {
        fileType = 'archive';
      }
      // File code
      else if (fileName.endsWith('.js') ||
          fileName.endsWith('.py') ||
          fileName.endsWith('.java') ||
          fileName.endsWith('.cpp') ||
          fileName.endsWith('.cs') ||
          fileName.endsWith('.php') ||
          fileName.endsWith('.html') ||
          fileName.endsWith('.css') ||
          fileName.endsWith('.dart')) {
        fileType = 'code';
      }

      String secureUrl;
      if (kIsWeb) {
        // Web
        final uploadedUrl = await uploadBytesToCloudinary(
          file.bytes!,
          file.name,
        );
        if (uploadedUrl == null) throw Exception('Upload failed');
        secureUrl = uploadedUrl;
      } else {
        // Mobile
        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            file.path!,
            resourceType:
                fileType == 'audio' || fileType == 'video'
                    ? CloudinaryResourceType.Video
                    : CloudinaryResourceType.Raw,
          ),
        );
        secureUrl = response.secureUrl;
      }

      // Lưu thông tin file vào Firestore
      final fileData = {
        'url': secureUrl,
        'type': fileType,
        'name': file.name,
        'size': file.size,
        'uploadedBy': userId,
        'uploadedAt': FieldValue.serverTimestamp(),
        'projectId': projectId,
        if (parentId != null) 'parentId': parentId,
      };

      final fileRef = await FirebaseFirestore.instance
          .collection('files')
          .add(fileData);

      // Nếu là file đính kèm của project detail
      if (parentId != null) {
        await FirebaseFirestore.instance
            .collection('project_details')
            .doc(parentId)
            .update({
              'attachments': FieldValue.arrayUnion([fileRef.id]),
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }

      // Nếu là file đính kèm của comment
      if (parentId != null && parentId.startsWith('comment_')) {
        final commentId = parentId.replaceFirst('comment_', '');
        await FirebaseFirestore.instance
            .collection('comments')
            .doc(commentId)
            .update({
              'attachmentUrls': FieldValue.arrayUnion([secureUrl]),
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }

      return secureUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }
}
