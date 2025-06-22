import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/workspace_service.dart';

class TerminalPane extends StatefulWidget {
  const TerminalPane({super.key});

  @override
  TerminalPaneState createState() => TerminalPaneState();
}

class TerminalPaneState extends State<TerminalPane> {
  Process? _process;
  bool _isLoading = false;
  String? _error;
  final TextEditingController _controller = TextEditingController();
  final List<String> _output = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _startTerminal();
  }

  @override
  void dispose() {
    _process?.kill();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startTerminal() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final workspaceService = context.read<WorkspaceService>();
      final workspacePath = workspaceService.activeWorkspace;

      if (workspacePath == null) {
        setState(() {
          _error = 'No workspace opened';
          _isLoading = false;
        });
        return;
      }

      // Use bash on Linux/macOS and cmd on Windows
      final shell = Platform.isWindows ? 'cmd.exe' : '/bin/bash';
      final args = Platform.isWindows ? <String>[] : <String>[];

      _process = await Process.start(
        shell,
        args,
        workingDirectory: workspacePath,
        environment: {'TERM': 'xterm-256color'},
      );

      setState(() {
        _output.add('Welcome to CodeForge Terminal');
        _output.add('Current directory: $workspacePath');
        _output.add('');
      });

      // Connect stdin/stdout
      _process!.stdout.listen((event) {
        setState(() {
          _output.add(String.fromCharCodes(event).trim());
        });
        _scrollToBottom();
      });

      _process!.stderr.listen((event) {
        setState(() {
          _output.add(String.fromCharCodes(event).trim());
        });
        _scrollToBottom();
      });

      _process!.exitCode.then((exitCode) {
        setState(() {
          _output.add('[Process exited with code $exitCode]');
        });
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to start terminal: $e';
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _restartTerminal() {
    _process?.kill();
    setState(() {
      _output.clear();
    });
    _startTerminal();
  }

  void _sendCommand(String command) {
    if (_process != null) {
      setState(() {
        _output.add('> $command');
      });
      _process!.stdin.writeln(command);
      _controller.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Terminal toolbar
        Container(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 16),
                tooltip: 'Restart Terminal',
                onPressed: _restartTerminal,
              ),
              IconButton(
                icon: const Icon(Icons.clear_all, size: 16),
                tooltip: 'Clear Terminal',
                onPressed: () => setState(() => _output.clear()),
              ),
              const Spacer(),
              if (_isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),

        // Error display if any
        if (_error != null)
          Container(
            color: Theme.of(context).colorScheme.errorContainer,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!)),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _restartTerminal,
                ),
              ],
            ),
          ),

        // Terminal view
        Expanded(
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _output.length,
              itemBuilder: (context, index) {
                return Text(
                  _output[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                );
              },
            ),
          ),
        ),

        // Input field
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text('> ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(fontFamily: 'monospace'),
                  onSubmitted: _sendCommand,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
