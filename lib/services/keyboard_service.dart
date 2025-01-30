import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardService {
  static final Map<ShortcutActivator, void Function(BuildContext)> shortcuts = {
    const SingleActivator(LogicalKeyboardKey.keyS, control: true): _handleSave,
    const SingleActivator(LogicalKeyboardKey.keyF, control: true): _handleFind,
    const SingleActivator(LogicalKeyboardKey.keyB, control: true): _handleBuild,
    const SingleActivator(LogicalKeyboardKey.keyR, control: true): _handleRun,
  };

  static void _handleSave(BuildContext context) {
    // Save functionality will be implemented
  }

  static void _handleFind(BuildContext context) {
    // Find functionality will be implemented
  }

  static void _handleBuild(BuildContext context) {
    // Build functionality will be implemented
  }

  static void _handleRun(BuildContext context) {
    // Run functionality will be implemented
  }

  static Widget wrapWithShortcuts(Widget child) {
    return Shortcuts(
      shortcuts: {
        for (final entry in shortcuts.entries)
          entry.key: CallbackIntent(
            () => entry.value(child.key as BuildContext),
          ),
      },
      child: child,
    );
  }
}
