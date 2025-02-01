import 'package:flutter/material.dart';

class BottomPanel extends StatelessWidget {
  final VoidCallback onCommandPalette;
  const BottomPanel({super.key, required this.onCommandPalette});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Workspace: 3 files open • Autosave enabled",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(
            onPressed: onCommandPalette,
            icon: const Icon(Icons.keyboard, color: Colors.white),
            tooltip: "Show Command Palette",
          ),
        ],
      ),
    );
  }
}
