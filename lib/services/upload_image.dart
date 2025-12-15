// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class CloudneryUploader {
  final String cloudinaryCloudName = 'daai1jedw'; // Fixed typo: 'daalijedw' to 'daai1jedw'
  final String cloudinaryUploadPreset = 'byodapp';

  Future<String?> uploadFile(XFile file) async {
    try {
      final mimeTypeData = lookupMimeType(file.path)?.split('/'); // Fixed: lookupMinetype to lookupMimeType

      // Determine resource type based on MIME type
      String resourceType = 'image'; // default
      if (mimeTypeData != null) {
        if (mimeTypeData[0] == 'application' && mimeTypeData[1] == 'pdf') {
          resourceType = 'raw'; // PDFs go to /raw/upload
        } else if (mimeTypeData[0] == 'video') { // Fixed: mimeTypeData instead of minetypeData
          resourceType = 'video';
        }
        // Images stay as 'image'
      }

      final uploadUrl =
          "https://api.cloudinary.com/v1_1/$cloudinaryCloudName/$resourceType/upload";

      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
        ..fields['upload_preset'] = cloudinaryUploadPreset
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            contentType: mimeTypeData != null
                ? http.MediaType(mimeTypeData[0], mimeTypeData[1])
                : null,
          ),
        );

      final response = await request.send();
      final result = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(result.body);
        log("✅ Upload success ($resourceType): ${data['secure_url']}");
        return data['secure_url'];
      } else {
        log("❌ Upload failed: ${result.body}");
        return null;
      }
    } catch (e) {
      log("❌ Upload error: $e");
      return null;
    }
  }
}