class LanguageUtils {
  static String detectLanguageFromFilename(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'dart':
        return 'dart';
      case 'py':
        return 'python';
      case 'js':
        return 'javascript';
      case 'ts':
        return 'typescript';
      default:
        return 'dart';
    }
  }

  static String getFileIcon(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'dart':
        return '🎯';
      case 'py':
        return '🐍';
      case 'js':
        return '📜';
      case 'ts':
        return '💠';
      default:
        return '📄';
    }
  }
}
