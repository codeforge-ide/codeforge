import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/source_control_service.dart';
import 'shared/loading_overlay.dart';

class SourceControlPane extends StatefulWidget {
  const SourceControlPane({super.key});

  @override
  SourceControlPaneState createState() => SourceControlPaneState();
}

class SourceControlPaneState extends State<SourceControlPane> {
  String _status = '';
  List<String> _changedFiles = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _commitMessageController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = context.read<SourceControlService>();
      final status = await service.getStatus();
      final changedFiles = (await service.getChangedFiles())
          .split('\n')
          .where((line) => line.isNotEmpty)
          .toList();

      setState(() {
        _status = status;
        _changedFiles = changedFiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to refresh status: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _stageFile(String file) async {
    setState(() => _isLoading = true);
    try {
      await context.read<SourceControlService>().stageFile(file);
      await _refreshStatus();
    } catch (e) {
      setState(() {
        _error = 'Failed to stage file: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _commit() async {
    if (_commitMessageController.text.isEmpty) {
      setState(() => _error = 'Please enter a commit message');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context
          .read<SourceControlService>()
          .commit(_commitMessageController.text);
      _commitMessageController.clear();
      await _refreshStatus();
    } catch (e) {
      setState(() {
        _error = 'Failed to commit: $e';
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Source Control',
                  style: Theme.of(context).textTheme.titleMedium),
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
              Expanded(
                child: ListView.builder(
                  itemCount: _changedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _changedFiles[index];
                    return ListTile(
                      title: Text(file),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _stageFile(file),
                      ),
                    );
                  },
                ),
              ),
              TextField(
                controller: _commitMessageController,
                decoration: const InputDecoration(
                  labelText: 'Commit message',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _refreshStatus,
                    child: const Text('Refresh'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _commit,
                    child: const Text('Commit'),
                  ),
                ],
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
    _commitMessageController.dispose();
    super.dispose();
  }
}
