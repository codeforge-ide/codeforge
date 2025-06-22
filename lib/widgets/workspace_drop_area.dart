import 'package:flutter/material.dart';

/// This widget is a placeholder for file/folder drop support.
/// In a real application, you might use a package like `desktop_drop`.
class WorkspaceDropArea extends StatelessWidget {
  final Widget child;
  final void Function(List<String> paths)? onDrop;

  const WorkspaceDropArea({super.key, required this.child, this.onDrop});

  @override
  Widget build(BuildContext context) {
    return DragTarget<List<String>>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (data) {
        if (onDrop != null) onDrop!(data);
      },
      builder: (context, candidateData, rejectedData) {
        return child;
      },
    );
  }
}
