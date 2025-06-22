import 'package:flutter/material.dart';

class OutputPane extends StatefulWidget {
  const OutputPane({super.key});

  @override
  OutputPaneState createState() => OutputPaneState();
}

class OutputPaneState extends State<OutputPane> {
  final List<OutputEntry> _entries = [];
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;
  int _selectedChannel = 0;

  static const List<String> _channels = [
    'All',
    'Build',
    'Debug',
    'Flutter',
    'Dart'
  ];

  @override
  void initState() {
    super.initState();
    _addSampleEntries();
  }

  void _addSampleEntries() {
    _entries.addAll([
      OutputEntry(
        message: 'Flutter application started',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        channel: 'Flutter',
        type: OutputType.info,
      ),
      OutputEntry(
        message: 'Hot reload complete',
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        channel: 'Flutter',
        type: OutputType.success,
      ),
      OutputEntry(
        message: 'Warning: Unused import',
        timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
        channel: 'Dart',
        type: OutputType.warning,
      ),
      OutputEntry(
        message: 'Build completed successfully',
        timestamp: DateTime.now(),
        channel: 'Build',
        type: OutputType.success,
      ),
    ]);
  }

  void _addEntry(OutputEntry entry) {
    setState(() {
      _entries.add(entry);
      if (_autoScroll) {
        _scrollToEnd();
      }
    });
  }

  void _scrollToEnd() {
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

  void _clearOutput() {
    setState(() {
      _entries.clear();
    });
  }

  void _setSelectedChannel(int index) {
    setState(() {
      _selectedChannel = index;
    });
  }

  List<OutputEntry> _getFilteredEntries() {
    if (_selectedChannel == 0) {
      // "All" channel
      return _entries;
    } else {
      final channel = _channels[_selectedChannel];
      return _entries.where((entry) => entry.channel == channel).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _getFilteredEntries();

    return Column(
      children: [
        // Output toolbar
        Container(
          height: 36,
          color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Text('Output: '),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _selectedChannel,
                items: List.generate(_channels.length, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Text(_channels[index]),
                  );
                }),
                onChanged: (index) {
                  if (index != null) _setSelectedChannel(index);
                },
                underline: Container(),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _autoScroll
                      ? Icons.vertical_align_bottom
                      : Icons.vertical_align_center,
                  size: 16,
                ),
                tooltip: _autoScroll
                    ? 'Auto-scroll enabled'
                    : 'Auto-scroll disabled',
                onPressed: () {
                  setState(() {
                    _autoScroll = !_autoScroll;
                    if (_autoScroll) _scrollToEnd();
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.clear_all, size: 16),
                tooltip: 'Clear Output',
                onPressed: _clearOutput,
              ),
            ],
          ),
        ),

        // Output content
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            child: filteredEntries.isEmpty
                ? Center(
                    child: Text(
                      'No output in ${_channels[_selectedChannel]} channel',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade400),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = filteredEntries[index];
                      return _buildOutputEntry(entry);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutputEntry(OutputEntry entry) {
    final Color textColor;
    final IconData? icon;

    switch (entry.type) {
      case OutputType.error:
        textColor = Colors.redAccent;
        icon = Icons.error_outline;
        break;
      case OutputType.warning:
        textColor = Colors.orangeAccent;
        icon = Icons.warning_amber_outlined;
        break;
      case OutputType.success:
        textColor = Colors.greenAccent;
        icon = Icons.check_circle_outline;
        break;
      case OutputType.info:
      default:
        textColor = Theme.of(context).colorScheme.onSurface;
        icon = null;
        break;
    }

    final time =
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '[${entry.channel}]',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry.message,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum OutputType {
  info,
  warning,
  error,
  success,
}

class OutputEntry {
  final String message;
  final DateTime timestamp;
  final String channel;
  final OutputType type;

  OutputEntry({
    required this.message,
    required this.timestamp,
    required this.channel,
    this.type = OutputType.info,
  });
}
