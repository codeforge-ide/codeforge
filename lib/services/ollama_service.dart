import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'error_service.dart';

class OllamaService {
  final String _baseUrl;

  OllamaService({String? baseUrl})
      : _baseUrl = baseUrl ?? 'http://localhost:11434';

  Stream<String> generateResponseStream(String prompt,
      {String model = 'codellama'}) async* {
    try {
      final request = http.Request('POST', Uri.parse('$_baseUrl/api/generate'));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'model': model,
        'prompt': prompt,
        'stream': true,
      });

      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        ErrorService.logError('Failed to generate response',
            'Status code: ${response.statusCode}', StackTrace.current);
        throw Exception(
            ErrorService.getUserFriendlyMessage('HTTP ${response.statusCode}'));
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        for (final line in chunk.split('\n').where((line) => line.isNotEmpty)) {
          try {
            final data = jsonDecode(line);
            if (data['response'] != null) {
              yield data['response'];
            }
          } catch (e) {
            ErrorService.logWarning('Failed to parse JSON: $line');
          }
        }
      }
    } catch (e, stackTrace) {
      ErrorService.logError('Stream generation error', e, stackTrace);
      throw Exception(ErrorService.getUserFriendlyMessage(e));
    }
  }

  Future<String> generateResponse(String prompt,
      {String model = 'codellama'}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': model,
          'prompt': prompt,
          'stream': false,
        }),
      );

      if (response.statusCode != 200) {
        ErrorService.logError('Failed to generate response',
            'Status code: ${response.statusCode}', StackTrace.current);
        throw Exception(
            ErrorService.getUserFriendlyMessage('HTTP ${response.statusCode}'));
      }

      final data = jsonDecode(response.body);
      return data['response'] ?? '';
    } catch (e, stackTrace) {
      ErrorService.logError('Response generation error', e, stackTrace);
      throw Exception(ErrorService.getUserFriendlyMessage(e));
    }
  }

  Future<List<String>> listModels() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/tags'));

      if (response.statusCode != 200) {
        ErrorService.logError('Failed to list models',
            'Status code: ${response.statusCode}', StackTrace.current);
        throw Exception(
            ErrorService.getUserFriendlyMessage('HTTP ${response.statusCode}'));
      }

      final data = jsonDecode(response.body);
      return (data['models'] as List).map((e) => e['name'].toString()).toList();
    } catch (e, stackTrace) {
      ErrorService.logError('Model listing error', e, stackTrace);
      throw Exception(ErrorService.getUserFriendlyMessage(e));
    }
  }
}
