import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../models/ai_model.dart';
import '../widgets/shared/loading_overlay.dart';

class AIPane extends StatefulWidget {
  const AIPane({super.key});

  @override
  AIPaneState createState() => AIPaneState();
}

class AIPaneState extends State<AIPane> {
  final TextEditingController _promptController = TextEditingController();
  String _response = '';
  List<AIModel> _models = [];
  String _selectedModel = 'codellama';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final modelList = await context.read<AIService>().getAvailableModels();
      setState(() {
        _models = modelList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load models: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _generateResponse() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response =
          await context.read<AIService>().getAIResponse(_promptController.text);
      setState(() {
        _response = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to generate response: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (_error != null)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.error,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(_error!,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.error))),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _error = null),
                        ),
                      ],
                    ),
                  ),
                ),
              DropdownButton<String>(
                value: _selectedModel,
                items: _models
                    .map((model) => DropdownMenuItem(
                          value: model.name,
                          child: Text(model.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedModel = value);
                    context.read<AIService>().setModel(value);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _promptController,
                decoration: const InputDecoration(
                  labelText: 'Ask AI...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _generateResponse,
                child: Text(_isLoading ? 'Generating...' : 'Generate'),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_response),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading) const LoadingOverlay(),
      ],
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
