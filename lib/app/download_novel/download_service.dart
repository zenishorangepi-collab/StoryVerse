// lib/app/downloads/services/download_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class DownloadService {
  static final Dio _dio = Dio();

  /// Get app's document directory for storing downloads
  static Future<Directory> _getDownloadDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDir.path}/downloads');

    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    return downloadDir;
  }

  /// Download audio file
  static Future<String> downloadAudio({required String url, required String novelId, required String chapterId, Function(double)? onProgress}) async {
    try {
      final downloadDir = await _getDownloadDirectory();
      final audioDir = Directory('${downloadDir.path}/$novelId/audio');

      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      final fileName = '$chapterId.mp3';
      final filePath = '${audioDir.path}/$fileName';

      // Check if already downloaded
      if (await File(filePath).exists()) {
        print('✅ Audio already downloaded: $filePath');
        return filePath;
      }

      // Download with progress
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );

      print('✅ Audio downloaded: $filePath');
      return filePath;
    } catch (e) {
      print('❌ Error downloading audio: $e');
      rethrow;
    }
  }

  /// Download text/transcript JSON
  static Future<String> downloadText({required String url, required String novelId, required String chapterId}) async {
    try {
      final downloadDir = await _getDownloadDirectory();
      final textDir = Directory('${downloadDir.path}/$novelId/text');

      if (!await textDir.exists()) {
        await textDir.create(recursive: true);
      }

      final fileName = '$chapterId.json';
      final filePath = '${textDir.path}/$fileName';

      // Check if already downloaded
      if (await File(filePath).exists()) {
        print('✅ Text already downloaded: $filePath');
        return filePath;
      }

      // Download JSON
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsString(response.body);
        print('✅ Text downloaded: $filePath');
        return filePath;
      } else {
        throw Exception('Failed to download text: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error downloading text: $e');
      rethrow;
    }
  }

  /// Download cover image
  static Future<String> downloadCover({required String url, required String novelId}) async {
    try {
      final downloadDir = await _getDownloadDirectory();
      final coverDir = Directory('${downloadDir.path}/$novelId');

      if (!await coverDir.exists()) {
        await coverDir.create(recursive: true);
      }

      final fileName = 'cover.jpg';
      final filePath = '${coverDir.path}/$fileName';

      // Check if already downloaded
      if (await File(filePath).exists()) {
        return filePath;
      }

      await _dio.download(url, filePath);
      return filePath;
    } catch (e) {
      print('❌ Error downloading cover: $e');
      return url; // Return original URL if download fails
    }
  }

  /// Get file size
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Delete downloaded novel
  static Future<void> deleteDownload(String novelId) async {
    try {
      final downloadDir = await _getDownloadDirectory();
      final novelDir = Directory('${downloadDir.path}/$novelId');

      if (await novelDir.exists()) {
        await novelDir.delete(recursive: true);
        print('✅ Deleted download: $novelId');
      }
    } catch (e) {
      print('❌ Error deleting download: $e');
    }
  }

  /// Get total storage used by downloads
  static Future<int> getTotalStorageUsed() async {
    try {
      final downloadDir = await _getDownloadDirectory();
      int totalSize = 0;

      if (await downloadDir.exists()) {
        await for (final entity in downloadDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      return totalSize;
    } catch (e) {
      print('❌ Error calculating storage: $e');
      return 0;
    }
  }
}
