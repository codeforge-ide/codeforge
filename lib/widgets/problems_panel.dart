import 'package:flutter/material.dart';

enum ProblemSeverity { error, warning, info }

class Problem {
  final String message;
  final String file;
  final int line;
  final int column;
  final ProblemSeverity severity;

  Problem({
    required this.message,
    required this.file,
    required this.line,
    required this.column,
    required this.severity,
  });
}

class ProblemsPanel extends StatelessWidget {
  const ProblemsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: _buildProblemsList(),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Text('Problems'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: () {
              // Refresh problems
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, size: 18),
            onPressed: () {
              // Show filter options
            },
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all, size: 18),
            onPressed: () {
              // Clear all problems
            },
            tooltip: 'Clear',
          ),
        ],
      ),
    );
  }

  Widget _buildProblemsList() {
    return ListView.builder(
      itemCount: 0, // Replace with actual problems list
      itemBuilder: (context, index) {
        return const ListTile(
          leading: Icon(Icons.error_outline, size: 16),
          title: Text('No problems found'),
          dense: true,
        );
      },
    );
  }
}
