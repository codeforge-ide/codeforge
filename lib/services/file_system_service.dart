import 'dart:io';
import 'package:path/path.dart' as path;
import 'error_service.dart';

class FileSystemService {
  Future<String> readFile(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsString();
    } catch (e, stackTrace) {
      ErrorService.logError('Failed to read file', e, stackTrace);
      rethrow;
    }
  }

  Future<void> writeFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content);
    } catch (e, stackTrace) {
      ErrorService.logError('Failed to write file', e, stackTrace);
      rethrow;
    }
  }

  Future<List<String>> listDirectory(String dirPath, {String? pattern}) async {
    try {
      final dir = Directory(dirPath);
      final entities = await dir.list(recursive: true).toList();
      final files = entities
          .whereType<File>()
          .map((file) => file.path)
          .where((path) => pattern == null || path.endsWith(pattern))
          .toList();
      return files;
    } catch (e, stackTrace) {
      ErrorService.logError('Failed to list directory', e, stackTrace);
      rethrow;
    }
  }

  String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceFirst('.', '');
  }

  String getFileName(String filePath) {
    return path.basename(filePath);
  }

  String getDirName(String filePath) {
    return path.dirname(filePath);
  }

  Future<bool> fileExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (e, stackTrace) {
      ErrorService.logError('Failed to check file existence', e, stackTrace);
      rethrow;
    }
  }

  Future<void> createDirectory(String dirPath) async {
    try {
      await Directory(dirPath).create(recursive: true);
    } catch (e, stackTrace) {
      ErrorService.logError('Failed to create directory', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteFile(String filePath) async {
    try {
      await File(filePath).delete();
    } catch (e, stackTrace) {
      ErrorService.logError('Failed to delete file', e, stackTrace);
      rethrow;
    }
  }
}
