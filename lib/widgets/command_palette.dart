import 'package:flutter/material.dart';

class CommandPalette extends StatelessWidget {
  final VoidCallback onToggleLightDark;
  final VoidCallback onToggleHighContrast;
  final VoidCallback onToggleUltraDark;
  final bool isDarkMode;
  final bool isHighContrast;
  final bool isUltraDark;

  const CommandPalette({
    super.key,
    required this.onToggleLightDark,
    required this.onToggleHighContrast,
    required this.onToggleUltraDark,
    required this.isDarkMode,
    required this.isHighContrast,
    required this.isUltraDark,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        width: 400,
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              title: Text(
                  isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'),
              onTap: onToggleLightDark,
            ),
            ListTile(
              leading: const Icon(Icons.contrast),
              title: Text(isHighContrast
                  ? 'Disable High Contrast'
                  : 'Enable High Contrast'),
              onTap: onToggleHighContrast,
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_round),
              title: Text(
                  isUltraDark ? 'Disable Ultra Dark' : 'Enable Ultra Dark'),
              onTap: onToggleUltraDark,
            ),
            // Add more quick actions here as needed
          ],
        ),
      ),
    );
  }
}
