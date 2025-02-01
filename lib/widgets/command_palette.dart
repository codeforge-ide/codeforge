import 'package:flutter/material.dart';

class CommandPalette extends StatelessWidget {
  final VoidCallback onClose;

  const CommandPalette({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark translucent background to dismiss palette when tapped.
        GestureDetector(
          onTap: onClose,
          child: Container(
            color: Colors.black54,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter command...',
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Sample list of commands.
                    ListView(
                      shrinkWrap: true,
                      children: const [
                        ListTile(title: Text('Open Settings')),
                        ListTile(title: Text('Change Theme')),
                        ListTile(title: Text('Toggle Sidebar')),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
