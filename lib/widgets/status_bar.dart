import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 14),
          const SizedBox(width: 4),
          const Text('0 Problems'),
          const VerticalDivider(),
          const Text('Ln 1, Col 1'),
          const VerticalDivider(),
          const Text('UTF-8'),
          const VerticalDivider(),
          const Text('Dart'),
          const Spacer(),
          const Text('Git: main'),
          const VerticalDivider(),
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 14),
            onPressed: () {},
            tooltip: 'Notifications',
            constraints: const BoxConstraints(minWidth: 20),
          ),
        ],
      ),
    );
  }
}
