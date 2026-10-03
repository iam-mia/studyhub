import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import '../database/tables/documents_table.dart';

class PickedFileInfo {
  final String name;
  final String? path;
  final Uint8List? bytes;
  final int size;
  final DocumentType type;
  final String? dataUri;

  PickedFileInfo({
    required this.name,
    this.path,
    this.bytes,
    required this.size,
    required this.type,
    this.dataUri,
  });
}

class FileStorageService {
  static Future<PickedFileInfo?> pickDocumentFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
    );

    if (result.isEmpty) return null;

    final file = result.first;
    final path = file.path;
    final name = file.name;
    final size = file.lengthSync() ?? (await file.length()) ?? 0;
    final bytes = await file.readAsBytes();

    final ext = p.extension(name).toLowerCase();
    DocumentType docType = DocumentType.pdf;
    String mimeType = 'application/pdf';

    if (ext == '.pdf') {
      docType = DocumentType.pdf;
      mimeType = 'application/pdf';
    } else if (ext == '.doc' || ext == '.docx') {
      docType = DocumentType.word;
      mimeType = 'application/msword';
    } else if (ext == '.ppt' || ext == '.pptx') {
      docType = DocumentType.ppt;
      mimeType = 'application/vnd.ms-powerpoint';
    }

    String? dataUri;
    if (bytes.isNotEmpty) {
      dataUri = 'data:$mimeType;base64,${base64Encode(bytes)}';
    }

    return PickedFileInfo(
      name: name,
      path: path,
      bytes: bytes,
      size: size,
      type: docType,
      dataUri: dataUri,
    );
  }

  static Future<String?> copyFileToLocalStorage(
      String sourcePath, String fileName) async {
    if (kIsWeb) {
      return sourcePath;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final targetFolder = Directory(p.join(appDir.path, 'studyhub_files'));
      if (!await targetFolder.exists()) {
        await targetFolder.create(recursive: true);
      }

      final safeName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final targetPath = p.join(targetFolder.path, safeName);
      final sourceFile = File(sourcePath);

      if (await sourceFile.exists()) {
        await sourceFile.copy(targetPath);
        return targetPath;
      }
    } catch (_) {}
    return sourcePath;
  }

  static Future<bool> openUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
    return false;
  }

  static Future<String?> exportFile({
    String? sourceFilePath,
    String? fileUrl,
    required String defaultFileName,
  }) async {
    try {
      Uint8List? bytes;
      String extension = 'pdf';

      if (sourceFilePath != null && !kIsWeb) {
        final source = File(sourceFilePath);
        if (await source.exists()) {
          bytes = await source.readAsBytes();
          extension = p.extension(sourceFilePath).replaceAll('.', '');
        }
      }

      if (bytes == null && fileUrl != null && fileUrl.startsWith('data:')) {
        final commaIdx = fileUrl.indexOf(',');
        if (commaIdx != -1) {
          final base64Str = fileUrl.substring(commaIdx + 1);
          bytes = base64Decode(base64Str);
        }
      }

      if (bytes != null) {
        final saveUri = await FilePicker.saveFile(
          dialogTitle: 'Tải tài liệu về máy',
          fileName: defaultFileName,
          bytes: bytes,
          type: FileType.custom,
          allowedExtensions: [extension.isEmpty ? 'pdf' : extension],
        );
        if (saveUri != null) {
          return saveUri.path;
        }
      } else if (fileUrl != null) {
        await openUrl(fileUrl);
        return fileUrl;
      }
    } catch (_) {}
    return null;
  }
}
