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

  static String detectLanguage(String filename, [String? content]) {
    final extension = filename.split('.').length > 1
        ? filename.split('.').last.toLowerCase()
        : '';
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
        // Try to detect from content if available
        if (content != null && content.isNotEmpty) {
          if (content.startsWith('#!') && content.contains('python')) {
            return 'python';
          }
          if (content.contains('import dart:')) return 'dart';
          if (content.contains('function') || content.contains('console.log')) {
            return 'javascript';
          }
          if (content.contains('def ') || content.contains('print(')) {
            return 'python';
          }
        }
        return 'plaintext';
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
