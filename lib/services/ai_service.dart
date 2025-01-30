import 'package:flutter/foundation.dart';
import 'ollama_service.dart';
import 'error_service.dart';
import '../models/ai_model.dart';

class AIService extends ChangeNotifier {
  final OllamaService _ollamaService;
  String _selectedModel = 'codellama';
  bool _isStreaming = false;

  AIService({OllamaService? ollamaService})
      : _ollamaService = ollamaService ?? OllamaService();

  String get selectedModel => _selectedModel;
  bool get isStreaming => _isStreaming;

  Future<String> getAIResponse(String prompt) async {
    try {
      return await _ollamaService.generateResponse(prompt,
          model: _selectedModel);
    } catch (e, stackTrace) {
      ErrorService.logError('AI response error', e, stackTrace);
      rethrow;
    }
  }

  Stream<String> streamAIResponse(String prompt) async* {
    try {
      _isStreaming = true;
      notifyListeners();

      await for (final response in _ollamaService.generateResponseStream(prompt,
          model: _selectedModel)) {
        yield response;
      }
    } finally {
      _isStreaming = false;
      notifyListeners();
    }
  }

  Future<List<AIModel>> getAvailableModels() async {
    try {
      final modelNames = await _ollamaService.listModels();
      return modelNames.map((name) => AIModel(name: name)).toList();
    } catch (e, stackTrace) {
      ErrorService.logError('Model listing error', e, stackTrace);
      rethrow;
    }
  }

  void setModel(String model) {
    if (_selectedModel != model) {
      _selectedModel = model;
      notifyListeners();
    }
  }
}
