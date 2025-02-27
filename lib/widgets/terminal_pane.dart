import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:xterm/xterm.dart';
import '../services/workspace_service.dart';

class TerminalPane extends StatefulWidget {
  const TerminalPane({super.key});

  @override
  TerminalPaneState createState() => TerminalPaneState();
}

class TerminalPaneState extends State<TerminalPane> {
  late Terminal _terminal;
  Process? _process;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _terminal = Terminal(
      maxLines: 10000,
    );
    _startTerminal();
  }

  @override
  void dispose() {
    _process?.kill();
    _terminal.dispose();
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
      final args = Platform.isWindows ? [] : [];

      _process = await Process.start(
        shell,
        args,
        workingDirectory: workspacePath,
        environment: {'TERM': 'xterm-256color'},
      );

      _terminal.write('Welcome to CodeForge Terminal\r\n');
      _terminal.write('Current directory: $workspacePath\r\n\r\n');

      // Connect stdin/stdout
      _process!.stdout.listen((event) {
        _terminal.write(String.fromCharCodes(event));
      });

      _process!.stderr.listen((event) {
        _terminal.write(String.fromCharCodes(event));
      });

      _terminal.onOutput = (data) {
        _process?.stdin.write(data);
      };

      _process!.exitCode.then((exitCode) {
        _terminal.write('\r\n[Process exited with code $exitCode]\r\n');
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

  void _restartTerminal() {
    _process?.kill();
    _terminal.clear();
    _startTerminal();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Terminal toolbar
        Container(
          color: Theme.of(context).colorScheme.background.withOpacity(0.7),
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
                onPressed: () => _terminal.clear(),
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TerminalView(
              _terminal,
              padding: const EdgeInsets.all(8),
              textStyle: const TerminalStyle(
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
