import 'package:logger/logger.dart';

class ErrorService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void logError(String message, dynamic error, StackTrace? stackTrace) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void logWarning(String message) {
    _logger.w(message);
  }

  static void logInfo(String message) {
    _logger.i(message);
  }

  static String getUserFriendlyMessage(dynamic error) {
    if (error.toString().contains('Connection refused')) {
      return 'Could not connect to Ollama. Please make sure it\'s running.';
    }
    if (error.toString().contains('git')) {
      return 'Git operation failed. Please check your git installation.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
